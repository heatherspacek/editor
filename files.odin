package editre
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"
import SDL "vendor:sdl3"


file_line :: struct {
	builder: strings.Builder,
}

file_contents :: [dynamic]file_line

files_list :: [dynamic]^file_contents
all_open_files := files_list{}

read_file :: proc(fpath: string) -> (lines: ^file_contents, err: os.Error) {
	finfo := os.stat(fpath, context.allocator) or_return
	defer os.file_info_delete(finfo, context.allocator)
	// TODO: actually use finfo?! lol
	// maybe warn user if this would allocate a large number of MB.
	log.infof("size of loaded file is %d bytes.", finfo.size)

	fp := os.open(fpath, {.Read, .Write}) or_return
	defer os.close(fp)

	fbytes := os.read_entire_file_from_file(fp, context.allocator) or_return
	defer delete(fbytes)

	lines = new(file_contents)
	last_break := 0
	for b, i in fbytes {
		if b == '\n' || i == len(fbytes) - 1 {
			fl := new(file_line)
			// fl.contents = fbytes[last_break:i]
			strings.write_bytes(&fl.builder, fbytes[last_break:i])
			append_elem(lines, fl^)
			last_break = i
		}
	}
	return
}

open_file_cbk :: proc "c" (_: rawptr, selection: [^]cstring, _: i32) {
	context = runtime.default_context()
	contents, err := read_file(string(selection[0]))
	append_elem(&all_open_files, contents)

	// trigger adjusting layout of tboxes ("panels")
	new_layout := panels_layout(len(all_open_files))
	clear(&all_tboxes)
	for panel_rect in new_layout {
		add_tbox(panel_rect[0], panel_rect[1], panel_rect[2], panel_rect[3])
		// TODO: layout procedure leaks memory right now. derp.
	}
	for &tb, i in all_tboxes {
		tb.focused = false
		if i == len(all_tboxes) - 1 {
			tb.focused = true
		}
	}

}

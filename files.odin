package editre
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"
import SDL "vendor:sdl3"
import TTF "vendor:sdl3/ttf"


file_line :: struct {
	sdl_text: ^TTF.Text,
	len: int,
}

file_contents :: [dynamic]file_line


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
	START_FONT_I := 3
	for b, i in fbytes {
		if b == '\n' || i == len(fbytes) - 1 {
			fl := file_line{}
			cs := cstring(raw_data(fbytes[last_break:i]))
			len_ := max(i - last_break, 1)
			fl.sdl_text = TTF.CreateText(ctx.text_engine, fonts[START_FONT_I], cs, uint(len_))
			fl.len = len_
			append_elem(lines, fl)
			last_break = i + 1
			fmt.println(cs, len_)
		}
	}
	return
}

open_file_cbk :: proc "c" (_: rawptr, selection: [^]cstring, _: i32) {
	context = runtime.default_context()
	contents, err := read_file(string(selection[0]))

	np := new_panel(contents)
	e := SDL.Event{}
	_ = SDL.PushEvent(&e)
}

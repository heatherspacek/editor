package editre
import "core:os"
import "core:strings"


file_line :: struct {
	builder: strings.Builder,
}

read_file :: proc(fpath: string) -> (lines: ^[dynamic]file_line, err: os.Error) {
	finfo := os.stat(fpath, context.allocator) or_return
	defer os.file_info_delete(finfo, context.allocator)
	// TODO: actually use finfo?! lol
	// maybe warn user if this would allocate a large number of MB.

	fp := os.open(fpath, {.Read, .Write}) or_return
	defer os.close(fp)

	fbytes := os.read_entire_file_from_file(fp, context.allocator) or_return
	defer delete(fbytes)

	lines = new([dynamic]file_line)
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

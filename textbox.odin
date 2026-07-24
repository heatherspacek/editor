#+vet
package editre
import "core:strings"

tbox :: struct {
	x:         int,
	y:         int,
	w_chars:   int,
	h_chars:   int,
	focused:   bool,
	cursorpos: int,
	builder:   strings.Builder,
}
all_tboxes := [dynamic]tbox{}

add_tbox :: proc(x: int, y: int, w: int, h: int) {
	base_tbox := tbox{}
	base_tbox.x = x
	base_tbox.y = y
	base_tbox.w_chars = w
	base_tbox.h_chars = h

	append(&all_tboxes, base_tbox)
}


tbox_as_cstring :: proc(tb_ptr: ^tbox) -> cstring {
	// for r in tb_ptr.text {
	// 	strings.write_rune(&tb_ptr.builder, r)
	// }
	return strings.to_cstring(&tb_ptr.builder)
}

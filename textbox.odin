#+vet
package editre
import "core:strings"

tbox :: struct {
	x:         u16,
	y:         u16,
	w_chars:   u16,
	h_chars:   u16,
	focused:   bool,
	cursorpos: u16,
	builder:   strings.Builder,
}
all_tboxes := [dynamic]tbox{}

add_tbox :: proc(x: u16, y: u16, w: u16, h: u16) {
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

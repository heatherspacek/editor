#+vet
package editre
import SDL3 "vendor:sdl3"

DLS :: struct {
	rects: [dynamic]SDL3.Rect,
	lines: [dynamic]SDL3.FRect,
}
drawlists := DLS{}

add_rect :: proc(x1: i32, y1: i32, x2: i32, y2: i32) {
	rx := SDL3.Rect {
		x = x1,
		y = y1,
		w = x2 - x1,
		h = y2 - y1,
	}
	append(&drawlists.rects, (rx))
}

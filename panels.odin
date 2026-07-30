package editre
import "core:strings"
import SDL "vendor:sdl3"
import TTF "vendor:sdl3/ttf"

Panel :: struct {
	file:       ^file_contents,
	focused:    bool,
	font:       ^TTF.Font,
	sdl_lines:  [dynamic]^TTF.Text,
	screen_pos: Rect,
	scroll_pos: int,
}

all_panels := [dynamic]Panel{}

get_focused_panel :: proc() -> ^Panel {
	for &p in all_panels {
		if p.focused {
			return &p
		}
	}
	return nil
}

populate_panel :: proc(p: ^Panel) {
	// once per instantiation (please lol)
	for &fline in p.file {
		cs := strings.to_cstring(&fline.builder)
		defer delete(cs)
		tx := TTF.CreateText(ctx.text_engine, p.font, cs, len(cs))
		append_elem(&p.sdl_lines, tx)
	}
}

cleanup_panel :: proc(p: ^Panel) {
	for &sline in p.sdl_lines {
		TTF.DestroyText(sline)
	}
}

draw_panel :: proc(p: ^Panel) {
	r := p.screen_pos
	fr := SDL.FRect{f32(r[0]), f32(r[1]), f32(r[2]), f32(r[3])}
	SDL.RenderRect(ctx.renderer, &fr)

	// determine which sdl_lines are in the drawing region
	first_line: ^TTF.Text = p.sdl_lines[p.scroll_pos]
	TTF.DrawRendererText(first_line, f32(p.screen_pos[0]), f32(p.screen_pos[1]))
	w, h: i32
	TTF.GetTextSize(first_line, &w, &h)
	for i in 1 ..= 20 {
		TTF.DrawRendererText(
			p.sdl_lines[p.scroll_pos + i],
			f32(p.screen_pos[0]),
			f32(p.screen_pos[1] + u16(i) * u16(h)),
		)
	}

}

package editre
import "core:fmt"
import "core:log"
import "core:strings"
import SDL "vendor:sdl3"
import TTF "vendor:sdl3/ttf"

MAX_PANELS :: 16

Panel :: struct {
	cursor_pos:   [2]int,
	file:         ^file_contents,
	focused:      bool,
	font_i:       int,
	_n_vis_lines: int,
	_sizing_text: ^TTF.Text,
	sdl_lines:    [dynamic]^TTF.Text,
	screen_pos:   Rect,
	scroll_pos:   int,
}

all_panels : [dynamic]^Panel

new_panel :: proc(contents: ^file_contents) -> ^Panel {
	START_FONT_I := 3
	p := new(Panel)
	append_elem(&all_panels, p)
	p.file = contents
	p.focused = true
	p.font_i = START_FONT_I
	for &fline in contents {
		cs := strings.to_cstring(&fline.builder)
		tx := TTF.CreateText(ctx.text_engine, fonts[START_FONT_I], cs, len(cs))
		append_elem(&p.sdl_lines, tx)
	}
	relayout_screen()

	fmt.println("from new_panel: ", p.screen_pos)

	p._sizing_text = TTF.CreateText(ctx.text_engine, fonts[START_FONT_I], "#", 1)
	p._n_vis_lines = count_vislines_panel(p)
	p.cursor_pos = {0, 0}

	return p
}

get_focused_panel :: proc() -> ^Panel {
	for p in all_panels {
		if p.focused {
			return p
		}
	}
	return nil
}

cleanup_panel :: proc(p: ^Panel) {
	for &sline in p.sdl_lines {
		TTF.DestroyText(sline)
	}
	TTF.DestroyText(p._sizing_text)
}

count_vislines_panel :: proc(p: ^Panel) -> int {
	w, h: i32
	TTF.GetTextSize(p._sizing_text, &w, &h)
	fmt.println("from count_vislines_panel: ", p.screen_pos, h)
	return int(p.screen_pos[3] / u16(h)) + 1
}

fontchange_panel :: proc(p: ^Panel, f: ^TTF.Font) {
	for &sline in p.sdl_lines {
		TTF.SetTextFont(sline, f)
	}
	TTF.SetTextFont(p._sizing_text, f)
	p._n_vis_lines = count_vislines_panel(p)
}

draw_panel :: proc(p: ^Panel) {
	r := p.screen_pos

	new_cr := SDL.Rect{i32(r[0] - 1), i32(r[1] - 1), i32(r[2] + 2), i32(r[3] + 2)}
	SDL.SetRenderClipRect(ctx.renderer, &new_cr)

	// border.
	fr := SDL.FRect{f32(r[0]), f32(r[1]), f32(r[2]), f32(r[3])}
	paintwith(col_lineactive)
	SDL.RenderRect(ctx.renderer, &fr)

	// determine which sdl_lines are in the drawing region
	w, h: i32
	TTF.GetTextSize(p._sizing_text, &w, &h)
	for i in 0 ..= p._n_vis_lines {
		TTF.DrawRendererText(
			p.sdl_lines[p.scroll_pos + i],
			f32(p.screen_pos[0]),
			f32(p.screen_pos[1] + u16(i) * u16(h)),
		)
	}

	// draw the cursor, if it's on-screen.
	cursor_onscreen := p.cursor_pos[0] >= p.scroll_pos && p.cursor_pos[0] < p.scroll_pos + 20
	log.info("cursor onscreen = ", cursor_onscreen)
	if cursor_onscreen {
		cur := SDL.FRect {
			f32(p.cursor_pos[0]) * f32(w) + f32(p.screen_pos[0]),
			f32(p.cursor_pos[1] - p.scroll_pos) * f32(h) + f32(p.screen_pos[1]),
			f32(w),
			f32(h),
		}
		paintwith(col_red)
		SDL.RenderRect(ctx.renderer, &cur)
	}

}

package editre
import "core:fmt"
import "core:strings"
import SDL "vendor:sdl3"
import TTF "vendor:sdl3/ttf"

Panel :: struct {
	cursor_pos:		[2]int,
	file:       	^file_contents,
	focused:    	bool,
	font_i:     	int,
	_sizing_text:	^TTF.Text,
	sdl_lines:  	[dynamic]^TTF.Text,
	screen_pos: 	Rect,
	scroll_pos: 	int,
}

all_panels := [dynamic]Panel{}

new_panel :: proc(contents: ^file_contents) -> ^Panel {
	START_FONT_I := 3
	p := new(Panel)
	p.file = contents
	p.focused = true
	p.font_i = START_FONT_I
	for &fline in contents {
		cs := strings.to_cstring(&fline.builder)
		defer delete(cs)
		tx := TTF.CreateText(ctx.text_engine, fonts[START_FONT_I], cs, len(cs))
		append_elem(&p.sdl_lines, tx)
	}
	p._sizing_text = TTF.CreateText(ctx.text_engine, fonts[START_FONT_I], "#", 1)

	p.cursor_pos = {0, 0}
	return p
}

get_focused_panel :: proc() -> ^Panel {
	for &p in all_panels {
		if p.focused {
			return &p
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

fontchange_panel :: proc(p: ^Panel, f: ^TTF.Font) {
	for &sline in p.sdl_lines {
		TTF.SetTextFont(sline, f)
	}
	TTF.SetTextFont(p._sizing_text, f)
}

draw_panel :: proc(p: ^Panel) {
	r := p.screen_pos
	fr := SDL.FRect{f32(r[0] + 1), f32(r[1] + 1), f32(r[2] - 2), f32(r[3] - 2)}
	SDL.SetRenderDrawColor(ctx.renderer, 210, 255, 255, 255)
	SDL.RenderRect(ctx.renderer, &fr)

	// determine which sdl_lines are in the drawing region
	// first_line: ^TTF.Text = p.sdl_lines[p.scroll_pos]
	// TTF.DrawRendererText(first_line, f32(p.screen_pos[0]), f32(p.screen_pos[1]))
	w, h: i32
	TTF.GetTextSize(p._sizing_text, &w, &h)
	// h := 12 + 3 * p.font_i
	for i in 0 ..= 20 {
		TTF.DrawRendererText(
			p.sdl_lines[p.scroll_pos + i],
			f32(p.screen_pos[0]),
			f32(p.screen_pos[1] + u16(i) * u16(h)),
		)
	}

}

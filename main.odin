#+vet
package editre

// import "core:fmt"
import "core:fmt"
import "core:log"
import "core:os"
// import "core:strings"
import SDL "vendor:sdl3"
import TTF "vendor:sdl3/ttf"

CTX :: struct {
	window:       ^SDL.Window,
	surface:      ^SDL.Surface,
	renderer:     ^SDL.Renderer,
	text_engine:  ^TTF.TextEngine,
	should_close: bool,
}
ctx := CTX{}
N_FONTS_LOADED :: 12
FONTS :: [N_FONTS_LOADED]^TTF.Font
fonts := FONTS{}
scaling: f32 = 1.0

application_w: i32 = 640
application_h: i32 = 420

sdl_init :: proc() -> bool {
	if wayland_display, ok := os.lookup_env_alloc("WAYLAND_DISPLAY", context.allocator);
	   ok && wayland_display != "" {
		os.set_env("SDL_VIDEODRIVER", "wayland")
	}
	SDL.SetHint(SDL.HINT_VIDEO_DOUBLE_BUFFER, cstring("1"))
	if sdl_res := SDL.Init(SDL.INIT_VIDEO); sdl_res != true {
		log.errorf("failed to SDL3.Init: %v.\n", sdl_res)
		return false
	}
	ctx.window = SDL.CreateWindow(
		"editre",
		application_w,
		application_h,
		{.HIGH_PIXEL_DENSITY, .RESIZABLE},
	)
	if ctx.window == nil {
		log.errorf("CreateWindow failed.\n")
		return false
	}

	ctx.renderer = SDL.CreateRenderer(ctx.window, cstring(nil))
	if ctx.renderer == nil {
		log.errorf("CreateRenderer failed.\n")
		return false
	}
	SDL.SetRenderVSync(ctx.renderer, 1)

	if ttf_res := TTF.Init(); ttf_res != true {
		log.errorf("failed to TTF.Init: %v.\n", ttf_res)
		return false
	}
	ctx.text_engine = TTF.CreateRendererTextEngine(ctx.renderer)
	if ctx.text_engine == nil {
		log.errorf("CreateRendererTextEngine failed.\n")
		return false
	}

	base_path := SDL.GetBasePath()
	full_path := fmt.ctprint(base_path, cstring("res/Incon.ttf"), sep = "")
	scaling = SDL.GetWindowDisplayScale(ctx.window)
	base_pt: f32 = 8.0
	for &ft in fonts {
		ft = TTF.OpenFont(full_path, base_pt * scaling)
		if ft == nil {
			err := SDL.GetError()
			log.error(err)
			return false
		}
		TTF.SetFontHinting(ft, .LIGHT_SUBPIXEL)
		base_pt += 2
	}

	_ = SDL.StartTextInput(ctx.window)

	return true
}

scroll_accum: f32 = 0.0
last_quantized_scroll := 0
handle_event :: proc(e: ^SDL.Event) -> (needs_redraw: bool) {
	// log.info("event:", e.type)
	#partial switch (e.type) {
	case .FIRST:
		// this is a sloppy user event.
		// currently used for file open.
		return true
	case .WINDOW_EXPOSED:
		return true
	case .QUIT:
		ctx.should_close = true
	case .WINDOW_RESIZED:
		w, h: i32
		SDL.GetWindowSizeInPixels(ctx.window, &w, &h)
		application_h = h
		application_w = w
		return true
	case .DROP_FILE:
	// :0
	case .MOUSE_WHEEL:
		// fmt.print(e.wheel.integer_y, e.wheel.y, "\n")
		// TODO: integer_y is crappy because there are tons of "0" events
		// that don't accumulate properly. COUNT UP SCROLLS WITH THE FLOAT AMOUNT!
		scroll_accum += e.wheel.y

		p := get_focused_panel()
		if p == nil {return false}
		if (int(scroll_accum) == last_quantized_scroll) {return false}

		new_scroll_pos := p.scroll_pos - 2 * int(scroll_accum)
		maxline := len(p.sdl_lines) - 20
		if new_scroll_pos < 0 {new_scroll_pos = 0}
		if new_scroll_pos >= (maxline) {new_scroll_pos = maxline - 1}
		p.scroll_pos = new_scroll_pos
		last_quantized_scroll = int(scroll_accum)
		return true
	case .TEXT_INPUT:
		line_insert_text(e.text.text)
		return true
	case .KEY_DOWN:
		handled := dispatch_to_keybind(e.key.mod, e.key.scancode)
		if !handled {
			log.warn("keybind not mapped: ", e.key.mod, e.key.scancode)
		}
		return handled
	}
	// default: DONT redraw!
	return false
}

frame := 0
update :: proc() {
	// we can put frame-linked animations here?
}

draw :: proc() {
	paintwith(col_bg)
	SDL.RenderClear(ctx.renderer)

	for &panel in all_panels {
		draw_panel(&panel)
	}

	SDL.RenderPresent(ctx.renderer)
}

main :: proc() {
	context.logger = log.create_console_logger()
	if !sdl_init() {
		log.error("Init failed somewhere. Check logs. Exiting...\n")
		os.exit(1)
	}
	for !ctx.should_close {
		e: SDL.Event
		if SDL.WaitEventTimeout(&e, 500) {
			needs_redraw := handle_event(&e)
			update()
			if needs_redraw {draw()}
		} else {
			// timed out
			update()
			draw()
		}
	}

	SDL.DestroyWindow(ctx.window)
	SDL.Quit()
}

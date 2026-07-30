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

charsize_w_px, charsize_h_px: i32

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

	txx := TTF.CreateText(ctx.text_engine, fonts[2], cstring("@"), 1)
	// =======================
	TTF.GetTextSize(txx, &charsize_w_px, &charsize_h_px)

	_ = SDL.StartTextInput(ctx.window)

	return true
}

handle_event :: proc(e: ^SDL.Event) {
	#partial switch (e.type) {
	case .QUIT:
		ctx.should_close = true
	case .WINDOW_RESIZED:
		w, h: i32
		SDL.GetWindowSizeInPixels(ctx.window, &w, &h)
		application_h = h
		application_w = w

	case .DROP_FILE:
	// :0
	case .MOUSE_WHEEL:
		p := get_focused_panel()
		p.scroll_pos += 1
	case .TEXT_INPUT:
	// bd := &all_tboxes[0].builder
	// strings.write_string(bd, string(e.text.text))
	case .KEY_DOWN:
		handled := dispatch_to_keybind(e.key.mod, e.key.scancode)
		if !handled {
			log.warn("keybind not mapped: ", e.key.mod, e.key.scancode)
		}
	}
}

frame := 0
update :: proc() {
}

draw :: proc() {

	SDL.SetRenderDrawColor(ctx.renderer, 12, 17, 23, 0xff)
	SDL.RenderClear(ctx.renderer)

	// for tb, i in all_tboxes {
	// 	outline := SDL.FRect {
	// 		f32(tb.x - 1),
	// 		f32(tb.y - 1),
	// 		// f32(charsize_w_px * i32(tb.w_chars) + 1),
	// 		// f32(charsize_h_px * i32(tb.h_chars) + 1),
	// 		f32(tb.w_chars - 1),
	// 		f32(tb.h_chars - 1),
	// 	}

	// 	if tb.focused {
	// 		SDL.SetRenderDrawColor(ctx.renderer, 200, 200, 220, 0xff)
	// 	} else {
	// 		SDL.SetRenderDrawColor(ctx.renderer, 80, 80, 90, 0xff)
	// 	}
	// 	SDL.RenderRect(ctx.renderer, &outline)

	// 	// silly oversight: datastructs are disconnected (all_tboxes, all_open_files)
	// 	// also need a VIEWPORT concept???
	// 	if len(all_open_files) > 0 {
	// 		fcontents := all_open_files[i]
	// 		for &line, line_i in fcontents {
	// 			cs := strings.to_cstring(&line.builder)
	// 			tn := TTF.CreateText(ctx.text_engine, fonts[1], cs, len(cs))
	// 			_ = TTF.DrawRendererText(tn, f32(tb.x), f32(int(tb.y) + (25 * line_i)))
	// 			TTF.DestroyText(tn)
	// 		}
	// 	}

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
			handle_event(&e)
			update()
			draw()
		}
	}

	SDL.DestroyWindow(ctx.window)
	SDL.Quit()
}

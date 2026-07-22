#+vet
package editre

// import "core:fmt"
import "core:fmt"
import "core:log"
import "core:os"
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
FONTS :: [4]^TTF.Font
fonts := FONTS{}
scaling: f32 = 1.0


sdl_init :: proc() -> bool {
	if wayland_display, ok := os.lookup_env_alloc("WAYLAND_DISPLAY", context.allocator);
	   ok && wayland_display != "" {
		os.set_env("SDL_VIDEODRIVER", "wayland")
	}
	if sdl_res := SDL.Init(SDL.INIT_VIDEO); sdl_res != true {
		log.errorf("failed to SDL3.Init: %v.\n", sdl_res)
		return false
	}
	ctx.window = SDL.CreateWindow("hw", 600, 400, {.HIGH_PIXEL_DENSITY, .RESIZABLE})
	if ctx.window == nil {
		log.errorf("CreateWindow failed.\n")
		return false
	}

	ctx.renderer = SDL.CreateRenderer(ctx.window, cstring(nil))
	if ctx.renderer == nil {
		log.errorf("CreateRenderer failed.\n")
		return false
	}

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
	log.infof("SDL base path: %s", base_path)

	scaling = SDL.GetWindowDisplayScale(ctx.window)

	base_pt: f32 = 12.0
	for &ft in fonts {
		ft = TTF.OpenFont(full_path, base_pt * scaling)
		if ft == nil {
			err := SDL.GetError()
			log.error(err)
			return false
		}
		TTF.SetFontHinting(ft, .LIGHT_SUBPIXEL)
		base_pt += 4
	}

	return true
}

poll_input :: proc() {
	e: SDL.Event

	for SDL.PollEvent(&e) {
		#partial switch (e.type) {
		case .QUIT:
			ctx.should_close = true
		case .TEXT_INPUT:

		case .KEY_DOWN:
			if .LCTRL in e.key.mod || .RCTRL in e.key.mod {
				#partial switch (e.key.scancode) {
				case .C:
					log.info("ctrl c!")
				}
			}

			#partial switch (e.key.scancode) {
			case .ESCAPE:
				ctx.should_close = true
			}
		}
	}
}

dialog_cbk :: proc "c" (_: rawptr, _: [^]cstring, _: i32) {

}

frame := 0
update :: proc() {

	frame += 1
	if frame == 37 {
		_ = SDL.StartTextInput(ctx.window)

		log.info("trying to openfolderdialog")
		SDL.ShowOpenFolderDialog(dialog_cbk, nil, ctx.window, cstring("."), false)
		err := SDL.GetError()
		log.error(err)
	}
}

draw :: proc() {
	SDL.SetRenderDrawColor(ctx.renderer, 175, 77, 27, 0xff)
	SDL.RenderClear(ctx.renderer)

	for i in 0 ..< len(drawlists.rects) {
		rxx := drawlists.rects[i]
		frxx := SDL.FRect{}
		SDL.RectToFRect(rxx, &frxx)
		SDL.SetRenderDrawColor(ctx.renderer, 12, 12, 12, 0xff)
		SDL.RenderFillRect(ctx.renderer, &frxx)
	}
	t1 := TTF.CreateText(ctx.text_engine, fonts[0], cstring("hellow worl"), 11)
	TTF.SetTextColor(t1, 0, 0, 0, 255)

	_ = TTF.DrawRendererText(t1, 0, 0)

	t2 := TTF.CreateText(
		ctx.text_engine,
		fonts[2],
		cstring(
			"lorem ipsum dolor sit amet\nPublic Static Void Main...\nI haven't heard that name in some time.",
		),
		93,
	)
	_ = TTF.DrawRendererText(t2, 0, 50)

	SDL.RenderPresent(ctx.renderer)
}

main :: proc() {
	context.logger = log.create_console_logger()

	log.info("hello world, from the logger!")
	if !sdl_init() {
		log.error("failed init :0\n")
		os.exit(1)
	}

	add_rect(55, 59, 75, 79)

	for !ctx.should_close {
		poll_input()
		update()
		draw()
		SDL.Delay(16)
	}

	SDL.DestroyWindow(ctx.window)
	SDL.Quit()
}

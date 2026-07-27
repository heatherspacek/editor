package editre

import "core:log"
import "core:strings"
import SDL "vendor:sdl3"

dispatch_to_keybind :: proc(mod: SDL.Keymod, code: SDL.Scancode) -> (hendled: bool) {

	CTRL_MASK := SDL.Keymod{.LCTRL, .RCTRL}

	if mod == nil {
		// no mod pressed-- we should assume 'textinput' captured.
		#partial switch code {
		case .BACKSPACE:
			bd := &all_tboxes[0].builder
			strings.pop_rune(bd)
		}
		return true
	} else if (CTRL_MASK & mod) != nil {
		#partial switch code {
		case .C:
			ctx.should_close = true
			return true
		case .U:
			log.info("imagine we cleared the line. (^U)")
			return true
		case .O:
			// SDL.ShowOpenFolderDialog(dialog_cbk, nil, ctx.window, cstring("."), false)
			SDL.ShowOpenFileDialog(
				open_file_cbk,
				nil,
				ctx.window,
				nil,
				0,
				SDL.GetBasePath(),
				false,
			)

		}
	}

	return false
}

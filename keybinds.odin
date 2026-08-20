package editre

import "core:log"
import "core:strings"
import SDL "vendor:sdl3"

dispatch_to_keybind :: proc(mod: SDL.Keymod, code: SDL.Scancode) -> (handled: bool) {

	CTRL_MASK := SDL.Keymod{.LCTRL, .RCTRL}

	if mod == nil {
		// no mod pressed-- we should assume 'textinput' captured.
		#partial switch code {
		case .BACKSPACE:
			line_backspace()
		case .RIGHT:
			current_pos := get_focused_panel().cursor_pos
			move_cursor({current_pos[0] + 1, current_pos[1]})
		case .LEFT:
			current_pos := get_focused_panel().cursor_pos
			move_cursor({current_pos[0] - 1, current_pos[1]})
		case .UP:
			current_pos := get_focused_panel().cursor_pos
			move_cursor({current_pos[0], current_pos[1] - 1})
		case .DOWN:
			current_pos := get_focused_panel().cursor_pos
			move_cursor({current_pos[0], current_pos[1] + 1})
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
		case .TAB:
			// ... ctrl+tab
			return true
		case .EQUALS:
			// font size up
			panel := get_focused_panel()
			curr_size := panel.font_i
			if curr_size == N_FONTS_LOADED - 1 {
				log.warn("tried to increase font size past max")
			} else {
				panel.font_i += 1
				fontchange_panel(panel, fonts[panel.font_i])
			}
			return true
		case .MINUS:
			// font size down
			panel := get_focused_panel()
			curr_size := panel.font_i
			if curr_size == 0 {
				log.warn("tried to decrease font size below min")
			} else {
				panel.font_i -= 1
				fontchange_panel(panel, fonts[panel.font_i])
			}
			return true
		}
	}
	return false
}

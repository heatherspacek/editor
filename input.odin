package editre

import "core:fmt"
import "core:strings"
import TTF "vendor:sdl3/ttf"

line_insert_text :: proc(text: cstring) {
	curr_panel := get_focused_panel()
	if curr_panel == nil {return}
	line_i := curr_panel.cursor_pos[1]
	insert_pos := curr_panel.cursor_pos[0]

	TTF.InsertTextString(curr_panel.lines[line_i].sdl_text, i32(insert_pos), text, len(text))
	// todo: put this into some data structure that gives us UNDO!

	curr_panel.cursor_pos += {1, 0}
}

line_backspace :: proc() {
	panel := get_focused_panel()
	TTF.DeleteTextString(panel.lines[panel.cursor_pos[1]].sdl_text, i32(panel.cursor_pos[0]), 1)

	panel.cursor_pos -= {1, 0}
}

line_delete_word_back :: proc() {

}

move_cursor :: proc(new_pos: [2]int) {
	// bounds checking happens here!
	p := get_focused_panel()
	dest_line := clamp(new_pos[1], 0, len(p.lines))
	target_line_len := p.lines[dest_line].len
	dest_col := clamp(new_pos[0], 0, target_line_len)
	p.cursor_pos = {dest_col, dest_line}
}

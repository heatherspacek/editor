package editre

import "core:strings"

line_insert_text :: proc(text: cstring) {
	curr_panel := get_focused_panel()
	curr_line := curr_panel.file[curr_panel.cursor_pos[0]]

}

line_backspace :: proc() {

}

line_delete_word_back :: proc() {

}

move_cursor :: proc(new_pos: [2]int) {
	// bounds checking happens here!
	p := get_focused_panel()
	dest_line := clamp(new_pos[1], 0, len(p.file))
	target_line_len := strings.builder_len(p.file[dest_line].builder)
	dest_col := clamp(new_pos[0], 0, target_line_len)
	p.cursor_pos = {dest_col, dest_line}
}

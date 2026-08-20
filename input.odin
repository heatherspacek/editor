package editre

import "core:fmt"
import "core:strings"
import TTF "vendor:sdl3/ttf"

line_insert_text :: proc(text: cstring) {
	curr_panel := get_focused_panel()
	if curr_panel == nil {return}
	line_i := curr_panel.cursor_pos[1]
	insert_pos := curr_panel.cursor_pos[0]
	curr_line := &curr_panel.file[line_i]

	curr_line_string := strings.to_string(curr_line.builder)
	updated_line := strings.builder_make()
	strings.write_string(&updated_line, curr_line_string[0:insert_pos])
	strings.write_string(&updated_line, string(text))
	strings.write_string(&updated_line, curr_line_string[insert_pos:])

	strings.builder_destroy(&curr_line.builder)
	curr_line.builder = updated_line

	TTF.InsertTextString(curr_panel.sdl_lines[line_i], i32(insert_pos), text, len(text))
	// todo: put this into some data structure that gives us UNDO!

	curr_panel.cursor_pos += {1, 0}
}

line_backspace :: proc() {
	panel := get_focused_panel()
	// trying not deleting from the backing store.
	TTF.DeleteTextString(panel.sdl_lines[panel.cursor_pos[1]], i32(panel.cursor_pos[0]), 1)

	panel.cursor_pos -= {1, 0}
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

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
	curr_panel.lines[curr_panel.cursor_pos[1]].len += len(text)

	// todo: put this into some data structure that gives us UNDO!

	curr_panel.cursor_pos += {1, 0}
}

line_backspace :: proc() {
	panel := get_focused_panel()
	cur := panel.cursor_pos
	if cur[0] == 0 {
		if cur[1] == 0 {return}
		cs := cstring(panel.lines[cur[1]].sdl_text.text)
		landing_pos := panel.lines[cur[1]-1].len
		adding_len := panel.lines[cur[1]].len
		TTF.AppendTextString(panel.lines[cur[1]-1].sdl_text, cs, uint(adding_len))
		panel.lines[cur[1]-1].len += adding_len
		ordered_remove(panel.lines, cur[1])
		panel.cursor_pos = {landing_pos , cur[1]-1}
	}
	else {
		TTF.DeleteTextString(panel.lines[cur[1]].sdl_text, i32(cur[0]-1), 1)
		panel.lines[cur[1]].len -= 1
		panel.cursor_pos -= {1, 0}
	}
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
	fmt.println(p.cursor_pos)
}

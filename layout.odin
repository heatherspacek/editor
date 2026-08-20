package editre

import "core:fmt"

PANELS_MARGIN: u16 : 5
LINE_NO_LEFT_PAD: u16: 18
Rect :: [4]u16

pad_rect :: proc(r: Rect) -> Rect {
	p_m :: PANELS_MARGIN
	return Rect{r[0] + p_m, r[1] + p_m, r[2] -2 *p_m, r[3] - 2*p_m}
}

panels_layout :: proc(n_panels: int) -> [MAX_PANELS]Rect {
	ret : [MAX_PANELS]Rect
	switch n_panels {
	case 0:
	case 1:
		ret[0] = pad_rect({0, 0, u16(application_w), u16(application_h)})
	case 2:
		midpoint := u16(application_w / 2)
		ret[0] = pad_rect({0, 0, midpoint, u16(application_h)})
		ret[1] = pad_rect({midpoint, 0, u16(application_w / 2), u16(application_h)})
	case 3:
		ret[0] = pad_rect({0, 0, u16(application_w / 3), u16(application_h)})
		ret[1] = pad_rect({u16(application_w / 3), 0, u16(application_w / 3), u16(application_h)})
		ret[2] = pad_rect(
			{u16(2 * application_w / 3), 0, u16(application_w / 3), u16(application_h)},
		)
	case:
		panic("")
	}
	return ret
}

relayout_screen :: proc() {
	// LAYOUTING
	n_panels := len(all_panels)
	rxx : [MAX_PANELS]Rect
	new_layout := panels_layout(n_panels)

	for &p, i in all_panels {
		p.screen_pos = new_layout[i]
		fmt.println("from relayout: ", new_layout[i])
	}
}

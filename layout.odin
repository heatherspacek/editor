package editre

PANELS_MARGIN: u16 : 5
Rect :: [4]u16

pad_rect :: proc(r: Rect) -> Rect {
	p_m :: PANELS_MARGIN
	return Rect{r[0] + p_m, r[1] + p_m, r[2] -2 *p_m, r[3] - 2*p_m}
}

panels_layout :: proc(n_panels: int, ret: []Rect) -> []Rect {
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

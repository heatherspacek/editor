package editre

PANELS_MARGIN: u16 : 5
Rect :: [4]u16

pad_rect :: proc(r: Rect) -> Rect {
	p_m :: PANELS_MARGIN
	return Rect{r[0] + p_m, r[1] + p_m, r[2] - p_m, r[3] - p_m}
}

panels_layout :: proc(n_panels: int) -> []Rect {
	ret := make([]Rect, n_panels)
	switch n_panels {
	case 1:
		ret[0] = pad_rect({0, 0, u16(application_w), u16(application_h)})
		return ret
	case 2:
		midpoint := u16(application_w / 2)
		ret[0] = pad_rect({0, 0, midpoint, u16(application_h)})
		ret[1] = pad_rect({midpoint, 0, u16(application_w / 2), u16(application_h)})
		return ret
	}
	return {}
}

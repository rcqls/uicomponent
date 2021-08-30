module uicomponent

import ui
import gx

// Only once: append colorbox to window
pub fn colorbox_add(mut w ui.Window) {
	w.children << ui.subwindow(
		id: "_sw_cbox"
		layout: colorbox(id: '_swl_cbox', light: true, hsl: false)
	)
}

// to connect the colorbox to gx.Color reference
pub fn colorbox_connect(w &ui.Window, col &gx.Color, x int, y int) {
	mut s := w.subwindow("_sw_cbox")
	cb_layout := w.stack("_swl_cbox")
	mut cb := component_colorbox(cb_layout)
	cb.connect(col)
	s.set_pos(x, y)
	s.set_visible(s.hidden)
	s.update_layout()
}
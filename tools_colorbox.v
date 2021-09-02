module uicomponent

import ui
import gx

const(
	colorbox_id = "_sw_cbox"
	colorbox_layout_id = '_sw_cbox_layout'
)

// Append colorbox to window
pub fn colorbox_add(mut w ui.Window) {
	// only once
	if !ui.Layout(w).has_child_id(colorbox_id) {
		w.children << ui.subwindow(
			id: colorbox_id
			z_index: 1000
			layout: colorbox(id: colorbox_layout_id, light: true, hsl: false)
		)
	}
}

// to connect the colorbox to gx.Color reference
pub fn colorbox_connect(w &ui.Window, col &gx.Color, x int, y int) {
	mut s := w.subwindow(colorbox_id)
	cb_layout := w.stack(colorbox_layout_id)
	mut cb := component_colorbox(cb_layout)
	cb.connect(col)
	s.set_pos(x, y)
	s.set_visible(s.hidden)
	s.update_layout()
}

pub struct ButtonColorConfig {
	id           string
	text         string
	height       int
	width        int
	z_index      int
	tooltip      string
	tooltip_side ui.Side = .top
	radius       f64
	padding      f64
	bg_color 	 &gx.Color
}

pub fn button_color(c ButtonColorConfig) &ui.Button {
	b := &ui.Button{
		id: c.id
		width_: c.width
		height_: c.height
		z_index: c.z_index
		bg_color: c.bg_color
		theme_cfg: ui.no_theme
		tooltip: ui.TooltipMessage{c.tooltip, c.tooltip_side}
		onclick: button_color_click
		radius: f32(c.radius)
		padding: f32(c.padding)
		ui: 0
	}
	return b
}

fn button_color_click(a voidptr, b &ui.Button) {
	colorbox_connect(b.ui.window, b.bg_color, b.x, b.y)
}


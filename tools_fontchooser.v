module uicomponent

import ui
import os

const (
	fontchooser_id = "_sw_font"
	fontchooser_lb_id = "_lb_sw_font"
	fontchooser_row_id = "_row_sw_font"
)

// Append fontchooser to window
pub fn fontchooser_add(mut w ui.Window, fontchooser_lb_change ui.ListBoxSelectionChangedFn) {
	// only once
	if !ui.Layout(w).has_child_id(fontchooser_id) {
		mut lb := ui.listbox(
			id: fontchooser_lb_id
			draw_lines: true
			on_change: fontchooser_lb_change
		)
		w.children << ui.subwindow(
			id: fontchooser_id
			z_index: 1000
			layout: ui.row(
				id: fontchooser_row_id
				widths: 300.0
				heights: 300.0
				children: [ lb ]
			) 
		)
		fontchooser_init(mut lb)
	}
}

pub fn fontchooser_visible(w &ui.Window) {
	mut s := w.subwindow(fontchooser_id)
	s.set_visible(s.hidden)
	s.update_layout()
}

pub fn fontchooser_subwindow(w &ui.Window) &ui.SubWindow {
	return w.subwindow(fontchooser_id)
}

pub fn fontchooser_listbox(w &ui.Window) &ui.ListBox {
	return w.listbox(fontchooser_lb_id)
}

fn fontchooser_init(mut lb ui.ListBox) {
	 
	mut font_root_path := ''
	$if windows {
		font_root_path = 'C:/windows/fonts'
	}
	$if macos {
		font_root_path = '/System/Library/Fonts/*'
	}
	$if linux {
		font_root_path = '/usr/share/fonts/truetype/*'
	}
	font_paths := os.glob('$font_root_path/*.ttf') or { panic(err) }

	for fp in font_paths {
		lb.append_item(fp, os.file_name(fp), 0)
	}
}

/*
fn lb_change(mut app App, lb &ui.ListBox) {
	mut w := lb.ui.window
	c := w.canvas_layout('c')
	mut dtw := ui.DrawTextWidget(c)
	fp, id := lb.selected() or { 'classic', '' }
	// println("$id, $fp")
	$if windows {
		w.ui.add_font(id, 'C:/windows/fonts/$fp')
	} $else {
		w.ui.add_font(id, fp)
	}

	app.prev_font = id
	dtw.update_text_style(font_name: id, size: 30)
}
*/

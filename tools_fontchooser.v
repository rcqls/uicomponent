module uicomponent

import ui

const (
	fontchooser_id = '_sw_font'
)

// Append fontchooser to window
pub fn fontchooser_add(mut w ui.Window) { //}, fontchooser_lb_change ui.ListBoxSelectionChangedFn) {
	// only once
	if !ui.Layout(w).has_child_id(uicomponent.fontchooser_id) {
		w.children << ui.subwindow(
			id: uicomponent.fontchooser_id
			z_index: 1000
			layout: fontchooser()
		)
	}
}

pub fn fontchooser_visible(w &ui.Window) {
	mut s := w.subwindow(uicomponent.fontchooser_id)
	s.set_visible(s.hidden)
	s.update_layout()
}

pub fn fontchooser_subwindow(w &ui.Window) &ui.SubWindow {
	return w.subwindow(uicomponent.fontchooser_id)
}

pub fn fontchooser_listbox(w &ui.Window) &ui.ListBox {
	return w.listbox(fontchooser_lb_id)
}

fn btn_font_click(a voidptr, b &ui.Button) {
	fontchooser_visible(b.ui.window)
}

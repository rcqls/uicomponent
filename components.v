module uicomponent

import ui

// All the components could be listed here to have an overall of all components
pub fn component_doublelistbox(w ui.ComponentChild) &DoubleListBox {
	return &DoubleListBox(w.component)
}

pub fn component_toolbar(w ui.ComponentChild) &ToolBar {
	return &ToolBar(w.component)
}

pub fn component_colorbox(w ui.ComponentChild) &ColorBox {
	return &ColorBox(w.component)
}

pub fn component_tabs(w ui.ComponentChild) &Tabs {
	return &Tabs(w.component)
}

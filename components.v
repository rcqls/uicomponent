module uicomponent

import ui


// All the components could be listed here to have an overall of all components
pub fn component_doublelistbox(w ui.Component) &DoubleListBox {
	return &DoubleListBox(w.component)
}

pub fn component_toolbar(w ui.Component) &ToolBar {
	return &ToolBar(w.component)
}
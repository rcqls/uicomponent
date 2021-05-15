import ui
import uicomponent as uic

const (
	win_width  = 30 + 256 + 4 * 10 + uic.cb_cv_hsv_w
	win_height = 276
)

struct App {
mut:
	window &ui.Window
}

fn main() {
	mut app := &App{
		window: 0
	}
	window := ui.window({
		width: win_width
		height: win_height
		title: 'V UI: Toolbar'
		state: app
		// mode: .resizable
		native_message: false
	}, [
		ui.column({}, [
			uic.colorbox(id: 'cbox', light: true),
		]),
	])
	app.window = window
	ui.run(window)
}

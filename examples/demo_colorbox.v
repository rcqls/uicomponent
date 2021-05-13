import ui
import uicomponent as uic

const (
	win_width  = 600
	win_height = 400
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
		mode: .resizable
		native_message: false
	}, [
		ui.column({
			margin_: .05
			spacing: .05
		}, [
			uic.colorbox(
				id: "cbox"
			),
		]),
	])
	app.window = window
	ui.run(window)
}
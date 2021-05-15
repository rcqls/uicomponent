module uicomponent

import ui
import gx
import sokol.sgl

const (
	cb_sp      = 5
	cb_hsv_col = 30
	cb_nc      = 2
	cb_nr      = 3
)

struct HSVColor {
	h f64
	s f64
	v f64
}

[heap]
struct ColorBox {
mut:
	simg    C.sg_image
	h       f64 = 0.5
	s       f64 = 0.5
	v       f64 = 0.5
	rgb     gx.Color
	ind_sel int
	hsv_sel []HSVColor = []HSVColor{len: uicomponent.cb_nc * uicomponent.cb_nr}
pub mut:
	layout     &ui.Stack // optional
	cv_h       &ui.CanvasLayout
	cv_sv      &ui.CanvasLayout
	r_rgb_cur  &ui.Rectangle
	cv_hsv_sel &ui.CanvasLayout
	// To become a component of a parent component
	component voidptr
}

pub struct ColorBoxConfig {
	id string
}

pub fn colorbox(c ColorBoxConfig) &ui.Stack {
	mut cv_h := ui.canvas_plus(
		width: 30
		height: 256
		on_draw: cv_h_draw
		on_click: cv_h_click
		on_mouse_move: cv_h_mouse_move
	)
	mut cv_sv := ui.canvas_plus(
		width: 256
		height: 256
		on_draw: cv_sv_draw
		on_mouse_move: cv_sv_mouse_move
		on_click: cv_sv_click
	)
	mut r_rgb_cur := ui.rectangle(
		width: 30
		height: 30
		radius: 5
	)
	mut cv_hsv_sel := ui.canvas_plus(
		bg_radius: 5
		bg_color: gx.rgb(220, 220, 220)
		on_draw: cv_sel_draw
		on_click: cv_sel_click
	)
	mut layout := ui.row({
		id: c.id
		bg_color: gx.rgba(0, 0, 0, 200)
		widths: [30., 256., ui.compact]
		heights: [256., 256., ui.compact]
		spacing: 10.
		margin_: 10
	}, [
		cv_h,
		cv_sv,
		ui.column({
			heights: [30.,
				(uicomponent.cb_hsv_col + uicomponent.cb_sp) * uicomponent.cb_nr +
				uicomponent.cb_sp,
			]
			widths: [30.,
				(uicomponent.cb_hsv_col + uicomponent.cb_sp) * uicomponent.cb_nc +
				uicomponent.cb_sp,
			]
			spacing: 5.
		}, [r_rgb_cur, cv_hsv_sel]),
	])
	mut cb := &ColorBox{
		layout: layout
		cv_h: cv_h
		cv_sv: cv_sv
		r_rgb_cur: r_rgb_cur
		cv_hsv_sel: cv_hsv_sel
	}
	cb.cv_h.component = cb
	cb.cv_sv.component = cb
	cb.r_rgb_cur.component = cb
	cb.cv_hsv_sel.component = cb
	layout.component = cb
	// init component
	layout.component_init = colorbox_init
	// cb.update_buffer()
	return layout
}

// equivalent of init method for widget
// automatically called in by the layout
fn colorbox_init(layout &ui.Stack) {
	mut cb := component_colorbox(layout)
	cb.update_cur_color()
	for i in 0 .. (uicomponent.cb_nc * uicomponent.cb_nr) {
		cb.hsv_sel[i] = HSVColor{f64(i) / (uicomponent.cb_nc * uicomponent.cb_nr), .75, .75}
	}
	cb.simg = create_dynamic_texture(256, 256)
	cb.update_buffer()
}

fn cv_h_click(e ui.MouseEvent, c &ui.CanvasLayout) {
	mut cb := component_colorbox(c)
	cb.h = f64(e.y) / 256
	cb.update_buffer()
}

fn cv_h_mouse_move(e ui.MouseMoveEvent, c &ui.CanvasLayout) {
	if c.ui.btn_down[0] {
		mut cb := component_colorbox(c)
		cb.h = f64(e.y) / 256
		cb.update_buffer()
	}
}

fn cv_h_draw(c &ui.CanvasLayout, app voidptr) {
	cb := component_colorbox(c)
	for j in 0 .. 255 {
		c.draw_rect(0, j, 30, 1, ui.hsv_to_rgb(f64(j) / 256., 1., 1.))
	}
	c.draw_rounded_rect(-3, int(cb.h * 256) - 3, 36, 6, 2, ui.hsv_to_rgb(cb.h, .2, .7))
	c.draw_rect(3, int(cb.h * 256) - 1, 24, 2, ui.hsv_to_rgb(cb.h, 1., 1.))
	c.draw_empty_rounded_rect(-3, int(cb.h * 256) - 3, 36, 6, 2, gx.white)
}

fn cv_sv_click(e ui.MouseEvent, c &ui.CanvasLayout) {
	mut cb := component_colorbox(c)
	cb.s = f64(e.x) / 256.
	cb.v = 1. - f64(e.y) / 256.
	cb.update_sel_color()
}

fn cv_sv_mouse_move(e ui.MouseMoveEvent, c &ui.CanvasLayout) {
	if c.ui.btn_down[0] {
		mut cb := component_colorbox(c)
		cb.s = f64(e.x) / 256.
		cb.v = 1. - f64(e.y) / 256.
		cb.update_cur_color()
	}
}

fn cv_sv_draw(mut c ui.CanvasLayout, app voidptr) {
	mut cb := component_colorbox(c)
	ctx := c.ui.gg
	w, h := 256, 256
	u0 := f32((c.x + c.offset_x) / w)
	v0 := f32((c.y + c.offset_y) / h)
	u1 := f32((c.x + c.offset_x + c.width) / w)
	v1 := f32((c.y + c.offset_y + c.height) / h)
	x0 := f32((c.x + c.offset_x) * ctx.scale)
	y0 := f32((c.y + c.offset_y) * ctx.scale)
	x1 := f32((c.x + c.offset_x + c.width) * ctx.scale)
	y1 := f32((c.y + c.offset_y + c.height) * ctx.scale)
	sgl.load_pipeline(ctx.timage_pip)
	sgl.enable_texture()
	sgl.texture(cb.simg)
	sgl.begin_quads()
	sgl.c4b(255, 255, 255, 255)
	sgl.v2f_t2f(x0, y0, u0, v0)
	sgl.v2f_t2f(x1, y0, u1, v0)
	sgl.v2f_t2f(x1, y1, u1, v1)
	sgl.v2f_t2f(x0, y1, u0, v1)
	sgl.end()
	sgl.disable_texture()
	c.draw_rounded_rect(int(cb.s * 256.) - 10, int((1. - cb.v) * 256.) - 10, 20, 20, 10,
		ui.hsv_to_rgb(cb.h, 1 - cb.s, 1. - cb.v))
	c.draw_rounded_rect(int(cb.s * 256.) - 7, int((1. - cb.v) * 256.) - 7, 14, 14, 7,
		ui.hsv_to_rgb(cb.h, cb.s, cb.v))
}

fn cv_sel_click(e ui.MouseEvent, c &ui.CanvasLayout) {
	mut cb := component_colorbox(c)
	i := (e.x - uicomponent.cb_sp) / (uicomponent.cb_sp + uicomponent.cb_hsv_col)
	j := (e.y - uicomponent.cb_sp) / (uicomponent.cb_sp + uicomponent.cb_hsv_col)
	cb.ind_sel = i + j * uicomponent.cb_nc
	// println("($i, $j) -> ${cb.ind_sel}")
	hsv := cb.hsv_sel[cb.ind_sel]
	cb.h, cb.s, cb.v = hsv.h, hsv.s, hsv.v
	cb.update_buffer()
}

fn cv_sel_draw(mut c ui.CanvasLayout, app voidptr) {
	cb := component_colorbox(c)
	mut hsv := HSVColor{}
	mut h, mut s, mut v := 0., 0., 0.
	ii, jj := cb.ind_sel % uicomponent.cb_nc, cb.ind_sel / uicomponent.cb_nc
	c.draw_rounded_rect(uicomponent.cb_sp + ii * (uicomponent.cb_hsv_col + uicomponent.cb_sp) - 1,
		uicomponent.cb_sp + jj * (uicomponent.cb_hsv_col + uicomponent.cb_sp) - 1,
		uicomponent.cb_hsv_col + 2, uicomponent.cb_hsv_col + 2, .25, gx.black)
	for j in 0 .. uicomponent.cb_nr {
		for i in 0 .. uicomponent.cb_nc {
			hsv = cb.hsv_sel[i + j * uicomponent.cb_nc]
			h, s, v = hsv.h, hsv.s, hsv.v
			c.draw_rounded_rect(uicomponent.cb_sp + i * (uicomponent.cb_hsv_col + uicomponent.cb_sp),
				uicomponent.cb_sp + j * (uicomponent.cb_hsv_col + uicomponent.cb_sp),
				uicomponent.cb_hsv_col, uicomponent.cb_hsv_col, .25, ui.hsv_to_rgb(h,
				s, v))
		}
	}
}

fn (mut cb ColorBox) update_cur_color() {
	cb.r_rgb_cur.color = ui.hsv_to_rgb(cb.h, cb.s, cb.v)
}

fn (mut cb ColorBox) update_sel_color() {
	// cb.r_sel.color = ui.hsv_to_rgb(cb.h, cb.s, cb.v)
	cb.hsv_sel[cb.ind_sel] = HSVColor{cb.h, cb.s, cb.v}
}

pub fn (mut cb ColorBox) update_buffer() {
	unsafe { destroy_texture(cb.simg) }
	sz := 256 * 256 * 4
	buf := unsafe { malloc(sz) }
	mut col := gx.Color{}
	mut i := 0
	for y in 0 .. 256 {
		for x in 0 .. 256 {
			unsafe {
				col = ui.hsv_to_rgb(cb.h, f64(x) / 256., 1. - f64(y) / 256.)
				buf[i] = col.r
				buf[i + 1] = col.g
				buf[i + 2] = col.b
				buf[i + 3] = col.a
				i += 4
			}
		}
	}
	unsafe {
		cb.simg = create_texture(256, 256, buf)
		// update_text_texture(cb.simg, 256, 256, buf)
		free(buf)
	}
}

fn create_dynamic_texture(w int, h int) C.sg_image {
	mut img_desc := C.sg_image_desc{
		width: w
		height: h
		num_mipmaps: 0
		min_filter: .linear
		mag_filter: .linear
		usage: .dynamic
		wrap_u: .clamp_to_edge
		wrap_v: .clamp_to_edge
		label: &byte(0)
		d3d11_texture: 0
	}

	sg_img := C.sg_make_image(&img_desc)
	return sg_img
}

fn create_texture(w int, h int, buf &byte) C.sg_image {
	mut img_desc := C.sg_image_desc{
		width: w
		height: h
		num_mipmaps: 0
		min_filter: .linear
		mag_filter: .linear
		wrap_u: .clamp_to_edge
		wrap_v: .clamp_to_edge
		label: &byte(0)
		d3d11_texture: 0
	}
	sz := w * h * 4

	img_desc.data.subimage[0][0] = C.sg_range{
		ptr: buf
		size: size_t(sz)
	}

	sg_img := C.sg_make_image(&img_desc)
	return sg_img
}

fn destroy_texture(sg_img C.sg_image) {
	C.sg_destroy_image(sg_img)
}

// Use only if usage: .dynamic is enabled
fn update_text_texture(sg_img C.sg_image, w int, h int, buf &byte) {
	sz := w * h * 4
	mut tmp_sbc := C.sg_image_data{}
	tmp_sbc.subimage[0][0] = C.sg_range{
		ptr: buf
		size: size_t(sz)
	}
	C.sg_update_image(sg_img, &tmp_sbc)
}

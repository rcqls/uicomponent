module uicomponent

import ui
import gx
import gg
import sokol.sgl

[heap]
struct ColorBox {
mut:
	simg		C.sg_image
	h 			f64
	s           f64
	v 			f64
pub mut:
	layout &ui.Stack // optional
	cv_h	   &ui.CanvasLayout
	cv_sv	   &ui.CanvasLayout
	// To become a component of a parent component
	component voidptr
}

pub struct ColorBoxConfig {
	id       string
}

pub fn colorbox(c ColorBoxConfig) &ui.Stack {
	mut cv_h := ui.canvas_layout({
		width: 30
		height: 256
		draw_fn: draw_h
	},[])
	mut cv_sv := ui.canvas_layout({
		width: 256
		height: 256
		draw_fn: draw_sv
	},[])
	mut layout := ui.row({
		id: c.id
		widths: [30., 256.]
		heights: 256.
		spacing: 30.
	}, [
		cv_h, cv_sv
	])
	mut cb := &ColorBox{
		layout: layout
		cv_h: cv_h
		cv_sv: cv_sv
	}
	cb.cv_h.component = cb
	cb.cv_sv.component = cb
	layout.component = cb
	// init component
	layout.component_init = colorbox_init
	// cb.update_buffer()
	return layout
}

fn colorbox_init(layout &ui.Stack) {
	mut cb := component_colorbox(layout)
	cb.simg=create_texture(256,256)
	cb.update_buffer()
}

fn draw_h(c &ui.CanvasLayout, app voidptr) {
	for j in 0..255 {
		c.draw_rect(0,j,30,1,ui.hsv_to_rgb(f64(j)/256.,1.,1.))
	}
}

fn draw_sv(mut c ui.CanvasLayout, app voidptr) {
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
}

pub fn (mut cb ColorBox) update_buffer() {
	sz := 256 * 256 * 4
	buf := unsafe { malloc(sz) }
	mut col := gx.Color{}
	mut i := 0
	for y in 0 .. 256 {
	for x in 0 .. 256 {
			unsafe { 
				col = ui.hsv_to_rgb(0.3,f64(x)/256.,1. -f64(y)/256.)
				buf[i] = col.r
				buf[i+1] = col.g
				buf[i+2] = col.b
				buf[i+3] = col.a
				i += 4
			}
		}
	}
	unsafe {
		update_text_texture(cb.simg, 256, 256, buf)
		free(buf)
	}
}

fn create_texture(w int, h int) C.sg_image {
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
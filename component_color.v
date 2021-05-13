module uicomponent

import ui
import gx
import gg

[heap]
struct ColorBox {
mut:
	buf 	   	[]byte
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
	cb.update_buffer()
}

fn draw_h(c &ui.CanvasLayout, app voidptr) {
	for j in 0..255 {
		c.draw_rect(0,j,30,1,ui.hsv_to_rgb(f64(j)/256.,1.,1.))
	}
}

pub fn (mut cb ColorBox) update_buffer() {
	sz := 256 * 256
	mut col := gx.Color{}
	cb.buf.clear()
	mut x, mut y := 0, 0
	for i in  0 .. sz {
		y = i >> 0x8
		x = i & 0xFF
		col = ui.hsv_to_rgb(0.6,f64(x)/256.,f64(y)/256.)
		// 
		if true  {println("$i -> ($x, $y) -> $col")}
		cb.buf << col.r
		cb.buf << col.g
		cb.buf << col.b
		// cb.buf << 128
	}
	// println("end update")
}

fn draw_sv(mut c ui.CanvasLayout, app voidptr) {
	mut cb := component_colorbox(c)
	img := c.ui.gg.create_image_from_byte_array(cb.buf)
	c.ui.gg.draw_image(c.x + c.offset_x, c.y + c.offset_y, c.width, c.height, &img)
}

/*
fn create_texture(w int, h int, buf &u8) C.sg_image {
	sz := w * h * 4
	mut img_desc := C.sg_image_desc{
		width: w
		height: h
		num_mipmaps: 0
		min_filter: .linear
		mag_filter: .linear
		// usage: .dynamic
		wrap_u: .clamp_to_edge
		wrap_v: .clamp_to_edge
		label: &byte(0)
		d3d11_texture: 0
	}
	// commen if .dynamic is enabled
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

*/
require_relative 'neven'
require 'RMagick'
include Magick
module Botstache
	def self.getmoustacheimg
		stachefiles = Dir.entries("moustaches")
		stachefiles.delete_if {|item| not item.end_with?(".svg") }
		stachefile = stachefiles[Random.rand(stachefiles.length)]

		img = Image.read("moustaches/" + stachefile) { self.background_color = "transparent" }[0]
		return img
	end
	def self.addstache(srcimg)
		img = srcimg
		scale = 1
		if [img.columns, img.rows].max > 600
			scale = [img.columns, img.rows].max / 600.0
			img = img.resize(1 / scale)
		end
		detector = Neven.neven_create(img.columns, img.rows, 1)
		if detector == nil
			puts("WTF")
			return nil
		end
		pixels = img.export_pixels_to_str(0, 0, img.columns, img.rows, "I");
		pixelPtr = FFI::MemoryPointer::from_string(pixels)
		detectCount = Neven.neven_detect(detector, pixelPtr)
		if detectCount < 1
			puts("detect fail")
			return nil
		end
		face = Neven::NevenFace.new
		Neven.neven_get_face(detector, face, 1);
		Neven.neven_destroy(detector)
		print(face[:confidence], " ", face[:midpointx], " ", face[:midpointy], " ", face[:eyedist])
		eyedist = face[:eyedist] * scale
		midpointx = face[:midpointx] * scale
		midpointy = face[:midpointy] * scale
		overlayimg = self.getmoustacheimg()
		overlayscale = (eyedist * 2) / 300.0
		overlayimg.scale!(overlayscale)
		overlaymidy = 120 * overlayscale
		outimg = srcimg.composite(overlayimg, midpointx - (overlayimg.columns / 2), midpointy + (eyedist * 0.9) - overlaymidy, 
			OverCompositeOp)
		return outimg
	end
end

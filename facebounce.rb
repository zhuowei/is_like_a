require_relative 'neven'
require_relative 'botstache'
require 'RMagick'
include Magick
module Facebounce

	def self.process(srcimg)
		eyedist, midpointx, midpointy = Botstache::detectFace(srcimg)
		if eyedist == nil
			return nil
		end
		x = midpointx - eyedist
		y = midpointy - eyedist
		facewidth = eyedist * 2
		faceheight = eyedist * 3

		faceimg = srcimg.crop x, y, facewidth, faceheight

		circleimg = Image.new facewidth, faceheight
		gc = Draw.new
		gc.fill "black"
		gc.ellipse(facewidth / 2, faceheight / 2, facewidth / 2, faceheight / 2, 0, 360)
		#gc.circle(eyewidth / 2, eyeheight / 2, eyewidth / 2, 0)
		gc.draw circleimg
		#maskimg = circleimg.blur_image(0, 4).negate
		#maskimg.matte = false
		maskimg = circleimg.negate
		maskimg.matte = false

		# mask out the face
		faceimg.matte = true
		faceimg.composite!(maskimg, 0, 0, CopyOpacityCompositeOp)


		xvel = eyedist / 8
		yvel = -eyedist / 8

		x += xvel
		y += yvel

		img = srcimg
		outimg = ImageList.new

		for i in 0..19
			newimg = img.composite faceimg, x, y, OverCompositeOp
			outimg.push newimg
			img = newimg
			x += xvel
			y += yvel
		end

		outimg.delay = 10
		outimg = outimg.optimize_layers OptimizeLayer

		return outimg
	end
end

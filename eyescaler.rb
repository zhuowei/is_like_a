require_relative 'neven'
require_relative 'botstache'
require 'RMagick'
include Magick
module Eyescaler

	def self.process(srcimg)
		eyedist, midpointx, midpointy = Botstache::detectFace(srcimg)
		if eyedist == nil
			return nil
		end

		eyewidth = (eyedist * 1)
		eyeheight = eyewidth / 3

		circleimg = Image.new eyewidth, eyeheight
		gc = Draw.new
		gc.fill "black"
		gc.ellipse(eyewidth / 2, eyeheight / 2, eyewidth / 2.5, eyeheight / 2.5, 0, 360)
		#gc.circle(eyewidth / 2, eyeheight / 2, eyewidth / 2, 0)
		gc.draw circleimg
		maskimg = circleimg.blur_image(0, 4).negate
		maskimg.matte = false

		# mask out the left eye
		lefteyex = midpointx - (eyedist / 2)
		lefteyey = midpointy
		lefteye = srcimg.crop lefteyex - (eyewidth / 2), lefteyey - (eyeheight / 2), eyewidth, eyeheight
		lefteye.matte = true
		lefteye.composite!(maskimg, 0, 0, CopyOpacityCompositeOp)

		# and the right
		righteyex = midpointx + (eyedist / 2)
		righteyey = midpointy
		righteye = srcimg.crop righteyex - (eyewidth / 2), righteyey - (eyeheight / 2), eyewidth, eyeheight
		righteye.matte = true
		righteye.composite!(maskimg, 0, 0, CopyOpacityCompositeOp)

		# scale up the eyes

		scalefactor = 2

		lefteye.scale!(scalefactor)
		righteye.scale!(scalefactor)

		# composite on top of original picture
		outimg = srcimg.composite(lefteye, lefteyex - (eyewidth / 2 * scalefactor), lefteyey - (eyeheight / 2 * scalefactor),
			OverCompositeOp)
		outimg.composite!(righteye, righteyex - (eyewidth / 2 * scalefactor), righteyey - (eyeheight / 2 * scalefactor),
			OverCompositeOp)
		return outimg
	end
end

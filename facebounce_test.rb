require_relative 'facebounce'
require 'RMagick'
include Magick
img = Image.read(ARGV[0])[0]
outimg = Facebounce.process(img)
outimg.animate()
outimg.write("out.gif")

require_relative 'eyescaler'
require 'RMagick'
include Magick
img = Image.read(ARGV[0])[0]
outimg = Eyescaler.process(img)
outimg.display()
outimg.write("out.jpg")

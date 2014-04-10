require_relative 'botstache'
require 'RMagick'
include Magick
img = Image.read(ARGV[0])[0]
outimg = Botstache.addstache(img)
outimg.display()
outimg.write("out.jpg")

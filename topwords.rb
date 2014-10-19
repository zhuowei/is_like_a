#!/usr/bin/env ruby
require 'twitter_ebooks'
include Ebooks
if not ARGV[0]
	p "Usage: topwords.rb path/to/model.model"
else
	model = Model.load(ARGV[0])
	p model.keywords.top(100).map(&:to_s).map(&:downcase)
end

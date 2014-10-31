#!/usr/bin/env ruby
require 'twitter_ebooks'
include Ebooks
if not ARGV[0]
	p "Usage: topwords.rb path/to/model.model <count>"
else
	model = Model.load(ARGV[0])
	p model.keywords.top(ARGV[1]? ARGV[1].to_i : 100).map(&:to_s).map(&:downcase)
end

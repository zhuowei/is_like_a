#!/usr/bin/env ruby

require_relative 'bots'
require_relative 'sonnetbot'
require_relative 'botstache_bot'
require_relative 'aspects_bot'
require_relative 'eyescaler_bot'
require_relative 'standard_bots'
#require_relative 'boo'
#require_relative 'hanan_bot'
require_relative 'multimodel_bot'

EM.run do
 Ebooks::Bot.all.each do |bot|
    bot.start
 end
end

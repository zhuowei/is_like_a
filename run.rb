#!/usr/bin/env ruby

require_relative 'bots'
require_relative 'sonnetbot'
require_relative 'botstache_bot'
require_relative 'spagheti'
require_relative 'eyescaler_bot'

EM.run do
 Ebooks::Bot.all.each do |bot|
    bot.start
  end
end

#!/usr/bin/env ruby

require_relative 'bots'
require_relative 'sonnetbot'

EM.run do
 Ebooks::Bot.all.each do |bot|
    bot.start
  end
end

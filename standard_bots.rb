#!/usr/bin/env ruby

require 'twitter_ebooks'
require_relative 'aspects_bot'
include Ebooks

Ebooks::Bot.new("sl2c_ebooks") do |bot| # Ebooks account username
  bot.consumer_key = ENV["CONSUMER_KEY"] # Your app consumer key
  bot.consumer_secret = ENV["CONSUMER_SECRET"] # Your app consumer secret
  bot.oauth_token = ENV["SL2C_TOKEN"] # oauth token for ebooks account
  bot.oauth_token_secret = ENV["SL2C_SECRET"] # oauth secret for ebooks account

  make_bot(bot, "sl2c") # This should be the name of the text model
end

Ebooks::Bot.new("Munchlax_ebooks") do |bot| # Ebooks account username
  bot.consumer_key = ENV["CONSUMER_KEY"] # Your app consumer key
  bot.consumer_secret = ENV["CONSUMER_SECRET"] # Your app consumer secret
  bot.oauth_token = ENV["MUNCHLAX_TOKEN"] # oauth token for ebooks account
  bot.oauth_token_secret = ENV["MUNCHLAX_SECRET"] # oauth secret for ebooks account

  make_bot(bot, "MunchlaxRegrets") # This should be the name of the text model
end

=begin
Ebooks::Bot.new("pressEXE_ebooks") do |bot| # Ebooks account username
  bot.consumer_key = ENV["CONSUMER_KEY"] # Your app consumer key
  bot.consumer_secret = ENV["CONSUMER_SECRET"] # Your app consumer secret
  bot.oauth_token = ENV["PRESSEXE_TOKEN"] # oauth token for ebooks account
  bot.oauth_token_secret = ENV["PRESSEXE_SECRET"] # oauth secret for ebooks account

  make_bot(bot, "pressEXE") # This should be the name of the text model
end
=end

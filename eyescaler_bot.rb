#!/usr/bin/env ruby

require 'twitter_ebooks'
require_relative 'eyescaler'
require_relative 'facebounce'
require_relative 'image_bot_common'

Ebooks::Bot.new("Eyescaler") do |bot|
  # Consumer details come from registering an app at https://dev.twitter.com/
  # OAuth details can be fetched with https://github.com/marcel/twurl
  bot.consumer_key = ENV["CONSUMER_KEY"] # Your app consumer key
  bot.consumer_secret = ENV["CONSUMER_SECRET"] # Your app consumer secret
  bot.oauth_token = ENV["EYESCALER_OAUTH_TOKEN"] # Token connecting the app to this account
  bot.oauth_token_secret = ENV["EYESCALER_OAUTH_SECRET"] # Secret connecting the app to this account

  bot.on_mention do |tweet, meta|
    # Reply to a mention
    image_bot_handle(bot, tweet, meta) do |img|
      Eyescaler.process(img)
    end
  end
end

Ebooks::Bot.new("Facebounces") do |bot|
  # Consumer details come from registering an app at https://dev.twitter.com/
  # OAuth details can be fetched with https://github.com/marcel/twurl
  bot.consumer_key = ENV["CONSUMER_KEY"] # Your app consumer key
  bot.consumer_secret = ENV["CONSUMER_SECRET"] # Your app consumer secret
  bot.oauth_token = ENV["FACEBOUNCE_TOKEN"] # Token connecting the app to this account
  bot.oauth_token_secret = ENV["FACEBOUNCE_SECRET"] # Secret connecting the app to this account

  bot.on_mention do |tweet, meta|
    # Reply to a mention
    image_bot_handle(bot, tweet, meta) do |img|
      Facebounce.process(img)
    end
  end

end

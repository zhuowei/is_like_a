#!/usr/bin/env ruby

require 'twitter_ebooks'

require_relative 'sonnetgen'

# This is an example bot definition with event handlers commented out
# You can define as many of these as you like; they will run simultaneously

Ebooks::Bot.new("thee_to") do |bot|
  # Consumer details come from registering an app at https://dev.twitter.com/
  # OAuth details can be fetched with https://github.com/marcel/twurl
  bot.consumer_key = ENV["CONSUMER_KEY"] # Your app consumer key
  bot.consumer_secret = ENV["CONSUMER_SECRET"] # Your app consumer secret
  bot.oauth_token = ENV["SONNET_OAUTH_TOKEN"] # Token connecting the app to this account
  bot.oauth_token_secret = ENV["SONNET_OAUTH_SECRET"] # Secret connecting the app to this account

  interval_config = ENV["SONNET_TWEET_INTERVAL"]? ENV["SONNET_TWEET_INTERVAL"] : "30m"

  bot.scheduler.every interval_config do
    # Tweet something every 10 minutes
    # See https://github.com/jmettraux/rufus-scheduler
    # bot.tweet("hi")
    bot.tweet(SonnetGen.make())
  end
end

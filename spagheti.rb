#!/usr/bin/env ruby

require 'twitter_ebooks'

Ebooks::Bot.new("makespagheti") do |bot|
  # Consumer details come from registering an app at https://dev.twitter.com/
  # OAuth details can be fetched with https://github.com/marcel/twurl
  bot.consumer_key = ENV["CONSUMER_KEY"] # Your app consumer key
  bot.consumer_secret = ENV["CONSUMER_SECRET"] # Your app consumer secret
  bot.oauth_token = ENV["SPAGHETI_OAUTH_TOKEN"] # Token connecting the app to this account
  bot.oauth_token_secret = ENV["SPAGHETI_OAUTH_SECRET"] # Secret connecting the app to this account

  interval_config = ENV["TWEET_INTERVAL"]? ENV["TWEET_INTERVAL"] : "1h"

  bot.scheduler.every interval_config do
    # Tweet something every 10 minutes
    # See https://github.com/jmettraux/rufus-scheduler
    # bot.tweet("hi")
    # get my followers
    followers = bot.twitter.follower_ids.all
    # get a random follower
    followerid = followers.sample
    if followerid != nil
      followerinfo = bot.twitter.user(followerid, {:include_entities=>false, :skip_status=>true})
      followername = followerinfo.screen_name
      mymessage = "when @#{followername} com home and make hte spagheti"
      begin
        bot.tweet(mymessage)
      rescue Twitter::Error::Forbidden
        mymessage = "luks like @#{followername} is stil makeing hte spagheti"
        bot.tweet(mymessage)
      end
    end

  end
end

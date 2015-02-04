#!/usr/bin/env ruby
# lightly modified version of Misp's example_ebooks bot
require 'twitter_ebooks'
include Ebooks

DELAY = 2..30 # Simulated human reply delay range in seconds
BLACKLIST = ['insomnius', 'upulie'] # Grumpy users to avoid interaction with

# Track who we've randomly interacted with globally
$have_talked = {}

class GenBotMulti
  def initialize(bot, modelnames)
    @bot = bot
    @models = nil

    bot.on_startup do
      @models = modelnames.map{|modelname| Model.load("model/#{modelname}.model")}
      @top100 = @models[0].keywords.top(100).map(&:to_s).map(&:downcase)
      @top50 = @models[0].keywords.top(20).map(&:to_s).map(&:downcase)
      bot.delay DELAY do
        bot.tweet model.make_statement
        cleanfollowers
      end
    end

    bot.on_message do |dm|
      bot.delay DELAY do
        bot.reply dm, model.make_response(dm[:text])
      end
    end

    bot.on_follow do |user|
      bot.delay DELAY do
        bot.follow user[:screen_name]
      end
    end

    bot.on_mention do |tweet, meta|
      # Avoid infinite reply chains (50% chance of crosstalk)
      next if tweet[:user][:screen_name].include?('ebooks') && rand > 0.5

      tokens = NLP.tokenize(tweet[:text])

      very_interesting = tokens.find_all { |t| @top50.include?(t.downcase) }.length > 2
      special = false #tokens.find { |t| ['ebooks', 'bot', 'bots', 'clone', 'singularity', 'world domination'].include?(t) }

      if very_interesting || special
        favorite(tweet)
      end

      reply(tweet, meta)
    end

    bot.on_timeline do |tweet, meta|
      next if tweet[:retweeted_status] || tweet[:text].start_with?('RT')
      next if BLACKLIST.include?(tweet[:user][:screen_name])

      tokens = NLP.tokenize(tweet[:text])

      # We calculate unprompted interaction probability by how well a
      # tweet matches our keywords
      interesting = tokens.find { |t| @top100.include?(t.downcase) }
      very_interesting = tokens.find_all { |t| @top50.include?(t.downcase) }.length > 2
      special = false #tokens.find { |t| ['ebooks', 'bot', 'bots', 'clone', 'singularity', 'world domination'].include?(t) }

      if very_interesting #special
        favorite(tweet)

        bot.delay DELAY do
          bot.follow tweet[:user][:screen_name]
        end
      end

      # Any given user will receive at most one random interaction per day
      # (barring special cases)
      next if $have_talked[tweet[:user][:screen_name]]
      $have_talked[tweet[:user][:screen_name]] = true

      if very_interesting || special
        #favorite(tweet) if rand < 0.5 and not special
        retweet(tweet) if rand < 0.1 and not special
        reply(tweet, meta) if rand < 0.1
      elsif interesting
        favorite(tweet) if rand < 0.1
        reply(tweet, meta) if rand < 0.05
      end
    end

    interval_config = ENV["TWEET_INTERVAL"]? ENV["TWEET_INTERVAL"] : "1h"

    # Schedule a main tweet every hour
    bot.scheduler.every interval_config do
      bot.tweet model.make_statement
    end

    # Schedule cleanup of the don't reply list every day
    bot.scheduler.every '24h' do
      $have_talked = {}
    end

    # Schedule cleanup of followers
    bot.scheduler.every '1h' do
      cleanfollowers
    end

  end

  def reply(tweet, meta)
    resp = model.make_response(meta[:mentionless], meta[:limit])
    @bot.delay DELAY do
      @bot.reply tweet, meta[:reply_prefix] + resp
    end
  end

  def favorite(tweet)
    @bot.log "Favoriting @#{tweet[:user][:screen_name]}: #{tweet[:text]}"
    @bot.delay DELAY do
      @bot.twitter.favorite(tweet[:id])
    end
  end

  def retweet(tweet)
    @bot.log "Retweeting @#{tweet[:user][:screen_name]}: #{tweet[:text]}"
    @bot.delay DELAY do
      @bot.twitter.retweet(tweet[:id])
    end
  end

  def cleanfollowers()
    #following = @bot.twitter.friend_ids(@bot.username).all
    #followers = @bot.twitter.follower_ids(@bot.username).all
    #tounfollow = following - followers
    #tounfollow.slice(0, 10).each { |id|
    #  @bot.log "Unfollowing " + id.to_s
    #  @bot.twitter.unfollow(id)
    #}
  end

  def model()
    @models.sample
  end
end

def make_bot_multi(bot, modelname)
  GenBotMulti.new(bot, modelname)
end

Ebooks::Bot.new("lkc_ebooks") do |bot| # Ebooks account username
  bot.consumer_key = ENV["CONSUMER_KEY"] # Your app consumer key
  bot.consumer_secret = ENV["CONSUMER_SECRET"] # Your app consumer secret
  bot.oauth_token = ENV["LINUX_TOKEN"] # Token connecting the app to this account
  bot.oauth_token_secret = ENV["LINUX_SECRET"] # Secret connecting the app to this account

  make_bot_multi(bot, (0..19).map{|x| "lkcomments-" + x.to_s}) # This should be the name of the text model
end

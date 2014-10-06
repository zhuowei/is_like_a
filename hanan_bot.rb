#!/usr/bin/env ruby
# lightly modified version of Misp's example_ebooks bot
require 'twitter_ebooks'
include Ebooks

# Track who we've randomly interacted with globally
$have_talked = {}

class HananBot
  def initialize(bot, modelname)
    @bot = bot
    @model = nil

    bot.on_startup do
      @model = Model.load("model/#{modelname}.model")
      @top100 = @model.keywords.top(100).map(&:to_s).map(&:downcase)
      @top50 = @model.keywords.top(20).map(&:to_s).map(&:downcase)
      bot.delay DELAY do
        bot.tweet @model.make_statement
      end
      EM.next_tick do
        handle_other_user()
      end
    end

    bot.on_message do |dm|
      bot.delay DELAY do
        bot.reply dm, @model.make_response(dm[:text])
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
      special = tokens.find { |t| ['ebooks', 'bot', 'bots', 'clone', 'singularity', 'world domination'].include?(t) }

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
      special = tokens.find { |t| ['ebooks', 'bot', 'bots', 'clone', 'singularity', 'world domination'].include?(t) }

      if special
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
        favorite(tweet) if rand < 0.5 and not special
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
      bot.tweet @model.make_statement
    end

    # Schedule cleanup of the don't reply list every day
    bot.scheduler.every '24h' do
      $have_talked = {}
    end
  end

  def handle_other_user()
    @bot.stream.follow(@bot.twitter.user("hananahammocks", {:include_entities => false, :skip_status => false}).id) do |status|
      next unless status[:text]
      next if status.attrs[:entities][:user_mentions].length != 0
      tokens = Ebooks::NLP.tokenize(status[:text])
      tokens.map! { |x|
        if not Ebooks::NLP.punctuation?(x) and rand < 0.8
          "*click click click*"
        else
          x
        end
      }
      newtweet = Ebooks::NLP.reconstruct(tokens)
      while newtweet.length > 0
        bot.tweet(newtweet.slice(0, 140))
        newtweet = newtweet.slice(140)
      end
    end
  end

  def reply(tweet, meta)
    resp = @model.make_response(meta[:mentionless], meta[:limit])
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
end

Ebooks::Bot.new("hanan_ebooks") do |bot| # Ebooks account username
  bot.consumer_key = ENV["CONSUMER_KEY"] # Your app consumer key
  bot.consumer_secret = ENV["CONSUMER_SECRET"] # Your app consumer secret
  bot.oauth_token = ENV["HANAN_TOKEN"] # Token connecting the app to this account
  bot.oauth_token_secret = ENV["HANAN_SECRET"] # Secret connecting the app to this account

  HananBot.new(bot, "hananahammocks") # This should be the name of the text model
end

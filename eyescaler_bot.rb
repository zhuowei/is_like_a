#!/usr/bin/env ruby

require 'twitter_ebooks'
require_relative 'eyescaler'
require 'faraday'
require 'RMagick'

Ebooks::Bot.new("eyescaler") do |bot|
  # Consumer details come from registering an app at https://dev.twitter.com/
  # OAuth details can be fetched with https://github.com/marcel/twurl
  bot.consumer_key = ENV["CONSUMER_KEY"] # Your app consumer key
  bot.consumer_secret = ENV["CONSUMER_SECRET"] # Your app consumer secret
  bot.oauth_token = ENV["EYESCALER_OAUTH_TOKEN"] # Token connecting the app to this account
  bot.oauth_token_secret = ENV["EYESCALER_OAUTH_SECRET"] # Secret connecting the app to this account

  bot.on_mention do |tweet, meta|
    # Reply to a mention

    # does this contain an image?
    media = tweet.media()
    if media.length >= 1
    pic = media[0]
    urlbase = pic.media_url
    size = pic.sizes.max_by {|a| a[1].h}
    url = urlbase + ":" + String(size[0])
    imgdat = Faraday.get(url).body
    img = Magick::Image.from_blob(imgdat)[0]
    outimg = Eyescaler.process(img)
    img.destroy!()
    tweet_prefix = "@" + tweet[:user][:screen_name] + " "
    if outimg != nil
      tempfile = "out-" + String(tweet[:id]) + ".jpg"
      outimg.write(tempfile)
      bot.twitter.update_with_media(tweet_prefix, File.new(tempfile), in_reply_to_status_id: tweet[:id])
      File.delete(tempfile)
    else
      begin
        bot.reply(tweet, tweet_prefix + "No face detected, please try again.")
      rescue Twitter::Error::Forbidden
        bot.reply(tweet, tweet_prefix + "Again, no face detected, please try again.")
      end
    end
    end
  end

end

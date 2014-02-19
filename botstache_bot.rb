#!/usr/bin/env ruby

require 'twitter_ebooks'
require_relative 'botstache'
require 'faraday'
require 'RMagick'

Ebooks::Bot.new("botstache") do |bot|
  # Consumer details come from registering an app at https://dev.twitter.com/
  # OAuth details can be fetched with https://github.com/marcel/twurl
  bot.consumer_key = ENV["CONSUMER_KEY"] # Your app consumer key
  bot.consumer_secret = ENV["CONSUMER_SECRET"] # Your app consumer secret
  bot.oauth_token = ENV["STACHE_OAUTH_TOKEN"] # Token connecting the app to this account
  bot.oauth_token_secret = ENV["STACHE_OAUTH_SECRET"] # Secret connecting the app to this account

  bot.on_mention do |tweet, meta|
    # Reply to a mention
    # bot.reply(tweet, meta[:reply_prefix] + "oh hullo")
    # does this contain an image?
    media = tweet.media()
    if media.length >= 1
    puts(media)
    pic = media[0]
    puts(pic)
    urlbase = pic.media_url
    puts(urlbase)
    puts(pic.sizes)
    size = pic.sizes.max_by {|a| a[1].h}
    url = urlbase + ":" + String(size[0])
    puts(url)
    imgdat = Faraday.get(url).body
    img = Magick::Image.from_blob(imgdat)[0]
    outimg = Botstache.addstache(img)
    img.destroy!()
    if outimg != nil
      tempfile = "out-" + String(tweet[:id]) + ".jpg"
      outimg.write(tempfile)
      bot.twitter.update_with_media(meta[:reply_prefix], File.new(tempfile), in_reply_to_status_id: tweet[:id])
      File.delete(tempfile)
      puts("done")
    else
      begin
        bot.reply(tweet, meta[:reply_prefix] + "No face detected, please try again.")
      rescue Twitter::Error::Forbidden
        bot.reply(tweet, meta[:reply_prefix] + "Again, no face detected, please try again.")
      end
    end
    end
  end

end

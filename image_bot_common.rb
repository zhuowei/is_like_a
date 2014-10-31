require 'twitter_ebooks'
require 'faraday'
require 'RMagick'

def image_bot_handle(bot, tweet, meta, extension = ".jpg", &handler)
    # does this contain an image?
    media = tweet.media()
    if media.length < 1
      if tweet.in_reply_to_status_id != nil
        prevtweet = bot.twitter.status(tweet.in_reply_to_status_id, trim_user: true)
        media = tweet.media()
      end
      if media.length < 1
        return
      end
    end
    pic = media[0]
    urlbase = pic.media_url
    size = pic.sizes.max_by {|a| a[1].h}
    url = urlbase + ":" + String(size[0])
    imgdat = Faraday.get(url).body
    img = Magick::Image.from_blob(imgdat)[0]
    outimg = handler.call(img)
    img.destroy!()
    tweet_prefix = "@" + tweet[:user][:screen_name] + " "
    if outimg != nil
      tempfile = "out-" + String(tweet[:id]) + extension
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

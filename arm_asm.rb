#!/usr/bin/env ruby

require 'twitter_ebooks'

Ebooks::Bot.new("arm_asm") do |bot|
  # Consumer details come from registering an app at https://dev.twitter.com/
  # OAuth details can be fetched with https://github.com/marcel/twurl
  bot.consumer_key = ENV["CONSUMER_KEY"] # Your app consumer key
  bot.consumer_secret = ENV["CONSUMER_SECRET"] # Your app consumer secret
  bot.oauth_token = ENV["SPAGHETI_OAUTH_TOKEN"] # Token connecting the app to this account
  bot.oauth_token_secret = ENV["SPAGHETI_OAUTH_SECRET"] # Secret connecting the app to this account

  bot.on_mention do |tweet, meta|
    IO.popen([{"LD_LIBRARY_PATH" => "gas"}, "gas/arm-linux-gnueabi-as", "-aln", "-mcpu=cortex-a9", :err => [:child, :out]], "r+") do |io|
      io.puts(meta[:mentionless])
      io.close_write
      output = io.read
      output.chars.each_slice(140 - meta[:reply_prefix].length).map {|s|
        begin
          bot.reply tweet, meta[:reply_prefix] + s.join
        rescue Twitter::Error::Forbidden
          bot.reply tweet, meta[:reply_prefix] + "same as before"
        end
      }
    end
  end
end

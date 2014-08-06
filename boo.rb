require 'tweetstream'

def startBoo

	boo_comments = ["BOOO BOOO BOOO", "GET OFF THE STAGE", "BOOO *throws tomatoes*"]
	applaud_comments = ["Clap clap clap", "Good job!", "That's awesome!", "Round of applause!"]
	hug_comments = ["*hug*", "*hugs*", "*hug* ^_^", "HUG"]

	TweetStream.configure do |config|
		config.consumer_key = ENV["CONSUMER_KEY"]
		config.consumer_secret = ENV["CONSUMER_SECRET"]
		config.oauth_token = ENV["OAUTH_TOKEN"]
		config.oauth_token_secret = ENV["OAUTH_SECRET"]
	end

	client = TweetStream::Client.new

	client.track("#boochorus") do |status|
		if not status.retweet?
			mentions = status.attrs[:entities][:user_mentions]
			reply_target = "@" + status.attrs[:user][:screen_name]
			if mentions.length != 0
				reply_target += " @" + mentions[0][:screen_name]
			end
			Ebooks::Bot.all.each do |bot|
				begin
					bot.delay DELAY do
						begin
							bot.reply(status, reply_target + " " + boo_comments.sample)
						rescue Exception => msg
							puts msg
						end
					end
				rescue Exception => msg
					puts msg
				end
			end
		end
	end

	client.track("#botapplaud") do |status|
		if not status.retweet?
			mentions = status.attrs[:entities][:user_mentions]
			reply_target = "@" + status.attrs[:user][:screen_name]
			if mentions.length != 0
				reply_target += " @" + mentions[0][:screen_name]
			end
			Ebooks::Bot.all.each do |bot|
				begin
					bot.delay DELAY do
						begin
							bot.reply(status, reply_target + " " + applaud_comments.sample)
						rescue Exception => msg
							puts msg
						end
					end
				rescue Exception => msg
					puts msg
				end
			end
		end
	end

	client.track("#bothug") do |status|
		if not status.retweet?
			mentions = status.attrs[:entities][:user_mentions]
			reply_target = "@" + status.attrs[:user][:screen_name]
			if mentions.length != 0
				reply_target += " @" + mentions[0][:screen_name]
			end
			delay = DELAY.to_a.sample
			Ebooks::Bot.all.each do |bot|
				begin
					bot.delay delay do
						begin
							bot.reply(status, reply_target + " " + hug_comments.sample)
						rescue Exception => msg
							puts msg
						end
					end
					delay += (1..5).to_a.sample
				rescue Exception => msg
					puts msg
				end
			end
		end
	end

	puts "Started boo chorus listener"
end

A collection of Twitter bots operated by me.

These bots are based on Mispy's [twitter-ebooks](https://github.com/mispy/twitter_ebooks) framework,
and are currently hosted on Heroku.

- [@is_like_a](https://twitter.com/is_like_a]) - simile generator, `bots.rb`
- [@thee_to](https://twitter.com/thee_to]) - shall-I-compare-thee generator, `similebot.rb`
- [@Botstache](https://twitter.com/Botstache) - adds moustaches to selfies, `botstache_bot.rb`
- [@Eyescaler](https://twitter.com/Eyescaler) - enlarges eyes in selfies, `eyescaler_bot.rb`
- [@aspects_ebooks](https://twitter.com/aspects_ebooks) - runs a Markov chain against the text of [Glory in the Thunder](http://gloryinthethunder.com), `aspects_bot.rb`

Botstache and Eyescaler use [lqs's port of the Neven face detection library](https://github.com/lqs/neven). They also
depend on RMagick to process images.

Is_like_a and thee_to's vocabulary is compiled by [my SimileGen tool](https://github.com/zhuowei/SimileGen).

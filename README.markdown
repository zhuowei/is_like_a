A collection of Twitter bots operated by me.

These bots are based on Mispy's [twitter-ebooks](https://github.com/mispy/twitter_ebooks) framework,
and are currently hosted on Heroku.

- [https://twitter.com/is_like_a](@is_like_a) - simile generator, `bots.rb`
- [https://twitter.com/thee_to](@thee_to) - shall-I-compare-thee generator, `similebot.rb`
- [https://twitter.com/Botstache](@Botstache) - adds moustaches to selfies, `botstache_bot.rb`
- [https://twitter.com/makespagheti](@makespagheti) - follow to be featured in a spagheti tweet. `spagheti.rb`
- [https://twitter.com/Eyescaler](@Eyescaler) - enlarges eyes in selfies, `eyescaler_bot.rb`

Botstache and Eyescaler use [lqs's port of the Neven face detection library](https://github.com/lqs/neven). They also
depend on RMagick to process images.

Is_like_a and thee_to's vocabulary is compiled by [my SimileGen tool](https://github.com/zhuowei/SimileGen).

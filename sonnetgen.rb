# load corpus

module SonnetGen
	@adjpairs = []

	data = File.read("sourcedata/sonnets.txt")

	data.lines.each do |l|
		vals = l.sub("\n", "").split(",")
		@adjpairs << vals
	end

	@template = "Shall I compare thee to &&&THING?\nThou art more FIRST and more SECOND."
	@template2 = "... &&&THING?\nThou art more FIRST and more SECOND."

	def self.make
		# select a random adjective
		adjarr = @adjpairs[Random.rand(@adjpairs.length)]
		words = adjarr[1..-1]
		first = words.delete_at(Random.rand(words.length))
		second = words.delete_at(Random.rand(words.length))
		lastletter = adjarr[0][-1].downcase
		firstletter = adjarr[0][0].downcase 
		pronoun = "a "
		if firstletter == "a" or firstletter == "e" or firstletter == "i" or firstletter == "o" or firstletter == "u"
			pronoun = "an "
		end
		if lastletter == "s"
			pronoun = ""
		end
		out = @template.sub("&&&", pronoun).sub("THING", adjarr[0]).sub("FIRST", first).sub("SECOND", second)
		if out.length > 140
			out = @template2.sub("&&&", pronoun).sub("THING", adjarr[0]).sub("FIRST", first).sub("SECOND", second)
		end
		return out
	end
end

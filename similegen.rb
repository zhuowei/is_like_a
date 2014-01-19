# load corpus

module SimileGen
	@adjpairs = []

	data = File.read("sourcedata/sourcedata.txt")

	data.lines.each do |l|
		vals = l.sub("\n", "").split(",")
		@adjpairs << vals
	end

	@template = "FIRST is like SECOND since they are both ADJECTIVE"

	def self.make
		# select a random adjective
		adjarr = @adjpairs[Random.rand(@adjpairs.length)]
		words = adjarr[1..-1]
		first = words.delete_at(Random.rand(words.length))
		second = words.delete_at(Random.rand(words.length))
		out = @template.sub("ADJECTIVE", adjarr[0]).sub("FIRST", first).sub("SECOND", second)
		return out
	end
end

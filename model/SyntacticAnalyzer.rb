require 'set'

class SyntacticAnalyzer
	def initialize(gram)
		@gramat = gram
		@parsed = parse(gram)
		@initial = gram[0]
	end
	attr_accessor :parsed

	def parse(text)
		parsed = Hash.new
		text.each_line do |line|
			x = line.split("->")
			w = x[0].gsub(" ","")
			parsed[w] = Set.new
			y = x[1].split("|")
			y.each do |prod|
				parsed[w] << prod.gsub(" ","").gsub("\n","")
			end
		end
		return parsed
	end

	def deep_copy(o)
		Marshal.load(Marshal.dump(o))
	end

	def first
		first = Hash.new
		@parsed.each_pair do |name, val|
			first[name] = Set.new
			val.each do |x|
				if x[0] == x[0].downcase
					first[name] << x[0]
				end
			end
		end
		atual = Hash.new
		while first != atual
			atual = deep_copy(first)
			@parsed.each_pair do |name, val|
				val.each do |x|
					count = 0
					while count <= (x.size - 1) and x[count] != x[count].downcase
						if first[x[count]].include?("&")
							first[x[count]].each { |e| if e != "&"; first[name] << e; end }
							if count <= (x.size - 2)
								if x[count+1] == x[count+1].downcase
									first[name] << x[count+1]
								else
									first[x[count+1]].each { |e| if e != "&"; first[name] << e; end }
								end
							end
							if count == (x.size - 1)
								first[name] << "&"
							end
						else
							first[x[count]].each { |e| first[name] << e }
							break if true
						end
						count = count + 1
					end
				end
			end
		end
		return first
	end
end

# gram = "S -> ABC
# A -> aA
# B -> bB | ACd
# C -> cC | &"
# lex = SyntacticAnalyzer.new(gram)
# first = lex.first
# puts first.inspect
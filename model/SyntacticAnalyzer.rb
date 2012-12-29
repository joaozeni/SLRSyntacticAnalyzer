require 'set'

class SyntacticAnalyzer
	def initialize(gram)
		@gramat = gram
		@parsed = parse(gram)
		@initial = gram[0]
		@first = self.first
	end
	attr_accessor :parsed
	attr_accessor :first

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

	def follow
		follow = Hash.new
		@parsed.each_pair do |name, val|
			follow[name] = Set.new
			if name == @initial
				follow[name] << "$"
			end
		end
		atual = Hash.new
		while follow != atual
			atual = deep_copy(follow)
			@parsed.each_pair do |name, val|
				val.each do |x|
					count = x.size - 1
					while count >= 1
						if x[count] != x[count].downcase
							if x[count - 1] != x[count - 1].downcase
								@first[x[count]].each { |e| if e != "&"; follow[x[count - 1]] << e; end }
							end
							#Those 2 are work in progress
							if count == x.size - 1 or behindNil(count, x)
								follow[name].each { |e| follow[x[count]] << e }
							end
							if count != x.size - 1 and @first[x[count]].include?("&")
								follow[name].each { |e| follow[x[count]] << e }
							end
						elsif x[count] == x[count].downcase and x[count - 1] != x[count - 1].downcase
							follow[x[count - 1]] << x[count]
						end
						count = count - 1
					end
				end
			end
		end
		return follow
	end

	#Work in progress too
	def behindNil(pos, var)
		pos = pos + 1
		while pos < var.size
			if var[pos] == var[pos].downcase or not @first[var[pos]].include?("&")
				return false
			end
			pos = pos + 1
		end
		return true
	end
end

gram = "S -> ABC
A -> aA
B -> bB | ACd
C -> cC | &"
lex = SyntacticAnalyzer.new(gram)
first = lex.follow
puts first.inspect
require 'set'
require_relative 'Table'
require_relative 'SLRAnalyzer'

class SyntacticAnalyzerStructConstructor
	def initialize(gram)
		@gramat = gram.dup
		x = parseAndSymbols(gram)
		@parsed = x[0]
		@parsed1 = x[2]
		@symbols = x[1]
		@initial = gram[0]
		@numGram = numGramMaker(@parsed1)
		@firstSet = first(@parsed1)
		@followSet = follow(@parsed1)
		@marked = marker(@parsed1)
		y = itemSetMaker(gram)
		@itemSet = y[0]
		@switch = y[1]
		@lexTable = tableMaker(@symbols,@switch,@itemSet,@followSet,@numGram)
		# @fatorada = fatorada?(@parsed1, @firstSet)
		# @cond3 = cond3?(@parsed1, @firstSet, @followSet)
		# @leftRecurtion = leftRecurtion?(@parsed1, @firstSet)
	end
	attr_accessor :parsed1
	attr_accessor :parsed
	attr_accessor :firstSet
	attr_accessor :followSet
	attr_accessor :marked
	attr_accessor :symbols
	attr_accessor :gramat
	attr_accessor :itemSet
	attr_accessor :switch
	attr_accessor :numGram
	attr_accessor :lexTable
	attr_accessor :fatorada
	attr_accessor :cond3
	# attr_accessor :leftRecurtion

	def parseAndSymbols(text)
		parsed = Hash.new
		parsed1 = Hash.new
		symbols = Set.new
		text.each_line do |line|
			x = line.split("->")
			w = x[0].gsub(" ","").gsub("\r","")
			symbols << w
			parsed[w] = Set.new
			parsed1[w] = Set.new
			x[1] = x[1][1..(x[1].size-1)]
			y = x[1].split("|")
			y.each do |prod|
				if ((prod[0] == " ") and (prod[prod.size - 1] == " "))
					parsed1[w] << prod.gsub("\n","")[1..(prod.size-2)].gsub("\r","")
				elsif (prod[0] == " ")
					parsed1[w] << prod.gsub("\n","")[1..(prod.size-1)].gsub("\r","")
				elsif (prod[prod.size - 1] == " ")
					parsed1[w] << prod.gsub("\n","")[0..(prod.size-2)].gsub("\r","")
				elsif (prod[prod.size - 1] == "\n")
					parsed1[w] << prod.gsub("\n","").gsub("\r","")
				else
					parsed1[w] << prod.gsub("\r","")
				end
				parsed[w] << prod.gsub(" ","").gsub("\n","")
				z = prod.split(" ")
				z.each { |e| symbols << e }
			end
		end
		return parsed, symbols, parsed1
	end

	def numGramMaker(parsedGramar)
		numGram = Hash.new
		count = 0
		parsedGramar.each do |key, val|
			numGram[key] = Hash.new
			val.each do |x|
				numGram[key][x] = count
				count = count + 1
			end
		end
		return numGram
	end

	def deep_copy(o)
		Marshal.load(Marshal.dump(o))
	end

	def first(parsedGramar)
		first = Hash.new
		parsedGramar.each_pair do |name, val|
			first[name] = Set.new
			val.each do |x|
				arr = x.split(" ")
				if arr[0] == arr[0].downcase
					first[name] << arr[0]
				end
			end
		end
		atual = Hash.new
		while first != atual
			atual = deep_copy(first)
			parsedGramar.each_pair do |name, val|
				#puts "#{name}, #{val.inspect}"
				val.each do |x|
					arr = x.split(" ")
					count = 0
					while count <= (arr.size - 1) and arr[count] != arr[count].downcase
						if first[arr[count]].include?("&")
							first[arr[count]].each { |e| if e != "&"; first[name] << e; end }
							if count <= (arr.size - 2)
								if arr[count+1] == arr[count+1].downcase
									first[name] << arr[count+1]
								else
									first[arr[count+1]].each { |e| if e != "&"; first[name] << e; end }
								end
							end
							if count == (arr.size - 1)
								first[name] << "&"
							end
						else
							first[arr[count]].each { |e| first[name] << e }
							break if true
						end
						count = count + 1
					end
				end
			end
		end
		return first
	end

	def follow(parsedGramar)
		follow = Hash.new
		parsedGramar.each_pair do |name, val|
			follow[name] = Set.new
			if name == @initial
				follow[name] << "$"
			end
		end
		atual = Hash.new
		while follow != atual
			atual = deep_copy(follow)
			parsedGramar.each_pair do |name, val|
				val.each do |x|
					arr = x.split(" ")
					count = 0
					while count < arr.size - 1
						if ((arr[count+1] == arr[count+1].downcase) and (arr[count] != arr[count].downcase))
							follow[arr[count]] << arr[count+1]
						elsif arr[count+1] != arr[count+1].downcase and arr[count] != arr[count].downcase
							@firstSet[arr[count+1]].each { |e| if e != "&"; follow[arr[count]] << e; end }
							#------------------------------------------------------------------------------
							#Don't know if this is needed
							y = count + 1
							while y < arr.size - 1 and arr[y] != arr[y].downcase and @firstSet[arr[y]].include?("&")
								if arr[y+1] != arr[y+1].downcase
									@firstSet[arr[y+1]].each { |e| if e != "&"; follow[arr[count]] << e; end }
								elsif arr[y+1] == arr[y+1].downcase
									follow[arr[count]] << arr[y+1]
								end
								y = y + 1
							end
							#------------------------------------------------------------------------------
						end
						if behindNil(count, arr) and arr[count] != arr[count].downcase
							follow[name].each { |e| follow[arr[count]] << e }
						end
						count = count + 1
					end
					if count == arr.size - 1 and arr[count] != arr[count].downcase
						follow[name].each { |e| follow[arr[count]] << e }
					end
				end
			end
		end
		return follow
	end

	def behindNil(pos, var)
		pos = pos + 1
		while pos < var.size
			if var[pos] == var[pos].downcase or not @firstSet[var[pos]].include?("&")
				return false
			end
			pos = pos + 1
		end
		return true
	end

	def tableMaker(symbols, switch, itemSet, follow, numGram)
		# puts "#{numGram}"
		header = symbols.to_a
		header << "$"
		sider = itemSet.keys
		table = Table.new header, sider
		header.each do |i|
			sider.each do |j|
				if switch[j].has_key?(i)
					if table[[i,j]] == nil
						table[[i,j]] = Array.new
						table[[i,j]] << "S#{switch[j][i]}"
					else
						table[[i,j]] << "S#{switch[j][i]}"
					end
				end
			end
		end
		itemSet.each do |num, set|
			set.each do |doted|
				if doted[doted.size-1] == "."
					x = doted.split("->")
					head = x[0].gsub(" ","")
					e = x[1][1..x[1].size-3]
					follow[head].each do |val|
						if e == "."
							e = "&"
						end
						if table[[val,num]] == nil
							table[[val,num]] = Array.new
							table[[val,num]] << "R#{numGram[head][e]}"
						else
							table[[val,num]] << "R#{numGram[head][e]}"
						end
					end
				elsif doted == "#{@initial}' -> #{@initial} . $"
					table[["$",num]] = Array.new
					table[["$",num]] << "Halt"
				end
			end
		end
		return table
	end

	def itemSetMaker(gramar)
		gramar.insert(0, "#{@initial}' -> #{@initial} $\n")
		c = Hash.new
		desvio = Hash.new
		c[0] = closure("#{@initial}' -> . #{@initial} $")
		desvio[0] = Hash.new
		desvio[0]["#{@initial}"] = 1
		count = 1
		control = Hash.new
		while c != control
			control = deep_copy(c)
			control.each_pair do |num , i|
				if not desvio.has_key?(num)
					desvio[num] = Hash.new
				end
				@symbols.each do |sym|
					got = goto(i, sym)
					if (not c.has_value?(got)) and (not got.empty?)
						c[count] = got
						desvio[num][sym] = count
						count = count + 1
					end
					if (c.has_value?(got)) and (not got.empty?)
						desvio[num][sym] = c.key(got)
					end
				end
			end
		end
		return c, desvio
	end

	def goto(i, symbol)
		goto = Set.new
		i.each do |prod|
			if prod[prod.size - 1] != "."
				name = prod.split("->")[0].gsub(" ","")
				x = prod.split("->")[1].split(".")
				if x[1].split(" ")[0] == symbol
					moved = x[0]
					y = x[1].split(" ").insert(1, ".")
					y.each { |e| moved << "#{e} " }
					moved = moved.chop
					moved = "#{name} ->#{moved}"
					closure(moved).each { |e| goto << e }
				end
			end
		end
		return goto
	end

	def marker(parsedGramar)
		marked = Set.new
		parsedGramar.each do |key, val|
			val.each do |transition|
				y = transition.split(" ")
				(y.size + 1).times do |position|
					doted = y.dup
					doted.insert(position, ".")
					x = ""
					doted.each { |e| x << e + " "}
					x = x[0..(x.size-2)]
					if transition.gsub(" ","") == "&"
						marked << "#{key} -> ."
					else
						marked << "#{key} -> #{x}"
					end
				end
			end
		end
		return marked
	end

	def closure(i)
		itemSet = Set.new
		itemSet << i
		control = Set.new
		element = ""
		while itemSet != control
			control = deep_copy(itemSet)
			control.each do |transition|
				if transition[transition.size - 1] != "."
					element = transition.split(".")[1][1]
				end
				if element != element.downcase
					addSet = @marked.to_a.select { |e| e =~ /^(#{element} -> \.).*/ }
					addSet.each { |e| itemSet << e }
				end
			end
		end
		return itemSet
	end

	def setHashConverter(setHash)
		converted = Hash.new
		setHash.each do |key, value|
			converted["#{key}"] = value.to_a
		end
		return converted
	end

	def fatorada?(parsedGramar, first)
		error = false
		parsedGramar.each do |key, val|
			firsts = Set.new
			val.each do |prod|
				prod.split(" ").each do |element|
					if element == element.downcase
						if firsts.include?(element)
							error = true
						else
							firsts << element
						end
					else
						first[element].each do |fir|
							if firsts.include?(fir)
								error = true
							else
								if fir != "&"
									firsts << fir
								end
							end
						end
					end
					break if element == element.downcase or not first[element].include?("&")
				end
				break if error
			end
			break if error
		end
		return (not error)
	end

	def cond3?(parsedGramar, first, follow)
		error = false
		parsedGramar.each do |key, val|
			if first[key].include?("&")
				if not (first[key] & follow[key]).empty?
					error = true
				end
			end
			break if error
		end
		return (not error)
	end

	def leftRecurtion?(parsedGramar, first)
		error = false
		copy = parsedGramar.dup
		productions = Hash.new
		parsedGramar.each do |key, val|
			productions[key] = Set.new
			val.each do |prod|
				x = prod.split(" ")
				count = 0
				while (x[count] != x[count].downcase)
					productions[key] << x[count]
					break if not first[x[count]].include?("&")
					count = count + 1
				end
			end
		end
		productions.each do |key, val|
			val.each do |gen|
				if productions[gen].include?(key)
					error = true
				end
				break if error
			end
			break if error
		end
		return error
	end
end

# gram = "E -> E + T | T
# T -> T * F | F
# F -> ( E ) | id"
# gram = "S -> L = R | R
# L -> * R | id
# R -> L"
# gram = "S -> c S c | B c
# B -> a B | B b | &"
# lex = SyntacticAnalyzerStructConstructor.new(gram)
# puts lex.parsed1.inspect
# puts lex.firstSet.inspect
# puts lex.followSet.inspect
# puts lex.marked.inspect.inspect
# puts lex.symbols.inspect.inspect
# puts lex.gramat
# puts lex.itemSet.inspect
# puts lex.switch.inspect
# puts lex.numGram.inspect
# puts lex.lexTable.inspect
# puts lex.setHashConverter(lex.itemSet)
# puts lex.lexTable.table
# puts lex.lexTable.to_a.inspect
# puts lex.fatorada
# puts lex.leftRecurtion
# puts SLRAnalyzer.analyzeWithHistory("id + id $", lex.lexTable.table, lex.numGram)
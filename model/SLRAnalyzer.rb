class SLRAnalyzer
	def self.analyze(input, table, numGram)
		input = input.split(" ")
		a = input[0]
		count = 0
		stack = Array.new
		stack.push 0
		error = false
		while true
			s = stack[stack.size - 1]
			element = table[[a,s]]
			if element == nil
				error = true
			elsif element[0] == "S"
				stack.push element[1..element.size-1].to_i
				if a.downcase == a
					count = count + 1
					a = input[count]
				elsif a.downcase != a
					a = input[count]
				end
			elsif element[0] == "R"
				x = getProd(element[1..element.size-1].to_i, numGram)
				a = x[0]
				prod = x[1].split(" ")
				prod.size.times{stack.pop}
			end
			break if error or element == "Halt"
		end
		return error
	end

	def self.analyzeBySteps(input, table, numGram, stack, a, count)
		error = false
		s = stack[stack.size - 1]
		element = table[[a,s]]
		if element == nil
			error = true
		elsif element[0] == "S"
			stack.push element[1..element.size-1].to_i
			if a.downcase == a
				count = count + 1
				a = input[count]
			elsif a.downcase != a
				a = input[count]
			end
		elsif element[0] == "R"
			x = getProd(element[1..element.size-1].to_i, numGram)
			a = x[0]
			prod = x[1].split(" ")
			prod.size.times{stack.pop}
		end
		return input, table, numGram, stack, a, count
	end

	def self.getProd(num, numGram)
		value = ""
		prod = ""
		numGram.each do |key, val|
			if val.has_value?(num)
				value = key
				prod = val.key(num)
			end
		end
		return value, prod
	end
end
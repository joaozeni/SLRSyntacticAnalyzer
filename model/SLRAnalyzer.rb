class SLRAnalyzer
	def self.analyzeWithHistory(input, table, numGram)
		inputArr = input.split(" ")
		stackHistory = String.new
		wordHistory = String.new
		a = inputArr[0]
		count = 0
		stack = Array.new
		stack.push 0
		stackHistory << "#{stack}\n"
		wordHistory << "#{input}\n"
		error = false
		while true
			s = stack[stack.size - 1]
			element = table["#{a}#{s}"]
			if element == nil
				error = true
			elsif element[0][0] == "S"
				stack.push element[0][1..element[0].size-1].to_i
				if a.downcase == a
					count = count + 1
					a = inputArr[count]
				elsif a.downcase != a
					a = inputArr[count]
				end
				word = String.new
				inputArr[count..input.size-1].each { |e| word << "#{e} " }
				wordHistory << "#{word}\n"
			elsif element[0][0] == "R"
				x = getProd(element[0][1..element[0].size-1].to_i, numGram)
				a = x[0]
				prod = x[1].split(" ")
				if prod[0] != "&"
					prod.size.times{stack.pop}
				end
				word = String.new
				inputArr[count..input.size-1].each { |e| word << "#{e} " }
				wordHistory << "#{a} #{word}\n"
			end
			break if error or element[0] == "Halt"
			stackHistory << "#{stack}\n"
		end
		return error, stackHistory, wordHistory
	end

	# def self.analyze(input, table, numGram)
	# 	return analyzeWithHistory(input, table, numGram)[0]
	# end

	def self.analyzeBySteps(input, table, numGram, stack, a, count, wordHistory, stackHistory)
		inputArr = input.split(" ")
		error = false
		s = stack[stack.size - 1]
		element = table["#{a}#{s}"]
		if element == nil
			error = true
		elsif element[0][0] == "S"
			stack.push element[0][1..element[0].size-1].to_i
			if a.downcase == a
				count = count + 1
				a = inputArr[count]
			elsif a.downcase != a
				a = inputArr[count]
			end
			word = String.new
			inputArr[count..input.size-1].each { |e| word << "#{e} " }
			wordHistory << "#{word}\n"
		elsif element[0][0] == "R"
			x = getProd(element[0][1..element[0].size-1].to_i, numGram)
			a = x[0]
			prod = x[1].split(" ")
			if prod[0] != "&"
				prod.size.times{stack.pop}
			end
			word = String.new
			inputArr[count..input.size-1].each { |e| word << "#{e} " }
			wordHistory << "#{a} #{word}\n"
		end
		stackHistory << "#{stack}\n"
		return error, table, numGram, stack, a, count, wordHistory, stackHistory
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
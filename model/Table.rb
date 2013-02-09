class Table
	def initialize(headers, siders)
		@headers = headers
		@siders = siders
		@table = Hash.new
		if headers.is_a?(Array) and siders.is_a?(Array)
			headers.each do |i|
				siders.each do |j|
					@table["#{i}#{j}"] = nil
				end
			end
		end
	end

	attr_accessor :table

	def [](ij)
		@table["#{ij[0]}#{ij[1]}"]
	end

	def []=(ij, value)
		@table["#{ij[0]}#{ij[1]}"] = value
	end

	def inspect
		str = String.new
		great = self.sizer
		greatSider = self.sizerSider
		str << "  #{" "*(greatSider-1)}| "
		@headers.each do |x|
			str << "#{x} #{" "*(great-x.size)}| "
		end
		str << "\n"
		@siders.each do |sider|
			str << "#{sider} #{" "*(greatSider-sider.to_s.size)}| "
			@headers.each do |header|
				index = "#{header}#{sider}"
				if @table[index] != nil
					str << "#{@table[index]} #{" "*(great-@table[index].size)}| "
				else
					str << "  #{" "*(great-1)}| "
				end
			end
			str << "\n"
		end
		return str
	end

	def sizer
		size = 0
		@table.each_value do |val|
			if val != nil
				if size < val.to_s.size
					size = val.to_s.size
				end
			end
		end
		return size
	end

	def sizerSider
		size = 0
		@siders.each do |val|
			if size < val.to_s.size
				size = val.to_s.size
			end
		end
		return size
	end

	def to_s
		return inspect
	end

	def to_a(siderName="sider")
		arrayTable = Array.new
		x = @headers.dup
		x.insert(0, siderName)
		arrayTable << x
		@siders.each do |sider|
			x = Array.new
			x << sider
			@headers.each do |header|
				x << @table["#{header}#{sider}"]
			end
			arrayTable << x
		end
		return arrayTable
	end

	def self.to_mongo(value)
		x = Hash.new
		value.table.each do |key, value|
			if key[0] == "$"
				x[key.reverse] = value
			else
				x[key] = value
			end
		end
		return x
	end

	def self.from_mongo(value)
		x = Hash.new
		value.each do |key, value|
			if key[key.size-1] == "$"
				x[key.reverse] = value
			else
				x[key] = value
			end
		end
		return x
	end
end
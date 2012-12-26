require '../model/SyntacticAnalyzer'
require "test/unit"

class TcSyntacticAnalyzer < Test::Unit::TestCase
=begin
Gram
S -> Ab | ABc
B -> bB | Ad | &
A -> aA | &
=end
	def test_parse1
		gram = "S -> Ab | ABc
B -> bB | Ad | &
A -> aA | &"
		lex = SyntacticAnalyzer.new(gram)
		test = Hash.new
		test["S"] = Set.new
		test["S"] << "Ab" << "ABc"
		test["B"] = Set.new
		test["B"] << "bB" << "Ad" << "&"
		test["A"] = Set.new
		test["A"] << "aA" << "&"
		assert( lex.parsed == test , "parse Test")
	end
=begin
Gram               | FIRST
S -> Ab | ABc      | a,b,c,d
B -> bB | Ad | &   | &,a,b,d
A -> aA | &        | &,a

=end
	def test_first1
		gram = "S -> Ab | ABc
B -> bB | Ad | &
A -> aA | &"
		lex = SyntacticAnalyzer.new(gram)
		test = Hash.new
		test["S"] = Set.new
		test["S"] << "a" << "b" << "c" << "d"
		test["B"] = Set.new
		test["B"] << "a" << "b" << "&" << "d"
		test["A"] = Set.new
		test["A"] << "a" << "&"
		first = lex.first
		assert( first == test , "first Test1")
	end
=begin
Gram               | FIRST
S -> ABC           | a, b, c, d
A -> aA | &        | &, a
B -> bB | ACd      | b, a, c, d
C -> cC | &        | c, &
=end
	def test_first2
		gram = "S -> ABC
A -> aA | &
B -> bB | ACd
C -> cC | &"
		lex = SyntacticAnalyzer.new(gram)
		test = Hash.new
		test["S"] = Set.new
		test["S"] << "a" << "b" << "c" << "d"
		test["A"] = Set.new
		test["A"] << "a" << "&"
		test["B"] = Set.new
		test["B"] << "a" << "b" << "c" << "d"
		test["C"] = Set.new
		test["C"] << "c" << "&"
		first = lex.first
		assert( first == test , "first Test1")
	end
=begin
Gram               | FIRST
S -> ABC           | a
A -> aA            | a
B -> bB | ACd      | b, a
C -> cC | &        | c, &
=end
	def test_first3
		gram = "S -> ABC
A -> aA
B -> bB | ACd
C -> cC | &"
		lex = SyntacticAnalyzer.new(gram)
		test = Hash.new
		test["S"] = Set.new
		test["S"] << "a"
		test["A"] = Set.new
		test["A"] << "a"
		test["B"] = Set.new
		test["B"] << "a" << "b"
		test["C"] = Set.new
		test["C"] << "c" << "&"
		first = lex.first
		assert( first == test , "first Test1")
	end
=begin
Gram               | FIRST
S -> AdBC          | a, d
A -> aA | &        | a, &
B -> bB | ACd      | b, a
C -> cC | &        | c, &
=end
	def test_first4
		gram = "S -> AdBC
A -> aA | &
B -> bB | ACd
C -> cC | &"
		lex = SyntacticAnalyzer.new(gram)
		test = Hash.new
		test["S"] = Set.new
		test["S"] << "a" << "d"
		test["A"] = Set.new
		test["A"] << "a" << "&"
		test["B"] = Set.new
		test["B"] << "a" << "b" << "d" << "c"
		test["C"] = Set.new
		test["C"] << "c" << "&"
		first = lex.first
		assert( first == test , "first Test1")
	end
end
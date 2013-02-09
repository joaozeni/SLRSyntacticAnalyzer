require '../model/SyntacticAnalyzerStructConstructor'
require "test/unit"

class TcSyntacticAnalyzerStructConstructor < Test::Unit::TestCase
=begin
Gram
S -> Ab | ABc
B -> bB | Ad | &
A -> aA | &
=end
	def test_parse1
		gram = "S -> A b | A B c
B -> b B | A d | &
A -> a A | &"
		lex = SyntacticAnalyzerStructConstructor.new(gram)
		test = Hash.new
		test["S"] = Set.new
		test["S"] << "A b" << "A B c"
		test["B"] = Set.new
		test["B"] << "b B" << "A d" << "&"
		test["A"] = Set.new
		test["A"] << "a A" << "&"
		assert( lex.parsed1 == test , "parse Test")
	end
=begin
Gram               | FIRST
S -> Ab | ABc      | a,b,c,d
B -> bB | Ad | &   | &,a,b,d
A -> aA | &        | &,a

=end
	def test_first1
		gram = "S -> A b | A B c
B -> b B | A d | &
A -> a A | &"
		lex = SyntacticAnalyzerStructConstructor.new(gram)
		test = Hash.new
		test["S"] = Set.new
		test["S"] << "a" << "b" << "c" << "d"
		test["B"] = Set.new
		test["B"] << "a" << "b" << "&" << "d"
		test["A"] = Set.new
		test["A"] << "a" << "&"
		first = lex.firstSet
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
		gram = "S -> A B C
A -> a A | &
B -> b B | A C d
C -> c C | &"
		lex = SyntacticAnalyzerStructConstructor.new(gram)
		test = Hash.new
		test["S"] = Set.new
		test["S"] << "a" << "b" << "c" << "d"
		test["A"] = Set.new
		test["A"] << "a" << "&"
		test["B"] = Set.new
		test["B"] << "a" << "b" << "c" << "d"
		test["C"] = Set.new
		test["C"] << "c" << "&"
		first = lex.firstSet
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
		gram = "S -> A B C
A -> a A
B -> b B | A C d
C -> c C | &"
		lex = SyntacticAnalyzerStructConstructor.new(gram)
		test = Hash.new
		test["S"] = Set.new
		test["S"] << "a"
		test["A"] = Set.new
		test["A"] << "a"
		test["B"] = Set.new
		test["B"] << "a" << "b"
		test["C"] = Set.new
		test["C"] << "c" << "&"
		first = lex.firstSet
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
		gram = "S -> A d B C
A -> a A | &
B -> b B | A C d
C -> c C | &"
		lex = SyntacticAnalyzerStructConstructor.new(gram)
		test = Hash.new
		test["S"] = Set.new
		test["S"] << "a" << "d"
		test["A"] = Set.new
		test["A"] << "a" << "&"
		test["B"] = Set.new
		test["B"] << "a" << "b" << "d" << "c"
		test["C"] = Set.new
		test["C"] << "c" << "&"
		first = lex.firstSet
		assert( first == test , "first Test1")
	end
=begin
Gram               | FOLLOW
S -> Ab | ABc      | $
B -> bB | Ad | &   | c
A -> aA | &        | a, b, c, d

=end
	def test_follow1
		gram = "S -> A b | A B c
B -> b B | A d | &
A -> a A | &"
		lex = SyntacticAnalyzerStructConstructor.new(gram)
		test = Hash.new
		test["S"] = Set.new
		test["S"] << "$"
		test["B"] = Set.new
		test["B"] << "c"
		test["A"] = Set.new
		test["A"] << "a" << "b" << "c" << "d"
		follow = lex.followSet
		assert( follow == test , "follow Test1")
	end
=begin
Gram               | FOLLOW
S -> A B C         | $
A -> a A | &       | a, b, c, d
B -> b B | A C d   | $, c
C -> c C | &       | $, d

=end
	def test_follow2
		gram = "S -> A B C
A -> a A | &
B -> b B | A C d
C -> c C | &"
		lex = SyntacticAnalyzerStructConstructor.new(gram)
		test = Hash.new
		test["S"] = Set.new
		test["S"] << "$"
		test["A"] = Set.new
		test["A"] << "a" << "b" << "c" << "d"
		test["B"] = Set.new
		test["B"] << "c" << "$"
		test["C"] = Set.new
		test["C"] << "d" << "$"
		follow = lex.followSet
		assert( follow == test , "follow Test1")
	end
=begin
Gram               | FOLLOW
S -> A B C         | $
A -> a A           | a, b, c, d
B -> b B | A C d   | $, c
C -> c C | &       | $, d

=end
	def test_follow3
		gram = "S -> A B C
A -> a A
B -> b B | A C d
C -> c C | &"
		lex = SyntacticAnalyzerStructConstructor.new(gram)
		test = Hash.new
		test["S"] = Set.new
		test["S"] << "$"
		test["A"] = Set.new
		test["A"] << "a" << "b" << "c" << "d"
		test["B"] = Set.new
		test["B"] << "c" << "$"
		test["C"] = Set.new
		test["C"] << "d" << "$"
		follow = lex.followSet
		assert( follow == test , "follow Test1")
	end
=begin
Gram               | FOLLOW
S -> A d B C       | $
A -> a A | &       | c, d
B -> b B | A C d   | $, c
C -> c C | &       | $, d

=end
	def test_follow4
		gram = "S -> A d B C
A -> a A | &
B -> b B | A C d
C -> c C | &"
		lex = SyntacticAnalyzerStructConstructor.new(gram)
		test = Hash.new
		test["S"] = Set.new
		test["S"] << "$"
		test["A"] = Set.new
		test["A"] << "c" << "d"
		test["B"] = Set.new
		test["B"] << "c" << "$"
		test["C"] = Set.new
		test["C"] << "d" << "$"
		follow = lex.followSet
		assert( follow == test , "follow Test1")
	end
end
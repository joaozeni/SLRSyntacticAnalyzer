require 'sinatra'
require 'haml'
require '../model/SLRAnalyzer'
require '../model/SyntacticAnalyzerStructConstructor'
require '../model/Table'
require 'mongo_mapper'
require 'cgi'

class SyntacticAnalyzerStruct
	include MongoMapper::Document

	key :struct_id, String
	key :gramat, String
	key :numGram, Hash
	key :firstSet, Hash
	key :followSet, Hash
	key :itemSet, Hash
	key :hashTable, Hash
	key :table, Array
	key :count, Integer
	key :fatorada, Boolean
	key :cond3, Boolean
	# key :leftRecurtion, Boolean
end

configure do
	MongoMapper.database = 'SyntacticAnalyzerStructs'
end

get '/' do
	haml :index
end

post '/SLRAnalyzerMount' do
	@gram = SyntacticAnalyzerStruct.where(:gramat=>params[:gram]).first
	if @gram.nil?
		struct = SyntacticAnalyzerStructConstructor.new(params[:gram])
		struct_id = SyntacticAnalyzerStruct.all.count.to_s(16)
		@gram = SyntacticAnalyzerStruct.new(:struct_id=>struct_id, :gramat=>struct.gramat, :numGram=>struct.numGram,
			:firstSet=>struct.setHashConverter(struct.firstSet), :followSet=>struct.setHashConverter(struct.followSet),
			:table=>struct.lexTable.to_a, :count=>0, :itemSet=>struct.setHashConverter(struct.itemSet), 
			:hashTable=>Table.to_mongo(struct.lexTable), )
		@gram.save!
	end
	redirect "/#{@gram.struct_id}/SLRStructInfo"
end

get "/:id/SLRStructInfo" do |id|
	@gram = SyntacticAnalyzerStruct.where(:struct_id=>id).first
	haml :SLRAnalyzerInfo
end

get "/:id/SLRStructInfoFirstFollow" do |id|
	@gram = SyntacticAnalyzerStruct.where(:struct_id=>id).first
	@ff = Hash.new
	@gram.firstSet.each do |key, value|
		@ff[key] = Array.new
		@ff[key] << value
	end
	@gram.followSet.each do |key, value|
		@ff[key] << value
	end
	haml :SLRAnalyzerInfoFirstFollow
end

get "/:id/SLRStructInfoItenLR" do |id|
	@gram = SyntacticAnalyzerStruct.where(:struct_id=>id).first
	haml :SLRAnalyzerInfoItenLR
end

get '/:id/SLRStructInfoLexTable' do |id|
	@gram = SyntacticAnalyzerStruct.where(:struct_id=>id).first
	haml :SLRAnalyzerInfoLexTable
end

get '/:id/SLRAnalyzerWordInput' do |id|
	@gram = SyntacticAnalyzerStruct.where(:struct_id=>id).first
	haml :SLRAnalyzerWordInput
end

post '/:id/SLRAnalyzerWordTipeSelect' do |id|
	if params[:mode] == "complete"
		redirect "/#{id}/SLRAnalyzerWordComplete?palavra=#{CGI.escape(params[:palavra])}"
	elsif params[:mode] == "stepByStep"
		redirect "/#{id}/SLRAnalyzerWordStepByStep?palavra=#{CGI.escape(params[:palavra])}"
	end
end

get '/:id/SLRAnalyzerWordComplete' do |id|
	@gram = SyntacticAnalyzerStruct.where(:struct_id=>id).first
	@analyze = SLRAnalyzer.analyzeWithHistory(params[:palavra], Table.from_mongo(@gram.hashTable), @gram.numGram)
	@el = "Halt"
	@statement = ""
	if @analyze[0]
		@statement << "Erro na analise da palavra"
	else
		@statement << "Palavra aceita"
	end
	haml :SLRAnalyzerWordComplete
end

get '/:id/SLRAnalyzerWordStepByStep' do |id|
	@gram = SyntacticAnalyzerStruct.where(:struct_id=>id).first
	stack = Array.new
	stack.push 0
	@a = params[:palavra].split(" ")[0]
	count = 0
	@wordHistory = ""
	@wordHistory << "#{params[:palavra]}\n"
	@stackHistory = ""
	@stackHistory << "#{stack}\n"
	@el = Table.from_mongo(@gram.hashTable)["#{@a}#{stack[stack.size - 1]}"]
	@analyze = SLRAnalyzer.analyzeBySteps(params[:palavra], Table.from_mongo(@gram.hashTable), @gram.numGram, stack, @a, count, @wordHistory.dup, @stackHistory.dup)
	@statement = ""
	if @analyze[0]
		@statement << "Erro na analise da palavra"
	else
		@statement << "Palavra aceita"
	end
	haml :SLRAnalyzerWordStepByStep
end

get '/:id/SLRAnalyzerWordStepByStepNext' do |id|
	@gram = SyntacticAnalyzerStruct.where(:struct_id=>id).first
	@a = params[:a]
	stackString = params[:stack].gsub("[","").gsub("]","").gsub(" ","").split(",")
	stack = Array.new
	stackString.each { |e| stack << e.to_i }
	@wordHistory = params[:wordHistory].dup
	@stackHistory = params[:stackHistory].dup
	@el = Table.from_mongo(@gram.hashTable)["#{@a}#{stack[stack.size - 1]}"]
	@analyze = SLRAnalyzer.analyzeBySteps(params[:palavra], Table.from_mongo(@gram.hashTable), @gram.numGram, stack, params[:a], params[:count].to_i, params[:wordHistory], params[:stackHistory])
	@statement = ""
	if @el == 'Halt' or @analyze[0]
		if @analyze[0]
			@statement << "Erro na analise da palavra"
		else
			@statement << "Palavra aceita"
		end
		haml :SLRAnalyzerWordStepByStepEnd
	else
		if @analyze[0]
			@statement << "Erro na analise da palavra"
		else
			@statement << "Continuando analise"
		end
		haml :SLRAnalyzerWordStepByStep
	end
end

get '/:id/LLAnalyzer' do |id|
	@gram = SyntacticAnalyzerStruct.where(:struct_id=>id).first
	@statement = ""
	if @gram.fatorada
		@statement << "A gramatica esta fatorada\n"
	elsif not @gram.fatorada
		@statement << "A gramatica nao esta fatorada\n"
	end
	if @gram.leftRecurtion
		@statement << "A gramatica possui recursao a esquerda\n"
	elsif not @gram.leftRecurtion
		@statement << "A gramatica nao possui recursao a esquerda\n"
	end
	if @gram.cond3
		@statement << "A gramatica passa na condicao 3\n"
	elsif not @gram.cond3
		@statement << "A gramatica nao passa na condicao 3\n"
	end
	haml :LLAnalyzer
end

get '/clear' do
	SyntacticAnalyzerStruct.destroy_all
end
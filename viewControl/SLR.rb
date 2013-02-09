require 'sinatra'
require 'haml'
require '../model/SLRAnalyzer'
require '../model/SyntacticAnalyzerStructConstructor'
require '../model/Table'
require 'mongo_mapper'

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
end

configure do
	MongoMapper.database = 'SyntacticAnalyzerStructs'
end

get '/' do
	haml :index
end

get '/SLRAnalyzerInput' do
	haml :SLRAnalyzerInput
end

get '/LLInspecter' do
	haml :LLInspecter
end

post '/SLRAnalyzerMount' do
	@gram = SyntacticAnalyzerStruct.where(:gramat=>params[:gram]).first
	if @gram.nil?
		struct = SyntacticAnalyzerStructConstructor.new params[:gram]
		struct_id = SyntacticAnalyzerStruct.all.count.to_s(16)
		@gram = SyntacticAnalyzerStruct.new(:struct_id=>struct_id, :gramat=>struct.gramat, :numGram=>struct.numGram,
			:firstSet=>struct.setHashConverter(struct.firstSet), :followSet=>struct.setHashConverter(struct.followSet),
			:table=>struct.lexTable.to_a, :count=>0, :itemSet=>struct.setHashConverter(struct.itemSet), 
			:hashTable=>Table.to_mongo(struct.lexTable))
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

get '/clear' do
	SyntacticAnalyzerStruct.destroy_all
end
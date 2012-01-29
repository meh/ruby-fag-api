#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

require 'fag/http'
require 'fag/author'
require 'fag/flow'

module Fag

class Session < HTTP
	attr_reader :user

	def initialize (*)
		super

		version '1'

		@user = Anonymous.new

		yield self if block_given?
	end

	def signup (username, password)
		post('/users', name: username, password: password)

		login(username, password)
	end

	def login (username, password)
		@user = User.new(post('/auth', name: username, password: password), username, self)
	rescue
		false
	end

	def logged_in?
		get '/auth'
	end

	def flow (id)
		Flow.from_json(get("/flows/#{id}"), self)
	end

	def flows (expression, range = nil)
		if range.nil?
			get "/flows?expression=#{CGI.escape(expression)}"
		elsif range.end == -1
			get "/flows?expression=#{CGI.escape(expression)}&offset=#{range.begin}"
		elsif range.begin == -1
			get "/flows?expression=#{CGI.escape(expression)}&limit=#{range.end}"
		else
			get "/flows?expression=#{CGI.escape(expression)}&offset=#{range.begin}&limit=#{range.to_a.length}"
		end.map { |data| Flow.from_json(data, self) }
	end

	def create_flow (title, tags, content)
		Flow.from_json(post('/flows', title: title, tags: tags.to_json, content: content, name: user.name), self)
	end

	def drop (id)
		Drop.from_json(get("/drops/#{id}"), self)
	end
end

end

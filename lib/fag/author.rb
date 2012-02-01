#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

module Fag

class Author
	def self.from_json (data, session = nil)
		if data['id']
			User.from_json(data, session)
		else
			Anonymous.from_json(data, session)
		end
	end

	attr_reader :name

	def initialize (name, session = nil)
		@name = name

		@session = session
	end

	alias to_s name
end

class User < Author
	singleton_memoize
	def self.from_json (data, session = nil)
		User.new(data['id'], nil, session)
	end

	include Sessioned

	attr_reader :id

	def initialize (id, name = nil, session = nil)
		unless name
			name = session.get("/users/#{id}")['name']
		end

		super(name, session)

		@id = id
	end

	session_define :flows do |s, range = nil|
		if range.nil?
			get "/users/#{id}/flows"
		elsif range.end == -1
			get "/users/#{id}/flows?offset=#{range.begin}"
		elsif range.begin == -1
			get "/users/#{id}/flows?limit=#{range.end}"
		else
			get "/users/#{id}/flows?offset=#{range.begin}&limit=#{range.to_a.length}"
		end.map { |f| Flow.from_json(f, s) }
	end

	session_define :drops do |s, range = nil|
		if range.nil?
			get "/users/#{id}/drops"
		elsif range.end == -1
			get "/users/#{id}/drops?offset=#{range.begin}"
		elsif range.begin == -1
			get "/users/#{id}/drops?limit=#{range.end}"
		else
			get "/users/#{id}/drops?offset=#{range.begin}&limit=#{range.to_a.length}"
		end.map { |d| Drop.from_json(d, s) }
	end

	session_define :powers do |s|
		s.get "/users/#{id}/powers"
	end

	session_define :can? do |s, what|
		s.get "/users/#{id}/can/#{what}"
	end

	session_define :cannot? do |s, what|
		s.get "/users/#{id}/cannot/#{what}"
	end

	session_define :change_password do |s, password|
		s.post "/users/#{id}/change/password", password: password
	end
end

class Anonymous < Author
	def self.from_json (data, session = nil)
		Anonymous.new(data['name'], session)
	end

	attr_accessor :name

	def initialize (name = nil, session = nil)
		super(name || 'Anonymous', session)
	end
end

end

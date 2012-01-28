#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

require 'fag/tags'
require 'fag/drop'

module Fag

class Flow
	def self.from_json (data, session = nil)
		Flow.new(data['id'], session) { |f| f.fetch(data) }
	end

	include Fetchable
	include Sessioned

	attr_reader :id

	def initialize (id, session = nil)
		@id = id

		@session = session

		yield self if block_given?
	end

	session_define :create_drop do |s, content, title = nil|
		Drop.from_json(s.post("/flows/#{id}/drops", content: content, title: title, name: s.user.name), s)
	end

	%w[title tags author created_at updated_at drops].each {|name|
		fetchable_define name do
			instance_variable_get "@#{name}"
		end
	}

	def fetch (data = nil)
		(data || @session.get("/flow/#{id}")).tap {|o|
			@title  = o['title']
			@tags   = Tags.from_json(o['tags'], @session)
			@author = Author.from_json(o['author'], @session)

			@drops = o['drops'].map { |d| Drop.from_json(d, @session) }

			@created_at = DateTime.parse(o['created_at'])
			@updated_at = DateTime.parse(o['updated_at'])
		}
	end
end

end

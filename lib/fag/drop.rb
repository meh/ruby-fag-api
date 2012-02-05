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

class Drop
	def self.from_json (data, session = nil)
		Drop.new(data['id'], session) { |f| f.fetch(data) }
	end

	include Fetchable
	include Sessioned

	attr_reader   :id
	attr_accessor :relative_id

	def initialize (id, session = nil)
		@id = id

		@session = session

		yield self if block_given?
	end

	session_define :destroy do |s|
		s.delete "/drops/#{id}"
	end

	session_define :update do |s, data|
		if data[:author].is_a?(Anonymous)
			data[:author_name] = data[:author].name
		else
			data[:author_id] = data[:author].is_a?(Integer) ? data[:author] : data[:author].id
		end

		s.put "/drops/#{id}", data
	end

	%w[title author content created_at updated_at].each {|name|
		fetchable_define name do
			instance_variable_get "@#{name}"
		end
	}

	def fetch (data = nil)
		(data || @session.get("/drops/#{id}")).tap {|o|
			@title  = o['title']
			@author = Author.from_json(o['author'], @session)

			@content = o['content']

			@created_at = DateTime.parse(o['created_at'])
			@updated_at = DateTime.parse(o['updated_at'])
		}
	end
end

class Drops < Array
	include Sessioned

	def initialize (data, session)
		@session = session

		data.each_with_index {|data, index|
			self << if data.is_a?(Integer)
				@to_fetch = true

				Drop.new(data, session)
			else
				Drop.from_json(data, session)
			end.tap {|drop|
				drop.relative_id = index + 1
			}
		}
	end

	session_define :fetch! do |s|
		return self unless @to_fetch

		ids = map(&:id)
		clear

		session.get("/drops/#{ids.join(',')}?array").each_with_index {|data, index|
			self << Drop.from_json(data, s).tap {|drop|
				drop.relative_id = index + 1
			}
		}

		@to_fetch = false

		self
	end
end

end

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

class Tag
	singleton_memoize
	def self.from_json (data, session = nil)
		Tag.new(data['name'], data['id'], session)
	end

	include Sessioned
	include WithMetadata

	attr_reader :name, :id

	def initialize (name, id = nil, session = nil)
		@session = session

		@name = name
		@id   = id
	end

	alias to_s name
	alias to_str name
end

class Tags < Array
	def self.from_json (data, session = nil)
		Tags.new.tap { |tags|
			data.each {|name|
				tags << Tag.new(name, session)
			}
		}
	end

	def to_s
		join ', '
	end
end

end

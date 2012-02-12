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

class Metadata < Hash
	attr_reader :owner

	def initialize (owner)
		@owner = owner
	end

	def save
		@owner.session.put url, data: self
	end

	def load
		replace @owner.session.get(url)
	end

private
	def url
		"/metadata/#{owner.class.name[/[^:]*$/].downcase}/#{owner.id}"
	end
end

end

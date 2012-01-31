# this file contains fixes for various external parts
# each part is under its own project's license

require 'cookiejar'
require 'net/http'
require 'json'
require 'refining'
require 'call-me/memoize'

module Net
	class HTTPResponse
		def [] (key)
			@header[key.to_s.downcase].tap {|h|
				break h.join(', ') if h.respond_to?(:join)
			}
		end

		def keys
			@header.keys
		end

		def values
			@header.values
		end
	end
end

module CookieJar
	class Jar
		def self.load_ns (file)
			self.from_ns(File.read(file))
		end

		def self.from_ns (string)
			jar = self.new

			string.each_line {|line|
				if matches = line.match(/^((?:^[^^]+))\s+(TRUE|FALSE)\s+(\S+)\s+(TRUE|FALSE)\s+(\d+)\s+(\S+)\s+(\S+)\s*$/)
					jar.add_cookie Cookie.new(domain: matches[1], path: matches[3], secure: matches[4] == 'TRUE' ? true : false,
						expires_at: Time.at(matches[5].to_i), name: matches[6], value: matches[7])
				end
			}

			jar
		end

		def to_ns
			"# Netscape HTTP Cookie File\n" <<
			"# http://curl.haxx.se/rfc/cookie_spec.html\n" <<
			"# This file was generated by ruby-zdren! Edit at your own risk.\n\n" <<

			to_a.map {|cookie|
				"#{cookie.domain}\t#{cookie.domain[0] == ?. ? 'TRUE' : 'FALSE'}\t#{cookie.path} #{cookie.secure ? 'TRUE' : 'FALSE'}" <<
					"\t#{cookie.expires_at.to_i}\t#{cookie.name}\t#{cookie.value}\n" if !cookie.session?
			}.compact.join
		end

		def save_ns (file)
			File.open(file, 'w') {|f|
				f.write(self.to_ns)
			}
		end
	end
end

module JSON
	refine_singleton_method :parse do |old, what|
		if what =~ /^\s*[\{\[]/
			old.(what)
		else
			old.("[#{what}]")[0]
		end
	end
end

module Fag
	module Sessioned
		def self.included (klass)
			class << klass
				def session_define (name, &block)
					define_method name do |*args, &blk|
						raise RuntimeError, 'no session defined' unless @session

						singleton_class.instance_eval { define_method name, &block }

						__send__(name, @session, *args, &blk).tap {
							singleton_class.instance_eval { remove_method name }
						}
					end
				end
			end
		end

		attr_reader :session
	end

	module Fetchable
		def self.included (klass)
			class << klass
				def fetchable_define (name, &block)
					(@@fetchables ||= []) << name

					define_method "#{name}=" do |value|
						instance_variable_set "@#{name}", value
					end

					define_method name do |*args, &blk|
						fetch unless instance_variable_defined? "@#{name}"

						singleton_class.instance_eval { define_method name, &block }

						__send__(name, *args, &blk).tap {
							singleton_class.instance_eval { remove_method name }
						}
					end
				end
			end
		end

		def refresh
			@@fetchables.each {|name|
				remove_instance_variable "@#{name}"
			}
		end

		def fetch (*)
			raise NotImplementedError, 'the specialized #fetch has not been implemented'
		end
	end
end

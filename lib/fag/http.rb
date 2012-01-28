#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

require 'fag/extensions'
require 'fag/version'

module Fag

class HTTP
	class APIException < Exception
		attr_reader :method, :url, :code

		def initialize (method, url, message, code)
			super(message)

			@method = method
			@url    = url
			@code   = code
		end

		def to_s
			"#{@method.upcase} #{@url}: #{super}"
		end
	end

	attr_reader :cookies

	def initialize (address = nil, port = nil, ssl = nil)
		if address && !port && !ssl
			URI.parse(address).tap {|uri|
				address = uri.host
				port    = uri.port
				ssl     = uri.scheme == 'https'
			}
		end

		@address = address
		@port    = port
		@ssl     = ssl

		@cookies = CookieJar::Jar.new
	end

	def version (what = nil)
		what ? @version = what : @version
	end

	def request (method, path, *args)
		path = "/#{version}/#{path}".gsub(%r(//+), '/') if version
		res  = Net::HTTP.start(@address, @port) {|http|
			http.__send__ method.downcase, path, *args
		}

		@cookies.set_cookies_from_headers(url, res)

		if res.code.to_s.start_with? ?2
			JSON.parse(res.body)
		else
			raise APIException.new(method, path, (res.body.empty? ? res.status : res.body rescue nil), res.code)
		end
	end

	memoize
	def url
		"http#{?s if @ssl}://#{@address}#{":#{@port}" if (!@ssl and @port != 80) or (@ssl and @port != 443)}/"
	end

	def get (path, headers = {})
		request :GET, path, prepare_headers(headers)
	end

	def post (path, data, headers = {})
		request :POST, path, prepare_data(data), prepare_headers(headers)
	end

	private

	def prepare_data (data)
		(data.is_a?(Hash) ? URI.encode_www_form(data) : data.to_s) << "&_csrf=#{URI.encode_www_form_component(csrf)}"
	end

	def prepare_headers (headers = {})
		headers.merge(
			'User-Agent' => "ruby-fag-api/#{Fag::VERSION}",
			'Cookie'     => @cookies.get_cookie_header(url)
		)
	end

	def csrf (renew = false)
		unless renew
			@csrf ||= get '/csrf'
		else
			@csrf = get '/csrf/renew'
		end
	end
end

end

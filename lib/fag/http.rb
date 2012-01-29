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
		attr_reader :method, :path

		def initialize (method, path, response)
			@method   = method
			@path     = path
			@response = response

			super("#{method.upcase} #{path}: #{code} #{body}")
		end

		def code
			@response.code.to_i
		end

		def body
			result = @response.body.empty? ? @response.message : @response.body

			if result.start_with? code.to_s
				result.sub!(/^(\d+)\s*/, '')
			end

			result
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

	def request (method, path, headers = nil, data = nil)
		path = "/#{version}/#{path}".gsub(%r(//+), '/') if version
		res  = Net::HTTP.start(@address, @port) {|http|
			req = Net::HTTP.const_get(method.capitalize).new(path)

			if %w[POST PUT DELETE].member? method.to_s
				req.set_form_data _prepare_data(data)
			end

			_prepare_headers(headers).each {|name, value|
				req[name] = value
			}

			http.request(req)
		}

		@cookies.set_cookies_from_headers(url, res)

		if res.is_a? Net::HTTPSuccess
			JSON.parse(res.body)
		else
			raise APIException.new(method, path, res)
		end
	end

	memoize
	def url
		"http#{?s if @ssl}://#{@address}#{":#{@port}" if (!@ssl and @port != 80) or (@ssl and @port != 443)}/"
	end

	def get (path, headers = nil)
		request :GET, path, headers
	end

	def post (path, data, headers = nil)
		request :POST, path, headers, data
	end

	def put (path, data, headers = nil)
		request :PUT, path, headers, data
	end

	def delete (path, headers = nil)
		request :DELETE, path, headers
	end

	def csrf (renew = false)
		unless renew
			@csrf ||= get '/csrf'
		else
			@csrf = get '/csrf/renew'
		end
	end

private
	def _prepare_data (data)
		(data || {}).merge(
			_csrf: csrf
		)
	end

	def _prepare_headers (headers)
		(headers || {}).merge(
			'User-Agent' => "ruby-fag-api/#{Fag::VERSION}",
			'Cookie'     => @cookies.get_cookie_header(url),
			'Connection' => 'close'
		)
	end
end

end

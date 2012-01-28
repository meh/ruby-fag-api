Gem::Specification.new {|s|
	s.name         = 'fag-api'
	s.version      = '0.0.1'
	s.author       = 'meh.'
	s.email        = 'meh@paranoici.org'
	s.homepage     = 'http://github.com/meh/ruby-fag-api'
	s.platform     = Gem::Platform::RUBY
	s.summary      = 'Official API library for fag'

	s.files         = `git ls-files`.split("\n")
	s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
	s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
	s.require_paths = ['lib']

	s.add_dependency 'cookiejar'
	s.add_dependency 'json'
	s.add_dependency 'refining'
	s.add_dependency 'call-me'
}

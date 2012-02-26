# -*- encoding: utf-8 -*-
require File.expand_path('../lib/attentive/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["John Bintz"]
  gem.email         = ["john@coswellproductions.com"]
  gem.description   = %q{A new take on Ruby presentation software}
  gem.summary       = %q{A new take on Ruby presentation software}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "attentive"
  gem.require_paths = ["lib"]
  gem.version       = Attentive::VERSION

  gem.add_dependency 'sinatra'

  gem.add_dependency 'sprockets'
  gem.add_dependency 'sprockets-vendor_gems'
  gem.add_dependency 'coffee-script'
  gem.add_dependency 'sprockets-sass'
  gem.add_dependency 'compass', '~> 0.12.rc'

  gem.add_dependency 'haml'

  gem.add_dependency 'nokogiri'
  gem.add_dependency 'rdiscount'
  gem.add_dependency 'pygments.rb'

  gem.add_dependency 'thor'
  gem.add_dependency 'backbone-rails'
  gem.add_dependency 'rack', '~> 1.4.0'
end


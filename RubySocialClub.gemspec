# -*- encoding: utf-8 -*-
require File.expand_path('../lib/RubySocialClub/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Alessio Caiazza"]
  gem.email         = ["nolith@abisso.org"]
  gem.description   = %q{A tool for writing beamer presentation containig ruby code examples}
  gem.summary       = %q{This tool allows you to include real ruby example, with output, in latex presentations.}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "RubySocialClub"
  gem.require_paths = ["lib"]
  gem.version       = RubySocialClub::VERSION

  gem.add_dependency 'thor'
  gem.add_dependency 'syntax'
  gem.add_development_dependency 'rspec'
end

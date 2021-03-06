# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "recess/version"

Gem::Specification.new do |s|
  s.name        = "recess"
  s.version     = Recess::VERSION
  s.authors     = ["Brian Leonard"]
  s.email       = ["brian@bleonard.com"]
  s.homepage    = ""
  s.summary     = %q{You know, to break up your classes.}
  s.description = %q{You know, to break up your classes.}

  s.rubyforge_project = "recess"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end

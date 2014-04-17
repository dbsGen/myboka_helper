$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "myboka_helpers/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "myboka_helpers"
  s.version     = MybokaHelpers::VERSION
  s.authors     = ["Gen"]
  s.email       = ["gen@zhaorenzhi.cn"]
  s.homepage    = "http://zhaorenzhi.cn"
  s.summary     = "Myboka的helpers的封装"
  s.description = "Myboka的helpers的封装"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_dependency 'nokogiri'
  s.add_dependency 'template_manager', '>= 0.1.5'
  s.add_dependency 'httpclient'
  s.add_dependency 'hashie'

  s.add_development_dependency "sqlite3"
end

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "locomotive/exporter/version"

Gem::Specification.new do |s|
  s.name        = "locomotive_exporter"
  s.version     = Locomotive::Exporter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Keith Pitt", "Steven Webb", "Mario Visic", "Dirk Kelly", "Tony Issakov"]
  s.email       = ["support@thefrontiergroup.com.au"]
  s.homepage    = "http://www.thefrontiergroup.com.au"
  s.summary     = "An exporter for the locomotive CMS"
  s.description = "An exporter for the locomotive CMS"

  s.required_rubygems_version = ">= 1.3.6"

  s.files        = Dir[ "Gemfile",
                        "{app}/**/*",
                        "{config}/**/*",
                        "{lib}/**/*" ]

  s.require_path = 'lib'

  s.extra_rdoc_files = [ "README.md" ]

end


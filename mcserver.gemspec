Gem::Specification.new do |spec|
  spec.name         = 'mcserver'
  spec.version      = '0.0.0'
  spec.summary      = 'Easy management of Minecraft server processes'
  spec.authors      = ['Tony Von Wolfe']
  spec.email        = 'tonyvonwolfe@gmail.com'
  spec.homepage     = 'TBD'
  spec.license      = 'TBD'

  spec.files        = `git ls-files`.split("\n")
  spec.test_files   = `git ls-files -- test/*`.split("\n")

  spec.add_development_dependency 'rspec'
end

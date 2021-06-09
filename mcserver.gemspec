# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name         = 'mcserver'
  spec.version      = '0.0.0'
  spec.summary      = 'Easy management of Minecraft server processes'
  spec.authors      = ['tvonwolfe']
  spec.email        = 'tonyvonwolfe@gmail.com'
  spec.homepage     = 'https://tonyvonwolfe.com'
  spec.license      = 'GPL-2.0'

  spec.files        = `git ls-files`.split("\n")
  spec.test_files   = `git ls-files -- test/*`.split("\n")

  spec.add_development_dependency 'rspec'
end

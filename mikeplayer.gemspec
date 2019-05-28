# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mikeplayer/version'

Gem::Specification.new do |gem|
  gem.name          = 'mikeplayer'
  gem.version       = MikePlayer::VERSION
  gem.authors       = ['Mike Crockett']
  gem.email         = ['rubygems@mmcrockett.com']
  gem.summary       = 'Wraps Sox\'s `play` command, allowing playslists, find, random and time limit.'
  gem.executables   << 'MikePlayer.rb'
  gem.description   = <<-EOF.gsub(/^\s+/, '')
    #{gem.summary}

    Once a song is playing you can:
      'x' to previous
      'c' to pause/play
      'v' to next
      'q' to quit
      't' n to set a timer that will pause the music after n minutes
  EOF
  gem.homepage      = 'https://github.com/mmcrockett/mikeplayer'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.licenses      = ['MIT']

  gem.add_dependency 'json', '~> 1.8'
  gem.add_dependency 'ruby-mp3info', '~> 0.8'
  gem.add_dependency 'minitest', '~> 5'
  gem.add_development_dependency 'rake', '~> 12'
  gem.add_development_dependency 'byebug', '~> 11'
end

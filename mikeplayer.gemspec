# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mikeplayer/version'

Gem::Specification.new do |spec|
  spec.name          = 'mikeplayer'
  spec.version       = MikePlayer::VERSION
  spec.authors       = ['Mike Crockett']
  spec.email         = ['rubygems@mmcrockett.com']
  spec.summary       = 'Wraps Sox\'s `play` command, allowing playslists, find, random and time limit.'
  spec.executables   << 'MikePlayer.rb'
  spec.description   = <<-EOF.gsub(/^\s+/, '')
    #{spec.summary}

    Once a song is playing you can:
      'x' to previous
      'c' to pause/play
      'v' to next
      'q' to quit
      't' n to set a timer that will pause the music after n minutes
  EOF
  spec.homepage      = 'https://github.com/mmcrockett/mikeplayer'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match?(%r{^(test|spec|features|helpers|)/}) || f.match?(%r{^(\.[[:alnum:]]+)}) || f.match?(/console/)
  end

  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.licenses      = ['MIT']

  spec.add_dependency 'json', '~> 2.5'
  spec.add_dependency 'ruby-mp3info', '~> 0.8'
  spec.add_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'rake', '~> 12'
  spec.add_development_dependency 'byebug', '~> 11'
end

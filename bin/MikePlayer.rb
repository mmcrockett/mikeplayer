#!/usr/bin/env ruby

require 'mikeplayer'

options = {}
OptionParser.new do |opt|
  opt.banner = <<-EOF
   Usage: MikePlayer.rb [options] <search || file>

   Example: `MikePlayer.rb --shuffle --directory /User/Catman/Music cats /MyMusic/GreatestBand-Song.mp3`
     Finds all songs matching 'cats' in directory /User/Catman/Music ignoring case
      and specific song /MyMusic/GreatestBand-Song.mp3
      and randomizes the order

  EOF
  opt.on('-s', '--shuffle', 'Shuffle playlist.') { |o| options[:shuffle] = true }
  opt.on('-r', '--random n', 'Create playlist with randomly picked n songs.') { |o| options[:random] = o.to_i }
  opt.on('-o', '--overwrite', 'Overwrite playlist.') { |o| options[:overwrite] = true }
  opt.on('-v', '--volume n', 'Changes default volume.') { |o| options[:volume] = o }
  opt.on('-p', '--playlist name', 'Play playlist name.') { |o| options[:playlist] = o }
  opt.on('-l', '--list', 'List songs in playlist.') { |o| options[:list] = true; }
  opt.on('-d', '--directory name', 'Directory to find mp3s.') { |o| options[:directory] = o }
  opt.on('-t', '--time minutes', 'Limit time to number of minutes.') { |o| options[:minutes] = o }
  opt.on('-x', '--debug', 'Turn on debug.') { |o| options[:debug] = true }
end.parse!

MikePlayer::Player.new(options, ARGV).play

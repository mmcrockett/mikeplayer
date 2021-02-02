require 'optparse'
require 'json'
require 'open3'
require 'io/console'
require 'mp3info'
require 'mikeplayer/version'
require 'mikeplayer/display'
require 'mikeplayer/playlist'
require 'mikeplayer/play_thread'
require 'mikeplayer/settings'
require 'mikeplayer/song'

module MikePlayer
  class Player
    PLAY_SLEEP         = 0.5
    PAUSE_SLEEP        = 1.0
    STOPPED            = :stopped
    PLAYING            = :playing
    PAUSED             = :paused
    SONG_CHANGE        = :song_change

    def initialize(options, *args)
      @settings  = Settings.new(options)
      @playlist  = Playlist.new(@settings.playlist)
      @minutes   = @settings.minutes
      @command   = ''
      @timer_start = Time.now if (@minutes > 0)
      @state     = STOPPED
      @player    = PlayThread.new(volume: @settings.volume)

      if (true == @settings.list?)
        @songs.map { |song| File.basename(song) }.sort.each {|song| puts "#{File.basename(song)}"}

        exit 0
      end

      args.flatten.each do |arg|
        @playlist.find_song(arg, @settings.music_dir)
      end

      if (true == @settings.random?)
        @playlist.add_random(@settings.random, @settings.music_dir)
      end

      @playlist.save
    end

    def play
      @playlist.shuffle! if @settings.shuffle?

      puts "Mike Player v#{MikePlayer::VERSION}"
      puts "Playlist #{@playlist.info}\n"

      if (0 == @playlist.size)
        puts "No songs in playlist."
        
        exit 1
      end

      @thread = Thread.new do
        @display = Display.new
        @song_i  = 0

        while (@song_i < @playlist.size)
          @display.song_info = @playlist.song_info(@song_i)

          @player.play(song.filename)

          @state   = PLAYING

          while @player.playing?
            pause_if_over_time_limit

            @display.elapsed = @player.elapsed if playing?

            @display.display!(song.length_str(@player.elapsed), minutes_remaining)

            sleep(sleep_time)
          end

          if playing? && @player.stopped?
            next_song
          elsif paused?
            while paused?
              sleep(sleep_time)
            end
          end
        end

        @player.stop
        print("\r\n")
        exit
      end

      wait_on_user

      print("\r\n")
    end

    private

    def wait_on_user
      while ('q' != @command)
        @command = STDIN.getch

        if ('c' == @command)
          press_pause
        elsif ('v' == @command)
          next_song
        elsif ('z' == @command)
          previous_song
        elsif ('q' == @command)
          press_stop
        elsif ('t' == @command)
          @timer_start = Time.now
        elsif (false == @timer_start.nil?) && ("#{@command.to_i}" == @command)
          if (0 == @minutes)
            @minutes = @command.to_i
          else
            @minutes *= 10
            @minutes += @command.to_i
          end
        end
      end
    end

    def playing?
      return (PLAYING == @state)
    end

    def paused?
      return (PAUSED == @state)
    end

    def changing?
      return (SONG_CHANGE == @state)
    end

    def press_stop
      @player.stop
      @state = STOPPED
    end

    def press_pause
      debug('|')

      if playing?
        debug('>')
        @state = PAUSED
        @display.paused
        @player.pause
      elsif paused?
        debug('|')
        @state = PLAYING
      else
        print("Confused state #{@state}.")
      end
    end

    def next_song
      debug('n')

      @state = SONG_CHANGE

      @player.stop

      @song_i += 1
    end

    def previous_song
      debug('p')

      @state = SONG_CHANGE

      if (@player.elapsed < 10)
        @song_i -= 1 if @song_i.positive?
      else
        debug('x')
      end

      @player.stop
    end

    def pause_if_over_time_limit
      if (false == @timer_start.nil?) && (0 < @minutes) && (true == playing?)
        if (minutes_remaining && 0 >= minutes_remaining)
          press_pause
          @timer_start = nil
          @minutes    = 0
        end
      end
    end

    def minutes_remaining
      return if ((0 == @minutes) || (@timer_start.nil?))

      (@minutes - ((Time.now - @timer_start).to_i / 60).to_i)
    end

    def sleep_time
      return PLAY_SLEEP if playing?

      PAUSE_SLEEP
    end

    def song
      @playlist.get(@song_i)
    end

    def debug(str)
      print(str) if @settings.debug?
    end
  end
end

require 'optparse'
require 'json'
require 'open3'
require 'io/console'
require 'mp3info'
require 'mikeplayer/version'
require 'mikeplayer/settings'
require 'mikeplayer/playlist'
require 'mikeplayer/song'

module MikePlayer
  class Player
    PAUSE_INDICATOR    = " ||".freeze
    SLEEP_SETTING      = 0.5
    STOPPED            = :stopped
    PLAYING            = :playing
    PAUSED             = :paused

    def initialize(options, *args)
      @settings  = Settings.new(options)
      @playlist  = Playlist.new(@settings.playlist)
      @minutes   = @settings.minutes
      @command   = ''
      @pid       = nil
      @timer_start = nil
      @state     = STOPPED

      check_system

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

      if @playlist.finished?
        puts "No songs in playlist."
        
        exit 1
      end

      @thread = Thread.new do
        display_width   = 0

        while (false == @playlist.finished?)
          song        = @playlist.current
          @song_start = Time.now
          info_prefix = "\r#{@playlist.current_song_info}".freeze

          stdin, stdother, thread_info = Open3.popen2e('play', '--no-show-progress', '--volume', @settings.volume, song.filename)

          @state   = PLAYING
          @pid     = thread_info.pid
          indicator = ''
          info_changed = false

          while (true == pid_alive?)
            pause_if_over_time_limit

            if (true == playing?)
              indicator = "#{'>' * (playing_time % 4)}".ljust(4)
              info_changed = true
            elsif (true == paused?) && (PAUSE_INDICATOR != indicator)
              indicator = PAUSE_INDICATOR
              info_changed = true
            end

            if (true == info_changed)
              mindicator = ""

              if (0 < minutes_remaining)
                mindicator = "(#{minutes_remaining}↓) "
              end

              print("\r" << ' '.ljust(display_width))

              info  = "#{info_prefix} #{song.length_str(playing_time)} #{mindicator}#{indicator}"

              print(info)

              display_width = info.size

              info_changed = false
              $stdout.flush
            end

            sleep SLEEP_SETTING
          end

          stdin.close
          stdother.close

          @pid = nil

          if (true == playing?)
            next_song unless @pid.nil?
          end
        end

        @pid   = nil
        print("\r\n")
        exit
      end

      wait_on_user

      print("\r\n")
    end

    def cmd_exist?(cmd)
      if (true != system('command'))
        raise "Missing 'command' command, which is used to test compatibility."
      end

      if (true != system("command -v #{cmd} >/dev/null 2>&1"))
        return false
      end

      return true
    end

    private

    def check_system
      %w(play).each do |cmd|
        if (false == cmd_exist?(cmd))
          raise "#{cmd} failed, do you have sox installed?"
        end
      end

      return nil
    end

    def wait_on_user
      while ('q' != @command)
        @command = STDIN.getch

        if ('c' == @command)
          press_pause
        elsif ('v' == @command)
          next_song
        elsif ('z' == @command)
          previous_song
        elsif ('q' == @command) && (false == @pid.nil?)
          stop_song
          @thread.kill
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

    def press_pause
      if (true == playing?)
        kill("STOP")
        @pause_time = Time.now
        @state = PAUSED
      elsif (true == paused?)
        kill("CONT")
        @song_start += (Time.now - @pause_time)
        @pause_time = nil
        @state = PLAYING
      else
        print("Confused state #{@state}.")
      end
    end

    def stop_song
      if (true == paused?)
        kill("CONT")
      end

      kill("INT")

      sleep 0.2

      if (true == pid_alive?)
        kill("KILL")
      end

      @state = STOPPED
      @pid   = nil
    end

    def pid_alive?(pid = @pid)
      if (false == pid.nil?)
        return system("ps -p #{pid} > /dev/null")
      end

      return false
    end

    def next_song
      stop_song

      @playlist.next
    end

    def previous_song
      stop_song

      if (playing_time < 10)
        @playlist.previous
      end
    end

    def kill(signal)
      if (false == @pid.nil?)
        Process.kill(signal, @pid)
      end
    end

    def pause_if_over_time_limit
      if (false == @timer_start.nil?) && (0 < @minutes) && (true == playing?)
        if (0 > minutes_remaining)
          press_pause
          @timer_start = nil
          @minutes    = 0
        end
      end
    end

    def playing_time
      return (Time.now - @song_start).to_i - pause_time
    end

    def pause_time
      if (@pause_time.nil?)
        return 0
      else
        return (Time.now - @pause_time).to_i
      end
    end

    def minutes_remaining
      if ((0 == @minutes) || (@timer_start.nil?))
        return -1
      else
        return (@minutes - ((Time.now - @timer_start).to_i / 60).to_i)
      end
    end
  end
end

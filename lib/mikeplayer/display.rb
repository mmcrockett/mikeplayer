module MikePlayer
  class Display
    PAUSE_INDICATOR = '||'.freeze
    INDICATOR_SIZE  = 4

    RESET           = "\e[0m".freeze
    TITLE_COLOR     = "\e[1;36m".freeze # bold cyan
    DIM_COLOR       = "\e[2m".freeze    # dim gray
    BANNER_COLOR    = "\e[1;37m".freeze # bold white
    ELAPSED_COLOR   = "\e[37m".freeze   # white
    COUNTDOWN_COLOR = "\e[33m".freeze   # yellow
    PLAY_COLOR      = "\e[32m".freeze   # green
    PAUSE_COLOR     = "\e[1;31m".freeze # bold red

    ENTER_ALT_SCREEN = "\e[?1049h\e[2J\e[H".freeze
    EXIT_ALT_SCREEN  = "\e[?1049l".freeze

    def self.colorize(text, color)
      return text unless $stdout.tty?

      "#{color}#{text}#{RESET}"
    end

    def self.enter_fullscreen
      print(ENTER_ALT_SCREEN)
      $stdout.flush
    end

    def self.exit_fullscreen
      print(EXIT_ALT_SCREEN)
      $stdout.flush
    end

    def initialize
      @width     = 0
      @indicator = ''
      @paused    = false
      @changed   = false
      @color     = $stdout.tty?
    end

    def song_info=(v)
      @position = v[:position].freeze
      @title    = v[:title].freeze
    end

    def elapsed=(v)
      @indicator = "#{'>' * (v % INDICATOR_SIZE)}".ljust(INDICATOR_SIZE)
      @paused    = false
      @changed   = true
    end

    def paused
      if (false == @paused)
        @indicator = PAUSE_INDICATOR.ljust(INDICATOR_SIZE)
        @paused    = true
        @changed   = true
      end
    end

    def display!(elapsed_info, countdown = nil)
      return unless changed?

      mindicator = "(#{countdown}↓) " if countdown

      position  = colorize(@position, DIM_COLOR)
      title     = colorize(@title, TITLE_COLOR)
      elapsed   = colorize(elapsed_info, ELAPSED_COLOR)
      indicator = colorize(@indicator, @paused ? PAUSE_COLOR : PLAY_COLOR)
      count     = countdown ? colorize(mindicator, COUNTDOWN_COLOR) : ''

      plain_info = "Playing #{@position}: #{@title} #{elapsed_info} #{mindicator}#{@indicator}"
      info       = "\rPlaying #{position}: #{title} #{elapsed} #{count}#{indicator}"

      print("\r" << ' '.ljust(@width))

      print(info)

      @width   = plain_info.size
      @changed = false

      $stdout.flush
    end

    def changed?
      true == @changed
    end

    private

    def colorize(text, color)
      return text unless @color

      "#{color}#{text}#{RESET}"
    end
  end
end

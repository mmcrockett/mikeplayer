module MikePlayer
  class Display
    PAUSE_INDICATOR = '||'.freeze
    INDICATOR_SIZE  = 4

    RESET           = "\e[0m".freeze
    TITLE_COLOR     = "\e[1;36m".freeze # bold cyan
    COUNTDOWN_COLOR = "\e[33m".freeze   # yellow
    PLAY_COLOR      = "\e[32m".freeze   # green
    PAUSE_COLOR     = "\e[1;31m".freeze # bold red

    def initialize
      @width     = 0
      @indicator = ''
      @paused    = false
      @changed   = false
      @color     = $stdout.tty?
    end

    def song_info=(v)
      @song_info = v.freeze
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

      title     = colorize(@song_info, TITLE_COLOR)
      indicator = colorize(@indicator, @paused ? PAUSE_COLOR : PLAY_COLOR)
      count     = countdown ? colorize(mindicator, COUNTDOWN_COLOR) : ''

      plain_info = "#{@song_info} #{elapsed_info} #{mindicator}#{@indicator}"
      info       = "\r#{title} #{elapsed_info} #{count}#{indicator}"

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

module MikePlayer
  class Display
    PAUSE_INDICATOR = '||'.freeze
    INDICATOR_SIZE  = 4

    def initialize
      @width     = 0
      @indicator = ''
      @changed   = false
    end

    def song_info=(v)
      @info_prefix = "\r#{v}".freeze
    end

    def elapsed=(v)
      @indicator = "#{'>' * (v % INDICATOR_SIZE)}".ljust(INDICATOR_SIZE)
      @changed   = true
    end

    def paused
      if (false == @indicator.include?(PAUSE_INDICATOR))
        @indicator = PAUSE_INDICATOR.ljust(INDICATOR_SIZE)
        @changed   = true
      end
    end

    def display!(elapsed_info, countdown = nil)
      return unless changed?

      mindicator = "(#{countdown}↓) " if countdown

      print("\r" << ' '.ljust(@width))

      info  = "#{@info_prefix} #{elapsed_info} #{mindicator}#{@indicator}"

      print(info)

      @width   = info.size
      @changed = false

      $stdout.flush
    end

    def changed?
      true == @changed
    end
  end
end

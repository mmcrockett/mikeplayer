module MikePlayer
  class Display
    PAUSE_INDICATOR = '||'.freeze
    INDICATOR_SIZE  = 4
    PROGRESS_WIDTH  = 40

    TITLE_ROW = 4
    BAR_ROW   = 5
    HINT_ROW  = 7

    HINT_TEXT = 'c: pause/play   v: next   z: previous   t: set timer   q: quit'.freeze

    RESET           = "\e[0m".freeze
    TITLE_COLOR     = "\e[1;36m".freeze # bold cyan
    DIM_COLOR       = "\e[2m".freeze    # dim gray
    BANNER_COLOR    = "\e[1;37m".freeze # bold white
    ELAPSED_COLOR   = "\e[37m".freeze   # white
    COUNTDOWN_COLOR = "\e[33m".freeze   # yellow
    PLAY_COLOR      = "\e[32m".freeze   # green
    PAUSE_COLOR     = "\e[1;31m".freeze # bold red

    ENTER_ALT_SCREEN = "\e[?1049h\e[2J\e[H\e[?25l".freeze
    EXIT_ALT_SCREEN  = "\e[?25h\e[?1049l".freeze

    PUSH_TITLE = "\e[22;0t".freeze
    POP_TITLE  = "\e[23;0t".freeze

    PLAY_GLYPH  = '▶'.freeze
    PAUSE_GLYPH = '⏸'.freeze

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

    def self.set_title(text)
      return unless $stdout.tty?

      print("\e]0;#{text}\a")
      $stdout.flush
    end

    def self.push_title
      return unless $stdout.tty?

      print(PUSH_TITLE)
      $stdout.flush
    end

    def self.pop_title
      return unless $stdout.tty?

      print(POP_TITLE)
      $stdout.flush
    end

    def initialize(fullscreen: false)
      @width           = 0
      @indicator       = ''
      @paused          = false
      @changed         = false
      @color           = $stdout.tty?
      @fullscreen      = fullscreen
      @elapsed_seconds = 0
      @length          = 0
      @last_title      = nil
    end

    def song_info=(v)
      @position = v[:position].freeze
      @title    = v[:title].freeze
      @length   = v[:length].to_f

      update_terminal_title
    end

    def elapsed=(v)
      @elapsed_seconds = v
      @indicator = "#{'>' * (v % INDICATOR_SIZE)}".ljust(INDICATOR_SIZE)
      @paused    = false
      @changed   = true

      update_terminal_title
    end

    def paused
      if (false == @paused)
        @indicator = PAUSE_INDICATOR.ljust(INDICATOR_SIZE)
        @paused    = true
        @changed   = true

        update_terminal_title
      end
    end

    def display!(elapsed_info, countdown = nil)
      return unless changed?

      if @fullscreen
        display_panel!(elapsed_info, countdown)
      else
        display_line!(elapsed_info, countdown)
      end
    end

    def changed?
      true == @changed
    end

    private

    def display_line!(elapsed_info, countdown)
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

    def display_panel!(elapsed_info, countdown)
      mindicator = "(#{countdown}↓) " if countdown
      count      = countdown ? colorize(mindicator, COUNTDOWN_COLOR) : ''
      state      = colorize(@paused ? 'PAUSED' : 'PLAYING', @paused ? PAUSE_COLOR : PLAY_COLOR)

      move_to(TITLE_ROW)
      print("Playing #{colorize(@position, DIM_COLOR)}: #{colorize(@title, TITLE_COLOR)}")

      move_to(BAR_ROW)
      print("#{progress_bar} #{colorize(elapsed_info, ELAPSED_COLOR)} #{count}#{state}")

      move_to(HINT_ROW)
      print(colorize(HINT_TEXT, DIM_COLOR))

      @changed = false

      $stdout.flush
    end

    def update_terminal_title
      return if @title.nil?

      glyph = @paused ? PAUSE_GLYPH : PLAY_GLYPH
      title = "#{glyph} #{@title} #{@position}"

      return if title == @last_title

      @last_title = title

      Display.set_title(title)
    end

    def move_to(row)
      print("\e[#{row};1H\e[2K")
    end

    def progress_bar
      pct    = @length.positive? ? (@elapsed_seconds.to_f / @length).clamp(0, 1) : 0
      filled = (pct * PROGRESS_WIDTH).round
      bar    = "[#{'#' * filled}#{'-' * (PROGRESS_WIDTH - filled)}]"

      colorize(bar, @paused ? PAUSE_COLOR : PLAY_COLOR)
    end

    def colorize(text, color)
      return text unless @color

      "#{color}#{text}#{RESET}"
    end
  end
end

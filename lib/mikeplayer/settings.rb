module MikePlayer
  class Settings
    DEFAULT_DIRECTORY  = 'Music'.freeze
    DEFAULT_VOLUME     = '0.1'
    SETTINGS_DIRECTORY = '.mikeplayer'.freeze
    PL_FILE_ENDING     = '.mpl'.freeze

    attr_reader :random, :music_dir, :playlist, :volume, :minutes

    def initialize(options)
      @shuffle   = options[:shuffle]
      @overwrite = options[:overwrite]
      @list      = options[:list]
      @home      = options[:home] || Dir.home
      @volume    = options[:volume] || DEFAULT_VOLUME
      @music_dir = options[:directory] || File.join(@home, DEFAULT_DIRECTORY)
      @settings_dir = options[:settings] || File.join(@home, SETTINGS_DIRECTORY)
      @minutes   = options[:minutes].to_i
      @random    = options[:random].to_i

      if (false == Dir.exist?(@settings_dir))
        Dir.mkdir(@settings_dir)
      end

      @playlist  = find_playlist(options[:playlist])

      remove_playlist_if_needed(@playlist)
    end

    def shuffle?
      return true == @shuffle
    end

    def random?
      return 0 < @random
    end

    def overwrite?
      return true == @overwrite
    end

    def list?
      return true == @list
    end

    private

    def find_playlist(user_option)
      name = nil

      if (false == user_option.nil?)
        if (true == File.file?(user_option))
          return user_option
        else
          name = File.basename(user_option, PL_FILE_ENDING)
        end
      elsif (true == self.random?)
        name = "random_n#{@random}"
      else
        name = 'default'
      end

      return File.join(@settings_dir, "#{name}#{PL_FILE_ENDING}")
    end

    def remove_playlist_if_needed(filename)
      if (true == File.file?(filename))
        if ((true == overwrite?) || (true == random?))
          File.delete(filename)
        end
      end
    end
  end
end

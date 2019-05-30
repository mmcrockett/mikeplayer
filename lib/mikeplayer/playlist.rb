module MikePlayer
  class Playlist
    attr_reader :songs

    def initialize(filename)
      @filename = filename
      @songs    = []
      @song_i   = 0
      @length   = 0
    
      load_songs

      @loaded_song_count = @songs.size
    end

    def <<(song)
      if ((true == File.file?(song)) && (false == @songs.any? { |s| s.filename == song }))
        @songs << Song.new(song)
        @length += @songs.last.length
      end

      return self
    end

    def add_random(n, directory)
      files = Dir.glob(File.join(directory, "**", "*.mp3"), File::FNM_CASEFOLD) - @songs

      files.sample(n).each do |file|
        self << file
      end

      return self
    end

    def find_song(file, directory)
      if (true == File.file?(file))
        self << file
      else
        Dir.glob(File.join(directory, "**", "*#{file}*"), File::FNM_CASEFOLD).each do |f|
          self << f
        end
      end

      return self
    end

    def current
      return @songs[@song_i]
    end

    def next
      @song_i += 1

      return self.current
    end

    def previous
      @song_i -= 1

      @song_i = 0 if @song_i < 0

      return self.current
    end

    def shuffle!
      @songs.shuffle!

      return self
    end

    def save
      File.open(@filename, 'w') do |f|
        f.puts(JSON.pretty_generate(@songs.map {|s| s.to_json }))
      end
    end

    def name
      return File.basename(@filename, Settings::PL_FILE_ENDING)
    end

    def info
      return "#{self.name} loaded #{@loaded_song_count} songs with length #{Song.as_duration_str(@length)}, added #{@songs.size - @loaded_song_count}"
    end

    def current_song_info
      song_i_str = "#{@song_i + 1}".rjust(@songs.size.to_s.size)

      return "Playing (#{song_i_str}/#{@songs.size}): #{current.info}".freeze
    end

    def finished?
      return @song_i >= @songs.size
    end

    private

    def load_songs
      if File.file?(@filename)
        JSON.parse(File.read(@filename)).each {|song| self << song}
      end
    end
  end
end

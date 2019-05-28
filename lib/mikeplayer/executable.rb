module MikePlayer
  class PlayThread
    def initialize(filename)
      @filename = filename
      @mp3info  = Mp3Info.new(filename)
    end

    def info
      artist = "#{@mp3info.tag.artist}"
      title  = "#{@mp3info.tag.title}"

      if (true == artist.empty?) && (true == title.empty?)
        return File.basename(filename, '.mp3')
      elsif (true == artist.empty?)
        artist = "?????"
      elsif (true == title.empty?)
        title  = "?????"
      end

      return "#{artist} - #{title}"
    end

    def to_json
      return @filename
    end
  end
end

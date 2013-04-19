require 'RMagick'
require 'video_info'
require 'net/http'

class YouTube
  def initialize identifier
    @id = find_id(identifier)

    @meta = nil
  end

  def title
    parse
    @meta.title
  end

  def href
    "http://www.youtube.com/watch?v=#{@id}"
  end

  def tags(uri)
    parse

    thumbs = get_thumbs.map do |key,thumb|
      uri.path = thumb.uri_path
      [key, %Q{<a href="#{href}"><img src="#{uri}" alt="#{title}"/></a>}]
    end
    Hash[thumbs]
  end

  def valid?
    parse
    not @meta.title.nil?
  end

  def id
    @id
  end

  private
  def find_id identifier
    id_part  = "[a-zA-Z0-9]{4,16}"
    if matches = identifier.match("^#{id_part}$")
      matches[0]
    elsif matches = identifier.match("^http(?:s)?:\/\/(?:www\.)?youtube\.com\/watch\\?v=(#{id_part})")
      matches[1]
    elsif matches = identifier.match("^http(?:s)?:\/\/youtu.be\/(#{id_part})")
      matches[1]
    elsif matches = identifier.match("\<iframe(?:.*)src=\"http://www.youtube.com/embed/(#{id_part}).+")
      matches[1]
    else
      nil
    end
  end

  def parse
    @meta ||= VideoInfo.get(href)
  end

  def get_thumbs
    img = Net::HTTP.get(URI(@meta.thumbnail_large))
    tmpfile = Tempfile.new(["tubemp", ".jpg"])

    thumbs = {}
    begin
      tmpfile.binmode
      tmpfile.write(img)
      tmpfile.close

      thumbs["basic"]   = Thumbnail.new(id, tmpfile).write
      thumbs["overlay"] = Thumbnail.new(id, tmpfile).add_overlay.write(@uri)
    ensure
      images = nil
      tmpfile.unlink
    end
    thumbs
  end
end

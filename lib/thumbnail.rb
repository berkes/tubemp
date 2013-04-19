require "pathname"

class Thumbnail
  def initialize id, tmpfile
    @id = id
    @images = Magick::ImageList.new(tmpfile.path)

    @filename_parts = [@id]
  end

  def images
    @images
  end

  def uri_path
    File.join("/", "thumbs", container_dir, filename)
  end

  def write suffix = nil
    final = @images.shift
    @images.each do |image|
      final = final.composite(image, Magick::CenterGravity, Magick::OverCompositeOp)
    end

    extra_parts = [suffix] unless suffix.nil?
    final.write(root.join(container_dir, filename))
    #it should be easier and cleaner with flatten: however: no idea how to CenterGravity that
    # see http://stackoverflow.com/questions/15724387/how-to-flatten-rmagick-images-and-center-them
    #@images.flatten_images.write(File.join("public", "thumbs", parts.join("_") + ".png"))

    self
  end

  def add_overlay
    @filename_parts << "overlay"

    filename = File.join(File.dirname(__FILE__), "..", "assets","overlay.png")
    @images << Magick::ImageList.new(filename)[0]

    self
  end

  private
  def filename
    @filename_parts.join("_") + ".png"
  end

  def root
    path = Pathname.new(File.join(File.dirname(__FILE__), "public", "thumbs"))

    FileUtils.mkdir_p(path) unless File.exists?(path)

    path
  end

  def container_dir
    dirname = @id.slice(0,2)

    FileUtils.mkdir_p(root.join(dirname)) unless File.exists?(dirname)

    dirname
  end
end

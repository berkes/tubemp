require "spec_helper"
require File.join(File.dirname(__FILE__), "..", "lib", "thumbnail")

describe Thumbnail do

  before do
    @id = "D80QdsFWdcQ"
    @slice = @id.slice(0,2)
    @container = File.join("lib", "public", "thumbs", @slice)
    @filename = File.join(@container, "#{@id}.png")
    @tmpfile    = File.open(File.join(File.dirname(__FILE__), "fixtures", "thumb.jpg"))
    @thumbnail = Thumbnail.new(@id, @tmpfile)
  end

  describe "#write" do
    it 'should create a simple png' do
      @thumbnail.write
      File.should exist(@filename)
    end

    it 'should include overlay filenames in filename' do
      @thumbnail.add_overlay
      @thumbnail.write
      File.should exist(File.join(@container, "#{@id}_overlay.png"))
    end

    it 'should be chainable' do
      @thumbnail.write.should be_kind_of(Thumbnail)
    end

    it 'should overwrite existing files' do
      FileUtils.cp(root_path.join("spec", "fixtures", "thumb.jpg"), @filename)
      existing = File.stat(@filename)
      @thumbnail.write
      existing.should_not eq File.stat(@filename)
    end

    describe 'subdirs' do
      before do
        @container = File.join("lib", "public", "thumbs")
        FileUtils.rm_rf(@container)
      end

      it 'should create the thumbs container dir' do
        @thumbnail.write
        File.should exist(@container)
      end

      it 'to a subdirectory of the first two characters of the id' do
        @thumbnail.write
        File.should exist(File.join(@container, @slice))
      end
    end
  end

  describe "#images" do
    it 'should be an ImageList' do
      @thumbnail.images.should be_kind_of Magick::ImageList
    end
    it 'should include the tmpfile' do
      expected = Magick::ImageList.new(@tmpfile.path)[0]
      @thumbnail.images.should include expected
    end
  end

  describe "#add_overlay" do
    before do
      @overlay_name = File.join("assets", "overlay.png")
      @expected = Magick::ImageList.new(@overlay_name)[0]
      @thumbnail.add_overlay
    end

    it 'should add files to ImageList stack' do
      @thumbnail.images.should include @expected
    end

    it 'should call combine the images to one' do
      Magick::Image.any_instance.should_receive(:composite).once.and_return(@expected)
      @thumbnail.write
    end

    it 'should be chainable' do
      @thumbnail.add_overlay.should be_kind_of(Thumbnail)
    end
  end

  describe "uri_path" do
    it 'should return an absolute path from within "/public".' do
      @thumbnail.uri_path.should eq "/thumbs/#{@slice}/#{@id}.png"
    end
  end
end

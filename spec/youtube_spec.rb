require "spec_helper"
require File.join(File.dirname(__FILE__), "..", "lib", "youtube")
require File.join(File.dirname(__FILE__), "..", "lib", "thumbnail")

IMAGE_RE = /\<img.*src="(.*)".*alt="(.*).*\/\>/
LINK_RE  = /\<a.*href="(.*)".*\>/

describe YouTube do
  context "valid ID" do
    before do
      stub_info
      @id = "D80QdsFWdcQ"
      @yt = YouTube.new @id
      @filename = File.join("public", "thumbs", "#{@id}.png")

      @thumb = mock(Thumbnail)
      @thumb.stub(:uri_path => "/thumbs/#{@id}.png")
      @thumb.stub(:add_overlay).and_return @thumb
      @thumb.stub(:write).and_return @thumb

      @uri = URI("http://example.com")
    end

    describe '#tags' do
      before do
        @tags = @yt.tags(@uri)
        @basic = @tags["basic"]
      end
      it 'should render a list of valid image tags' do
        @tags.each {|key,t| t.should match IMAGE_RE }
      end

      it 'should have an overlayed image' do
        Thumbnail.any_instance.should_receive(:add_overlay).and_return @thumb
        @yt.tags(@uri)
      end

      it 'should link to a thumbnail in PNG format' do
        @basic.match(IMAGE_RE)[1].should match /#{@id}\.png/
      end

      it 'should link to an absolute URL' do
        @basic.match(IMAGE_RE)[1].should match /^http:\/\/.*$/
      end

      it 'should have the title as alt attribute' do
        @basic.match(IMAGE_RE)[2].should match "Tony Tribe , Red Red Wine"
      end

      it 'should have a link pointing to the youtube video' do
        @basic.match(LINK_RE)[1].should match /http:\/\/www\.youtube\.com/
      end
    end

    describe "#title" do
      it "should render a title" do
        @yt.title.should eq "Tony Tribe , Red Red Wine"
      end
    end

    describe "#href" do
      it 'should render a link' do
        @yt.href.should eq "http://www.youtube.com/watch?v=#{@id}"
      end
    end

    describe "#valid?" do
      it 'should return true for a valid youtube-ID' do
        @yt = YouTube.new("D80QdsFWdcQ")
        @yt.should be_valid
      end
    end

    it 'should get the large thumbnail' do
      # re-stub to allow message-expectation
      info = mock("video")
      info.stub(:title)
      info.should_receive(:thumbnail_large).and_return("http://i.ytimg.com/vi/D80QdsFWdcQ/hqdefault.jpg")
      VideoInfo.stub(:get).and_return info
      @yt.tags(@uri)
    end
  end #end valid-ID

  describe "invalid-ID" do
    before do
      info = mock(VideoInfo)
      info.stub(:title).and_return nil
      VideoInfo.stub(:get).and_return info
      @yt = YouTube.new("INVALID")
    end

    describe "#valid?" do
      it 'should return false for an invalid youtube-ID' do
        @yt = YouTube.new("INVALID")
        @yt.should_not be_valid
      end
    end
  end

  describe "liberal IDs" do
    before do
      @id = "D80QdsFWdcQ"
    end

    it "should allow an ID" do
      @yt = YouTube.new(@id)
      @yt.id.should eq @id
    end

    it 'should allow an URL' do
      @yt = YouTube.new("http://www.youtube.com/watch?v=#{@id}")
      @yt.id.should eq @id
    end

    it 'should allow a shortened URL' do
      @yt = YouTube.new("http://youtu.be/#{@id}")
      @yt.id.should eq @id
    end

    it 'should allow an embed-code' do
      @yt = YouTube.new("<iframe src=\"http://www.youtube.com/embed/D80QdsFWdcQ\" frameborder=\"0\" allowfullscreen=\"allowfullscreen\"></iframe>")
      @yt.id.should eq @id
    end
  end
end

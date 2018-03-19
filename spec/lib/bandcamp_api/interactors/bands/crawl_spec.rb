RSpec.describe Bands::Crawl, type: :interactor do
  before do
    stub_request(:get, "http://#{band.guid}.bandcamp.com/")
      .to_return(status: 200, body: '', headers: {})
  end

  let(:interactor) { described_class.new(band, logger: Logger.new(nil)) }
  let(:band) { Fabricate.build(:band) }

  describe '#call' do
    subject { interactor.call }

    it 'crawls band bandcamp profile' do
      expect(interactor).to receive(:parse_page)
      expect(interactor).to receive(:parse_album)

      subject

      expect(WebMock)
        .to have_requested(:get, "http://#{band.guid}.bandcamp.com/")
    end
  end

  describe '#parse_page' do
    subject { interactor.send(:parse_page, page) }

    let(:page) { Nokogiri::HTML('') }

    after { subject }

    it { expect(interactor).to receive(:find_name).with(page) }
    it { expect(interactor).to receive(:find_description).with(page) }
    it { expect(interactor).to receive(:find_location).with(page) }
    it { expect(interactor).to receive(:find_photo_url).with(page) }
  end

  describe '#find_name' do
    subject { interactor.send(:find_name, page) }

    let(:page) do
      Nokogiri::HTML('<div id="band-name-location"><span class="title">Band name</span></div>')
    end

    it { should eq 'Band name' }
  end

  describe '#find_description' do
    subject { interactor.send(:find_description, page) }

    let(:page) do
      Nokogiri::HTML('<div id="bio-text">Band description</div>')
    end

    it { should eq 'Band description' }
  end

  describe '#find_location' do
    subject { interactor.send(:find_location, page) }

    let(:page) do
      Nokogiri::HTML('<div id="band-name-location"><span class="location">Band location</span></div>')
    end

    it { should eq 'Band location' }
  end

  describe '#find_photo_url' do
    subject { interactor.send(:find_photo_url, page) }

    let(:page) do
      Nokogiri::HTML('<img src="http://example.com/photo.jpg" class="band-photo"/>')
    end

    it { should eq 'http://example.com/photo.jpg' }
  end

  describe '#parse_album' do
    subject { interactor.send(:parse_album, page) }

    let(:page) do
      Nokogiri::HTML('<div itemtype="http://schema.org/MusicAlbum"><h2 class="trackTitle">Album name</h2></div>')
    end

    before do
      allow(interactor).to receive(:find_album_id).and_return(1)
      allow(interactor).to receive(:find_album_release_date).and_return('1 Apr 2018')
      allow(interactor).to receive(:add_album)
    end

    after { subject }

    it { expect(interactor).to receive(:find_album_id).with(page) }
  end

  describe '#find_album_id' do
    subject { interactor.send(:find_album_id, page) }

    let(:page) do
      Nokogiri::HTML('<meta property="og:video" content="https://bandcamp.com/EmbeddedPlayer/v=2/album=2093768027/size=large/tracklist=false/artwork=small/"/>')
    end

    it { should eq "2093768027" }
  end

  describe '#find_album_release_date' do
    subject { interactor.send(:find_album_release_date, page) }

    let(:page) do
      Nokogiri::HTML('<meta itemprop="datePublished" content="20130101" />')
    end

    it { should eq Date.parse('20130101') }
  end
end

RSpec.describe Bands::Crawl, type: :interactor do
  before do
    stub_request(:get, "http://#{band.guid}.bandcamp.com/")
      .to_return(status: 200, body: '', headers: {})
  end

  let(:interactor) { described_class.new(band, logger: Logger.new(nil)) }
  let(:band) { Fabricate.create(:band) }

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

    before do
      allow(interactor).to receive(:find_album_release_date).and_return('1 Apr 2018')
      allow(interactor).to receive(:add_album)
    end

    after { subject }

    context 'when album title is present' do
      let(:page) do
        Nokogiri::HTML('<div itemtype="http://schema.org/MusicAlbum"><h2 class="trackTitle">Album name</h2></div>')
      end

      it { expect(interactor).to receive(:find_album_id).with(page) }

      context 'when album_id has been found on the page' do
        before { allow(interactor).to receive(:find_album_id).and_return(1) }

        it 'calls #add_album' do
          expect(interactor).to receive(:add_album)
        end
      end

      context 'when album_id has not been found on the page' do
        before { allow(interactor).to receive(:find_album_id).and_return(nil) }

        it 'does not call #add_album' do
          expect(interactor).to_not receive(:add_album)
        end
      end
    end

    context 'when album title is not present' do
      let(:page) do
        Nokogiri::HTML('<div>wrong album page</div>')
      end

      it { expect(interactor).to_not receive(:find_album_id) }
    end
  end

  describe '#find_album_id' do
    subject { interactor.send(:find_album_id, page) }

    let(:page) do
      Nokogiri::HTML('<script>BandFollow.init({"tralbum_id":2286089655,"tralbum_type":"a"});</script>')
    end

    it { should eq "2286089655" }
  end

  describe '#find_album_release_date' do
    subject { interactor.send(:find_album_release_date, page) }

    let(:page) do
      Nokogiri::HTML('<meta itemprop="datePublished" content="20130101" />')
    end

    it { should eq Date.parse('20130101') }
  end

  describe '#persist_albums' do
    subject { interactor.send(:persist_albums) }

    let(:registered_albums) do
      [
        { uid: 'album1', name: 'Album 1' },
        { uid: 'album2', name: 'Album 2' },
      ]
    end

    before do
      allow(interactor).to receive(:albums).and_return(registered_albums)
    end

    context 'when all albums are new' do
      it { expect { subject }.to change { AlbumRepository.new.count }.by(2) }
    end

    context 'when one of the albums is already present' do
      before do
        AlbumRepository.new.create(
          uid: 'album1', name: 'Album 1', band_id: band.id
        )
      end

      it { expect { subject }.to change { AlbumRepository.new.count }.by(1) }
    end

    context 'when one of the albums is not present anymore' do
      let(:registered_albums) { [] }

      before do
        AlbumRepository.new.create(
          uid: 'album3', name: 'Album 3', band_id: band.id
        )
      end

      it { expect { subject }.to change { AlbumRepository.new.count }.by(-1) }
    end
  end
end

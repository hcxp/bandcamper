require 'hanami/interactor'
require 'hanami/utils/path_prefix'

class Bands::Crawl
  include Hanami::Interactor
  include Hanami::Validations

  IGNORED_PATHS = [
    %r{/track/},
    %r{/feed},
    %r{/gift_cards},
    %r{/contact},
    %r{/help},
  ].freeze

  expose :band, :name, :description, :location, :photo_url

  def initialize(band, logger: Hanami.logger)
    @band = band
    @logger = logger
    @album_repo = AlbumRepository.new
  end

  def call
    @albums = []
    host = URI.parse("https://#{band.guid}.bandcamp.com").host
    logger.info "Scrapping #{host}"

    Spidr.host(host) do |spider|
      spider.every_url do |url|
        spider.skip_link! if IGNORED_PATHS.any? { |r| !(url.path =~ r).nil? }

        logger.debug "Scrap #{url}"
      end

      spider.every_page do |page|
        parse_page(page)
        parse_album(page)
      end
    end

    logger.info
    logger.info "GUID: #{band.guid}"
    logger.info "Name: #{@name}"
    logger.info "Description: #{@description}"
    logger.info "Location: #{@location}"
    logger.info "Photo url: #{@photo_url}"
    # logger.info "Tags: #{tags.join(', ')}"
    logger.info 'Albums:'
    logger.info albums
    logger.info

    persist_albums
  end

  private

  attr_reader :logger, :albums, :band, :album_repo

  # @todo Move that to separate service
  def parse_page(page)
    @name ||= find_name(page)
    @description ||= find_description(page)
    @location ||= find_location(page)
    @photo_url ||= find_photo_url(page)
  end

  # @todo Move that to separate service
  def parse_album(page)
    res = page.search('div[itemtype="http://schema.org/MusicAlbum"] h2.trackTitle')

    if res.first
      album_id = find_album_id(page)
      album_release_date = find_album_release_date(page)

      return false if album_id.nil?

      add_album(
        uid:  album_id,
        name: res.first.text.split.join(' '),
        released_at: album_release_date
      )
    end
  end

  def find_name(page)
    res = page.search('#band-name-location .title')
    res.first ? res.first.text.split.join(' ') : nil
  end

  def find_description(page)
    res = page.search('#bio-text')
    res.first ? res.first.text.split.join(' ') : nil
  end

  def find_location(page)
    res = page.search('#band-name-location .location')
    res.first ? res.first.text.split.join(' ') : nil
  end

  def find_photo_url(page)
    res = page.search('.band-photo')
    res.first ? res.first.attr('src').split.join(' ') : nil
  end

  def find_album_id(page)
    matches = page.to_s.match(/"tralbum_id":(\d+)/)
    matches ? matches[1] : nil
  end

  def find_album_release_date(page)
    res = page.search('//meta[@itemprop="datePublished"]')
              .first
              .attributes['content']
              .value

    Date.parse(res)
  end

  def add_album(opts = {})
    present = albums.any? { |a| a[:uid] == opts[:uid] }

    if present
      logger.debug "Album #{opts[:name]} already registered, skip"
    else
      logger.debug "Registering album #{opts[:name]}"
      @albums << opts
    end
  end

  def persist_albums
    uids = albums.map {|a| a[:uid] }
    logger.debug "Registered album ids: #{uids}"

    existing = BandRepository.new.find_with_albums(band.id).albums
    existing_uids = existing.map(&:uid)
    logger.debug "Existing album uids: #{existing_uids}"

    new_uids = uids - existing_uids
    new_albums = albums.select { |a| new_uids.include? a[:uid] }
    logger.debug "New album uids: #{new_uids}"

    to_delete_uids = existing_uids - uids
    logger.debug "Albums to delete: #{to_delete_uids}"

    album_repo.delete_by_uids(to_delete_uids)
    album_repo.create(new_albums.each { |h| h[:band_id] = band.id })
  end
end

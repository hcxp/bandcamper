require 'hanami/interactor'
require 'hanami/utils/path_prefix'

class Bands::FindOrCreateByUrls
  include Hanami::Interactor
  include Hanami::Validations

  expose :urls, :guids, :existing_guids, :new_guids, :bands

  # validations do
  #   required(:urls) { filled? & array? }
  # end

  def initialize(urls: [], logger: Hanami.logger)
    @urls = urls
    @logger = logger
  end

  def call
    logger.debug "URLs passed: #{@urls}"

    # Create an array of guids to look for based on given urls.
    @guids = @urls.map { |l| guid_from_link(l) }
    logger.debug "GUIDs to add: #{@guids}"

    # Find if any of the given GUIDs exists in the database.
    existing = BandRepository.new.find_by_guids(@guids).call
    logger.debug "Existing GUIDs: #{existing.map(&:guid)}"

    # Check which ones does not exist and create a new array with ones to be
    # added.
    @existing_guids = existing.map(&:guid)
    @new_guids = @guids - @existing_guids
    logger.debug "GUIDs to add: #{@new_guids}"
    new_bands = BandRepository.new.create_many_by_guids(@new_guids)

    crawl_new_bands(new_bands)

    # Return all the bands having a guid specified in interactor payload. This
    # will return both existing and ones created by this interactor.
    @bands = BandRepository.new.find_by_guids(@guids).call
  end

  private

  attr_reader :logger

  def guid_from_link(link)
    host = URI.parse(link).host || link
    host = host.gsub('www.', '')

    host.split('.').first
  end

  def crawl_new_bands(bands)
    return unless bands

    bands.each do |band|
      logger.debug "Setting crawler for #{band.guid}"
      BandCrawlWorker.perform_async(band.id)
    end
  end
end

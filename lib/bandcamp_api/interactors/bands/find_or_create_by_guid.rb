require 'hanami/interactor'
require 'hanami/utils/path_prefix'

class Bands::FindOrCreateByGuid
  include Hanami::Interactor
  include Hanami::Validations

  expose :guid, :band

  # validations do
  #   required(:urls) { filled? & array? }
  # end

  def initialize(guid, logger: Hanami.logger)
    @guid = guid
    @logger = logger
  end

  def call
    logger.debug "GUID passed: #{@guid}"
    @band = BandRepository.new.find_or_create_by_guid(@guid)

    crawl_band
  end

  private

  attr_reader :logger

  def band_repo
    @band_repo ||= BandRepository.new
  end

  def crawl_band
    return unless @band
    return unless can_crawl_band?

    BandCrawlWorker.perform_async(@band.id)
  end

  def can_crawl_band?
    now = Time.now.freeze
    return true if @band.queued_at.nil?

    ((now - @band.queued_at) / 3600).round > 5
  end
end

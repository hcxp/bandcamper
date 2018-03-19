class BandCrawlWorker
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: :bandcamp

  sidekiq_throttle(
    # One concurrent job
    concurrency: { limit: 1 },

    # Just one job per 2 minutes
    threshold: { limit: 1, period: 120 }
  )

  def self.perform_async(band_id)
    band = BandRepository.new.find(band_id)
    Bands::UpdateState.new(band, :queued).call

    super
  end

  def perform(band_id)
    @band = band_repo.find(band_id)
    update_band_state(:crawling)

    state = nil
    result = true

    begin
      serv = Bands::Crawl.new(band).call
    rescue => e
      state = :failed
      result = false
    else
      state = :crawled
      persist_band(serv)
    ensure
      update_band_state(state)
    end

    result
  end

  private

  attr_reader :band, :band_repo

  def band_repo
    @band_repo ||= BandRepository.new
  end

  def update_band_state(state)
    Bands::UpdateState.new(band, state, repo: band_repo).call
  end

  def persist_band(serv)
    band_repo.update(
      band.id,
      name: serv.name,
      description: serv.description,
      location: serv.location,
      photo_url: serv.photo_url,
    )
  end
end

require 'hanami/interactor'
require 'hanami/utils/path_prefix'

class Bands::UpdateState
  include Hanami::Interactor
  include Hanami::Validations

  expose :band

  # validations do
  #   required(:urls) { filled? & array? }
  # end

  def initialize(band, state, repo: BandRepository.new)
    @band = band
    @state = state.to_s
    @repo = repo
  end

  def call
    @band = @repo.update(@band.id, state: @state)
  end
end

module Api::Controllers::Bands
  class ByGuid
    include Api::Action
    include JSONAPI::Hanami::Action

    def call(params)
      serv = Bands::FindOrCreateByGuid.new(params[:guid]).call
      band = BandRepository.new.find_with_albums(serv.band.id)

      self.data = band
      self.include = [:albums]
      self.status = 201
    end
  end
end

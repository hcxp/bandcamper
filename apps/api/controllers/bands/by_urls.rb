module Api::Controllers::Bands
  class ByUrls
    include Api::Action
    include JSONAPI::Hanami::Action

    def call(params)
      serv = Bands::FindOrCreateByUrls.new(urls: params[:urls]).call

      self.data = serv.bands
      self.status = 201
    end
  end
end

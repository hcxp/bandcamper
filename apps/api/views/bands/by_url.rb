module Api::Views::Bands
  class ByUrl
    include Api::View

    def render
      "name: #{band.name}"
    end
  end
end

class SerializableAlbum < JSONAPI::Serializable::Resource
  type 'albums'

  attributes :id, :uid, :name

  attribute :released_at do
    @object.released_at.iso8601
  end

  attribute :created_at do
    @object.created_at.iso8601
  end

  attribute :updated_at do
    @object.updated_at.iso8601
  end

  has_one :band
end

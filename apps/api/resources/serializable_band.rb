class SerializableBand < JSONAPI::Serializable::Resource
  type 'bands'

  attributes :id, :guid, :name, :bio, :state

  attribute :queued_at do
    @object.queued_at&.iso8601
  end

  attribute :created_at do
    @object.created_at&.iso8601
  end

  attribute :updated_at do
    @object.updated_at&.iso8601
  end

  has_many :albums
end

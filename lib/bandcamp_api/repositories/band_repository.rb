class BandRepository < Hanami::Repository
  def all_by_guids(guids)
    bands
      .where(guid: guids)
  end

  def find_by_guid(guid)
    find_by_guids([guid])
      .first
  end

  def find_by_guids(guids)
    bands
      .where(guid: guids)
  end

  def find_or_initialize_by_guid(guid)
    existing = find_by_guid(guid)

    existing ? existing : Band.new(guid: guid)
  end

  def find_or_create_by_guid(guid)
    existing = find_by_guid(guid)

    existing || create(guid: guid)
  end

  def create_many_by_guids(guids)
    records = guids.each_with_object({}) do |guid, hash|
      hash[:guid] = guid
      hash[:created_at] = DateTime.now
      hash[:updated_at] = DateTime.now
    end

    command(:create, bands, result: :many).call(records) if records.any?
  end
end

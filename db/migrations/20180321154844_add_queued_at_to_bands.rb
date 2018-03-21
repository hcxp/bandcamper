Hanami::Model.migration do
  change do
    add_column :bands, :queued_at, DateTime
  end
end

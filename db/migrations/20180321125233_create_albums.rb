Hanami::Model.migration do
  change do
    create_table :albums do
      primary_key :id
      foreign_key :band_id, :bands, on_delete: :cascade, null: false

      column :name, String
      column :uid, String, null: false, unique: true
      column :released_at, DateTime

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end

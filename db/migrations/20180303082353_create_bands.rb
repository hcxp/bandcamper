Hanami::Model.migration do
  change do
    create_table :bands do
      primary_key :id

      column :name, String
      column :bio, String, size: 65535
      column :guid, String, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end

Hanami::Model.migration do
  change do
    add_column :bands, :state, String, null: false, default: 'new'
  end
end

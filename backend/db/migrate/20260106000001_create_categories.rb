class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    create_table :categories, id: :uuid do |t|
      t.string :name, null: false
      t.string :display_name, null: false
      t.uuid :parent_id
      t.integer :sort_order, default: 0

      t.timestamps
    end

    add_index :categories, :name, unique: true
    add_index :categories, :parent_id
    add_foreign_key :categories, :categories, column: :parent_id
  end
end

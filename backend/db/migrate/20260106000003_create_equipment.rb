class CreateEquipment < ActiveRecord::Migration[8.0]
  def change
    create_table :equipment, id: :uuid do |t|
      t.references :category, type: :uuid, null: false, foreign_key: true
      t.references :brand, type: :uuid, null: false, foreign_key: true
      t.string :model, null: false
      t.string :slug, null: false
      t.integer :release_year
      t.integer :msrp_jpy
      t.string :status, default: "active"
      t.jsonb :specs, default: {}
      t.jsonb :images, default: []
      t.text :description
      t.text :features, array: true, default: []

      t.timestamps
    end

    add_index :equipment, :slug, unique: true
    add_index :equipment, [:brand_id, :model], unique: true
    add_index :equipment, :status
    add_index :equipment, :specs, using: :gin
  end
end

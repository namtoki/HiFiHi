class CreateCompatibilities < ActiveRecord::Migration[8.0]
  def change
    create_table :compatibilities, id: :uuid do |t|
      t.uuid :equipment_a_id, null: false
      t.uuid :equipment_b_id, null: false
      t.integer :compatibility_score, null: false
      t.jsonb :compatibility_details, default: {}
      t.string :source, null: false
      t.string :source_url
      t.uuid :user_id

      t.timestamps
    end

    add_foreign_key :compatibilities, :equipment, column: :equipment_a_id
    add_foreign_key :compatibilities, :equipment, column: :equipment_b_id

    add_index :compatibilities, [:equipment_a_id, :equipment_b_id], unique: true
    add_index :compatibilities, :equipment_a_id
    add_index :compatibilities, :equipment_b_id
  end
end

class Compatibility < ApplicationRecord
  belongs_to :equipment_a, class_name: "Equipment"
  belongs_to :equipment_b, class_name: "Equipment"

  validates :compatibility_score, presence: true, inclusion: { in: 1..5 }
  validates :source, presence: true, inclusion: { in: %w[official user article calculated] }
  validates :equipment_a_id, uniqueness: { scope: :equipment_b_id }

  validate :different_equipment

  scope :for_equipment, ->(equipment_id) {
    where("equipment_a_id = :id OR equipment_b_id = :id", id: equipment_id)
  }

  def other_equipment(equipment)
    equipment_a_id == equipment.id ? equipment_b : equipment_a
  end

  private

  def different_equipment
    if equipment_a_id == equipment_b_id
      errors.add(:base, "Cannot have compatibility with itself")
    end
  end
end

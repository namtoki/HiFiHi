class Equipment < ApplicationRecord
  self.table_name = "equipment"

  belongs_to :category
  belongs_to :brand

  has_many :compatibilities_as_a, class_name: "Compatibility", foreign_key: :equipment_a_id, dependent: :destroy
  has_many :compatibilities_as_b, class_name: "Compatibility", foreign_key: :equipment_b_id, dependent: :destroy

  validates :model, presence: true, uniqueness: { scope: :brand_id }
  validates :slug, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[active discontinued upcoming] }

  scope :active, -> { where(status: "active") }
  scope :by_category, ->(category_id) { where(category_id: category_id) if category_id.present? }
  scope :by_brand, ->(brand_id) { where(brand_id: brand_id) if brand_id.present? }
  scope :search, ->(query) {
    return all if query.blank?
    joins(:brand).where(
      "equipment.model ILIKE :q OR brands.name ILIKE :q OR equipment.description ILIKE :q",
      q: "%#{query}%"
    )
  }

  def to_param
    slug
  end

  def compatible_equipment
    Equipment.joins(
      "INNER JOIN compatibility ON (compatibility.equipment_a_id = equipment.id OR compatibility.equipment_b_id = equipment.id)"
    ).where(
      "(compatibility.equipment_a_id = :id OR compatibility.equipment_b_id = :id) AND equipment.id != :id",
      id: id
    ).distinct
  end

  def compatibilities
    Compatibility.where("equipment_a_id = :id OR equipment_b_id = :id", id: id)
  end
end

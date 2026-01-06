class Category < ApplicationRecord
  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: :parent_id, dependent: :nullify
  has_many :equipment, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :display_name, presence: true

  default_scope { order(:sort_order, :name) }
end

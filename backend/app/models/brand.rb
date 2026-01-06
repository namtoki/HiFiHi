class Brand < ApplicationRecord
  has_many :equipment, dependent: :restrict_with_error

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  default_scope { order(:name) }

  def to_param
    slug
  end
end

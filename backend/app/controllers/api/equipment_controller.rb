module Api
  class EquipmentController < ApplicationController
    def index
      equipment = Equipment.includes(:brand, :category)
                           .by_category(params[:categoryId])
                           .by_brand(params[:brandId])
                           .search(params[:search])

      equipment = equipment.where(status: params[:status]) if params[:status].present?

      page = (params[:page] || 1).to_i
      limit = [[params[:limit].to_i, 100].min, 1].max
      limit = 20 if params[:limit].blank?

      paginated = equipment.page(page).per(limit)

      render json: {
        data: paginated.map { |e| equipment_json(e) },
        pagination: pagination_meta(paginated)
      }
    end

    def show
      equipment = Equipment.includes(:brand, :category).find_by!(slug: params[:slug])

      render json: equipment_json(equipment)
    end

    def compatibility
      equipment = Equipment.find_by!(slug: params[:slug])
      compatibilities = equipment.compatibilities.includes(
        equipment_a: [:brand, :category],
        equipment_b: [:brand, :category]
      )

      render json: compatibilities.map { |c| compatibility_json(c, equipment) }
    end

    private

    def equipment_json(equipment)
      {
        id: equipment.id,
        categoryId: equipment.category_id,
        brandId: equipment.brand_id,
        model: equipment.model,
        slug: equipment.slug,
        releaseYear: equipment.release_year,
        msrpJpy: equipment.msrp_jpy,
        status: equipment.status,
        specs: equipment.specs,
        images: equipment.images,
        description: equipment.description,
        features: equipment.features,
        brand: {
          name: equipment.brand.name,
          slug: equipment.brand.slug,
          country: equipment.brand.country
        },
        category: {
          name: equipment.category.name,
          displayName: equipment.category.display_name
        }
      }
    end

    def compatibility_json(compatibility, equipment)
      other = compatibility.other_equipment(equipment)

      {
        id: compatibility.id,
        equipmentAId: compatibility.equipment_a_id,
        equipmentBId: compatibility.equipment_b_id,
        compatibilityScore: compatibility.compatibility_score,
        compatibilityDetails: compatibility.compatibility_details,
        source: compatibility.source,
        sourceUrl: compatibility.source_url,
        otherEquipment: {
          slug: other.slug,
          model: other.model,
          brandName: other.brand.name,
          categoryName: other.category.name
        }
      }
    end
  end
end

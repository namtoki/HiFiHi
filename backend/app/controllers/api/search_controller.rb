module Api
  class SearchController < ApplicationController
    def index
      query = params[:q]

      if query.blank? || query.length < 2
        render json: { error: "Search query must be at least 2 characters" }, status: :bad_request
        return
      end

      results = Equipment.includes(:brand, :category)
                         .search(query)
                         .limit(20)

      render json: results.map { |e| search_result_json(e) }
    end

    private

    def search_result_json(equipment)
      {
        id: equipment.id,
        model: equipment.model,
        slug: equipment.slug,
        msrpJpy: equipment.msrp_jpy,
        images: equipment.images,
        brand: {
          name: equipment.brand.name,
          slug: equipment.brand.slug
        },
        category: {
          name: equipment.category.name,
          displayName: equipment.category.display_name
        }
      }
    end
  end
end

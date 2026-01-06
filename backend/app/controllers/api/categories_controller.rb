module Api
  class CategoriesController < ApplicationController
    def index
      categories = Category.all

      render json: categories.map { |c| category_json(c) }
    end

    private

    def category_json(category)
      {
        id: category.id,
        name: category.name,
        displayName: category.display_name,
        parentId: category.parent_id,
        sortOrder: category.sort_order
      }
    end
  end
end

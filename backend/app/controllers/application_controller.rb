class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def not_found
    render json: { error: "Not found" }, status: :not_found
  end

  def pagination_meta(collection)
    {
      page: collection.current_page,
      limit: collection.limit_value,
      total: collection.total_count,
      total_pages: collection.total_pages
    }
  end
end

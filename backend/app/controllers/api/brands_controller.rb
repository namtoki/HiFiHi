module Api
  class BrandsController < ApplicationController
    def index
      brands = Brand.all

      render json: brands.map { |b| brand_json(b) }
    end

    def show
      brand = Brand.find_by!(slug: params[:slug])

      render json: brand_json(brand)
    end

    private

    def brand_json(brand)
      {
        id: brand.id,
        name: brand.name,
        slug: brand.slug,
        country: brand.country,
        websiteUrl: brand.website_url,
        logoUrl: brand.logo_url,
        description: brand.description
      }
    end
  end
end

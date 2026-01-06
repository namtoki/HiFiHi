Rails.application.routes.draw do
  namespace :api do
    resources :categories, only: [:index]
    resources :brands, only: [:index, :show], param: :slug
    resources :equipment, only: [:index, :show], param: :slug do
      member do
        get :compatibility
      end
    end
    get "search", to: "search#index"
  end

  get "up", to: "rails/health#show", as: :rails_health_check
end

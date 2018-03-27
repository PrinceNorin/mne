Rails.application.routes.draw do
  devise_for :users

  root 'home#index'

  scope :api do
    resources :licenses do
      resources :statements
    end
  end

  match '*path', to: 'home#index', via: :all
end

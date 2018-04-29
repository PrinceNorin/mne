Rails.application.routes.draw do
  devise_for :users

  root 'home#index'
  get '/search' => 'search#index'

  resources :licenses do
    resources :statements, except: [:index, :show]
  end

  # scope :api do
  #   resources :licenses do
  #     resources :statements
  #   end
  # end

  # match '*path', to: 'home#index', via: :all
end

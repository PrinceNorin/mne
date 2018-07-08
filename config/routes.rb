Rails.application.routes.draw do
  devise_for :users

  root 'home#index'
  get '/search' => 'search#index'
  get '/download' => 'search#download'
  get '/plan_download' => 'search#plan_download'

  resources :licenses do
    resources :taxes, only: [:new, :create, :destroy]
    resources :statements, except: [:index, :show]
    resource :business_plan, only: [:show, :create, :update]
  end

  resources :taxes, only: [:index]
  resources :companies, only: [:index, :show]

  # scope :api do
  #   resources :licenses do
  #     resources :statements
  #   end
  # end

  # match '*path', to: 'home#index', via: :all
end

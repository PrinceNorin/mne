Rails.application.routes.draw do
  devise_for :users

  root 'home#index'
  get '/search' => 'search#index'

  resources :licenses, except: :destroy do
    resources :statements, except: [:index, :show]
    resource :business_plan, only: [:show, :create, :update]
  end

  # scope :api do
  #   resources :licenses do
  #     resources :statements
  #   end
  # end

  # match '*path', to: 'home#index', via: :all
end

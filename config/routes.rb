Rails.application.routes.draw do

  get 'welcome/index'

  resources :carts do
    resources :checkouts
  end

  root 'welcome#index'

end

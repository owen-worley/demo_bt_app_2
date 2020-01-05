Rails.application.routes.draw do

  get 'welcome/index'

#nest checkouts inside carts do/end to nest the routes
  resources :carts do
    resources :checkouts
  end

  root 'welcome#index'

end

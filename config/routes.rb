Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#home"
    get "/static_pages/home"
    get "/static_pages/help"
    get "/static_pages/contact"

    get "/categories/index"
    get "/categories/show"

    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    
    get "/search", to: "search#index"

    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    resources :users do
      resources :addresses, except: :show
    end
    resources :categories do
      resources :products
    end
    resources :carts, only: :show do
      post 'add_item', on: :collection
      member do
        post 'increment_item'
        post 'decrement_item'
        delete 'remove_item'
      end
    end
    resources :products, only: %i(show index)
    resources :password_resets, only: %i(new create edit update)
  end
end

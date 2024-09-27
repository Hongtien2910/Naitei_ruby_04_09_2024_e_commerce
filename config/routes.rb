Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    root "home#index"
  end
end

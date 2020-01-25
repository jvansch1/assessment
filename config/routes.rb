Rails.application.routes.draw do
  resources :posts, only: [:index]
  get 'posts/fetch', :to => 'posts#fetch'
  get 'api/ping', :to => "api/pings#ping"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

Rails.application.routes.draw do
  namespace :admin do
    resources :exports, :only => [ :new ]
  end
end

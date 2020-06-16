Rails.application.routes.draw do
  
  
  root 'static_pages#home'
  
  get     '/help',    to: 'static_pages#help'
  get     '/about',   to: 'static_pages#about'
  get     '/contact', to: 'static_pages#contact'
  get     '/signup',  to: 'users#new'
  get     '/login',   to: 'sessions#new'
  post    '/login',   to: 'sessions#create'
  delete  '/logout',  to: 'sessions#destroy'
  resources :users    # needs show action at least
  #For Resources I need to look onto the RESTfull Routes Table to see all generated routes!
  resources :account_activations, only: [:edit]
end

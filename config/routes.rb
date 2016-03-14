Rails.application.routes.draw do
  mount Payola::Engine => '/payola', as: :payola
  namespace :admin do
    resources :dashboard, only: [:index]
    namespace :billing do
      resources :subscriptions do
        resources :card
      end
    end
    resources :contacts, except: :edit
    resources :schedules, except: :edit
    get "contacts/:id/clone", to: "contacts#clone", as: "contacts_clone"
    get "schedules/:id/clone", to: "schedules#clone", as: "schedules_clone"
    get "billing", to: "billing#index", as: "billing_index"
  end

  devise_for :users, controllers: { registrations: 'users/registrations', passwords: 'users/passwords', :sessions => :sessions, :confirmations => :confirmations }

  devise_scope :user do
    match '/users/sign_in' => "devise/sessions#new", as: :login, via: :get
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  get '/admin', to: redirect('/admin/dashboard')

  delete '/admin/billing' => 'admin/billing#cancel_subscription'


  # get 'admin/dashboard' => 'dashboard#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

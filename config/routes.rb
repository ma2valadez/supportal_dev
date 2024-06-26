Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'sessions/new'
  get 'users/new'

  root                                            "static_pages#home"

  get    "/help",                                 to: "static_pages#help"
  get    "/about",                                to: "static_pages#about"
  get    "/contact",                              to: "static_pages#contact"
  get    "/signup",                               to: "users#new"
  get    "/login",                                to: "sessions#new"

  get    "/welcome",                              to: "protected_pages#show"
  get    "/scripts/dynamic",                      to: "protected_pages#dynamic"
  get    "/scripts/firstup",                      to: "protected_pages#firstup"
  
  get    "scripts/dynamic/get_users",             to: "protected_pages#get_users"
  get    "scripts/dynamic/download_users",        to: "protected_pages#download_users"
  get    "download_complete",                     to: "protected_pages#download_complete", as: "download_complete"

  get    "scripts/dynamic/suspend_users",         to: "protected_pages#suspend_users"
  post   "scripts/dynamic/suspend_users",         to: "suspend_users#upload", as: "suspend_upload"

  get    "scripts/firstup/get_users",             to: "protected_pages#get_firstup_users"
  get    "scripts/firstup/download_users",        to: "protected_pages#firstup_download_users"
  get    "firstup_download_complete",             to: "protected_pages#firstup_download_complete", as: "firstup_download_complete"

  post   "/login",                                to: "sessions#create"
  delete "/logout",                               to: "sessions#destroy"
  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
end

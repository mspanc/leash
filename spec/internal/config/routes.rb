Rails.application.routes.draw do
  leash_provider

  devise_for :admins
end

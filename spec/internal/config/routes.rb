Rails.application.routes.draw do
  leash

  devise_for :admins
end

Rails.application.routes.draw do

  namespace :v1 do
    resources :events, only: [:index, :show]
  end

end


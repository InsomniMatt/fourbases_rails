Rails.application.routes.draw do
  resources :players, only: [:index] do
    get 'stats', to: 'players#stats'
    get 'rolling_stats', to: 'players#rolling_stats'
  end

  resource :players, only: [] do
    get 'search', to: 'players#search'
  end

end

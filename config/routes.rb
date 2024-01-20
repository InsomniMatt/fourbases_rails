Rails.application.routes.draw do
  resources :players, only: [:index] do
    get 'stats', to: 'players#stats'
    get 'rolling_stats', to: 'players#rolling_stats'
    get 'compare_to_baseline', to: 'players#compare_to_baseline'
  end

  resource :players, only: [] do
    get 'search', to: 'players#search'
  end

  resources :teams, only: [] do
    get 'stats', to: "teams#stats"
  end

end

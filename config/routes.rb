Rails.application.routes.draw do
  get 'build_charts', action: :build_charts, controller: :players
  root to: 'players#trends'
end

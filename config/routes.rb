Mogade::Application.routes.draw do  
  namespace 'api' do
    resources :scores, :only => [:create]
  end
  
  match '/:controller(/:action(/:id))'
  root :to => 'home#index'
end
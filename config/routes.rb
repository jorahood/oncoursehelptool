ActionController::Routing::Routes.draw do |map|
  map.connect '', :controller => 'helptool', :action => 'index'
  map.connect ':controller/search', :action=> 'search', :format=> 'html'
  map.connect ':controller/live_search', :action=> 'search', :format=> 'xml'
  map.connect ':controller/:action/:docid'
  map.connect ':controller/:action/:id'
end

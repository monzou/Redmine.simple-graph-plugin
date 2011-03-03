require 'redmine'

Redmine::Plugin.register :redmine_simple_graphs do
  
  name 'Redmine Simple Graphs plugin'
  author '@monzou'
  description 'This is a simple graph plugin for Redmine'
  version '0.1.0'
  
  permission :simple_graphs, { :simple_graphs => [:index] }, :public => true
  menu :project_menu, :simple_graphs, { :controller => 'simple_graphs', :action => 'index' }, :caption => :simple_graphs, :last => true, :param => :project_id
  
end

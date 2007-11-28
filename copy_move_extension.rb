require_dependency 'application'

class CopyMoveExtension < Radiant::Extension
  version "1.8.4"
  description "Adds the ability to copy and move a page and all its children"
  url "http://darcs.bigchieflabs.com/radiant/extensions/copy_move/rdoc/"
    
  define_routes do |map|
    map.page_copy_move  'admin/pages/copy_move/:id', :controller => 'admin/page', :action => 'copy_move'
  end
  
  def activate
    Admin::PageController.class_eval %{ include CopyMovePageControllerExtensions }
  end
  
  def deactivate
  end
  
end

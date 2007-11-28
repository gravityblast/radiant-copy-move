require_dependency 'application'

class CopyMoveExtension < Radiant::Extension
  version "1.8.4"
  description "Adds the ability to copy and move a page and all of its children"
  url "http://gravityblast.com/projects/radiant-page-utilities/"
    
  define_routes do |map|
    map.page_copy_move  'admin/pages/copy_move/:id', :controller => 'admin/page', :action => 'copy_move'
  end
  
  def activate
    raise "The Shards extension is required and must be loaded first!" unless defined?(Shards)
    Admin::PageController.class_eval %{ include CopyMovePageControllerExtensions }
    admin.page.index.add :node, 'copy_move_extra_td', :after => "add_child_column"
  end
  
  def deactivate
  end
  
end

require_dependency 'application'

class CopyMoveExtension < Radiant::Extension
  version "1.9.1"
  description "Adds the ability to copy and move a page and all of its children"
  url "http://gravityblast.com/projects/radiant-copymove-extension/"
    
  define_routes do |map|
    map.copy_move_index       'admin/pages/copy_move/:id',            :controller => 'copy_move', :action => 'index'
    map.copy_move_copy_move   'admin/pages/copy_move/:id/copy_move',  :controller => 'copy_move', :action => 'copy_move'
  end
  
  def activate
#    raise "The Shards extension is required and must be loaded first!" unless defined?(Shards)
    admin.page.index.add :sitemap_head, 'copy_move_extra_th'
    admin.page.index.add :node, 'copy_move_extra_td', :after => "add_child_column"
  end
  
  def deactivate
  end
  
end

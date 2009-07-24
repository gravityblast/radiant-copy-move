require_dependency 'application_controller'

class CopyMoveExtension < Radiant::Extension
  version "2.0.0"
  description "Adds the ability to copy and move a page and all of its children"
  url "http://gravityblast.com/projects/radiant-copymove-extension/"

  define_routes do |map|
    map.with_options(:controller => "admin/pages") do |cm|
      cm.copy_page_admin_page     '/admin/pages/:id/copy_page',     :action => 'copy_page'
      cm.copy_children_admin_page '/admin/pages/:id/copy_children', :action => 'copy_children'
      cm.copy_tree_admin_page     '/admin/pages/:id/copy_tree',     :action => 'copy_tree'
      cm.move_admin_page          '/admin/pages/:id/move',          :action => 'move'
    end
  end

  def activate
    Admin::PagesController.class_eval do
      include CopyMove::Controller
      helper :copy_move
    end
    Page.class_eval { include CopyMove::Model }
    admin.page.index.add :sitemap_head, 'copy_move_extra_th'
    admin.page.index.add :node, 'copy_move_extra_td', :after => "add_child_column"
    admin.page.index.add :bottom, 'copy_move_popup'
  end
end

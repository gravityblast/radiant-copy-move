module CopyMove
  module Controller
    def self.included(base)
      base.class_eval do
        before_filter do |c|
          c.include_stylesheet 'admin/copy_move'
        end
        before_filter :load_page, :only => [:copy_page, :copy_children, :copy_tree, :move]
        before_filter :load_parent, :only => [:copy_page, :copy_children, :copy_tree, :move]
      end
    end

    def copy_page
      @new_page = @page.copy_to(@parent, params[:status_id])
      flash[:notice] = "A copy of <strong>#{@page.title}</strong> was created under <strong>#{@parent.title}</strong>."
      redirect_to admin_pages_url
    end

    def copy_children
      @new_page = @page.copy_with_children_to(@parent, params[:status_id])
      flash[:notice] = "Copies of <strong>#{@page.title}</strong> and its immediate children were created under <strong>#{@parent.title}</strong>."
      redirect_to admin_pages_url
    end

    def copy_tree
      @new_page = @page.copy_tree_to(@parent, params[:status_id])
      flash[:notice] = "Copies of <strong>#{@page.title}</strong> and all its descendants were created under <strong>#{@parent.title}</strong>."
      redirect_to admin_pages_url
    end

    def move
      @page.move_under(@parent)
      flash[:notice] = "Page <strong>#{@page.title}</strong> and all its descendants were moved under <strong>#{@parent.title}</strong>."
      redirect_to admin_pages_url
    rescue CopyMove::CircularHierarchy => e
      flash[:error] = e.message
      redirect_to admin_pages_url
    end
    
    private
    def load_parent
      @parent = Page.find(params[:parent_id])
    end
    
    def load_page
      self.model = @page = Page.find(params[:id])
    end
  end
end
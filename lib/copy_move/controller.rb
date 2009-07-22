module CopyMove
  module Controller
    def self.included(base)
      base.class_eval do
        before_filter do |c|
          c.include_stylesheet 'admin/copy_move'
        end
        before_filter :load_model, :only => [:copy, :copy_children, :copy_tree, :move]
        before_filter :load_parent, :only => [:copy, :copy_children, :copy_tree, :move]
      end
    end

    def copy
      @new_page = @page.copy_to(@parent)
      respond_to do |wants|
        wants.html do
          flash[:notice] = "A copy of <strong>#{@page.title}</strong> was created under <strong>#{@parent.title}</strong>."
          redirect_to admin_pages_url
        end
        wants.xml do
          render :xml => @new_page, :status => :created, :location => admin_page_url(@new_page, :format => params[:format])
        end
        wants.json do
          render :json => @new_page, :status => :created, :location => admin_page_url(@new_page, :format => params[:format])
        end
      end
    end

    def copy_children
      @new_page = @page.copy_with_children_to(@parent)
      respond_to do |wants|
        wants.html do
          flash[:notice] = "Copies of <strong>#{@page.title}</strong> and its immediate children were created under <strong>#{@parent.title}</strong>."
          redirect_to admin_pages_url
        end
        wants.xml do
          render :xml => @new_page, :status => :created, :location => admin_page_url(@new_page, :format => params[:format])
        end
        wants.json do
          render :json => @new_page, :status => :created, :location => admin_page_url(@new_page, :format => params[:format])
        end
      end
    end

    def copy_tree
      @new_page = @page.copy_tree_to(@parent)
      respond_to do |wants|
        wants.html do
          flash[:notice] = "Copies of <strong>#{@page.title}</strong> and all its descendants were created under <strong>#{@parent.title}</strong>."
          redirect_to admin_pages_url
        end
        wants.xml do
          render :xml => @new_page, :status => :created, :location => admin_page_url(@new_page, :format => params[:format])
        end
        wants.json do
          render :json => @new_page, :status => :created, :location => admin_page_url(@new_page, :format => params[:format])
        end
      end
    end

    def move
      @page.move_under(@parent)
      respond_to do |wants|
        wants.html do
          flash[:notice] = "Page <strong>#{@page.title}</strong> and all its descendants were moved under <strong>#{@parent.title}</strong>."
          redirect_to admin_pages_url
        end
        wants.xml do
          render :xml => @page
        end
        wants.json do
          render :json => @page
        end
      end
    rescue CopyMove::CircularHierarchy => e
      respond_to do |wants|
        wants.html do
          flash[:error] = e.message
          redirect_to admin_pages_url
        end
        wants.xml { render :xml => e, :status => :conflict }
        wants.json { render :json => e, :status => :conflict }
      end
    end
    
    private
    def load_parent
      @parent = Page.find(params[:parent_id])
    end
  end
end
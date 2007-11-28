module CopyMovePageControllerExtensions
  def copy_move
    @page = Page.find_by_id params[:id]
    redirect_to page_index_url and return unless @page
    if request.post?
      if @page.parent_id.nil? and params[:duplicate_what] and params[:duplicate_what] == 'move'
        flash[:error] = "You can't move the homepage under another parent."
      else
        new_parent = Page.find params[:new_parent_id]
        redirect_url = page_index_url
        if params[:duplicate_what]
          case params[:duplicate_what]
            when 'page'
              new_page = duplicate_page @page, new_parent
              flash[:notice] = "A copy of <strong>#{@page.title}</strong> has been created correctly"
              redirect_to page_edit_url(:id => new_page.id) and return
            when 'page_and_children'
              new_page = duplicate_page @page, new_parent
              duplicate_children @page, new_page
              flash[:notice] = 'The page and its children have been duplicated correctly'
            when 'tree'              
              @copy_of_tree_root = duplicate_page @page, new_parent
              duplicate_children @page, @copy_of_tree_root, true
              flash[:notice] = 'Entire page tree has been duplicated correctly'
            when 'move'
              if @page.id == new_parent.id
                flash[:error] = "You can't move this page under itself"
                redirect_url = page_copy_move_url(:id => @page.id)
              else
                @page.parent_id = params[:new_parent_id]
                @page.save
                flash[:notice] = 'Page has been moved correctly'
              end
          end
        end
        redirect_to redirect_url
      end      
    end
  end
  
private

  def suggest_title_and_slug_for_new_page page, parent
    new_title, new_slug, i = '', '', 0
    loop do
      case i
      when 0 then copy = ""
      when 1 then copy = " (Copy)"
      else copy = " (Copy #{i})"
      end
      new_title = "#{page.title}#{copy}"
      new_slug = new_title.downcase.gsub(/[^-a-z0-9~\s\.:;+=_]/, '').gsub(/[\s\.:;=+]+/, '-')
      break unless Page.find(:first, :conditions => ["parent_id = ? AND slug = ?", parent.id, new_slug])
      i += 1
    end
    return new_title, new_slug
  end

  def duplicate_page page, new_parent
    new_title, new_slug = suggest_title_and_slug_for_new_page page, new_parent
    new_page = Page.create(
      :title => new_title, :slug => new_slug, :breadcrumb => new_title, :class_name => page.class_name,
      :status_id => page.status_id, :parent_id => new_parent.id, :layout_id => page.layout_id
    ) 
    page.parts.each do |part|
      new_page.parts << PagePart.create(:name => part.name, :filter_id => part.filter_id, :content => part.content)
    end
    new_page
  end
  
  def duplicate_children source_page, dest_page, recursive = false
    source_page.children.each do |page|
      next if page.id == @copy_of_tree_root.id
      new_page = duplicate_page page, dest_page
      if recursive
        page.children.each do |sub_page|
          next if sub_page.id == @copy_of_tree_root.id
          new_page = duplicate_page sub_page, new_page
          duplicate_children sub_page, new_page, true
        end
      end
    end
  end          
       
end
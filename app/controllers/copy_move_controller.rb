class CopyMoveController < ApplicationController

  before_filter :find_page

  def index 
  end

  def copy_move
    if request.post? && find_new_parent            
      case params[:copy_move_action]
      when 'page', nil
        @new_page = duplicate_page(@page, @new_parent)
        flash[:notice] = "A copy of <strong>#{@page.title}</strong> has been created correctly."
      when 'children'
        @new_page = duplicate_page(@page, @new_parent)
        duplicate_children(@page, @new_page)
        flash[:notice] = 'The page and its children have been duplicated correctly.'
      when 'tree'
        @new_page = duplicate_page(@page, @new_parent)
        duplicate_children(@page, @new_page, true)
        flash[:notice] = 'Entire page tree has been duplicated correctly.'
      when 'move'
        if @page.parent.nil?
          flash.now[:error] = "You can't move the homepage under another parent."
          render(:action => 'index') and return
        elsif @page.id == @new_parent.id
          flash.now[:error] = "You can't move this page under itself."
          render(:action => 'index') and return
        else
          @page.update_attribute(:parent_id, @new_parent.id)
          flash[:notice] = 'Page has been moved correctly.'
        end
      end      
    end
    redirect_to(admin_pages_url)
  end

private

  def find_page
    @page = Page.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to(admin_pages_url)
  end

  def find_new_parent
    @new_parent = params[:parent] ? Page.find_by_id(params[:parent]) : @page.parent    
    unless @new_parent
      flash.now[:error] = "You must specify the new parent"
    end
    @new_parent
  end
  
  def suggest_title_and_slug_for_new_page(page, parent)    
    new_title, new_slug, i = '', '', 0
    loop do
      case i
      when 0 then new_title = page.title; new_slug = page.slug
      when 1 then new_title = "#{page.title} (Copy)"; new_slug = "#{page.slug}-#{i+1}"
      else new_title = "#{page.title} (Copy #{i})"; new_slug = "#{page.slug}-#{i+1}"
      end
      break unless Page.find(:first, :conditions => ["parent_id = ? AND slug = ?", parent.id, new_slug])
      i += 1
    end
    return new_title, new_slug
  end

  def duplicate_page(page, new_parent)    
    new_title, new_slug = suggest_title_and_slug_for_new_page(page, new_parent)
    new_status_id = params[:status_id].blank? ? page.status_id : params[:status_id]
    new_page = page.clone
    new_page.title = new_title
    new_page.slug = new_slug
    new_page.status_id = new_status_id
    new_page.parent = new_parent
    new_page.save
    page.parts.each do |part|
      new_page.parts << part.clone
    end
    new_page
  end
  
  def duplicate_children(source_page, dest_page, recursive = false)
    source_page.children.each do |page|
      next if page.id == @new_page.id
      new_page = duplicate_page(page, dest_page)
      if recursive
        page.children.each do |sub_page|
          next if sub_page.id == @new_page.id
          new_sub_page = duplicate_page(sub_page, new_page)
          duplicate_children(sub_page, new_sub_page, true)
        end
      end
    end
  end
end

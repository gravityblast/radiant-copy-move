require File.dirname(__FILE__) + '/../spec_helper'

describe Admin::PagesController do
  dataset :users_and_pages
  before :each do
    login_as :existing
  end
  
  describe "routes" do
    it "should route URLs to the copy_page action" do
      route_for(:controller => "admin/pages", :action => "copy_page", :id => "1").should == "/admin/pages/1/copy_page"
      params_from(:post, "/admin/pages/1/copy_page").should == {:controller => "admin/pages", :action => "copy_page", :id => "1"}
    end
    
    it "should route URLs to the copy_children action" do
      route_for(:controller => "admin/pages", :action => "copy_children", :id => "1").should == "/admin/pages/1/copy_children"
      params_from(:post, "/admin/pages/1/copy_children").should == {:controller => "admin/pages", :action => "copy_children", :id => "1"}
    end
    
    it "should route URLs to the copy_tree action" do
      route_for(:controller => "admin/pages", :action => "copy_tree", :id => "1").should == "/admin/pages/1/copy_tree"
      params_from(:post, "/admin/pages/1/copy_tree").should == {:controller => "admin/pages", :action => "copy_tree", :id => "1"}
    end
    
    it "should route URLs to the move action" do
      route_for(:controller => "admin/pages", :action => "move", :id => "1").should == "/admin/pages/1/move"
      params_from(:post, "/admin/pages/1/move").should == {:controller => "admin/pages", :action => "move", :id => "1"}
    end
  end
  
  describe "POST to /admin/pages/:id/copy_page" do
    before :each do
      post :copy_page, :id => page_id(:first), :parent_id => page_id(:another)
    end
    
    it "should load the page" do
      assigns[:page].should == pages(:first)
    end
    
    it "should load the parent page" do
      assigns[:parent].should == pages(:another)
    end
    
    it "should create a new page" do
      assigns[:new_page].should be
    end
    
    it "should write a flash notice" do
      flash[:notice].should be
    end
    
    it "should redirect to the sitemap" do
      response.should redirect_to(admin_pages_url)
    end
  end
  
  describe "POST to /admin/pages/:id/copy_children" do
    before :each do
      post :copy_children, :id => page_id(:assorted), :parent_id => page_id(:another)
    end
    
    it "should load the page" do
      assigns[:page].should == pages(:assorted)
    end
    
    it "should load the parent page" do
      assigns[:parent].should == pages(:another)
    end
    
    it "should create a new page" do
      assigns[:new_page].should be
    end
    
    it "should have copied the children" do
      assigns[:new_page].should have(12).children
    end
    
    it "should write a flash notice" do
      flash[:notice].should be
    end
    
    it "should redirect to the sitemap" do
      response.should redirect_to(admin_pages_url)
    end
  end
  
  describe "POST to /admin/pages/:id/copy_tree" do
    before :each do
      post :copy_tree, :id => page_id(:parent), :parent_id => page_id(:another)
    end
    
    it "should load the page" do
      assigns[:page].should == pages(:parent)
    end
    
    it "should load the parent page" do
      assigns[:parent].should == pages(:another)
    end
    
    it "should create a new page" do
      assigns[:new_page].should be
    end
    
    it "should have copied the descendants" do
      assigns[:new_page].should have(3).children
      assigns[:new_page].children.first.should have(1).child
    end
    
    it "should write a flash notice" do
      flash[:notice].should be
    end
    
    it "should redirect to the sitemap" do
      response.should redirect_to(admin_pages_url)
    end
  end
  
  describe "POST to /admin/pages/:id/move" do
    describe "when moving to a valid parent" do
      before :each do
        post :move, :id => page_id(:first), :parent_id => page_id(:another)
      end

      it "should load the page" do
        assigns[:page].should == pages(:first)
      end

      it "should load the parent page" do
        assigns[:parent].should == pages(:another)
      end

      it "should have moved the page to its new parent" do
        assigns[:page].parent.should == assigns[:parent]
      end

      it "should write a flash notice" do
        flash[:notice].should be
      end

      it "should redirect to the sitemap" do
        response.should redirect_to(admin_pages_url)
      end
    end
    
    describe "when moving to an invalid parent" do
      before :each do
        post :move, :id => page_id(:parent), :parent_id => page_id(:child)
      end
      
      it "should load the page" do
        assigns[:page].should == pages(:parent)
      end

      it "should load the parent page" do
        assigns[:parent].should == pages(:child)
      end

      it "should write a flash error" do
        flash[:error].should be
      end
      
      it "should redirect to the sitemap" do
        response.should redirect_to(admin_pages_url)
      end
    end
  end
end
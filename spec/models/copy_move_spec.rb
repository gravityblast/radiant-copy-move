require File.dirname(__FILE__) + '/../spec_helper'

describe CopyMove do
  dataset :pages
  
  describe "suggesting a new slug and title" do
    it "should use the same slug and title when there is not a child page of the new parent that has the same slug or title" do
      pages(:first).new_slug_and_title_under(pages(:parent)).should == {:slug => "first", :title => "First"}
    end
    
    it "should use a different slug and title when there is a conflicting child page of the new parent" do
      pages(:first).new_slug_and_title_under(pages(:home)).should_not == {:slug => "first", :title => "First"}
      pages(:first).new_slug_and_title_under(pages(:home)).should == {:slug => "first-1", :title => "First (Copy)"}
    end
  end
  
  describe "moving under a new parent" do
    it "should refuse to move under itself" do
      lambda { pages(:first).move_under(pages(:first)) }.should raise_error(CopyMove::CircularHierarchy)
    end
    
    it "should refuse to move under a descendant of itself" do
      lambda { pages(:parent).move_under(pages(:child)) }.should raise_error(CopyMove::CircularHierarchy)
    end
    
    it "should move to a new parent" do
      @page = pages(:first)
      lambda { @page.move_under(pages(:another)) }.should_not raise_error
    end
  end
  
  describe "copying the page" do
    before :each do
      @page = pages(:first)
    end
    
    it "should duplicate the page" do
      @new_page = @page.copy_to(pages(:another))
      @page.attributes.delete_if {|k,v| [:id, :parent_id].include?(k.to_sym) }.each do |key,value|
        @new_page[key].should == value
      end
      @page.parts.each do |part|
        @new_page.part(part.name).should_not be_nil
      end
    end
    
    it "should use a new slug and title if a similar page exists under the new parent" do
      @new_page = @page.copy_to(pages(:home))
      @new_page.slug.should_not == @page.slug
      @new_page.title.should_not == @page.title
    end
    
    it "should override the status when given" do
      @new_page = @page.copy_to(pages(:another), Status[:draft].id)
      @new_page.status.should == Status[:draft]
    end
    
    it "should ignore a blank status" do
      @new_page = @page.copy_to(pages(:another), '   ')
      @new_page.status.should == Status[:published]
    end
  end
  
  describe "copying the page with first-level children" do
    it "should copy the page and its children" do
      @page = pages(:assorted)
      @new_page = @page.copy_with_children_to(pages(:first))
      @new_page.parent.should == pages(:first)
      @new_page.should have(12).children
    end
    
    it "should not copy grandchild pages" do
      @page = pages(:parent)
      @new_page = @page.copy_with_children_to(pages(:childless))
      @new_page.children.count.should == 3
      @new_page.children.first.children.count.should == 0
    end
    
    it "should override the status when given" do
      @page = pages(:assorted)
      @new_page = @page.copy_with_children_to(pages(:first), Status[:hidden].id)
      @new_page.status.should == Status[:hidden]
      @new_page.children.each do |child|
        child.status.should == Status[:hidden]
      end
    end
  end
  
  describe "copying the page with all descendants" do
    before :each do
      @page = pages(:parent)
    end
    
    it "should copy the page and all descendants" do
      @new_page = @page.copy_tree_to(pages(:first))
      @new_page.parent.should == pages(:first)
      @new_page.should have(3).children
      @new_page.children.first.should have(1).child
      @new_page.children.first.children.first.should have(1).child
    end
    
    it "should override the status when given" do
      @new_page = @page.copy_tree_to(pages(:first), Status[:hidden].id)
      @new_page.status.should == Status[:hidden]
      @new_page.children.each do |child|
        child.status.should == Status[:hidden]
      end
      @new_page.children.first.children.first.status.should == Status[:hidden]
      @new_page.children.first.children.first.children.first.status.should == Status[:hidden]
    end
  end
end
require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
CopyMoveController.class_eval { def rescue_action(e) raise e end }

class CopyMoveControllerTest < Test::Unit::TestCase
  
  fixtures :users, :pages
  test_helper :pages, :login
  
  def setup
    @controller = CopyMoveController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as(:existing)    
  end
  
  def test_index_should_redirect_if_page_does_not_exist
    get :index, :id => 1111
    assert_response :redirect, admin_pages_url
  end
  
  def test_index_should_not_redirect_if_page_exists
    get :index, :id => pages(:projects).id
    assert_response :success
  end
   
  def test_copy_move_should_redirect_if_page_does_not_exist
    post :copy_move, :id => 9999
    assert_response :redirect, admin_pages_url    
  end
  
  def test_copy_move_should_duplicate_page
    assert_equal 3, pages(:homepage).children.count
    assert_difference Page, :count do
      post :copy_move, :id => pages(:projects), :copy_move_action => 'page'
      assert_equal 4, pages(:homepage).children.count
      assert pages(:homepage).children.find_by_title('Projects (Copy)')
    end
  end
  
  def test_copy_move_should_duplicate_page_under_another_parent
    assert_equal 1, pages(:projects).children.count
    assert_difference Page, :count do
      post :copy_move, :id => pages(:copy_move).id, :copy_move_action => 'page', :parent => pages(:projects).id
      assert_equal 2, pages(:projects).children.count
      assert pages(:projects).children.find_by_title('CopyMove')
    end
  end
  
  def test_copy_move_should_duplicate_page_and_its_first_level_children
    assert_equal 3, pages(:homepage).children.count
    assert_difference Page, :count, 2 do
      post :copy_move, :id => pages(:projects), :copy_move_action => 'children'
      assert_equal 4, pages(:homepage).children.count
      new_page = pages(:homepage).children.find_by_title('Projects (Copy)')
      assert new_page
      assert_equal 1, new_page.children.count
      assert_equal 0, new_page.children[0].children.count
    end
  end
  
  def test_copy_move_should_duplicate_page_and_its_first_level_children_under_another_parent
    assert_equal 0, pages(:subpage).children.count
    assert_difference Page, :count, 2 do
      post :copy_move, :id => pages(:projects).id, :copy_move_action => 'children', :parent => pages(:subpage).id
      assert_equal 1, pages(:subpage).children.count
      new_page = pages(:subpage).children.find_by_title('Projects')
      assert new_page
      assert_equal 1, new_page.children.count
      assert_equal 0, new_page.children[0].children.count
    end
  end
  
  def test_copy_move_should_duplicate_entire_page_tree
    assert_equal 3, pages(:homepage).children.count
    assert_difference Page, :count, 3 do
      post :copy_move, :id => pages(:projects).id, :copy_move_action => 'tree'
      assert_equal 4, pages(:homepage).children.count
      new_page = pages(:homepage).children.find_by_title('Projects (Copy)')
      assert new_page
      assert_equal 1, new_page.children.count
      assert_equal 1, new_page.children[0].children.count
    end
  end
  
  def test_copy_move_should_duplicate_entire_page_tree_under_another_parent
    assert_equal 0, pages(:subpage).children.count
    assert_difference Page, :count, 3 do
      post :copy_move, :id => pages(:projects).id, :copy_move_action => 'tree', :parent => pages(:subpage)
      assert_equal 1, pages(:subpage).children.count
      assert_equal 3, pages(:homepage).children.count
      new_page = pages(:subpage).children.find_by_title('Projects')
      assert new_page
      assert_equal 1, new_page.children.count
      assert_equal 1, new_page.children[0].children.count
    end
  end
  
  def test_copy_move_should_duplicate_page_under_one_of_its_children
    assert_difference Page, :count, 6 do
      post :copy_move, :id => pages(:homepage), :copy_move_action => 'tree', :parent => pages(:homepage)
    end
  end
  
  def test_copy_move_should_duplicate_page_tree_under_one_of_its_children
    assert_difference Page, :count, 4 do
      post :copy_move, :id => pages(:homepage), :copy_move_action => 'children', :parent => pages(:homepage)
    end
  end
  
  def test_should_be_impossible_to_move_a_page_under_itself
    assert_no_difference Page, :count do
      post :copy_move, :id => pages(:projects).id, :copy_move_action => 'move', :parent => pages(:projects).id
      assert_response :success
      assert_template "index"
      assert_tag :tag => 'div',
                 :attributes => { :id => 'error' },
                 :content => "You can't move this page under itself."
    end    
  end
  
  def test_should_move_page
    assert_equal 3, pages(:homepage).children.count
    assert_equal 0, pages(:subpage).children.count
    assert_no_difference Page, :count do
      post :copy_move, :id => pages(:projects).id, :copy_move_action => 'move', :parent => pages(:subpage).id
      assert_equal 2, pages(:homepage).children.count
      assert_equal 1, pages(:subpage).children.count
      assert_response :redirect
    end    
  end
  
  def test_should_be_impossible_to_move_the_homepage
    post :copy_move, :id => pages(:homepage), :copy_move_action => 'move', :parent => pages(:subpage).id
    assert_response :success
    assert_template 'index'
    assert_tag :tag => 'div',
               :attributes => { :id => 'error' },
               :content => "You can't move the homepage under another parent."
  end
  
  def _test_should_be_possible_to_set_a_different_status
    post :copy_move, :id => pages(:projects).id, :copy_move_action => 'tree', :status_id => "1" #draft
    new_page = pages(:homepage).children.find_by_title('Projects (Copy)')
    assert_not_equal pages(:projects).status_id, new_page.status_id
    assert_equal 1, new_page.status_id
    
    assert_not_equal pages(:projects).children[0].status_id, new_page.children[0].status_id
    assert_not_equal 1, new_page.children[0].status_id
  end
  
  def test_should_use_original_slug_even_if_a_page_with_the_same_title_exists_under_the_same_parent
    assert_equal 1, pages(:projects).children.count
    assert_difference Page, :count, 2 do
      post :copy_move, :id => pages(:extensions2), :parent => pages(:projects).id
      assert_equal 2, pages(:projects).reload.children.count
      children = pages(:projects).children
      assert_equal "Extensions", children[0].title
      assert_equal "Extensions", children[1].title
      assert_equal "extensions", children[0].slug
      assert_equal "extensions2", children[1].slug
      post :copy_move, :id => pages(:extensions2), :parent => pages(:projects).id
      assert_equal 3, pages(:projects).reload.children.count
      children = pages(:projects).children
      assert_equal "Extensions", children[0].title
      assert_equal "Extensions", children[1].title
      assert_equal "Extensions (Copy)", children[2].title
      assert_equal "extensions", children[0].slug
      assert_equal "extensions2", children[1].slug
      assert_equal "extensions2-2", children[2].slug
    end
  end
  
end

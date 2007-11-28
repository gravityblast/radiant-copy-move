require File.dirname(__FILE__) + '/../test_helper'

class CopyMoveExtensionTest < Test::Unit::TestCase
    
  def test_initialization
    assert_equal File.join(File.expand_path(RAILS_ROOT), 'vendor', 'extensions', 'copy_move'), CopyMoveExtension.root
    assert_equal 'Copy Move', CopyMoveExtension.extension_name
  end
  
end

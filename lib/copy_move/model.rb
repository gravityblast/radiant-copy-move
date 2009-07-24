module CopyMove
  module Model
    def new_slug_and_title_under(parent)
      test_page = self.clone
      test_page.parent = parent
      until test_page.valid?
        index = (index || 0) + 1
        test_page.title = "#{title} (Copy#{' '+index if index > 1})"
        test_page.slug = "#{slug}-#{index}"
      end
      {:slug => test_page.slug, :title => test_page.title}
    end

    def move_under(parent)
      raise CircularHierarchy.new(self) if parent == self || parent.ancestors.include?(self)
      update_attributes!(:parent_id => parent.id)
    end

    def copy_to(parent, status = nil)
      parent.children.build(copiable_attributes.symbolize_keys.merge(new_slug_and_title_under(parent))).tap do |new_page|
        self.parts.each do |part|
          new_page.parts << part.clone
        end
        new_page.status_id = status.blank? ? new_page.status_id : status
        new_page.save!
      end
    end

    def copy_with_children_to(parent, status = nil)
      copy_to(parent, status).tap do |new_page|
        children.each {|child| child.copy_to(new_page, status) }
      end
    end

    def copy_tree_to(parent, status = nil)
      copy_to(parent, status).tap do |new_page|
        children.each {|child| child.copy_tree_to(new_page, status) }
      end
    end

    private
    def copiable_attributes
      self.attributes.dup.delete_if {|k,v| [:id, :parent_id].include?(k.to_sym) }
    end
  end
end
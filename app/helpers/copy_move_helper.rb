module CopyMoveHelper   
  def page_parent_select_tag
    homes = Page.find_all_by_parent_id nil
    list = homes.inject([]) do |l, home|
      l.concat build_tree(home, [])
    end
    select_tag 'parent_id', options_for_select(list)
  end
  
  def build_tree(page, list, level = 0)
    label = "#{'-'*level}#{page.title}"
    id = page.id
    list << [label, id]
    page.children.each do |p|
      build_tree p, list, level + 1
    end
    list
  end
end
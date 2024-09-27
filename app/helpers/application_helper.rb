module ApplicationHelper
  def full_title page_title
    base_title = "B-World | We love book"
    page_title.blank? ? base_title : "#{page_title} | #{base_title}"
  end
end

module SessionsHelper
  def login_breadcrumbs
    "#{link_to('Collabbit', 'http://collabbit.org')} &#9656 #{link_to(@instance.long_name,login_path)}"
  end
end

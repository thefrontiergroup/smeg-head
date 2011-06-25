module ApplicationHelper

  def partial(name, options = {})
    render options.merge(:partial => name)
  end

end

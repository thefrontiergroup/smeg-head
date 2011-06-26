module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name
    when /the home\s?page/
      root_path
    when /the sign in page/
      new_user_session_path
    when /the sign out page/
      destroy_user_session_path
    when /the sign up page/
      new_user_registration_path
    when /my profile/
      raise NotImplementedError, 'The profile page'
    when /the edit profile page/
      edit_user_registration_path
    when /the new user repository page/
      new_users_repository_path
    when /the create user repository page/
      users_repositories_path
    when /the page for the "([^\"]*)" repository/
      repository = Repository.from_path($1)
      case repository.owner
      when User then user_repository_root_path(:user_id => repository.owner.to_param, :repository_id => repository.to_param)
      end
    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)

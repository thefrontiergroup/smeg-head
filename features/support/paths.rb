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
      '/'
    when /the new repository_management page/
      new_repository_management_path

    when /the new ssh_key_management page/
      new_ssh_key_management_path

    when /the new account_management page/
      new_account_management_path

    when /the new authentication page/
      new_authentication_path

    when /the new account_creation page/
      new_account_creation_path

    when /sign in/
      '/users/sign_in'
    when /sign out/
      '/users/sign_out'
    when /my profile/
      '/users/profile'
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

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

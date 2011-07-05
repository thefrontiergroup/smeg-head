module HtmlSelectorsHelpers

  def field_selector_for(name)
    case name
    when /the ssh key contents/
      'li#ssh_public_key_key_input'
    end
  end

  # Maps a name to a selector. Used primarily by the
  #
  #   When /^(.+) within (.+)$/ do |step, scope|
  #
  # step definitions in web_steps.rb
  #
  def selector_for(locator)
    case locator
    when /collaborators?/
      "ul#collaborators li.collaborator"
    when /the page/
      "html > body"
    when /the current ssh public key/
      "ul#ssh-public-keys li.ssh-public-key:last"
    when /a ssh public key/
      "ul#ssh-public-keys li.ssh-public-key"
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #  when /the (notice|error|info) flash/
    #    ".flash.#{$1}"

    # You can also return an array to use a different selector
    # type, like:
    #
    #  when /the header/
    #    [:xpath, "//header"]

    # This allows you to provide a quoted selector as the scope
    # for "within" steps as was previously the default for the
    # web steps:
    when /"(.+)"/
      $1

    else
      raise "Can't find mapping from \"#{locator}\" to a selector.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelpers)

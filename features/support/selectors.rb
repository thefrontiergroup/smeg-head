module HtmlSelectorsHelpers

  def field_selector_for(name)
    case name
    when /the ssh key contents/
      'li#ssh_public_key_key_input'
    when /the (.*)/
      "li##{$1.tr ' ', '_'}_input"
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
    when /the collaborator form/
      "form.formtastic.collaboration"
    when /collaborators?/
      "ul#collaborators li.collaborator"
    when /the page/
      "html > body"
    when /the current ssh public key/
      "ul#ssh-public-keys li.ssh-public-key:last"
    when /a ssh public key/
      "ul#ssh-public-keys li.ssh-public-key"
    #  when /the (notice|error|info) flash/
    #    ".flash.#{$1}"
    #  when /the header/
    #    [:xpath, "//header"]
    when /"(.+)"/
      $1
    else
      raise "Can't find mapping from \"#{locator}\" to a selector.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelpers)

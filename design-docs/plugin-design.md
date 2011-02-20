# Smeg Head - The plugin interface

Smeg Head makes it possible to hook into most stages of the repository management lifecycle.
It does this using a variety of hooks (via a simple in-application pub/sub implementation that
plugins can hook in to).

## What is in a plugin?

Since Smeg Head is built upon Rails 3, Smeg Head plugins are just special forms of the new
[Rails Engine](#todo-link-here) implementations. This means that you get access to a bunch of nice helpers out of the
box (namely, easy support for initializers, app-level extensions and the like) with added syntactic
sugar for registering on events and the like.

## Creating a Plugin

Creating a plugin is much like creating a plugin for a Rails application in gem form. In your plugin,
instead of subclassing `Rails::Railtie`, you instead subclass `SmegHead::Plugin`. This adds numerous
features (namely, `subscribe` short cuts in the plugin declaration, easy access to the smeg head configuration
and a way to register the name and version of your plugin as needed).

**TODO: Is subclassing Rails::Railtie a good idea? It makes it hard to do optional plugins**

As an example, given a library called `smeg_head-github_mirroring`, you would have a file in lib called
`smeg_head/github_mirroring/plugin.rb`. Inside this plugin, you'd have something similar to:

    module SmegHead::GitHubMirroring
      class Plugin < SmegHead::Plugin
      
        plugin_name    "GitHub Mirroring"
        plugin_author  "Darcy Laycock"
        plugin_version SmegHead::GitHubMirroring::VERSION
        plugin_url     "http://github.com/Sutto/smeg_head-github_mirroring"
      
        extend_model :User,       SmegHead::GitHubMirroring::UserMixin
        extend_model :Repository, SmegHead::GitHubMirroring::MirrorableRepository
      
        subscribe 'repository:created' do |options|
          if options[:repository].github?
          end
        end
      
      end
    end
    
This will automatically register your plugin in the application interface, subscribe to an event
and add some nice model extensions automatically on load. For a full set of documentation on what
methods are available inside a plugin, see the documentation for `SmegHead::Plugin`.

Note that to be able to use plugins, you must also make sure it's loading inside your gem *after*
the `smeg_head_base` gem, which provides the subscription hub and plugin utilities (but not the
application itself).

## Registering on Pub / Sub events

Events are inherently simple. They have a name and take an object that responds to `#call`. The standard
naming schema is composed of parts separated by colons (`:`). The name can be nested infinitely deep e.g.
`repository:created:offline` is as valid as `repository` and the like. The difference being when an event
is dispatched to the longer version, it will dispatch it to each of the prefixed events (e.g. `repository:created:offline`
would hence trigger `repository:created` and `repository`), making it super easy to hook in to high level
events as well as low level, individual actions.

In the case of a nested event like above, extra options will be passed down.

**TODO: Explain how - Possibly some sort of routing system?**

When an event is dispatched, the caller also passes in a hash of options with symbolized keys. This approach
means arbitrary data can be passed to events.

In general, to subscribe to a message it's a simple matter of doing:

    SmegHead::Hub.subscribe 'your-event-name:sub-name', ObjectWithCall
    
Or, in the simpler case of a proc:

    SmegHead::Hub.subscribe 'your-event-name:sub-name' do |options|
      p options[:some_value]
    end
    
Inside a plugin initializer, you can also use the `subscribe` method, making it very simple to set up and
register your application:


    class MyPlugin < SmegHead::Plugin
      
      subscribe 'key-path' do |options|
        # Something happens here
      end
      
    end
    
This leads to more concise code when it comes to managing events.
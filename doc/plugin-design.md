# Smeg Head - The plugin interface

Smeg Head makes it possible to hook into most stages of the repository management lifecycle.
It does this using a variety of hooks (via a simple in-application pub/sub implementation that
plugins can hook in to).

## What is in a plugin?

Since Smeg Head is built upon Rails 3, Smeg Head plugins are just special forms of the new
[Rails Engine]() implementations. This means that you get access to a bunch of nice helpers out of the
box (namely, easy support for initializers, app-level extensions and the like) with added syntactic
sugar for registering on events and the like.

## Creating a Plugin


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

## Acting upon events


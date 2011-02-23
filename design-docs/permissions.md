# Repository-level permissions

Smeg Head has an ACL-style permissions implementation built on four operations
matching groups of wild cards (tags and branches). Namely, it supports the following
operations:

* `push-to`
* `pull-from`
* `create`
* `destroy`

Which can match ones of:

* A branch (`refs/heads` prefix)
* A tag (`refs/tags` prefix)

Also, the special case `refs` which matches tags and branches.

## Verbs

Verb permissions are either `allow` or `deny`.

## Permission Scoping

Permissions can be scoped to:

* User
* Group
* Collaborators

In that order.

## Matching Branches

Finally, the target of it is matched on a wildcard / glob basis.

## Examples

    allow create    from user Sutto to branch *
    allow push-to   from user Sutto to branch *
    allow pull-from from user Sutto to branch *
    allow destroy   from user Sutto to branch *

This is a simple case, most repositories will default to:

    allow create    from collaborators to refs *
    allow push-to   from collaborators to refs *
    allow pull-from from collaborators to refs *
    allow destroy   from collaborators to refs *
    
This will ultimately expressed on some model level, possibly with a custom DSL.
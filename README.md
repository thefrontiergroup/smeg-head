# Smeg Head

Smeg Head is a simple git hosting application built with Ruby on Rails. It is currently under heavy development.

*Please Note:* Smeg Head is currently at very, very early stages. Honestly, there is nothing to see here.

## Getting Started

To get started, it should be as simple as running:

    git clone git://github.com/thefrontiergroup/smeg-head.git
    cd smeg-head
    bundle install
    cp config/database{.example,}.yml
    cp config/settings{.example,}.yml
    rake db:setup
    ./script/server
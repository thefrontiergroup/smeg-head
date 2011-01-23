# Rimmer

> Do you? Well, thank you. No-one's ever said I was charming before. They've said, "Rimmer, you're a total git." But never charming, no.

Rimmer is a simple git hosting application built with Ruby on Rails. It is currently under heavy development.

*Please Note:* Rimmer is currently at very, very early stages. Honestly, there is nothing to see here.

## Getting Started

To get started, it should be as simple as running:

    git clone git://github.com/thefrontiergroup/rimmer.git
    cd rimmer
    bundle install
    cp config/database{.example,}.yml
    cp config/settings{.example,}.yml
    rake db:setup
    ./script/server
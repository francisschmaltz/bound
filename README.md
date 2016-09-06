# Bound

Bound is a web-based frontend for managing DNS zones. It sits on top of an
existing BIND installation and exports appropriately formatted zone files and
handles configuration reloads when needed.

![Screenshot](https://share.adam.ac/16/8kduueswXg.png)

## Installation

1. `git clone https://github.com/adamcooke/bound`
2. `cp config/bound.example.yml config/bound.yml`
3. Make appropriate changes to config file
4. `bundle`
5. `bundle exec rake db:schema:load assets:precompile`
6. `bundle exec foreman start`

## Upgrade

1. Stop the running server
2. `git pull origin master`
3. `bundle`
4. `bundle exec rake assets:precompile db:migrate`
5. Start the server

# Bound

Bound is a web-based frontend for managing DNS zones. It sits on top of an
existing BIND installation and exports appropriately formatted zone files and
handles configuration reloads when needed.

![Screenshot](./demo-new.png)


## Requirements

* Ruby 2.5.9 (I use `rbenv`)
* Bundler (`gem install bundler`)
* mysql2 with user/password and db of `bound`
* bind9

Create database with:
```
CREATE DATABASE bound;
GRANT ALL PRIVILEGES ON bound.* TO 'boundUser'@'localhost';
FLUSH PRIVILEGES;
```

## Installation

1. `git clone https://github.com/francisschmaltz/bound`
2. `cp config/bound.example.yml config/bound.yml`
3. Make appropriate changes to config file
4. `bundle`
5. `bundle exec rake db:schema:load assets:precompile`
6. `rake db:migrate`
7. `bundle exec foreman start`

## Upgrade

1. Stop the running server
2. `git pull origin master`
3. `bundle`
4. `bundle exec rake assets:precompile db:migrate`
5. Start the server

## SSO Support

This app supports using omniauth with GitHub oAuth

## Notes

- macOS Mojave needs to run `gem install mysql2 -v '0.4.10' -- --with-ldflags=-L/usr/local/opt/openssl/lib --with-cppflags=-I/usr/local/opt/openssl/include` to install mysql2
- Ubuneu 20 needs to run `sudo apt-get install libmysqlclient-dev` to install mysql2 gem
- For testing, use `reload: echo "reloaded"` in bind command to skip reloading or enabling bind
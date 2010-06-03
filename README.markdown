# Welcome to Collabbit

Collabbit is a web-based communication tool which helps coordinate and organize relief efforts in times of disaster and recovery. It aims to eliminate burdensome conference calls between the various parties involved, replacing them with quick and easy updates online, as well as provide a written record of the progress of the event.

## Starting Collabbit Development

### Before you start...

1. Install Ruby on Rails and MySQL.
2. Create a GitHub account and upload a public key so you have SSH access.
3. Fork the latest stable version on GitHub. It's always available [on GitHub](http://github.com/collabbit/collabbit).

### Installation
1. `git clone git@github.com:YOURUSERNAME/collabbit.git`
2. Create a `config/database.yml` file. A simple default is [available here](http://gist.github.com/422927).
	You'll need to add the username/password of a MySQL user with all permissions on tables starting with `collabbit_`
3. Create a folder `config/settings`
4. Inside `config/settings` add a `keys.yml`, an `smtp.yml`, and&mdash;if you're going to be deploying with Capistrano&mdash;a `deploy.yml`.

	Default versions of these files may be found [in this gist](http://gist.github.com/422927). The default settings are only suitable for development and **should not be used** on production systems.
5. Run `rake gems:install` to install all of the necessary gems.
6. Run `rake db:redo` to create, migrate, and seed the database.
7. Add the following to your HOSTS file (`/etc/hosts` on Linux):

    127.0.0.1 collabbit.dev demo.collabbit.dev

8. Run `script/server` and go to [`http://demo.collabbit.dev:3000`](http://demo.collabbit.dev:3000).

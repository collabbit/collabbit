# Welcome to Collabbit

Collabbit is a web-based communication tool which helps coordinate and organize relief efforts in times of disaster and recovery. It aims to eliminate burdensome conference calls between the various parties involved, replacing them with quick and easy updates online, as well as provide a written record of the progress of the event.

## Doing Collabbit Development

### Before you start...

1. Install Ruby on Rails and MySQL.
2. Create a GitHub account and upload a public key so you have SSH access.
3. Fork the latest stable version on GitHub. It's always available [on GitHub](http://github.com/collabbit/collabbit).

### Installation
1. Run `git clone git@github.com:YOURUSERNAME/collabbit.git` to get a copy of your fork.
2. Create a `config/database.yml` file. A simple default is [available here](http://gist.github.com/422927).

   You'll need to add the username/password of a MySQL user with all permissions on tables starting with `collabbit_`
3. Create a folder `config/settings`
4. Inside `config/settings` add a `keys.yml`, an `smtp.yml`, and&mdash;if you're going to be deploying with Capistrano&mdash;a `deploy.yml`.

   Default versions of these files may be found [in this gist](http://gist.github.com/422927). The default settings are only suitable for development and **should not be used** on production systems.
5. Run `rake gems:install` to install all of the necessary gems.
6. Run `rake db:redo` to create, migrate, and seed the database.
7. Add the following line to your HOSTS file (`/etc/hosts` on Linux):

		127.0.0.1 collabbit.dev demo.collabbit.dev
	
	(Alternatively, if you can't modify your HOSTS file for whatever reason, you can also use an external domain that redirects to localhost. One such domain is localhacks.com, which redirects *.localhacks.com to localhost.)

8. Run `script/server` and go to [`http://demo.collabbit.dev:3000`](http://demo.collabbit.dev:3000). Collabbit should be running, and you can log in with one of the default users' usernames/passwords. (Those can be found in `db/seeds.rb`.)

### Code Style Guidelines

For editing Ruby files (.rb), please have your editor configured to use spaces instead of tabs, and have the tab width set to two spaces. For editing CSS and Erb templates, please have your editor configured to use tabs, not spaces. We are planning to migrate all templates to Haml and all CSS to Sass over the summer. Once that's complete, we'll standardize on two spaces for all filetypes.

In addition, please always indent nested block HTML tags, and nest CSS hierarchically. For a style example, see [this gist](http://gist.github.com/424138).

Do **not** add author or license declarations to the top of files you're committing. All files committed to Collabbit must be licensed by the author under the LGPL. The license is specified here, in the readme, and a copy is available in the top-level files `LICENSE_GPL.txt` and `LICENSE_LGPL.txt`. Commit records provide a record of authorship.

## License

This program is licensed under the GNU Lesser General Public License version 3, an additional set of permissions on top of the GNU General Public License version 3.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License and the GNU Lesser General Public License along with this program. If not, see [http://www.gnu.org/licenses](http://www.gnu.org/licenses).

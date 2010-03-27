# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'
require 'find'

require 'active_record/fixtures'
require 'set'

namespace :db do

  desc "Turn development database into fixtures"
  task :fixturize => :environment do
    sql  = "SELECT * FROM %s"
    skip_tables = ["schema_info", "schema_migrations"]
    ActiveRecord::Base.establish_connection
    (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
      i = "000"
      File.open("#{RAILS_ROOT}/test/fixtures/#{table_name}.yml", 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.to_yaml
      end
    end
  end

  desc "Drop, create, migrate, populate the database"
  task :redo => ['environment', 'db:drop', 'db:create', 'db:migrate', 'db:seed']

  desc "Backup the database to a file. Options: DIR=base_dir RAILS_ENV=production MAX=20"
  task :backup => [:environment] do
    datestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    base_path = ENV["DIR"] || "db"
    backup_base = File.join(base_path, 'backup')
    backup_folder = File.join(backup_base, datestamp)
    backup_file = File.join(backup_folder, "#{RAILS_ENV}_dump.sql.gz")
    File.makedirs(backup_folder)
    db_config = ActiveRecord::Base.configurations[RAILS_ENV]
    sh "mysqldump -u #{db_config['username']} -p#{db_config['password']} -Q —add-drop-table -O add-locks=FALSE -O lock-tables=FALSE #{db_config['database']} | gzip -c > #{backup_file}"
    dir = Dir.new(backup_base)
    all_backups = dir.entries[2..-1].sort.reverse
    puts "Created backup: #{backup_file}"
    max_backups = ENV["MAX"].to_i || 20
    unwanted_backups = all_backups[max_backups..-1] || []
    for unwanted_backup in unwanted_backups
      FileUtils.rm_rf(File.join(backup_base, unwanted_backup))
      puts "deleted #{unwanted_backup}"
    end
    puts "Deleted #{unwanted_backups.length} backups, #{all_backups.length - unwanted_backups.length} backups available"
  end

end

def flatten(hsh, prefix = '')
  hsh.to_a.inject([]) do |memo, e|
    k, v = e
    memo + (v.is_a?(String) ? ["#{prefix}#{k}"] : flatten(v, "#{prefix}#{k}."))
  end
end

namespace :i18n do
  desc 'Find unimplemented strings'
  task :missing => :environment do
    strings = Set.new
    Dir.glob("#{RAILS_ROOT}/app/**/*.{rb,erb}") do |path|
      File.open(path) do |file|
        strings.merge(file.read.scan(/\st\((\'|\")([^\)]+)(\'|\")\)/).map{|a|a[1]})
      end
    end
    translations = flatten(YAML.load_file("#{RAILS_ROOT}/config/locales/en.yml")['en'])
    puts (strings - translations).to_a.join("\n")
  end
end
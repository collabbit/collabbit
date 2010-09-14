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
require 'fileutils'

namespace :db do

  desc "Turn development database into fixtures"
  task :fixturize => :environment do
    sql = "SELECT * FROM %s"
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
    datestamp = Time.now.strftime("%Y%m%d%H%M%S")
    base_path = ENV["DIR"] || "db"
    backup_base = File.join(base_path, 'backup')
    backup_folder = File.join(backup_base, datestamp)
    backup_file = File.join(backup_folder, "#{RAILS_ENV}_dump.sql.gz")
    FileUtils.mkdir_p(backup_folder)
    db_config = ActiveRecord::Base.configurations[RAILS_ENV]
    sh "mysqldump -u #{db_config['username']} -p#{db_config['password']} -Q -O add-locks=FALSE -O lock-tables=FALSE #{db_config['database']} | gzip -c > #{backup_file}"
    dir = Dir.new(backup_base)
    all_backups = dir.entries[2..-1].sort.reverse
    puts "Created backup: #{backup_file}"
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

task :update_times => :environment do
  ActiveRecord::Base.record_timestamps = false

  ActiveRecord::Base.send(:subclasses).each do |k|
    times = k.columns.inject([]) do |memo, col|
      memo << col.name.to_s if [Time, Date, DateTime].include? col.klass
      memo
    end

    puts "Updating #{k}"
    times.each {|t| puts "\t#{t}" }
    puts

    k.all.each do |obj|
      times.each do |time_field|
        obj.update_attribute(time_field, obj.send(time_field).try(:-, (9.minutes + 20.seconds)))
      end
    end
  end
end
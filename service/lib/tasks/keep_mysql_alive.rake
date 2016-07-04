# encoding: utf-8
desc "Prevents mysql from closing it's connections if left alone for 8 hours"
task :keep_mysql_alive => :environment do
  User.first
  "MySQL kept alive at #{Time.now}"
end
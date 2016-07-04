# encoding: utf-8
desc "Checks for any files than have been added recently and adds them to the MPD database"
task :scan => :environment do
  Rails.logger.info "Running scanner..."
  scanner = Scanner.new
  scanner.start_updates
end

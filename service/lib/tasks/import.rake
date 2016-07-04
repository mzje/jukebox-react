# encoding: utf-8
namespace :import do

  desc "Starts to import any shares that have been queued"
  task :shares => :environment do
    import = Import.next
    if import
      files = import.share.find_files
      files.each do |url|
        import.share.user.import_track(url)
      end
    end
  end

  desc "save ratings"
  task :update_all_ratings => :environment do
    Track.all.each do |track|
      track.update_attribute :current_rating, track.calculated_rating
    end
  end

end

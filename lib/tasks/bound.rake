namespace :bound do

  desc 'Publish all zones'
  task :publish_all => :environment do
    Zone.publish(:all => true)
  end

  desc 'Publish stale zones'
  task :publish => :environment do
    Zone.publish
  end


end

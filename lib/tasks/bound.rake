namespace :bound do

  desc 'Publish all zones'
  task :publish_all => :environment do
    Bound::Publisher.new(:all => true).publish
  end

  desc 'Publish stale zones'
  task :publish => :environment do
    Bound::Publisher.new.publish
  end


end

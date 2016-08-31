namespace :bound do

  desc 'Publish all zones'
  task :publish_all => :environment do
    publisher = Bound::Publisher.new(:all => true)
    publisher.publish

  end

  desc 'Publish zones'
  task :publish => :environment do
    publisher = Bound::Publisher.new
    publisher.publish
  end

end

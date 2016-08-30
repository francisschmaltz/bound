namespace :bound do

  desc 'Publish all zones'
  task :publish_all => :environment do
    Bound::Publisher.new(:all => true).publish
  end

  desc 'Publish zones'
  task :publish => :environment do
    publisher = Bound::Publisher.new
    publisher.publish
    puts publisher.result.inspect
  end


end

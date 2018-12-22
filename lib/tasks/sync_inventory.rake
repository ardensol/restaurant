namespace :inventories do
  desc 'sync inventory'
  task sync: :environment do
    Inventories::Sync.new.execute
  end
end


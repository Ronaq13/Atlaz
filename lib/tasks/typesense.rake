namespace :typesense do
  desc "Create the hotels Typesense collection (drops existing if present)"
  task create_hotels_collection: :environment do
    begin
      TYPESENSE_CLIENT.collections["hotels"].delete
      puts "Dropped existing 'hotels' collection."
    rescue Typesense::Error::ObjectNotFound
      # nothing to drop
    end

    TYPESENSE_CLIENT.collections.create(HOTELS_COLLECTION_SCHEMA)
    puts "Created 'hotels' collection."
  end
end

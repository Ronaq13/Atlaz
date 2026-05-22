class HotelIndexSyncJob < ApplicationJob
  queue_as :low

  BATCH_SIZE = 200

  def perform
    Hotel.active
         .includes(:rates => :currency)
         .find_in_batches(batch_size: BATCH_SIZE) do |batch|
      documents = batch.map { |hotel| Search::HotelSearchDocument.from_hotel(hotel) }

      TYPESENSE_CLIENT.collections["hotels"].documents.import(documents, action: "upsert")
    end
  end
end

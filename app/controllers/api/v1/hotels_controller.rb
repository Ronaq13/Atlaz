class Api::V1::HotelsController < ApplicationController
  def search
    result = Search::HotelSearchQuery.new(search_params).call

    render json: {
      hotels:   result["hits"].map { |hit| hit["document"] },
      meta: {
        found:    result["found"],
        page:     result["page"],
        per_page: search_params[:per_page] || Search::HotelSearchQuery::DEFAULT_PER_PAGE
      }
    }
  rescue Typesense::Error => e
    render json: { error: e.message }, status: :service_unavailable
  end

  private

  def search_params
    params.permit(:q, :destination_id, :check_in, :min_price, :max_price, :class_rating, :sort_by, :page, :per_page)
  end
end

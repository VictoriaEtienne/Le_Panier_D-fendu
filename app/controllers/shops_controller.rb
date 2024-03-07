class ShopsController < ApplicationController
  def index
    # TODO:
    # - venir find l'history quand tout sera correctement connecté
    # - remplacer Shop.all par une recherche en fonction du product alternative sélectionné
    @shops = Shop.all
    @markers = @shops.geocoded.map do |shop|
      {
        lat: shop.latitude,
        lng: shop.longitude,
        info_window_html: render_to_string(partial: "info_window", locals: { shop: shop }),
        marker_html: render_to_string(partial: "marker", locals: {shop: shop}),
      }
    end
  end

  def show
    # TODO: venir find l'history quand tout sera correctement connecté
    @shop = Shop.find(params[:id])
  end

  def itinerary
    # TODO: venir find l'history quand tout sera correctement connecté
    @shop = Shop.find(params[:id])
    user_loc = [current_user.longitude, current_user.latitude]
    @options = {
      # [lng, lat]
      center: user_loc,
      zoom: 15,
      class: "h-100 w-100",
      token: ENV['MAPBOX_API_KEY'],
      path: "cycling",
      path_options: {
        line_color: "#000",
        # line_width: 2
      },
      markers: [
        user_loc,
        [@shop.longitude, @shop.latitude]
      ]
    }
  end
end

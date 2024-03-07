module ApplicationHelper
  Mapbox.access_token = ENV['MAPBOX_API_KEY']

  def map(options = {})
    content_tag(:div, '', id: 'map', class: options[:class], data: map_data(options))
  end

  private

  def map_data(options)
    {
      controller: 'map',
      map_center_value: options.fetch(:center, { lat: 0, lng: 0 }),
      map_zoom_value: options.fetch(:zoom, 15),
      map_markers_value: options.fetch(:markers, []),
      map_token_value: options.fetch(:token, Mapbox.access_token),
      map_path_value: options.fetch(:path, 'line'),
      map_path_coordinates_value: route_data(options[:markers], options[:path]),
      map_path_options_value: options.fetch(:path_options, {})
    }
  end

  def route_data(markers, type)
    return [] if type == 'line' || markers.blank?

    coordinates = markers_to_coordinates(markers)
    fetch_route(coordinates, type)
  end

  def markers_to_coordinates(markers)
    markers.map { |marker| { longitude: marker[0], latitude: marker[1] } }
  end

  def fetch_route(coordinates, type)
    response = Mapbox::Directions.directions(coordinates, type, geometries: 'geojson').first
    response.dig('routes', 0, 'geometry', 'coordinates') || []
  end
end

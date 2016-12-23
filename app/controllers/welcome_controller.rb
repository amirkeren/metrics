class WelcomeController < ApplicationController

  helper_method :get_driver_names
  helper_method :get_metric_names

  @@uri = URI.parse(ENV['DATABASE_URL'])
  @@conn = PGconn.connect(@@uri.hostname, @@uri.port, nil, nil, @@uri.path[1..-1], @@uri.user, @@uri.password)

  BASE_GOOGLE_URL = "http://maps.googleapis.com/maps/api/staticmap?size=640x640&zoom=10"

  def get_metric_names_by_driver_name(driver_name)
    result = []
    rows = @@conn.exec("SELECT distinct metrics.data->>'metric_name' as metric_name FROM metrics, drivers WHERE metrics.data->>'driver_id' = drivers.data->>'id' AND drivers.data->>'name' = '" + driver_name + "'")
    rows.each do |row|
      result.push(row['metric_name'])
    end
    result
  end

  def get_metric_locations(metric_names)
    result = []
    if metric_names.length > 0
      metric_names_str = ""
      metric_names.each do |metric_name|
        metric_names_str += metric_name + ","
      end
      rows = @@conn.exec("SELECT distinct data->>'lat' as lat, data->>'lon' as lon from metrics where data->>'metric_name' = ANY ('{" + metric_names_str[0, metric_names_str.size - 1] + "}'::text[]) limit 10")
      rows.each do |row|
        result.push(row['lat'] + "," + row['lon'])
      end
    end
    result
  end

  def get_metric_names
    metric_names = []
    rows = @@conn.exec("SELECT distinct data->>'metric_name' as metric_name FROM metrics order by metric_name")
    rows.each do |row|
      metric_names.push(row['metric_name'])
    end
    metric_names
  end

  def get_driver_names
    driver_names = []
    rows = @@conn.exec("SELECT distinct data->>'name' as name FROM drivers order by name")
    rows.each do |row|
      driver_names.push(row['name'])
    end
    driver_names
  end

  def google_map(coordinates_list)
    map_result = BASE_GOOGLE_URL
    if coordinates_list.length > 0
      map_result += "&center=#{coordinates_list[0]}"
      coordinates_list.each do |coordinates|
        map_result += "&markers=#{coordinates}"
      end
    end
    map_result
  end

  def get_coordinates_by_driver
    metric_names = get_metric_names_by_driver_name(params[:name])
    coordinates = google_map(get_metric_locations(metric_names))
    render :text => coordinates
  end

  def get_coordinates_by_metric
    coordinates = google_map(get_metric_locations([params[:name]]))
    render :text => coordinates
  end

  def index
  end

end

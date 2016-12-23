task :import do

  require 'json'
	require 'net/http'
	require 'uri'
	require 'pg'

  DRIVERS_JSON = 'https://raw.githubusercontent.com/gtforge/CodeChallenge/master/drivers.json'
  METRICS_JSON = 'https://raw.githubusercontent.com/gtforge/CodeChallenge/master/metrics.json'

	def read_from_url(url)
		uri = URI.parse(url)
  	response = Net::HTTP.get_response(uri)
  	return response.body
	end

  def build_json(rows, simple)
      if simple
        result = JSON.parse(rows)
      else
        result = []
			  rows.each do |row|
          json = JSON.parse(row)
          if json.key?('driver_id')
            result << json
          end
        end
			end
      return result
	end

	def insert_to_table(conn, json, table)
			json.each do |entry|
					conn.exec("INSERT INTO " + table + " VALUES ('" + entry.to_json + "')")
			end
	end

	uri = URI.parse(ENV['DATABASE_URL'])
	conn = PGconn.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1],
  	uri.user, uri.password)

	drivers = build_json(read_from_url(DRIVERS_JSON), true)
	metrics = build_json(read_from_url(METRICS_JSON).split(/\n+/), false)

	insert_to_table(conn, drivers, 'drivers')
  insert_to_table(conn, metrics, 'metrics')

end

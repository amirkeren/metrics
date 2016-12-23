# Metrics

1. Data model can be found in db/schema.rb
2. Rake import task can be found under lib/tasks/import.Rake and triggered by running - "heroku run rake import"
3. index.erb is the view and welcome_controller.rb is the relevant controller to show the metrics

* I chose to limit the number of coordinates to display to a maximum of 10
* The DB is being populated by the json files as they appear in the git repository

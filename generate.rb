#!/usr/bin/env ruby
# frozen_string_literal: true

require 'timezone_finder'
require 'fileutils'
require 'csv'

FileUtils.rm_rf('_site')
FileUtils.mkdir_p('_site')

Dir.chdir('_site') do
  system('curl -o cities.zip https://simplemaps.com/static/data/world-cities/basic/simplemaps_worldcities_basicv1.5.zip')
  system('unzip cities.zip')
end

tf = TimezoneFinder.create

csv = CSV.read('_site/worldcities.csv')

CSV.open('_site/cities_time_zones.csv', 'w') do |output|
  csv.drop(1).each do |city|
    name, _, lat, lon, country = city
    time_zone = tf.timezone_at(lng: lon.to_f, lat: lat.to_f)
    output << [name, country, time_zone]
  end
end

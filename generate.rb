#!/usr/bin/env ruby
# frozen_string_literal: true

require 'timezone_finder'
require 'fileutils'
require 'csv'
require 'json'

FileUtils.rm_rf('_site')
FileUtils.mkdir_p('_site')

Dir.chdir('_site') do
  system('curl -o cities.zip https://download.geonames.org/export/dump/cities15000.zip')
  system('unzip cities.zip')
end

tf = TimezoneFinder.create

csv = CSV.open("_site/cities15000.txt", "r", { :col_sep => "\t" })

cities = csv.map do |city|
  _, name, _, keywords, lat, lon, _, _, country = city
  time_zone = city[-2]
  
  # no need to lookup, Geonames data is super!
  # just for validation
  time_zone_calc = tf.timezone_at(lng: lon.to_f, lat: lat.to_f)
  STDERR.puts "#{name} - #{time_zone_calc} != #{time_zone} (#{city[-1]})" if time_zone != time_zone_calc
  
  {
    name: name,
    country: country,
    keywords: keywords,
    time_zone: time_zone,
  }
end

File.open('_site/cities_time_zones.json','w') do |output|
  output.write JSON.pretty_generate(cities)
end


CSV.open('_site/cities_time_zones.csv', 'w') do |output|
  cities.each do |city|
    output << city.values
  end
end

File.open('_site/_redirects', 'w') do |f| 
  f.puts '/   https://github.com/igor-makarov/timezones 301'
end

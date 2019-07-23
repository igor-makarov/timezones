#!/usr/bin/env ruby
# frozen_string_literal: true

require 'timezone_finder'
require 'fileutils'
require 'csv'
require 'json'

def download_and_unzip(url)
  Dir.chdir('_site') do
    system("curl -o output.zip \"#{url}\"")
    system('unzip output.zip')
    FileUtils.rm_rf('output.zip')
  end
end

FileUtils.rm_rf('_site')
FileUtils.mkdir_p('_site')

download_and_unzip 'https://download.geonames.org/export/dump/cities15000.zip'

tf = TimezoneFinder.create

csv = CSV.open("_site/cities15000.txt", "r", { :col_sep => "\t" })

cities = csv.map do |city|
  _, name, _, keywords, lat, lon, _, _, countryCode, _, admin_region = city
  time_zone = city[-2]
  
  # no need to lookup, Geonames data is super!
  # just for validation
  time_zone_calc = tf.timezone_at(lng: lon.to_f, lat: lat.to_f)
  STDERR.puts "#{name} - #{time_zone_calc} != #{time_zone} (#{city[-1]})" if time_zone != time_zone_calc
  
  # the keyowords are comma separated
  keywords = CSV.parse(keywords || '')
  
  city_hash = {
    name: name,
    countryCode: countryCode,
    keywords: keywords,
    timeZone: time_zone,
  }
  city_hash[:adminRegion] = admin_region if countryCode == "US"  
  city_hash
end

File.open('_site/cities_time_zones.json','w') do |output|
  output.write JSON.pretty_generate(cities)
end


CSV.open('_site/cities_time_zones.csv', 'w') do |output|
  cities.each do |city|
    output << [city[:name], city[:countryCode], city[:adminRegion], city[:keywords].join(','), city[:timeZone]]
  end
end

File.open('_site/_redirects', 'w') do |f| 
  f.puts '/   https://github.com/igor-makarov/timezones 301'
end

File.open('_site/_headers', 'w') do |f| 
  f.puts '/cities_time_zones.json'
  f.puts '  Content-type: application/json; charset=utf-8'
end

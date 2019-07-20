#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'csv'
require 'json'

def download(url)
  Dir.chdir('_site') do
    system("curl -O \"#{url}\"")
  end
end


def download_and_unzip(url)
  Dir.chdir('_site') do
    system("curl -o output.zip \"#{url}\"")
    system('unzip output.zip')
    FileUtils.rm_rf('output.zip')
  end
end

FileUtils.rm_rf('_site')
FileUtils.mkdir_p('_site')

# download 'file:///Users/igor/Downloads/admin1CodesASCII.txt'
download 'https://download.geonames.org/export/dump/admin1CodesASCII.txt'

admin_ids = CSV.open("_site/admin1CodesASCII.txt", "r", { :col_sep => "\t" }).each_with_object({}) do |row, admin_ids|
  id = row[-1]
  admin_ids[row.first.split('.')] = id
end

# download_and_unzip 'file:///Users/igor/Downloads/cities15000.zip'
download_and_unzip 'https://download.geonames.org/export/dump/cities15000.zip'

csv = CSV.open("_site/cities15000.txt", "r", { :col_sep => "\t" })

cities = csv.each_with_object({}) do |city, cities|
  id, name, _, keywords, lat, lon, _, _, countryCode, _, admin_region = city

  time_zone = city[-2]
  
  cities[id] = {
    name: name,
    countryCode: countryCode,
    adminRegion: admin_ids[[countryCode, admin_region]],
    timeZone: time_zone,
  }
end

# download_and_unzip 'file:///Users/igor/Downloads/alternateNames.zip'
download_and_unzip 'https://download.geonames.org/export/dump/alternateNames.zip'

all_admin_ids = Set.new(admin_ids.values)

translations = CSV.open("_site/alternateNames.txt", "r", col_sep: "\t", liberal_parsing: true).each_with_object({}) do |name, translations|
  rowid, geoname_id, lang_code, value = name
  next if cities[geoname_id].nil? && !all_admin_ids.include?(geoname_id)
  next if lang_code.nil? || lang_code.length != 2

  translations[geoname_id] ||= []
  translations[geoname_id] << [lang_code, value]
end

cities = cities.map do |id, city|
  city[:names] = translations[id].to_h
  city[:adminRegion] = translations[city[:adminRegion]].to_h
  city
end

File.open('_site/cities_time_zones.json','w') do |output|
  output.write JSON.pretty_generate(cities)
end


# CSV.open('_site/cities_time_zones.csv', 'w') do |output|
#   cities.values.each do |city|
#     output << [city[:name], city[:countryCode], city[:keywords].values.join(','), city[:time_zone]]
#   end
# end

File.open('_site/_redirects', 'w') do |f| 
  f.puts '/   https://github.com/igor-makarov/timezones 301'
end

File.open('_site/_headers', 'w') do |f| 
  f.puts '/cities_time_zones.json'
  f.puts '  Content-type: application/json; charset=utf-8'
end

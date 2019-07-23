# TimeZones - lots of cities and their timezones

This small project generates a CSV (and JSON!) of many cities and their IANA timezones.  
It was inspired by Dato by @sindresorhus which didn't have San Francisco!

The output is deployed to Netlfy. It downloads a CC-BY list of about 25k cities and their time zones from [Geonames](http://www.geonames.org/) and writes it into simplifed CSV and JSON files.  
For US cities, the JSON also contains `adminRegion` property with the state. Unfortunately, localized admin region data isn't readily available for the rest.

The output can be downloaded at (https://timezones.netlify.com/cities_time_zones.csv) or (https://timezones.netlify.com/cities_time_zones.json).

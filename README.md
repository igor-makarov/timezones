# TimeZones - lots of cities and their timezones

This small project generates a CSV of many cities and their IANA timezones.  
It was inspired by Dato by @sindresorhus which didn't have San Francisco!

The output is deployed to Netlfy. It downloads a CC-BY list of about 13k cities and their coordinates from [simplemaps.com](https://simplemaps.com/data/world-cities).  
Next, it runs it through [timezone_finder](https://github.com/gunyarakun/timezone_finder) to get the IANA timezone. 

The output can be downloaded at (https://timezones.netlify.com/cities_time_zones.csv)

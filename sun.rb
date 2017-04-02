# Calculates the sunrise/sunset times for a given date, lattitude, longitude, and altitude

require 'date'

puts "Date: \n"
date = DateTime.strptime(gets.chomp, "%F") # ISO 8601 date

puts "Latitude: \n"
latitude = gets.chomp.to_f

puts "Longitude: \n"
lon_west = -(gets.chomp.to_f) # Convert to west longitude

puts "Altitude: \n"
altitude = gets.chomp.to_f

# Implements https://en.wikipedia.org/wiki/Sunrise_equation
# All angles are stored in degrees

# Conversion between radians and degrees is necessary to use Ruby's trig equations
def to_radians(degrees)
	degrees * Math::PI / 180
end
def to_degrees(radians)
	radians * 180 / Math::PI
end

# Astronomical Julian day number since Jan 1st, 2000 12:00.
n = date.jd.to_f - 2451545.0 + 0.0008

# Approximation of mean solar time at lon_west (longitude west)
j_star = (lon_west/360) + n

# Solar mean anomaly
m = (357.5291 + 0.98560028 * j_star) % 360

# Equation of the center
c = (1.9148 * Math::sin(to_radians(m))) + (0.0200 * Math::sin(2*to_radians(m))) + (0.0003 * Math::sin(3*to_radians(m)))

# Ecliptic longitude
lambda = (m + c + 180 + 102.9372) % 360

# Hour angle for solar transit
j_transit = j_star + (0.0053 * Math::sin(to_radians(m))) - (0.0069 * Math::sin(2*to_radians(lambda)))

# Declination of the sun
delta = to_degrees Math::asin(Math::sin(to_radians(lambda)) * Math::sin(0.40910517))

# Solar altitude at sunrise/sunset - accounts for altitude and atmospheric refraction
solar_altitude = ((-2.076 * Math::sqrt(altitude)) / 60) - 0.83

# Omega is the hour angle from the observer's zenith
numerator = Math::sin(to_radians(solar_altitude)) - Math::sin(to_radians(latitude)) * Math::sin(to_radians(delta))
denominator = Math::cos(to_radians(latitude)) * Math::cos(to_radians(delta))
omega = to_degrees Math::acos(numerator/denominator)

sunset = DateTime.jd((j_transit + 2451545 - 0.0008 + 0.5) + (omega/360))
sunrise = DateTime.jd((j_transit + 2451545 - 0.0008 + 0.5) - (omega/360))

puts "Sunrise: #{sunrise.to_s}\n"
puts "Sunset: #{sunset.to_s}\n"

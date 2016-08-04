# Calculates the sunrise/sunset times for a given date, lattitude, longitude, and altitude
# Usage: ruby sun.rb <date> <latitude> <longitude> <altitude>

require 'date'

print "Date: \n"
date = DateTime.strptime(gets.chomp, "%F") # ISO 8601 date

print "Latitude: \n"
latitude = gets.chomp.to_f

print "Longitude: \n"
lon_west = -(gets.chomp.to_f) # Convert to west longitude

print "Altitude: \n"
altitude = gets.chomp.to_f

# Implements https://en.wikipedia.org/wiki/Sunrise_equation
# All angles are in degrees unless variable name ends with _rad

# Conversion between radians and degrees is necessary to use Ruby's trig equations
to_radians = lambda {|degrees| degrees * Math::PI / 180}
to_degrees = lambda {|radians| radians * 180 / Math::PI}

latitude_rad = to_radians.call latitude

# Astronomical Julian day number since Jan 1st, 2000 12:00.
n = date.jd.to_f - 2451545.0 + 0.0008

# Approximation of mean solar time at lon_west (longitude west)
j_star = (lon_west/360) + n

# Solar mean anomaly
M = (357.5291 + 0.98560028 * j_star) % 360
M_rad = to_radians.call M

# Equation of the center
C = (1.9148 * Math::sin(M_rad)) + (0.0200 * Math::sin(2*M_rad)) + (0.0003 * Math::sin(3*M_rad))

# Ecliptic longitude
lambda = (M + C + 180 + 102.9372) % 360
lambda_rad = to_radians.call lambda

# Hour angle for solar transit
j_transit = j_star + (0.0053 * Math::sin(M_rad)) - (0.0069 * Math::sin(2*lambda_rad))

# Declination of the sun
delta_rad = Math::asin(Math::sin(lambda_rad) * Math::sin(0.40910517))

# Solar altitude at sunrise/sunset - accounts for altitude and atmospheric refraction
solar_altitude = ((-2.076 * Math::sqrt(altitude)) / 60) - 0.83
solar_altitude_rad = to_radians.call solar_altitude

# Omega is the hour angle from the observer's zenith
numerator = Math::sin(solar_altitude_rad) - Math::sin(latitude_rad) * Math::sin(delta_rad)
denominator = Math::cos(latitude_rad) * Math::cos(delta_rad)
omega = to_degrees.call Math::acos(numerator/denominator)

sunset = DateTime.jd((j_transit + 2451545 - 0.0008 + 0.5) + (omega/360))
sunrise = DateTime.jd((j_transit + 2451545 - 0.0008 + 0.5) - (omega/360))

print "Sunrise: " + sunrise.to_s + "\n"
print "Sunset: " + sunset.to_s + "\n"

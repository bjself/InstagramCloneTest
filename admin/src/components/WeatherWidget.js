import React, { useState, useEffect } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import Typography from '@material-ui/core/Typography';
import CircularProgress from '@material-ui/core/CircularProgress';
import ErrorIcon from '@material-ui/icons/Error';

const useStyles = makeStyles((theme) => ({
  card: {
    maxWidth: 350,
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    color: '#fff',
    boxShadow: '0 8px 16px rgba(0, 0, 0, 0.2)',
  },
  cardContent: {
    padding: theme.spacing(2),
  },
  title: {
    fontSize: 14,
    fontWeight: 500,
    marginBottom: theme.spacing(1),
  },
  container: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: theme.spacing(2),
  },
  temperature: {
    fontSize: 48,
    fontWeight: 'bold',
    display: 'flex',
    alignItems: 'flex-start',
  },
  tempUnit: {
    fontSize: 24,
    marginTop: 8,
  },
  description: {
    fontSize: 18,
    textTransform: 'capitalize',
    marginTop: theme.spacing(1),
  },
  details: {
    marginTop: theme.spacing(2),
    display: 'grid',
    gridTemplateColumns: '1fr 1fr',
    gap: theme.spacing(1),
  },
  detailItem: {
    fontSize: 12,
    opacity: 0.9,
  },
  label: {
    fontSize: 10,
    opacity: 0.8,
    textTransform: 'uppercase',
  },
  loading: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 200,
  },
  error: {
    display: 'flex',
    alignItems: 'center',
    gap: theme.spacing(1),
    color: '#ffcdd2',
  },
}));

export default function WeatherWidget() {
  const classes = useStyles();
  const [weather, setWeather] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchWeather = async () => {
      try {
        setLoading(true);
        setError(null);

        // Get user's location
        if ('geolocation' in navigator) {
          navigator.geolocation.getCurrentPosition(
            async (position) => {
              const { latitude, longitude } = position.coords;
              
              // Using Open-Meteo API (free, no API key required)
              const weatherResponse = await fetch(
                `https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&temperature_unit=fahrenheit`
              );

              if (!weatherResponse.ok) {
                throw new Error('Failed to fetch weather data');
              }

              const weatherData = await weatherResponse.json();
              const current = weatherData.current;

              // Get location name from reverse geocoding
              const geoResponse = await fetch(
                `https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitude}`
              );

              let locationName = 'Current Location';
              if (geoResponse.ok) {
                const geoData = await geoResponse.json();
                locationName = geoData.address?.city || geoData.address?.town || 'Current Location';
              }

              setWeather({
                location: locationName,
                temperature: Math.round(current.temperature_2m),
                description: getWeatherDescription(current.weather_code),
                humidity: current.relative_humidity_2m,
                windSpeed: Math.round(current.wind_speed_10m * 10) / 10,
              });
              setLoading(false);
            },
            (err) => {
              setError('Unable to access your location. Please enable location services.');
              setLoading(false);
            }
          );
        } else {
          setError('Geolocation is not supported by your browser.');
          setLoading(false);
        }
      } catch (err) {
        setError(err.message || 'Failed to fetch weather data');
        setLoading(false);
      }
    };

    fetchWeather();

    // Refresh weather every 10 minutes
    const interval = setInterval(fetchWeather, 600000);
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <Card className={classes.card}>
        <CardContent className={`${classes.cardContent} ${classes.loading}`}>
          <CircularProgress style={{ color: '#fff' }} />
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Card className={classes.card}>
        <CardContent className={classes.cardContent}>
          <div className={classes.error}>
            <ErrorIcon />
            <Typography variant="body2">{error}</Typography>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={classes.card}>
      <CardContent className={classes.cardContent}>
        <Typography className={classes.title}>
          {weather?.location}
        </Typography>

        <div className={classes.container}>
          <div>
            <div className={classes.temperature}>
              <span>{weather?.temperature}</span>
              <span className={classes.tempUnit}>°F</span>
            </div>
            <Typography className={classes.description}>
              {weather?.description}
            </Typography>
          </div>
        </div>

        <div className={classes.details}>
          <div className={classes.detailItem}>
            <div className={classes.label}>Humidity</div>
            <div>{weather?.humidity}%</div>
          </div>
          <div className={classes.detailItem}>
            <div className={classes.label}>Wind Speed</div>
            <div>{weather?.windSpeed} mph</div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

// Convert WMO weather codes to descriptions
function getWeatherDescription(code) {
  const descriptions = {
    0: 'Clear sky',
    1: 'Mainly clear',
    2: 'Partly cloudy',
    3: 'Overcast',
    45: 'Foggy',
    48: 'Foggy',
    51: 'Light drizzle',
    53: 'Moderate drizzle',
    55: 'Dense drizzle',
    61: 'Slight rain',
    63: 'Moderate rain',
    65: 'Heavy rain',
    71: 'Slight snow',
    73: 'Moderate snow',
    75: 'Heavy snow',
    80: 'Slight showers',
    81: 'Moderate showers',
    82: 'Violent showers',
    85: 'Slight snow showers',
    86: 'Heavy snow showers',
    95: 'Thunderstorm',
    96: 'Thunderstorm with slight hail',
    99: 'Thunderstorm with heavy hail',
  };
  return descriptions[code] || 'Unknown';
}

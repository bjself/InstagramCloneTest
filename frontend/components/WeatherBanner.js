import React, { useEffect, useState } from 'react';
import { View, Text, ActivityIndicator } from 'react-native';
import { weather as weatherStyles } from './styles';

export default function WeatherBanner() {
  const [weatherData, setWeatherData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  useEffect(() => {
    fetchWeather();
  }, []);

  const fetchWeather = async () => {
    try {
      setLoading(true);
      setError(false);
      
      // Get user's coordinates - using a default for demo, or you could use geolocation
      // Using open-meteo API which requires no API key
      const response = await fetch(
        'https://api.open-meteo.com/v1/forecast?latitude=40.7128&longitude=-74.0060&current=temperature_2m,weather_code&temperature_unit=fahrenheit'
      );
      
      if (!response.ok) throw new Error('Weather fetch failed');
      
      const data = await response.json();
      const current = data.current;
      
      // Convert WMO weather code to simple condition
      const condition = getWeatherCondition(current.weather_code);
      
      setWeatherData({
        temperature: Math.round(current.temperature_2m),
        condition: condition
      });
    } catch (err) {
      console.log('Weather fetch error:', err);
      setError(true);
    } finally {
      setLoading(false);
    }
  };

  const getWeatherCondition = (code) => {
    // WMO Weather interpretation codes
    if (code === 0) return 'Clear';
    if (code === 1 || code === 2) return 'Cloudy';
    if (code === 3) return 'Overcast';
    if (code === 45 || code === 48) return 'Foggy';
    if (code >= 51 && code <= 67) return 'Rainy';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain';
    if (code >= 85 && code <= 86) return 'Snow';
    if (code >= 80 && code <= 99) return 'Storm';
    return 'Partly Cloudy';
  };

  if (error) {
    return null; // Don't show banner if there's an error
  }

  return (
    <View style={weatherStyles.banner}>
      {loading ? (
        <ActivityIndicator size="small" color="#999" />
      ) : weatherData ? (
        <>
          <Text style={weatherStyles.temperature}>
            {weatherData.temperature}°F
          </Text>
          <Text style={weatherStyles.condition}>
            {weatherData.condition}
          </Text>
        </>
      ) : null}
    </View>
  );
}

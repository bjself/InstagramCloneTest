/**
 * Weather service — fetches current weather from Open-Meteo (free, no API key needed).
 * We map their WMO weather-code to a short human-readable description and an emoji icon.
 */

const BASE_URL = 'https://api.open-meteo.com/v1/forecast';

/** WMO Weather Interpretation Codes → { label, icon } */
const WMO_CODES = {
    0:  { label: 'Clear sky',           icon: '☀️' },
    1:  { label: 'Mainly clear',        icon: '🌤️' },
    2:  { label: 'Partly cloudy',       icon: '⛅' },
    3:  { label: 'Overcast',            icon: '☁️' },
    45: { label: 'Foggy',               icon: '🌫️' },
    48: { label: 'Icy fog',             icon: '🌫️' },
    51: { label: 'Light drizzle',       icon: '🌦️' },
    53: { label: 'Drizzle',             icon: '🌦️' },
    55: { label: 'Heavy drizzle',       icon: '🌧️' },
    61: { label: 'Light rain',          icon: '🌧️' },
    63: { label: 'Rain',                icon: '🌧️' },
    65: { label: 'Heavy rain',          icon: '🌧️' },
    71: { label: 'Light snow',          icon: '🌨️' },
    73: { label: 'Snow',                icon: '❄️' },
    75: { label: 'Heavy snow',          icon: '❄️' },
    77: { label: 'Snow grains',         icon: '🌨️' },
    80: { label: 'Light showers',       icon: '🌦️' },
    81: { label: 'Showers',             icon: '🌧️' },
    82: { label: 'Heavy showers',       icon: '⛈️' },
    85: { label: 'Snow showers',        icon: '🌨️' },
    86: { label: 'Heavy snow showers',  icon: '❄️' },
    95: { label: 'Thunderstorm',        icon: '⛈️' },
    96: { label: 'Thunderstorm w/ hail',icon: '⛈️' },
    99: { label: 'Thunderstorm w/ hail',icon: '⛈️' },
};

/**
 * Fetches current weather for the given coordinates.
 * @param {number} latitude
 * @param {number} longitude
 * @returns {Promise<{ temperature: number, unit: string, condition: string, icon: string }>}
 */
export async function fetchWeather(latitude, longitude) {
    const url =
        `${BASE_URL}?latitude=${latitude}&longitude=${longitude}` +
        `&current_weather=true&temperature_unit=fahrenheit`;

    const response = await fetch(url);
    if (!response.ok) {
        throw new Error(`Weather API responded with status ${response.status}`);
    }

    const json = await response.json();
    const { temperature, weathercode } = json.current_weather;

    const wmo = WMO_CODES[weathercode] || { label: 'Unknown', icon: '🌡️' };

    return {
        temperature: Math.round(temperature),
        unit: '°F',
        condition: wmo.label,
        icon: wmo.icon,
    };
}

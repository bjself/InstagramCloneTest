const quotes = [
  "The only way to do great work is to love what you do. - Steve Jobs",
  "Life is what happens when you're busy making other plans. - John Lennon",
  "The future belongs to those who believe in the beauty of their dreams. - Eleanor Roosevelt",
  "It is during our darkest moments that we must focus to see the light. - Aristotle",
  "The way to get started is to quit talking and begin doing. - Walt Disney",
  "Don't let yesterday take up too much of today. - Will Rogers",
  "You learn more from failure than from success. - Unknown",
  "It's not whether you get knocked down, it's whether you get up. - Vince Lombardi",
  "Believe you can and you're halfway there. - Theodore Roosevelt",
  "The best time to plant a tree was 20 years ago. The second best time is now. - Chinese Proverb",
  "Success is not final, failure is not fatal. - Winston Churchill",
  "You don't have to be great to start, but you have to start to be great. - Zig Ziglar",
  "Dream bigger. Do bigger. - Unknown",
  "Don't watch the clock; do what it does. Keep going. - Sam Levenson",
  "Everything you want is on the other side of fear. - George Addair",
  "Great things never came from comfort zones. - Unknown",
  "Success doesn't just find you. You have to go out and get it. - Unknown",
  "The harder you work for something, the greater you'll feel when you achieve it. - Unknown",
  "Dream it. Believe it. Build it. - Unknown",
  "Do something today that your future self will thank you for. - Unknown"
];

export const getQuoteOfTheDay = () => {
  const today = new Date();
  const dayOfYear = Math.floor((today - new Date(today.getFullYear(), 0, 0)) / 1000 / 60 / 60 / 24);
  return quotes[dayOfYear % quotes.length];
};

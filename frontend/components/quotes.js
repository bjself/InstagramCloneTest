const quotes = [
  "The only way to do great work is to love what you do. - Steve Jobs",
  "Innovation distinguishes between a leader and a follower. - Steve Jobs",
  "Life is what happens when you're busy making other plans. - John Lennon",
  "The future belongs to those who believe in the beauty of their dreams. - Eleanor Roosevelt",
  "It is during our darkest moments that we must focus to see the light. - Aristotle",
  "The only impossible journey is the one you never begin. - Tony Robbins",
  "In the middle of difficulty lies opportunity. - Albert Einstein",
  "Success is not final, failure is not fatal. - Winston Churchill",
  "Believe you can and you're halfway there. - Theodore Roosevelt",
  "The best time to plant a tree was 20 years ago. The second best time is now. - Chinese Proverb",
  "Your time is limited, so don't waste it living someone else's life. - Steve Jobs",
  "The only source of knowledge is experience. - Albert Einstein",
  "What we think, we become. - Buddha",
  "Whether you think you can, or you think you can't – you're right. - Henry Ford",
  "Great minds discuss ideas; average minds discuss events; small minds discuss people. - Eleanor Roosevelt",
  "The question isn't who is going to let me; it's who is going to stop me. - Ayn Rand",
  "Everything you want is on the other side of fear. - Jack Canfield",
  "Success usually comes to those who are too busy to be looking for it. - Henry David Thoreau",
  "The way to get started is to quit talking and begin doing. - Walt Disney",
  "Don't let yesterday take up too much of today. - Will Rogers"
];

function getQuoteOfTheDay() {
  // Use date to ensure same quote throughout the day
  const today = new Date();
  const dayOfYear = Math.floor((today - new Date(today.getFullYear(), 0, 0)) / 86400000);
  const index = dayOfYear % quotes.length;
  return quotes[index];
}

export { getQuoteOfTheDay, quotes };

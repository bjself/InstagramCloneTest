import React from 'react'
import { StyleSheet, Text, View } from 'react-native'

const QUOTES = [
    { text: "The best way to get started is to quit talking and begin doing.", author: "Walt Disney" },
    { text: "The pessimist sees difficulty in every opportunity. The optimist sees opportunity in every difficulty.", author: "Winston Churchill" },
    { text: "Don't let yesterday take up too much of today.", author: "Will Rogers" },
    { text: "You learn more from failure than from success. Don't let it stop you. Failure builds character.", author: "Unknown" },
    { text: "It's not whether you get knocked down, it's whether you get up.", author: "Vince Lombardi" },
    { text: "If you are working on something that you really care about, you don't have to be pushed. The vision pulls you.", author: "Steve Jobs" },
    { text: "People who are crazy enough to think they can change the world, are the ones who do.", author: "Rob Siltanen" },
    { text: "Failure will never overtake me if my determination to succeed is strong enough.", author: "Og Mandino" },
    { text: "Entrepreneurs are great at dealing with uncertainty and also very good at creating it.", author: "Mohnish Pabrai" },
    { text: "We may encounter many defeats but we must not be defeated.", author: "Maya Angelou" },
    { text: "Knowing is not enough; we must apply. Wishing is not enough; we must do.", author: "Johann Wolfgang Von Goethe" },
    { text: "Imagine your life is perfect in every respect; what would it look like?", author: "Brian Tracy" },
    { text: "We generate fears while we sit. We overcome them by action.", author: "Dr. Henry Link" },
    { text: "Whether you think you can or think you can't, you're right.", author: "Henry Ford" },
    { text: "Security is mostly a superstition. Life is either a daring adventure or nothing.", author: "Helen Keller" },
    { text: "The man who has confidence in himself gains the confidence of others.", author: "Hasidic Proverb" },
    { text: "The only way to do great work is to love what you do.", author: "Steve Jobs" },
    { text: "Innovation distinguishes between a leader and a follower.", author: "Steve Jobs" },
    { text: "In the middle of every difficulty lies opportunity.", author: "Albert Einstein" },
    { text: "Do not go where the path may lead, go instead where there is no path and leave a trail.", author: "Ralph Waldo Emerson" },
    { text: "You miss 100% of the shots you don't take.", author: "Wayne Gretzky" },
    { text: "The secret of getting ahead is getting started.", author: "Mark Twain" },
    { text: "Act as if what you do makes a difference. It does.", author: "William James" },
    { text: "Success is not final, failure is not fatal: it is the courage to continue that counts.", author: "Winston Churchill" },
    { text: "Hardships often prepare ordinary people for an extraordinary destiny.", author: "C.S. Lewis" },
    { text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt" },
    { text: "Don't watch the clock; do what it does. Keep going.", author: "Sam Levenson" },
    { text: "Keep your eyes on the stars, and your feet on the ground.", author: "Theodore Roosevelt" },
    { text: "Try not to become a man of success. Rather become a man of value.", author: "Albert Einstein" },
    { text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius" },
]

function getDayOfYear() {
    const now = new Date()
    const startOfYear = new Date(now.getFullYear(), 0, 0)
    return Math.floor((now - startOfYear) / 1000 / 60 / 60 / 24)
}

export default function QuoteOfDay() {
    const dayOfYear = getDayOfYear()
    const { text: quoteText, author } = QUOTES[dayOfYear % QUOTES.length]

    return (
        <View style={styles.container}>
            <Text style={styles.quoteIcon}>"</Text>
            <Text style={styles.quoteText}>{quoteText}</Text>
            <Text style={styles.author}>— {author}</Text>
        </View>
    )
}

const styles = StyleSheet.create({
    container: {
        backgroundColor: '#f0f7ff',
        borderLeftWidth: 4,
        borderLeftColor: '#3897f0',
        paddingTop: 14,
        paddingBottom: 14,
        paddingLeft: 16,
        paddingRight: 16,
    },
    quoteIcon: {
        fontSize: 32,
        color: '#3897f0',
        lineHeight: 28,
        fontWeight: '700',
    },
    quoteText: {
        fontSize: 14,
        color: '#262626',
        fontStyle: 'italic',
        lineHeight: 22,
        paddingBottom: 8,
    },
    author: {
        fontSize: 13,
        color: '#8e8e8e',
        fontWeight: '600',
    },
})

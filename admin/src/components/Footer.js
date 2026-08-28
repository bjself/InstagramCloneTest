import React, { useState, useEffect } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { Box, Typography, Container } from '@material-ui/core';

const useStyles = makeStyles((theme) => ({
    footer: {
        backgroundColor: theme.palette.grey[900],
        color: theme.palette.common.white,
        padding: theme.spacing(4, 0),
        marginTop: 'auto',
        borderTop: `1px solid ${theme.palette.divider}`,
    },
    container: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        textAlign: 'center',
    },
    quoteText: {
        fontStyle: 'italic',
        marginBottom: theme.spacing(1),
        fontSize: '1.1rem',
    },
    quoteAuthor: {
        fontSize: '0.9rem',
        color: theme.palette.grey[400],
    },
}));

const quotes = [
    { text: "The only way to do great work is to love what you do.", author: "Steve Jobs" },
    { text: "Innovation distinguishes between a leader and a follower.", author: "Steve Jobs" },
    { text: "Life is what happens when you're busy making other plans.", author: "John Lennon" },
    { text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt" },
    { text: "It is during our darkest moments that we must focus to see the light.", author: "Aristotle" },
    { text: "The only impossible journey is the one you never begin.", author: "Tony Robbins" },
    { text: "Success is not final, failure is not fatal.", author: "Winston Churchill" },
    { text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt" },
    { text: "Do what you can, with what you have, where you are.", author: "Theodore Roosevelt" },
    { text: "The best time to plant a tree was 20 years ago. The second best time is now.", author: "Chinese Proverb" },
];

export default function Footer() {
    const classes = useStyles();
    const [quote, setQuote] = useState(quotes[0]);

    useEffect(() => {
        const today = new Date();
        const dayOfYear = Math.floor((today - new Date(today.getFullYear(), 0, 0)) / 86400000);
        const quoteIndex = dayOfYear % quotes.length;
        setQuote(quotes[quoteIndex]);
    }, []);

    return (
        <Box component="footer" className={classes.footer}>
            <Container className={classes.container}>
                <Typography className={classes.quoteText}>
                    "{quote.text}"
                </Typography>
                <Typography className={classes.quoteAuthor}>
                    — {quote.author}
                </Typography>
            </Container>
        </Box>
    );
}

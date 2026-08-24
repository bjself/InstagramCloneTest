import React, { useEffect, useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';

/**
 * A header component that displays a title on the left and a live clock
 * (updating every second) on the right.  It is used as a custom header
 * for every Stack.Screen in App.js.
 */
export default function HeaderWithTime({ title }) {
    const [currentTime, setCurrentTime] = useState(new Date());

    useEffect(() => {
        const timer = setInterval(() => {
            setCurrentTime(new Date());
        }, 1000);

        // Clean up the interval when the component is removed from the screen.
        return () => clearInterval(timer);
    }, []);

    const formatted = currentTime.toLocaleTimeString([], {
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
    });

    return (
        <View style={styles.container}>
            <Text style={styles.title}>{title}</Text>
            <Text style={styles.clock}>{formatted}</Text>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        flex: 1,
        paddingHorizontal: 12,
    },
    title: {
        fontWeight: '700',
        fontSize: 18,
    },
    clock: {
        fontSize: 14,
        color: 'grey',
    },
});

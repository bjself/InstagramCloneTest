import React from 'react';
import { ActivityIndicator, StyleSheet, Text, View } from 'react-native';
import { connect } from 'react-redux';

/**
 * WeatherWidget — a compact banner shown at the top of the Feed.
 * Reads weather data from the Redux store; parent is responsible for fetching.
 */
function WeatherWidget({ weatherData, loading, error }) {
    if (loading) {
        return (
            <View style={styles.card}>
                <ActivityIndicator size="small" color="#3897f0" />
                <Text style={styles.loadingText}>Getting weather…</Text>
            </View>
        );
    }

    if (error) {
        return (
            <View style={[styles.card, styles.errorCard]}>
                <Text style={styles.errorIcon}>🌡️</Text>
                <Text style={styles.errorText}>Weather unavailable</Text>
            </View>
        );
    }

    if (!weatherData) {
        return null;
    }

    const { temperature, unit, condition, icon } = weatherData;

    return (
        <View style={styles.card}>
            <Text style={styles.icon}>{icon}</Text>
            <View style={styles.info}>
                <Text style={styles.temperature}>
                    {temperature}{unit}
                </Text>
                <Text style={styles.condition}>{condition}</Text>
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    card: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: '#f0f8ff',
        borderBottomWidth: 1,
        borderColor: '#e0e0e0',
        paddingTop: 10,
        paddingBottom: 10,
        paddingLeft: 16,
        paddingRight: 16,
    },
    errorCard: {
        backgroundColor: '#fff8f0',
    },
    icon: {
        fontSize: 28,
    },
    info: {
        paddingLeft: 12,
    },
    temperature: {
        fontSize: 18,
        fontWeight: '700',
        color: '#262626',
    },
    condition: {
        fontSize: 13,
        color: '#8e8e8e',
        paddingTop: 2,
    },
    loadingText: {
        paddingLeft: 10,
        color: '#8e8e8e',
        fontSize: 13,
    },
    errorIcon: {
        fontSize: 22,
    },
    errorText: {
        paddingLeft: 10,
        color: '#8e8e8e',
        fontSize: 13,
    },
});

const mapStateToProps = (store) => ({
    weatherData: store.weatherState.data,
    loading: store.weatherState.loading,
    error: store.weatherState.error,
});

export default connect(mapStateToProps)(WeatherWidget);

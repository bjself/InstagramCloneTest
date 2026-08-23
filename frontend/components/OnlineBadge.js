import React from 'react';
import { View, StyleSheet } from 'react-native';

const OnlineBadge = ({ isOnline }) => {
  return (
    <View style={[styles.badge, isOnline ? styles.online : styles.offline]} />
  );
};

const styles = StyleSheet.create({
  badge: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginRight: 8,
  },
  online: {
    backgroundColor: '#31a24c',
  },
  offline: {
    backgroundColor: '#9CA3AF',
  },
});

export default OnlineBadge;

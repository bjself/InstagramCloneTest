import React from 'react';
import { View, Text } from 'react-native';
import { text, utils } from '../../styles';
import { getQuoteOfTheDay } from './quotes';

function QuoteFooter() {
  const quote = getQuoteOfTheDay();

  return (
    <View style={{
      paddingVertical: 20,
      paddingHorizontal: 15,
      backgroundColor: '#f5f5f5',
      borderTopWidth: 1,
      borderColor: 'lightgrey',
      alignItems: 'center'
    }}>
      <Text style={[text.center, text.grey, { fontSize: 12, fontStyle: 'italic' }]}>
        "{quote}"
      </Text>
    </View>
  );
}

export default QuoteFooter;

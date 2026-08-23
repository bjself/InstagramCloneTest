import React from 'react';
import { View, Text } from 'react-native';
import { connect } from 'react-redux';
import OnlineBadge from './OnlineBadge';

function HeaderTitle({ title, isOnline }) {
  return (
    <View style={{ flexDirection: 'row', alignItems: 'center' }}>
      <OnlineBadge isOnline={isOnline} />
      <Text style={{ fontSize: 18, fontWeight: '700' }}>{title}</Text>
    </View>
  );
}

const mapStateToProps = (state) => ({
  isOnline: state.userState.isOnline,
});

export default connect(mapStateToProps)(HeaderTitle);

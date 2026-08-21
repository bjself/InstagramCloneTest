import React from 'react';
import { View, Text, TouchableOpacity, ScrollView } from 'react-native';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import { setLanguage } from '../../redux/actions/localization';
import { t, SUPPORTED_LANGUAGES } from '../../localization';

function LanguageSelector(props) {
  const currentLanguage = props.localization?.language || 'en';

  const handleLanguageChange = (lang) => {
    props.setLanguage(lang);
  };

  return (
    <ScrollView style={{ flex: 1, backgroundColor: 'white', padding: 10 }}>
      <View style={{ marginBottom: 20 }}>
        <Text style={{ fontSize: 18, fontWeight: 'bold', marginBottom: 15 }}>
          {t('profile.language', currentLanguage)}
        </Text>

        {Object.entries(SUPPORTED_LANGUAGES).map(([langCode, langName]) => (
          <TouchableOpacity
            key={langCode}
            onPress={() => handleLanguageChange(langCode)}
            style={{
              padding: 15,
              marginBottom: 10,
              borderRadius: 8,
              borderWidth: 2,
              borderColor: currentLanguage === langCode ? '#007AFF' : '#E0E0E0',
              backgroundColor: currentLanguage === langCode ? '#F0F7FF' : 'white',
            }}
          >
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
              <Text
                style={{
                  fontSize: 16,
                  fontWeight: currentLanguage === langCode ? 'bold' : 'normal',
                  color: currentLanguage === langCode ? '#007AFF' : '#333',
                }}
              >
                {langName}
              </Text>
              {currentLanguage === langCode && (
                <Text style={{ fontSize: 18, color: '#007AFF' }}>✓</Text>
              )}
            </View>
          </TouchableOpacity>
        ))}
      </View>

      <View style={{ marginTop: 20, padding: 10, backgroundColor: '#F5F5F5', borderRadius: 8 }}>
        <Text style={{ fontSize: 14, color: '#666', lineHeight: 20 }}>
          {t('common.loading', currentLanguage)}: {currentLanguage.toUpperCase()}
        </Text>
      </View>
    </ScrollView>
  );
}

const mapStateToProps = (store) => ({
  localization: store.localization,
});

const mapDispatchToProps = (dispatch) => bindActionCreators({ setLanguage }, dispatch);

export default connect(mapStateToProps, mapDispatchToProps)(LanguageSelector);

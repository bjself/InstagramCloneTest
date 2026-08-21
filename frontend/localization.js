// Localization utility for multi-language support
import * as Localization from 'expo-localization';

const translations = {
  en: require('./locales/en.json'),
  es: require('./locales/es.json'),
  fr: require('./locales/fr.json'),
};

export const SUPPORTED_LANGUAGES = {
  en: 'English',
  es: 'Español',
  fr: 'Français',
};

export const getDefaultLanguage = () => {
  const locale = Localization.locale.split('-')[0];
  return translations[locale] ? locale : 'en';
};

export const t = (key, language = 'en') => {
  const keys = key.split('.');
  let value = translations[language] || translations.en;

  for (const k of keys) {
    value = value?.[k];
  }

  return value || key;
};

export const setLanguage = (language) => {
  return {
    type: 'SET_LANGUAGE',
    payload: language,
  };
};

export default translations;

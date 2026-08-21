# Localization Feature Documentation

## Overview

This Instagram Clone application now includes a comprehensive localization (i18n) system that supports multiple languages. The system is built with Redux state management and Expo's native localization detection.

## Supported Languages

- **English** (en)
- **Spanish** (es)
- **French** (fr)

## Features

### 1. Automatic Language Detection
The system automatically detects the device's locale and selects the appropriate language. If the device language is not supported, it defaults to English.

### 2. Redux State Management
Language preference is stored in the Redux state, allowing the entire application to respond to language changes in real-time.

### 3. Translation Strings
All translatable strings are organized in JSON files in the `frontend/locales/` directory:
- `frontend/locales/en.json` - English translations
- `frontend/locales/es.json` - Spanish translations
- `frontend/locales/fr.json` - French translations

## File Structure

```
frontend/
├── localization.js                 # Main localization utility
├── locales/
│   ├── en.json                    # English translations
│   ├── es.json                    # Spanish translations
│   └── fr.json                    # French translations
├── redux/
│   ├── actions/
│   │   └── localization.js        # Redux actions for localization
│   └── reducers/
│       └── localization.js        # Redux reducer for language state
├── components/
│   ├── auth/
│   │   └── Login.js               # Updated with localization
│   └── Main.js                    # Updated with localization
└── App.js                         # Updated with localization
```

## Usage

### Basic Usage - Getting a Translation

To get a translated string, use the `t()` function:

```javascript
import { t } from '../localization';

// Get current language from Redux
const language = props.localization?.language || 'en';

// Use translation
const emailPlaceholder = t('auth.email', language);
const signInButtonText = t('auth.signIn', language);
```

### In Components

Example with Redux connection:

```javascript
import { connect } from 'react-redux';
import { t } from '../localization';

function MyComponent(props) {
  const language = props.localization?.language || 'en';
  
  return (
    <Button title={t('auth.signIn', language)} />
  );
}

const mapStateToProps = (store) => ({
  localization: store.localization,
});

export default connect(mapStateToProps)(MyComponent);
```

### Setting the Language

To change the language at runtime:

```javascript
import { setLanguage } from '../redux/actions/localization';
import { useDispatch } from 'react-redux';

function LanguageSwitcher() {
  const dispatch = useDispatch();
  
  const handleLanguageChange = (lang) => {
    dispatch(setLanguage(lang));
  };
  
  return (
    <Button 
      title="Change to Spanish" 
      onPress={() => handleLanguageChange('es')}
    />
  );
}
```

## Translation Keys

Translation strings follow a hierarchical naming pattern with dot notation:

- `auth.*` - Authentication related strings
  - `auth.email`
  - `auth.password`
  - `auth.signIn`
  - `auth.signUp`
  - `auth.dontHaveAccount`
  - `auth.register`
  - `auth.login`
  - `auth.logout`

- `navigation.*` - Navigation labels
  - `navigation.feed`
  - `navigation.search`
  - `navigation.camera`
  - `navigation.chat`
  - `navigation.profile`

- `profile.*` - Profile related strings
  - `profile.edit`
  - `profile.followers`
  - `profile.following`
  - `profile.posts`
  - `profile.settings`
  - `profile.language`

- `post.*` - Post related strings
  - `post.comment`
  - `post.like`
  - `post.share`
  - `post.delete`

- `chat.*` - Chat related strings
  - `chat.message`
  - `chat.send`
  - `chat.noChats`

- `common.*` - Common UI strings
  - `common.loading`
  - `common.error`
  - `common.success`
  - `common.close`
  - `common.back`

## Adding New Translations

To add a new translation string:

1. **Add to all locale files** with the same key:

   In `frontend/locales/en.json`:
   ```json
   {
     "myFeature": {
       "title": "My Feature"
     }
   }
   ```

   In `frontend/locales/es.json`:
   ```json
   {
     "myFeature": {
       "title": "Mi Característica"
     }
   }
   ```

   In `frontend/locales/fr.json`:
   ```json
   {
     "myFeature": {
       "title": "Ma Fonction"
     }
   }
   ```

2. **Use in component**:
   ```javascript
   const title = t('myFeature.title', language);
   ```

## Integration with Components

Updated components now use localization:
- **Login.js** - Uses localized placeholders and button text
- **Main.js** - Uses localized navigation labels
- **App.js** - Uses localized screen titles

## Redux Store Structure

```javascript
{
  userState: {...},
  usersState: {...},
  localization: {
    language: 'en' | 'es' | 'fr'
  }
}
```

## API Reference

### `t(key, language)`
Get a translated string.

**Parameters:**
- `key` (string): Dot-notation path to translation key
- `language` (string): Language code ('en', 'es', 'fr')

**Returns:** Translated string or key if not found

**Example:**
```javascript
t('auth.email', 'es') // Returns: "Correo electrónico"
```

### `getDefaultLanguage()`
Get the device's default language based on system locale.

**Returns:** Language code or 'en' if not supported

**Example:**
```javascript
const lang = getDefaultLanguage(); // Could return 'es' if device is Spanish
```

### `setLanguage(language)`
Redux action to change the current language.

**Parameters:**
- `language` (string): Language code to set

**Example:**
```javascript
dispatch(setLanguage('fr'));
```

## Performance Considerations

- Translation files are loaded at app startup
- Redux state ensures components re-render when language changes
- Translations are memoized through Redux selectors
- No network calls needed for translations

## Future Enhancements

Possible improvements to the localization system:

1. **Pluralization Support** - Handle plural forms per language
2. **Date/Time Formatting** - Localize dates and times
3. **RTL Support** - Support right-to-left languages (Arabic, Hebrew)
4. **More Languages** - Add additional language support
5. **Language Persistence** - Save user's language preference to Firebase
6. **Namespace Splitting** - Lazy load locale files by feature
7. **Translation Management UI** - Admin panel for managing translations
8. **Dynamic Translation Updates** - Fetch translations from server

## Testing

When adding new features, remember to:
1. Add translation keys for all new user-facing strings
2. Test with different languages to ensure layout compatibility
3. Check for text overflow in UI components
4. Verify placeholder text renders correctly in input fields

## Troubleshooting

### Translation key returns the key itself
- Check that the key path is correct (case-sensitive)
- Verify the key exists in all locale files
- Ensure the JSON syntax is valid

### Language doesn't change in app
- Verify you're using Redux `connect()` and have `localization` in `mapStateToProps`
- Check that you're dispatching `setLanguage` action correctly
- Ensure the language reducer is included in the root reducer

### Missing translations in a locale
- Verify all locale files have the same structure
- Use a JSON validator to check file syntax
- Check for trailing commas in JSON

## Contributing

When contributing new features:
1. Always add translation strings to all three locale files
2. Use consistent key naming conventions
3. Test with all supported languages
4. Update this documentation for new translation keys

# Localization Setup Guide

## Quick Start

The Instagram Clone app now includes multi-language support out of the box!

### Supported Languages
- 🇺🇸 English (en)
- 🇪🇸 Spanish (es)
- 🇫🇷 French (fr)

### How It Works

1. **Automatic Detection**: The app automatically detects your device's language
2. **Manual Selection**: Users can switch languages anytime via settings
3. **Redux Integration**: Language state persists across the app

## File Structure

```
frontend/
├── localization.js                 # Core localization logic
├── locales/                        # Translation files
│   ├── en.json                    # English
│   ├── es.json                    # Spanish
│   └── fr.json                    # French
├── redux/
│   ├── actions/localization.js    # Redux actions
│   └── reducers/localization.js   # Redux reducer
└── components/
    ├── LanguageSelector.js        # Language switcher UI
    ├── auth/Login.js              # Example: localized auth
    └── Main.js                    # Example: localized navigation
```

## Usage Examples

### In a Component

```javascript
import { connect } from 'react-redux';
import { t } from '../localization';

function MyComponent(props) {
  // Get current language from Redux store
  const language = props.localization?.language || 'en';
  
  // Use translation function
  const emailLabel = t('auth.email', language);
  const passwordLabel = t('auth.password', language);
  
  return (
    <View>
      <Text>{emailLabel}</Text>
      <Text>{passwordLabel}</Text>
    </View>
  );
}

const mapStateToProps = (store) => ({
  localization: store.localization,
});

export default connect(mapStateToProps)(MyComponent);
```

### Changing Language

```javascript
import { setLanguage } from '../redux/actions/localization';
import { useDispatch } from 'react-redux';

function LanguageSwitcher() {
  const dispatch = useDispatch();
  
  const switchToSpanish = () => {
    dispatch(setLanguage('es'));
  };
  
  return <Button title="Español" onPress={switchToSpanish} />;
}
```

### Using Language Selector Component

A pre-built language selector component is available:

```javascript
import LanguageSelector from '../components/LanguageSelector';

// Use in your profile/settings screen
<LanguageSelector />
```

## Adding New Translation Keys

To add a new translatable string:

1. **Add to all three locale files** with the same key structure:

   **en.json**:
   ```json
   {
     "myFeature": {
       "title": "My Feature Title",
       "description": "My feature description"
     }
   }
   ```

   **es.json**:
   ```json
   {
     "myFeature": {
       "title": "Título de mi característica",
       "description": "Descripción de mi característica"
     }
   }
   ```

   **fr.json**:
   ```json
   {
     "myFeature": {
       "title": "Titre de ma fonction",
       "description": "Description de ma fonction"
     }
   }
   ```

2. **Use in your component**:
   ```javascript
   const title = t('myFeature.title', language);
   const description = t('myFeature.description', language);
   ```

## Translation Categories

- **auth** - Login/Register strings
- **navigation** - Tab and screen names
- **profile** - Profile-related strings
- **post** - Post actions and labels
- **chat** - Chat-related strings
- **common** - Generic UI strings

## Best Practices

✅ **Do's**
- Add all new user-facing strings to all locale files
- Use consistent, hierarchical key naming
- Test UI layout in all languages
- Keep translations close in meaning to originals
- Use the `t()` function everywhere

❌ **Don'ts**
- Don't hardcode English strings in components
- Don't forget to add strings to all locale files
- Don't use string interpolation in translation keys
- Don't skip translations for any language
- Don't rely on English for testing

## Redux Integration

The localization state is stored in Redux:

```javascript
store.localization = {
  language: 'en' | 'es' | 'fr'
}
```

This allows any component to access the current language via `connect()` or hooks.

## Performance

- ✨ Translation files are loaded at app startup
- ⚡ No network calls needed for translations
- 🚀 Language changes instantly update all components
- 💾 Minimal bundle size impact

## Troubleshooting

### Translation not appearing?
1. Check the key path is correct (dot notation)
2. Verify key exists in all three locale files
3. Ensure component is connected to Redux store
4. Check JSON syntax in locale files

### App crashes on language change?
1. Verify localization reducer is in root reducer
2. Check that `setLanguage` action is dispatched correctly
3. Ensure component is using Redux `connect()`

### Missing language support?
1. Create a new locale file (e.g., `de.json` for German)
2. Add to `SUPPORTED_LANGUAGES` in `localization.js`
3. Add to translations object in `localization.js`
4. Update documentation

## Next Steps

To fully integrate localization into your app:

1. Replace all hardcoded strings with translation keys
2. Add LanguageSelector to your Profile/Settings screen
3. Test all screens with different languages
4. Save user's language preference to Firebase (optional)

## Documentation

For detailed API reference and advanced features, see `LOCALIZATION.md`

## Contributing

When adding new features:
1. Always add translation keys for new strings
2. Update all three locale files simultaneously
3. Test layout with different string lengths
4. Document new translation categories

---

**Happy localizing! 🌍**

import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

// Import translation files
import enTranslations from './locales/en.json';
import frTranslations from './locales/fr.json';

// Ensure 'fr' is the default when nothing is stored.
// We do this BEFORE init so the LanguageDetector reads 'fr' from localStorage
// on first visit instead of falling back to the browser's navigator language.
const LANG_KEY = 'i18nextLng';
if (!localStorage.getItem(LANG_KEY)) {
  localStorage.setItem(LANG_KEY, 'fr');
}

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources: {
      en: { translation: enTranslations },
      fr: { translation: frTranslations },
    },
    // Explicit lng takes precedence over the detector.
    // Reading directly from localStorage guarantees 'fr' on first visit.
    lng: localStorage.getItem(LANG_KEY) ?? 'fr',
    fallbackLng: 'fr',
    detection: {
      // Only look at localStorage — never the browser navigator locale
      order: ['localStorage'],
      caches: ['localStorage'],
      lookupLocalStorage: LANG_KEY,
    },
    interpolation: {
      escapeValue: false,
    },
  });

export default i18n;

// Jest config for running admin tests directly with `jest` (avoids
// the react-scripts Babel version conflict).
const path = require('path');

const reactScriptsDir = path.join(__dirname, 'node_modules', 'react-scripts');
const firebaseMock = path.join(__dirname, 'src/__mocks__/firebase.js');

module.exports = {
  rootDir: __dirname,
  roots: ['<rootDir>/src'],
  testEnvironment: 'jsdom',
  setupFiles: [path.join(__dirname, 'node_modules/react-app-polyfill/jsdom')],
  setupFilesAfterEnv: ['<rootDir>/src/setupTests.js'],
  testMatch: [
    '<rootDir>/src/**/__tests__/**/*.{js,jsx}',
    '<rootDir>/src/**/*.{spec,test}.{js,jsx}',
  ],
  transform: {
    '^.+\\.(js|jsx|mjs|cjs)$': path.join(__dirname, 'config/jest/babelTransform.js'),
    '^.+\\.css$': path.join(reactScriptsDir, 'config/jest/cssTransform.js'),
    '^(?!.*\\.(js|jsx|mjs|cjs|css|json)$)': path.join(reactScriptsDir, 'config/jest/fileTransform.js'),
  },
  transformIgnorePatterns: [
    '/node_modules/',
    '^.+\\.module\\.(css|sass|scss)$',
  ],
  moduleNameMapper: {
    // Stub all CSS imports (including from node_modules like bootstrap)
    '\\.css$': path.join(__dirname, 'config/jest/cssStub.js'),
    '^.+\\.module\\.(css|sass|scss)$': 'identity-obj-proxy',
    // Mock Firebase so tests don't need a real Firebase project
    '^firebase$': firebaseMock,
    '^firebase/app$': firebaseMock,
    '^firebase/firestore$': firebaseMock,
    '^firebase/auth$': firebaseMock,
    // Stub the Babel plugin that requires @babel/core >= 7.22 (we have 7.12)
    '^@babel/plugin-syntax-import-attributes$': path.join(
      __dirname,
      'config/jest/syntaxImportAttributesStub.js'
    ),
  },
  moduleFileExtensions: ['js', 'jsx', 'json', 'node'],
  resetMocks: true,
};

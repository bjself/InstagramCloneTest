/**
 * Custom Babel transform for admin Jest tests.
 *
 * Avoids using @babel/preset-env (hoisted to a newer version that depends on
 * @babel/core >= 7.22, conflicting with the react-scripts @babel/core 7.12).
 * Covers everything the test suite actually needs: JSX, class properties,
 * optional chaining, nullish coalescing, and CommonJS module transforms.
 */
'use strict';

const babelJest = require('babel-jest');
const path = require('path');

// Resolve all plugins/presets from the admin node_modules so they are found
// regardless of the working directory Jest is invoked from.
const adminModules = path.join(__dirname, '../../node_modules');
function mod(name) {
  return require.resolve(name, { paths: [adminModules] });
}

module.exports = babelJest.createTransformer({
  presets: [
    [mod('@babel/preset-react'), { runtime: 'automatic' }],
  ],
  plugins: [
    mod('@babel/plugin-transform-modules-commonjs'),
    mod('@babel/plugin-transform-class-properties'),
    mod('@babel/plugin-proposal-optional-chaining'),
    mod('@babel/plugin-proposal-nullish-coalescing-operator'),
    mod('babel-plugin-jest-hoist'),
  ],
  babelrc: false,
  configFile: false,
});

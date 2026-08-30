/**
 * Stub for @babel/plugin-syntax-import-attributes.
 *
 * The real package (7.29.7) calls api.assertVersion("^7.22.0") which fails
 * against @babel/core 7.12 (bundled in react-scripts 4). Our tests don't use
 * import-attributes syntax, so a no-op stub is correct here.
 */
'use strict';

const { declare } = require('@babel/helper-plugin-utils');

module.exports = declare(() => ({
  name: 'syntax-import-attributes-stub',
}));

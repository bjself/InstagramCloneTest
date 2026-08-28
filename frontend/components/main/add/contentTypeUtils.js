/**
 * Content Type Utilities
 *
 * Utility functions for handling content types throughout the application.
 * Type 0: Video
 * Type 1: Photo
 */

export const CONTENT_TYPES = {
  VIDEO: 0,
  PHOTO: 1,
};

/**
 * Determines the content type based on media type
 * @param {string} mediaType - The media type (e.g., 'video', 'photo', 'video/mp4')
 * @returns {number} - Content type (0 for video, 1 for photo)
 */
export function determineContentType(mediaType) {
  if (!mediaType) return null;

  const lowerMediaType = mediaType.toLowerCase();

  if (lowerMediaType.startsWith('video')) {
    return CONTENT_TYPES.VIDEO;
  }

  if (lowerMediaType.startsWith('image') || lowerMediaType.startsWith('photo')) {
    return CONTENT_TYPES.PHOTO;
  }

  return null;
}

/**
 * Validates if a type is a valid content type
 * @param {number} type - The type to validate
 * @returns {boolean} - True if valid, false otherwise
 */
export function validateContentType(type) {
  if (typeof type !== 'number') {
    return false;
  }

  if (Number.isNaN(type) || !Number.isFinite(type)) {
    return false;
  }

  return type === CONTENT_TYPES.VIDEO || type === CONTENT_TYPES.PHOTO;
}

/**
 * Gets the display component name for a content type
 * @param {number} type - The content type
 * @returns {string|null} - Component name or null if invalid
 */
export function getDisplayComponentForType(type) {
  if (type === CONTENT_TYPES.VIDEO) {
    return 'Video';
  }

  if (type === CONTENT_TYPES.PHOTO) {
    return 'Image';
  }

  return null;
}

/**
 * Determines if a content type should include a thumbnail
 * @param {number} type - The content type
 * @returns {boolean} - True if thumbnail should be included
 */
export function shouldIncludeThumbnail(type) {
  return type === CONTENT_TYPES.VIDEO;
}

/**
 * Validates a post object for required fields and correct structure
 * @param {object} post - The post object to validate
 * @returns {object} - Validation result { isValid: boolean, errors: string[] }
 */
export function validatePostObject(post) {
  const errors = [];

  if (!post) {
    return {
      isValid: false,
      errors: ['Post object is empty'],
    };
  }

  // Check required fields
  if (!post.downloadURL) {
    errors.push('Missing downloadURL');
  }

  if (post.type === undefined || post.type === null) {
    errors.push('Missing type');
  } else if (!validateContentType(post.type)) {
    errors.push('Invalid type');
  }

  // Validate content type specific requirements
  if (validateContentType(post.type)) {
    if (post.type === CONTENT_TYPES.VIDEO && !post.downloadURLStill) {
      errors.push('Video posts require downloadURLStill');
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
}

/**
 * Creates a normalized post object with content type
 * @param {object} postData - Raw post data
 * @returns {object} - Normalized post object
 */
export function normalizePostObject(postData) {
  const normalized = {
    ...postData,
    type: validateContentType(postData.type) ? postData.type : null,
  };

  if (normalized.type === CONTENT_TYPES.VIDEO) {
    if (!normalized.downloadURLStill) {
      console.warn('Video post missing thumbnail URL');
    }
  }

  return normalized;
}

export default {
  CONTENT_TYPES,
  determineContentType,
  validateContentType,
  getDisplayComponentForType,
  shouldIncludeThumbnail,
  validatePostObject,
  normalizePostObject,
};

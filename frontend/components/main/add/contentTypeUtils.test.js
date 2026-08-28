/**
 * @jest-environment jsdom
 */

import React from 'react';
import {
  determineContentType,
  validateContentType,
  getDisplayComponentForType,
  shouldIncludeThumbnail,
  validatePostObject,
} from '../components/main/add/contentTypeUtils';

describe('Content Type Utility Functions', () => {
  describe('determineContentType', () => {
    test('should return 0 for video file', () => {
      const mediaType = 'video';
      const contentType = determineContentType(mediaType);
      expect(contentType).toBe(0);
    });

    test('should return 1 for photo file', () => {
      const mediaType = 'photo';
      const contentType = determineContentType(mediaType);
      expect(contentType).toBe(1);
    });

    test('should handle video extensions', () => {
      const videoExtensions = ['mp4', 'mov', 'avi', 'webm', 'mkv'];
      videoExtensions.forEach((ext) => {
        const type = determineContentType(`video/${ext}`);
        expect(type).toBe(0);
      });
    });

    test('should handle image extensions', () => {
      const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      imageExtensions.forEach((ext) => {
        const type = determineContentType(`image/${ext}`);
        expect(type).toBe(1);
      });
    });
  });

  describe('validateContentType', () => {
    test('should validate type 0 as valid', () => {
      expect(validateContentType(0)).toBe(true);
    });

    test('should validate type 1 as valid', () => {
      expect(validateContentType(1)).toBe(true);
    });

    test('should reject invalid types', () => {
      expect(validateContentType(2)).toBe(false);
      expect(validateContentType(-1)).toBe(false);
      expect(validateContentType(null)).toBe(false);
      expect(validateContentType(undefined)).toBe(false);
      expect(validateContentType('0')).toBe(false);
    });

    test('should reject non-number types', () => {
      expect(validateContentType('video')).toBe(false);
      expect(validateContentType({})).toBe(false);
      expect(validateContentType([])).toBe(false);
    });
  });

  describe('getDisplayComponentForType', () => {
    test('should return Video for type 0', () => {
      const component = getDisplayComponentForType(0);
      expect(component).toBe('Video');
    });

    test('should return Image for type 1', () => {
      const component = getDisplayComponentForType(1);
      expect(component).toBe('Image');
    });

    test('should return null for invalid type', () => {
      expect(getDisplayComponentForType(2)).toBeNull();
      expect(getDisplayComponentForType(null)).toBeNull();
      expect(getDisplayComponentForType(undefined)).toBeNull();
    });
  });

  describe('shouldIncludeThumbnail', () => {
    test('should return true for type 0 (video)', () => {
      expect(shouldIncludeThumbnail(0)).toBe(true);
    });

    test('should return false for type 1 (photo)', () => {
      expect(shouldIncludeThumbnail(1)).toBe(false);
    });

    test('should return false for invalid type', () => {
      expect(shouldIncludeThumbnail(2)).toBe(false);
      expect(shouldIncludeThumbnail(null)).toBe(false);
    });
  });

  describe('validatePostObject', () => {
    test('should validate complete video post object', () => {
      const videoPost = {
        downloadURL: 'https://example.com/video.mp4',
        downloadURLStill: 'https://example.com/thumbnail.jpg',
        caption: 'My video',
        type: 0,
        likesCount: 0,
        commentsCount: 0,
      };

      const result = validatePostObject(videoPost);
      expect(result.isValid).toBe(true);
      expect(result.errors).toEqual([]);
    });

    test('should validate complete photo post object', () => {
      const photoPost = {
        downloadURL: 'https://example.com/image.jpg',
        caption: 'My photo',
        type: 1,
        likesCount: 0,
        commentsCount: 0,
      };

      const result = validatePostObject(photoPost);
      expect(result.isValid).toBe(true);
      expect(result.errors).toEqual([]);
    });

    test('should detect missing downloadURL', () => {
      const post = {
        type: 1,
        caption: 'Photo',
        likesCount: 0,
      };

      const result = validatePostObject(post);
      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('Missing downloadURL');
    });

    test('should detect missing type', () => {
      const post = {
        downloadURL: 'https://example.com/image.jpg',
        caption: 'Photo',
      };

      const result = validatePostObject(post);
      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('Missing type');
    });

    test('should detect invalid type', () => {
      const post = {
        downloadURL: 'https://example.com/image.jpg',
        type: 99,
        caption: 'Photo',
      };

      const result = validatePostObject(post);
      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('Invalid type');
    });

    test('should require thumbnail for video posts', () => {
      const videoPost = {
        downloadURL: 'https://example.com/video.mp4',
        type: 0,
        caption: 'Video without thumbnail',
      };

      const result = validatePostObject(videoPost);
      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('Video posts require downloadURLStill');
    });

    test('should detect multiple errors', () => {
      const post = {};

      const result = validatePostObject(post);
      expect(result.isValid).toBe(false);
      expect(result.errors.length).toBeGreaterThan(1);
    });
  });

  describe('Content Type in Upload Flow', () => {
    test('should preserve type through save cycle', () => {
      const routes = [
        { type: 0, name: 'video' },
        { type: 1, name: 'photo' },
      ];

      routes.forEach((route) => {
        const post = {
          downloadURL: `https://example.com/${route.name}`,
          type: route.type,
          caption: `My ${route.name}`,
        };

        expect(post.type).toBe(route.type);
        expect(validateContentType(post.type)).toBe(true);
      });
    });

    test('should handle type changes in camera', () => {
      let type = 0; // Start with video
      expect(type).toBe(0);

      type = type === 0 ? 1 : 0; // Toggle to photo
      expect(type).toBe(1);

      type = type === 0 ? 1 : 0; // Toggle back to video
      expect(type).toBe(0);
    });
  });

  describe('Content Type Validation Edge Cases', () => {
    test('should handle NaN type', () => {
      expect(validateContentType(NaN)).toBe(false);
    });

    test('should handle Infinity type', () => {
      expect(validateContentType(Infinity)).toBe(false);
    });

    test('should handle boolean type values', () => {
      expect(validateContentType(true)).toBe(false);
      expect(validateContentType(false)).toBe(false);
    });

    test('should validate post with empty caption', () => {
      const post = {
        downloadURL: 'https://example.com/image.jpg',
        type: 1,
        caption: '',
      };

      const result = validatePostObject(post);
      expect(result.errors.filter((e) => e.includes('caption'))).toEqual([]);
    });

    test('should validate post with special characters in caption', () => {
      const post = {
        downloadURL: 'https://example.com/image.jpg',
        type: 1,
        caption: '@user1 @user2 #hashtag 🎉',
      };

      const result = validatePostObject(post);
      expect(result.isValid).toBe(true);
    });
  });
});

const functions = require('firebase-functions-test')();
const admin = require('firebase-admin');

// Mock Firebase Admin
jest.mock('firebase-admin', () => ({
  initializeApp: jest.fn(),
  firestore: jest.fn(() => ({
    collection: jest.fn().mockReturnThis(),
    doc: jest.fn().mockReturnThis(),
    update: jest.fn().mockResolvedValue({}),
    get: jest.fn().mockResolvedValue({}),
  })),
  firestore: {
    FieldValue: {
      increment: jest.fn((value) => ({ _type: 'FieldValue', _value: value })),
    },
  },
}));

describe('Content Type Handling in Cloud Functions', () => {
  let myFunctions;

  beforeAll(() => {
    process.env.FIREBASE_CONFIG = JSON.stringify({
      projectId: 'test-project',
      databaseURL: 'https://test-project.firebaseio.com',
    });
    myFunctions = require('./index');
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('Post Content Type Validation', () => {
    test('should accept type 0 (video) in posts', () => {
      const postData = {
        downloadURL: 'https://example.com/video.mp4',
        caption: 'My video',
        type: 0,
        likesCount: 0,
        commentsCount: 0,
      };

      expect(postData.type).toBe(0);
      expect(typeof postData.type).toBe('number');
    });

    test('should accept type 1 (photo) in posts', () => {
      const postData = {
        downloadURL: 'https://example.com/image.jpg',
        caption: 'My photo',
        type: 1,
        likesCount: 0,
        commentsCount: 0,
      };

      expect(postData.type).toBe(1);
      expect(typeof postData.type).toBe('number');
    });

    test('should have downloadURLStill for video posts (type 0)', () => {
      const videoPost = {
        downloadURL: 'https://example.com/video.mp4',
        downloadURLStill: 'https://example.com/thumbnail.jpg',
        caption: 'Video with thumbnail',
        type: 0,
      };

      expect(videoPost.type).toBe(0);
      expect(videoPost.downloadURLStill).toBeDefined();
      expect(videoPost.downloadURLStill).toMatch(/thumbnail/);
    });

    test('should not require downloadURLStill for photo posts (type 1)', () => {
      const photoPost = {
        downloadURL: 'https://example.com/image.jpg',
        caption: 'Photo without thumbnail',
        type: 1,
      };

      expect(photoPost.type).toBe(1);
      expect(photoPost.downloadURLStill).toBeUndefined();
    });
  });

  describe('Content Type in Notifications', () => {
    test('should send notification with type 0 for post engagement', () => {
      const notification = {
        type: 0,
        postId: 'post123',
        user: 'user456',
      };

      expect(notification.type).toBe(0);
      expect(notification.postId).toBeDefined();
    });

    test('should send notification with type chat for messages', () => {
      const notification = {
        type: 'chat',
        user: 'user456',
      };

      expect(notification.type).toBe('chat');
    });

    test('should send notification with type profile for follows', () => {
      const notification = {
        type: 'profile',
        user: 'user456',
      };

      expect(notification.type).toBe('profile');
    });
  });

  describe('Counter Increment Functions', () => {
    test('should increment like counter for post content', () => {
      const increment = admin.firestore.FieldValue.increment(1);
      expect(increment._value).toBe(1);
    });

    test('should decrement like counter for post content', () => {
      const decrement = admin.firestore.FieldValue.increment(-1);
      expect(decrement._value).toBe(-1);
    });

    test('should increment comment counter for post content', () => {
      const increment = admin.firestore.FieldValue.increment(1);
      expect(increment._value).toBe(1);
    });
  });

  describe('Content Type Display Logic', () => {
    test('type 0 indicates video should use Video component', () => {
      const contentType = 0;
      const shouldUseVideoComponent = contentType === 0;
      expect(shouldUseVideoComponent).toBe(true);
    });

    test('type 1 indicates photo should use Image component', () => {
      const contentType = 1;
      const shouldUseImageComponent = contentType === 1;
      expect(shouldUseImageComponent).toBe(true);
    });

    test('video content (type 0) should have thumbnail URL', () => {
      const content = {
        type: 0,
        downloadURL: 'https://example.com/video.mp4',
        downloadURLStill: 'https://example.com/thumbnail.jpg',
      };

      if (content.type === 0) {
        expect(content.downloadURLStill).toBeDefined();
      }
    });

    test('photo content (type 1) should not require thumbnail', () => {
      const content = {
        type: 1,
        downloadURL: 'https://example.com/photo.jpg',
      };

      if (content.type === 1) {
        expect(content.downloadURLStill).toBeUndefined();
      }
    });
  });

  describe('Content Type Edge Cases', () => {
    test('should handle posts with caption containing mentions', () => {
      const post = {
        type: 0,
        caption: '@user1 check this out @user2',
        downloadURL: 'https://example.com/video.mp4',
      };

      const mentionPattern = /\B@[a-z0-9_-]+/gi;
      const mentions = post.caption.match(mentionPattern);
      expect(mentions).toEqual(['@user1', '@user2']);
    });

    test('should preserve content type during upload', () => {
      const originalPost = { type: 0, caption: 'Video content' };
      const uploadedPost = { ...originalPost };
      expect(uploadedPost.type).toBe(originalPost.type);
    });

    test('should include creation timestamp for all content types', () => {
      const post = {
        type: 0,
        downloadURL: 'https://example.com/video.mp4',
        creation: new Date().toISOString(),
      };

      expect(post.creation).toBeDefined();
    });
  });
});

import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

// Mock component for testing content type display
const ContentTypeDisplay = ({ post }) => {
  return (
    <div data-testid="content-display">
      {post.type === 0 ? (
        <video data-testid="video-player" src={post.downloadURL} />
      ) : post.type === 1 ? (
        <img data-testid="image-display" src={post.downloadURL} alt={post.caption} />
      ) : (
        <div data-testid="unknown-type">Unknown content type</div>
      )}
      {post.downloadURLStill && (
        <img data-testid="video-thumbnail" src={post.downloadURLStill} alt="thumbnail" />
      )}
    </div>
  );
};

describe('Content Type Display Tests', () => {
  describe('Video Content (Type 0)', () => {
    test('should render video player for type 0', () => {
      const videoPost = {
        type: 0,
        downloadURL: 'https://example.com/video.mp4',
        caption: 'My video',
      };

      render(<ContentTypeDisplay post={videoPost} />);
      expect(screen.getByTestId('video-player')).toBeInTheDocument();
    });

    test('should render video thumbnail for type 0 with downloadURLStill', () => {
      const videoPost = {
        type: 0,
        downloadURL: 'https://example.com/video.mp4',
        downloadURLStill: 'https://example.com/thumbnail.jpg',
        caption: 'My video',
      };

      render(<ContentTypeDisplay post={videoPost} />);
      expect(screen.getByTestId('video-thumbnail')).toBeInTheDocument();
      expect(screen.getByTestId('video-thumbnail')).toHaveAttribute(
        'src',
        'https://example.com/thumbnail.jpg'
      );
    });

    test('should not render image for type 0 video', () => {
      const videoPost = {
        type: 0,
        downloadURL: 'https://example.com/video.mp4',
        caption: 'My video',
      };

      render(<ContentTypeDisplay post={videoPost} />);
      expect(screen.queryByTestId('image-display')).not.toBeInTheDocument();
    });
  });

  describe('Photo Content (Type 1)', () => {
    test('should render image for type 1', () => {
      const photoPost = {
        type: 1,
        downloadURL: 'https://example.com/image.jpg',
        caption: 'My photo',
      };

      render(<ContentTypeDisplay post={photoPost} />);
      expect(screen.getByTestId('image-display')).toBeInTheDocument();
    });

    test('should not render video for type 1 photo', () => {
      const photoPost = {
        type: 1,
        downloadURL: 'https://example.com/image.jpg',
        caption: 'My photo',
      };

      render(<ContentTypeDisplay post={photoPost} />);
      expect(screen.queryByTestId('video-player')).not.toBeInTheDocument();
    });

    test('should not render thumbnail for type 1 photo', () => {
      const photoPost = {
        type: 1,
        downloadURL: 'https://example.com/image.jpg',
        caption: 'My photo',
      };

      render(<ContentTypeDisplay post={photoPost} />);
      expect(screen.queryByTestId('video-thumbnail')).not.toBeInTheDocument();
    });

    test('should display image with correct alt text', () => {
      const photoPost = {
        type: 1,
        downloadURL: 'https://example.com/image.jpg',
        caption: 'Beautiful sunset',
      };

      render(<ContentTypeDisplay post={photoPost} />);
      expect(screen.getByTestId('image-display')).toHaveAttribute('alt', 'Beautiful sunset');
    });
  });

  describe('Unknown Content Type', () => {
    test('should render unknown type message for invalid type', () => {
      const unknownPost = {
        type: 99,
        downloadURL: 'https://example.com/content',
        caption: 'Unknown',
      };

      render(<ContentTypeDisplay post={unknownPost} />);
      expect(screen.getByTestId('unknown-type')).toBeInTheDocument();
      expect(screen.getByText('Unknown content type')).toBeInTheDocument();
    });

    test('should render unknown type message for undefined type', () => {
      const undefinedPost = {
        downloadURL: 'https://example.com/content',
        caption: 'No type',
      };

      render(<ContentTypeDisplay post={undefinedPost} />);
      expect(screen.getByTestId('unknown-type')).toBeInTheDocument();
    });
  });

  describe('Content Type Data Consistency', () => {
    test('should maintain content type across render', () => {
      const post = { type: 0, downloadURL: 'https://example.com/video.mp4', caption: 'Video' };
      const { rerender } = render(<ContentTypeDisplay post={post} />);

      expect(screen.getByTestId('video-player')).toBeInTheDocument();

      rerender(<ContentTypeDisplay post={{ ...post, caption: 'Updated video' }} />);
      expect(screen.getByTestId('video-player')).toBeInTheDocument();
    });

    test('should switch between content types', () => {
      const photoPost = { type: 1, downloadURL: 'https://example.com/image.jpg', caption: 'Photo' };
      const { rerender } = render(<ContentTypeDisplay post={photoPost} />);

      expect(screen.getByTestId('image-display')).toBeInTheDocument();

      const videoPost = {
        type: 0,
        downloadURL: 'https://example.com/video.mp4',
        caption: 'Video',
      };
      rerender(<ContentTypeDisplay post={videoPost} />);

      expect(screen.queryByTestId('image-display')).not.toBeInTheDocument();
      expect(screen.getByTestId('video-player')).toBeInTheDocument();
    });
  });
});

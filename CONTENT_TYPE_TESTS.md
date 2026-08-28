# Content Type Tests

This directory contains comprehensive tests for the content type system in the Instagram Clone application. The content type system distinguishes between two types of media:

- **Type 0**: Video content
- **Type 1**: Photo content

## Test Files

### Backend Tests

#### `backend/functions/index.test.js`
Tests for Firebase Cloud Functions content type handling:
- Post content type validation (types 0 and 1)
- Thumbnail URL requirements for videos
- Notification type system
- Counter increment functions for engagement
- Content type display logic
- Edge cases (mentions, type preservation, timestamps)

**Key test groups:**
- Post Content Type Validation
- Content Type in Notifications
- Counter Increment Functions
- Content Type Display Logic
- Content Type Edge Cases

### Admin Panel Tests

#### `admin/src/contentType.test.js`
React component tests for displaying content based on type:
- Video player rendering for type 0
- Image display for type 1
- Thumbnail display for videos
- Unknown type handling
- Content type consistency across re-renders
- Component switching between types

**Key test groups:**
- Video Content (Type 0)
- Photo Content (Type 1)
- Unknown Content Type
- Content Type Data Consistency

### Frontend Utility Tests

#### `frontend/components/main/add/contentTypeUtils.test.js`
Unit tests for content type utility functions:
- Content type determination from media type
- Type validation
- Display component selection
- Thumbnail inclusion logic
- Post object validation
- Edge cases (NaN, Infinity, booleans)

**Key test groups:**
- determineContentType
- validateContentType
- getDisplayComponentForType
- shouldIncludeThumbnail
- validatePostObject
- Content Type Validation Edge Cases

#### `frontend/components/main/add/contentTypeIntegration.test.js`
Integration tests for the complete upload workflow:
- Camera to Save flow for videos
- Camera to Save flow for photos
- Gallery selection type determination
- Multiple uploads in sequence
- Type preservation through backend
- Content type in notifications
- Feed display with mixed content
- Type consistency across components
- Error handling with invalid types

**Key test groups:**
- Camera to Save Flow - Video Upload
- Camera to Save Flow - Photo Upload
- Gallery Selection to Upload
- Multiple Uploads Same Session
- Type Preservation Through Backend
- Feed Display with Mixed Content Types
- Error Handling with Invalid Types

#### `frontend/components/main/add/contentTypeNotification.test.js`
Notification system tests related to content types:
- Post engagement notifications with content types
- Chat and profile notification types
- Notification routing by content type
- Content type validation in notifications
- Notification badges by content type
- Metadata inclusion for different types
- Notification grouping by content type
- Edge cases and type preservation

**Key test groups:**
- Post Engagement Notifications
- Chat Notifications
- Profile Notifications
- Notification Routing by Content Type
- Notification Content Type Validation
- Notification Badges by Content Type
- Notification Metadata
- Notification Grouping by Content Type

## Content Type System Overview

### Type Definitions
```javascript
CONTENT_TYPES = {
  VIDEO: 0,    // Video content
  PHOTO: 1     // Photo content
}
```

### Video Posts (Type 0)
- **Required fields:**
  - `downloadURL`: Main video file URL
  - `downloadURLStill`: Thumbnail image URL
  - `type`: 0
  - `caption`: Post caption
  - `likesCount`: Initial value 0
  - `commentsCount`: Initial value 0

- **Optional fields:**
  - `creation`: Timestamp

### Photo Posts (Type 1)
- **Required fields:**
  - `downloadURL`: Image file URL
  - `type`: 1
  - `caption`: Post caption
  - `likesCount`: Initial value 0
  - `commentsCount`: Initial value 0

- **Optional fields:**
  - `creation`: Timestamp
  - `downloadURLStill`: Not applicable (should be undefined)

## Utility Functions

### contentTypeUtils.js

Located at: `frontend/components/main/add/contentTypeUtils.js`

#### `determineContentType(mediaType)`
Determines content type from media type string.
```javascript
determineContentType('video/mp4')  // Returns 0
determineContentType('image/jpeg') // Returns 1
```

#### `validateContentType(type)`
Validates if a type is valid (0 or 1).
```javascript
validateContentType(0)    // Returns true
validateContentType(1)    // Returns true
validateContentType(2)    // Returns false
validateContentType(null) // Returns false
```

#### `getDisplayComponentForType(type)`
Returns the component name to use for display.
```javascript
getDisplayComponentForType(0) // Returns 'Video'
getDisplayComponentForType(1) // Returns 'Image'
```

#### `shouldIncludeThumbnail(type)`
Determines if thumbnail should be included.
```javascript
shouldIncludeThumbnail(0) // Returns true (video needs thumbnail)
shouldIncludeThumbnail(1) // Returns false (photo doesn't need thumbnail)
```

#### `validatePostObject(post)`
Comprehensive validation of post object.
```javascript
const result = validatePostObject(post);
// Returns: { isValid: boolean, errors: string[] }
```

## Running Tests

### Admin Panel Tests
```bash
cd admin
npm test contentType.test.js
```

### Frontend Tests
```bash
cd frontend
npm test contentTypeUtils.test.js
npm test contentTypeIntegration.test.js
npm test contentTypeNotification.test.js
```

### Backend Tests
```bash
cd backend/functions
npm test index.test.js
```

## Test Coverage

The test suite covers:

✅ **Type Validation**: Ensuring only valid types (0 or 1) are used
✅ **Media Handling**: Proper display of videos vs photos
✅ **Thumbnail Management**: Videos have thumbnails, photos don't
✅ **Upload Workflow**: Complete flow from camera/gallery to posting
✅ **Backend Integration**: Cloud Functions handle types correctly
✅ **Notification System**: Notifications include correct content type
✅ **Feed Display**: Mixed content renders correctly
✅ **Error Handling**: Invalid types are caught and reported
✅ **Edge Cases**: NaN, Infinity, null, undefined handling

## Common Issues & Solutions

### Video without Thumbnail
**Problem**: Posting video without thumbnail URL  
**Solution**: Use `validatePostObject()` to catch this error

### Wrong Component Rendering
**Problem**: Video showing with Image component  
**Solution**: Use `getDisplayComponentForType()` to select correct component

### Type Not Preserved
**Problem**: Content type changes during upload  
**Solution**: Tests ensure type stays consistent through save cycle

### Invalid Type Accepted
**Problem**: Invalid type (like 99) accepted in post  
**Solution**: Use `validateContentType()` before accepting user input

## Contributing

When adding new content type related functionality:

1. Add corresponding test cases
2. Run existing tests to ensure no regressions
3. Update this README if new features are added
4. Ensure all tests pass before submitting PR

## Future Enhancements

Potential areas for expansion:
- Audio content type (Type 2)
- Document sharing
- Carousel posts with mixed media
- Live video support
- Story content type

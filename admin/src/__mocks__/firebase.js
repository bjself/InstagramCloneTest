/**
 * Manual mock for the `firebase` package.
 *
 * Components import Firebase in two ways:
 *   - `import firebase from 'firebase'`        (App.js, login.js)
 *   - `import firebase from 'firebase/app'`    (Users.js, User.js, Post.js)
 *
 * Both are intercepted here via Jest's moduleNameMapper in jest.config.js.
 * The mock exposes jest.fn() stubs for every Firebase method the admin panel
 * components actually call, so tests can control return values and assert
 * on calls without a real Firebase project.
 */

// --- auth mock ---
const mockSignInWithEmailAndPassword = jest.fn(() => Promise.resolve({ user: { uid: 'test-uid' } }));
const mockSignOut = jest.fn(() => Promise.resolve());
const mockOnAuthStateChanged = jest.fn();
const mockCurrentUser = { uid: 'test-uid', email: 'admin@test.com' };

const mockAuth = {
  currentUser: null,
  onAuthStateChanged: mockOnAuthStateChanged,
  signInWithEmailAndPassword: mockSignInWithEmailAndPassword,
  signOut: mockSignOut,
};

// --- firestore mock ---
const mockOnSnapshot = jest.fn();
const mockCollection = jest.fn();
const mockDoc = jest.fn();
const mockUpdate = jest.fn(() => Promise.resolve());
const mockDelete = jest.fn(() => Promise.resolve());

// Build a chainable mock: firebase.firestore().collection().onSnapshot()
const mockDocRef = {
  onSnapshot: mockOnSnapshot,
  update: mockUpdate,
  delete: mockDelete,
  collection: jest.fn(() => mockCollectionRef),
};

const mockCollectionRef = {
  onSnapshot: mockOnSnapshot,
  doc: jest.fn(() => mockDocRef),
  add: jest.fn(() => Promise.resolve()),
};

mockCollection.mockReturnValue(mockCollectionRef);
mockDoc.mockReturnValue(mockDocRef);

const mockFirestore = jest.fn(() => ({
  collection: mockCollection,
  doc: mockDoc,
}));

mockFirestore.FieldValue = {
  serverTimestamp: jest.fn(() => 'mock-timestamp'),
  increment: jest.fn((n) => n),
};

// --- firebase top-level mock ---
const firebase = {
  auth: jest.fn(() => mockAuth),
  firestore: mockFirestore,
  initializeApp: jest.fn(),
};

// Attach helpers so tests can reference these fns directly.
firebase.__mockAuth = mockAuth;
firebase.__mockSignInWithEmailAndPassword = mockSignInWithEmailAndPassword;
firebase.__mockOnAuthStateChanged = mockOnAuthStateChanged;
firebase.__mockCurrentUser = mockCurrentUser;
firebase.__mockOnSnapshot = mockOnSnapshot;
firebase.__mockCollection = mockCollection;

module.exports = firebase;
module.exports.default = firebase;

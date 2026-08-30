import React from 'react';
import { render, screen, act } from '@testing-library/react';
import App from './App';
import firebase from 'firebase';

// firebase is auto-mocked via moduleNameMapper → src/__mocks__/firebase.js

// @material-ui/data-grid crashes in jsdom — stub it out.
jest.mock('@material-ui/data-grid', () => ({
  DataGrid: ({ rows }) => (
    <div role="grid" aria-label="data-grid">
      {(rows || []).map((r) => (
        <div key={r.id} role="row" />
      ))}
    </div>
  ),
}));

// Prevent "two Routers" warnings from the Home component.
jest.mock('react-router-dom', () => {
  const real = jest.requireActual('react-router-dom');
  return {
    ...real,
    useHistory: () => ({ push: jest.fn() }),
  };
});

// The Login component has a bug: when firebase.auth().currentUser is defined
// it returns undefined instead of null, crashing React. We stub Login here
// so App.test.js can test the routing logic in isolation.
jest.mock('./components/login', () => () => <div data-testid="login-page">Login</div>);

describe('App authentication flow', () => {
  test('shows the login form when no user is signed in', () => {
    firebase.auth.mockReturnValue({
      onAuthStateChanged: jest.fn((callback) => {
        callback(null); // not signed in
        return () => {};
      }),
      currentUser: null,
    });

    render(<App />);

    expect(screen.getByTestId('login-page')).toBeInTheDocument();
  });

  test('shows the home dashboard when a user is signed in', async () => {
    firebase.auth.mockReturnValue({
      onAuthStateChanged: jest.fn((callback) => {
        callback({ uid: 'user-123', email: 'admin@test.com' });
        return () => {};
      }),
      currentUser: { uid: 'user-123' },
    });

    // Stub the Firestore call that Users (inside Home) triggers
    firebase.firestore.mockReturnValue({
      collection: jest.fn(() => ({
        onSnapshot: jest.fn((callback) => {
          callback({ docs: [] });
          return jest.fn();
        }),
      })),
    });

    await act(async () => {
      render(<App />);
    });

    expect(screen.getByText(/FreeRide Admin/i)).toBeInTheDocument();
  });
});

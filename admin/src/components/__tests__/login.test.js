import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import Login from '../login';
import firebase from 'firebase';

// firebase is auto-mocked via moduleNameMapper → src/__mocks__/firebase.js

// Wrap Login in a Router because it uses <Redirect> from react-router-dom
function renderLogin() {
  return render(
    <MemoryRouter>
      <Login />
    </MemoryRouter>
  );
}

describe('Login component', () => {
  beforeEach(() => {
    // Default: no user signed in — component shows the login form
    firebase.auth.mockReturnValue({
      currentUser: undefined,
      signInWithEmailAndPassword: jest.fn(() => Promise.resolve()),
    });
  });

  test('renders the Sign In heading', () => {
    renderLogin();
    expect(screen.getByText(/sign in/i)).toBeInTheDocument();
  });

  test('renders an email input field', () => {
    renderLogin();
    expect(screen.getByPlaceholderText(/enter email/i)).toBeInTheDocument();
  });

  test('renders a password input field', () => {
    renderLogin();
    expect(screen.getByPlaceholderText(/enter password/i)).toBeInTheDocument();
  });

  test('renders a Submit button', () => {
    renderLogin();
    expect(screen.getByRole('button', { name: /submit/i })).toBeInTheDocument();
  });

  test('calls signInWithEmailAndPassword with the entered email and password', () => {
    const mockSignIn = jest.fn(() => Promise.resolve());
    firebase.auth.mockReturnValue({
      currentUser: undefined,
      signInWithEmailAndPassword: mockSignIn,
    });

    renderLogin();

    // Type into the email and password fields
    fireEvent.change(screen.getByPlaceholderText(/enter email/i), {
      target: { value: 'admin@test.com' },
    });
    fireEvent.change(screen.getByPlaceholderText(/enter password/i), {
      target: { value: 'secret123' },
    });

    // Click Submit
    fireEvent.click(screen.getByRole('button', { name: /submit/i }));

    expect(mockSignIn).toHaveBeenCalledWith('admin@test.com', 'secret123');
  });
});

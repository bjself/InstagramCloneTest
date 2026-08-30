import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import firebase from 'firebase';

// Home uses useHistory which requires a Router context.
// Home also renders its own <Router>, so we mock useHistory to avoid
// having two Routers nested inside each other.
jest.mock('react-router-dom', () => {
  const real = jest.requireActual('react-router-dom');
  return {
    ...real,
    useHistory: () => ({ push: jest.fn() }),
  };
});

// @material-ui/data-grid crashes in jsdom — stub it out.
// Home renders Users which uses DataGrid, so we stub it here too.
jest.mock('@material-ui/data-grid', () => ({
  DataGrid: ({ rows }) => (
    <div role="grid" aria-label="data-grid">
      {rows.map((r) => (
        <div key={r.id} role="row" />
      ))}
    </div>
  ),
}));

import Home from '../Home';

beforeEach(() => {
  // Stub the Firestore call that Users (rendered inside Home) triggers
  firebase.firestore.mockReturnValue({
    collection: jest.fn(() => ({
      onSnapshot: jest.fn((callback) => {
        callback({ docs: [] });
        return jest.fn();
      }),
      doc: jest.fn(),
    })),
  });
});

function renderHome() {
  // Home renders its own <Router> internally.
  return render(<Home />);
}

describe('Home component', () => {
  test('renders the FreeRide Admin title', () => {
    renderHome();
    expect(screen.getByText(/FreeRide Admin/i)).toBeInTheDocument();
  });

  test('renders a Users navigation link in the drawer', () => {
    renderHome();
    expect(screen.getByText(/^Users$/i)).toBeInTheDocument();
  });

  test('shows the open-drawer button when the drawer is closed', () => {
    renderHome();
    const menuButton = screen.getByLabelText(/open drawer/i);
    expect(menuButton).toBeInTheDocument();
  });

  test('drawer open/close button click does not crash the component', () => {
    renderHome();
    const menuButton = screen.getByLabelText(/open drawer/i);
    fireEvent.click(menuButton);
    // Title stays visible after opening the drawer
    expect(screen.getByText(/FreeRide Admin/i)).toBeInTheDocument();
  });
});

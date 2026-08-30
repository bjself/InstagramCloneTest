import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import firebase from 'firebase';

// Mock useHistory (Users uses it for the View button click handler)
jest.mock('react-router-dom', () => {
  const real = jest.requireActual('react-router-dom');
  return {
    ...real,
    useHistory: () => ({ push: jest.fn() }),
  };
});

// @material-ui/data-grid uses browser APIs that jsdom doesn't support.
// Replace it with a simple stub that renders the rows as a table so tests
// can assert on content without fighting jsdom compatibility issues.
jest.mock('@material-ui/data-grid', () => ({
  DataGrid: ({ rows, columns }) => (
    <div role="grid" aria-label="data-grid">
      <div role="row" className="header-row">
        {columns.map((col) => (
          <span key={col.field}>{col.headerName}</span>
        ))}
      </div>
      {rows.map((row) => (
        <div role="row" key={row.id} data-testid={`row-${row.id}`}>
          {columns.map((col) => (
            <span key={col.field}>{String(row[col.field] ?? '')}</span>
          ))}
        </div>
      ))}
    </div>
  ),
}));

import Users from '../Users';

function renderUsers() {
  return render(
    <MemoryRouter>
      <Users />
    </MemoryRouter>
  );
}

describe('Users component', () => {
  test('renders without crashing when the users list is empty', () => {
    firebase.firestore.mockReturnValue({
      collection: jest.fn(() => ({
        onSnapshot: jest.fn((callback) => {
          callback({ docs: [] });
          return jest.fn(); // unsubscribe fn
        }),
      })),
    });

    renderUsers();
    expect(document.querySelector('[role="grid"]')).toBeInTheDocument();
  });

  test('displays user rows returned from Firestore', async () => {
    const fakeUsers = [
      { id: 'uid-1', name: 'Alice', username: 'alice', banned: false },
      { id: 'uid-2', name: 'Bob',   username: 'bob',   banned: true  },
    ];

    firebase.firestore.mockReturnValue({
      collection: jest.fn(() => ({
        onSnapshot: jest.fn((callback) => {
          callback({
            docs: fakeUsers.map((u) => ({
              id: u.id,
              data: () => ({ name: u.name, username: u.username, banned: u.banned }),
            })),
          });
          return jest.fn();
        }),
      })),
    });

    renderUsers();

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument();
      expect(screen.getByText('Bob')).toBeInTheDocument();
    });
  });

  test('renders the column headers: ID, Name, Username, banned, Detail', async () => {
    firebase.firestore.mockReturnValue({
      collection: jest.fn(() => ({
        onSnapshot: jest.fn((callback) => {
          callback({ docs: [] });
          return jest.fn();
        }),
      })),
    });

    renderUsers();

    await waitFor(() => {
      expect(screen.getByText('ID')).toBeInTheDocument();
      expect(screen.getByText('Name')).toBeInTheDocument();
      expect(screen.getByText('Username')).toBeInTheDocument();
      expect(screen.getByText('banned')).toBeInTheDocument();
      expect(screen.getByText('Detail')).toBeInTheDocument();
    });
  });

  test('calls Firestore collection("users") to load user data', () => {
    const mockOnSnapshot = jest.fn((callback) => {
      callback({ docs: [] });
      return jest.fn();
    });
    const mockCollectionFn = jest.fn(() => ({ onSnapshot: mockOnSnapshot }));
    firebase.firestore.mockReturnValue({ collection: mockCollectionFn });

    renderUsers();

    expect(mockCollectionFn).toHaveBeenCalledWith('users');
  });
});

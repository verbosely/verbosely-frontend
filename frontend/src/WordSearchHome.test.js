import { render, screen } from '@testing-library/react';
import WordSearchHome from './WordSearchHome';

test('renders learn react link', () => {
  render(<WordSearchHome />);
  const linkElement = screen.getByText(/learn react/i);
  expect(linkElement).toBeInTheDocument();
});

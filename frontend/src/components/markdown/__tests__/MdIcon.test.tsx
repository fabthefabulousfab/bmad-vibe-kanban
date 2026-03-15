/**
 * Unit tests for the MdIcon component
 */
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MdIcon } from '../MdIcon';

describe('MdIcon', () => {
  it('renders the "MD" text', () => {
    render(<MdIcon />);
    expect(screen.getByText('MD')).toBeDefined();
  });

  it('applies default className', () => {
    const { container } = render(<MdIcon />);
    const span = container.querySelector('span');
    expect(span?.className).toContain('h-4');
    expect(span?.className).toContain('w-4');
  });

  it('applies custom className', () => {
    const { container } = render(<MdIcon className="h-8 w-8" />);
    const span = container.querySelector('span');
    expect(span?.className).toContain('h-8');
    expect(span?.className).toContain('w-8');
  });

  it('uses bold font styling', () => {
    const { container } = render(<MdIcon />);
    const span = container.querySelector('span');
    expect(span?.className).toContain('font-bold');
  });
});

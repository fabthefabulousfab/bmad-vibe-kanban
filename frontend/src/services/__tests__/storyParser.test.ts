/**
 * Unit Tests for Story Parser
 */

import { describe, it, expect } from 'vitest';
import {
  extractWesFromFilename,
  parseStoryMarkdown,
  sortStoriesByWes,
  type StoryFile,
} from '../storyParser';

describe('storyParser', () => {
  describe('extractWesFromFilename', () => {
    it('should extract W-E-S from valid filename', () => {
      expect(extractWesFromFilename('1-1-0-quick-spec.md')).toBe('1-1-0');
      expect(extractWesFromFilename('2-3-5-complex-feature.md')).toBe('2-3-5');
    });

    it('should return null for invalid filename', () => {
      expect(extractWesFromFilename('invalid.md')).toBeNull();
      expect(extractWesFromFilename('README.md')).toBeNull();
    });
  });

  describe('parseStoryMarkdown', () => {
    it('should parse story with standard format', () => {
      const markdown = `# Story 1-1/0: Quick Specification

**Wave:** 1 | **Epic:** 1 | **Story:** 0

## User Story

Content`;

      const result = parseStoryMarkdown(markdown, 5);

      expect(result.title).toBe('Quick Specification');
      expect(result.wes).toBe('1-1-0');
      expect(result.sequenceNumber).toBe(5);
    });
  });

  describe('sortStoriesByWes', () => {
    it('should sort stories in W-E-S order', () => {
      const files: StoryFile[] = [
        { filename: '2-1-0-test.md', wes: '2-1-0', path: '/2-1-0' },
        { filename: '1-1-0-test.md', wes: '1-1-0', path: '/1-1-0' },
      ];

      const sorted = sortStoriesByWes(files);

      expect(sorted[0].wes).toBe('1-1-0');
      expect(sorted[1].wes).toBe('2-1-0');
    });
  });
});

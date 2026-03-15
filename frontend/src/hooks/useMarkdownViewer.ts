import { useCallback, useRef } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { fileSystemApi, repoApi } from '@/lib/api';
import type { FileTreeEntry, FileContentResponse, RenameEntryResponse } from 'shared/types';

/** Query keys for markdown viewer */
export const markdownKeys = {
  tree: (basePath: string) => ['markdown-tree', basePath] as const,
  fileContent: (basePath: string, filePath: string) =>
    ['markdown-file-content', basePath, filePath] as const,
  branches: (repoId: string) => ['markdown-branches', repoId] as const,
};

/** Fetches the markdown file tree for a workspace path */
export function useMarkdownTree(basePath: string | null) {
  return useQuery<FileTreeEntry[]>({
    queryKey: markdownKeys.tree(basePath ?? ''),
    queryFn: () => fileSystemApi.getMarkdownTree(basePath!),
    enabled: !!basePath,
  });
}

/** Fetches file content for a specific markdown file */
export function useFileContent(basePath: string | null, filePath: string | null) {
  return useQuery<FileContentResponse>({
    queryKey: markdownKeys.fileContent(basePath ?? '', filePath ?? ''),
    queryFn: () => fileSystemApi.getFileContent(basePath!, filePath!),
    enabled: !!basePath && !!filePath,
  });
}

/** Fetches branches for a repository */
export function useBranches(repoId: string | null) {
  return useQuery({
    queryKey: markdownKeys.branches(repoId ?? ''),
    queryFn: () => repoApi.getBranches(repoId!),
    enabled: !!repoId,
  });
}

/** Mutation hook for saving file content */
export function useSaveFileContent(basePath: string | null) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      filePath,
      content,
    }: {
      filePath: string;
      content: string;
    }) => fileSystemApi.saveFileContent(basePath!, filePath, content),
    onSuccess: (_data, variables) => {
      queryClient.invalidateQueries({
        queryKey: markdownKeys.fileContent(basePath ?? '', variables.filePath),
      });
    },
  });
}

/** Mutation hook for creating a new .md file */
export function useCreateFile(basePath: string | null) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (relativePath: string) =>
      fileSystemApi.createFile(basePath!, relativePath),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: markdownKeys.tree(basePath ?? ''),
      });
    },
  });
}

/** Mutation hook for creating a new directory */
export function useCreateDirectory(basePath: string | null) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (relativePath: string) =>
      fileSystemApi.createDirectory(basePath!, relativePath),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: markdownKeys.tree(basePath ?? ''),
      });
    },
  });
}

/** Mutation hook for renaming a file or directory */
export function useRenameEntry(basePath: string | null) {
  const queryClient = useQueryClient();

  return useMutation<
    RenameEntryResponse,
    Error,
    { oldPath: string; newName: string }
  >({
    mutationFn: ({ oldPath, newName }) =>
      fileSystemApi.renameEntry(basePath!, oldPath, newName),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: markdownKeys.tree(basePath ?? ''),
      });
    },
  });
}

/** Mutation hook for deleting a file or directory */
export function useDeleteEntry(basePath: string | null) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (relativePath: string) =>
      fileSystemApi.deleteEntry(basePath!, relativePath),
    onSuccess: () => {
      queryClient.invalidateQueries({
        queryKey: markdownKeys.tree(basePath ?? ''),
      });
    },
  });
}

/**
 * Synchronizes scroll position between editor and preview panes
 * using proportional mapping. Uses requestAnimationFrame and a
 * scrollSource ref to prevent infinite feedback loops.
 */
export function useSyncScroll(
  editorRef: React.RefObject<HTMLTextAreaElement | null>,
  previewRef: React.RefObject<HTMLDivElement | null>
) {
  const scrollSourceRef = useRef<'editor' | 'preview' | null>(null);
  const rafRef = useRef<number | null>(null);

  const onEditorScroll = useCallback(() => {
    if (scrollSourceRef.current === 'preview') return;
    scrollSourceRef.current = 'editor';

    if (rafRef.current) cancelAnimationFrame(rafRef.current);
    rafRef.current = requestAnimationFrame(() => {
      const editor = editorRef.current;
      const preview = previewRef.current;
      if (!editor || !preview) return;

      const editorMaxScroll = editor.scrollHeight - editor.clientHeight;
      if (editorMaxScroll <= 0) return;

      const ratio = editor.scrollTop / editorMaxScroll;
      const previewMaxScroll = preview.scrollHeight - preview.clientHeight;
      preview.scrollTop = ratio * previewMaxScroll;

      requestAnimationFrame(() => {
        scrollSourceRef.current = null;
      });
    });
  }, [editorRef, previewRef]);

  const onPreviewScroll = useCallback(() => {
    if (scrollSourceRef.current === 'editor') return;
    scrollSourceRef.current = 'preview';

    if (rafRef.current) cancelAnimationFrame(rafRef.current);
    rafRef.current = requestAnimationFrame(() => {
      const editor = editorRef.current;
      const preview = previewRef.current;
      if (!editor || !preview) return;

      const previewMaxScroll = preview.scrollHeight - preview.clientHeight;
      if (previewMaxScroll <= 0) return;

      const ratio = preview.scrollTop / previewMaxScroll;
      const editorMaxScroll = editor.scrollHeight - editor.clientHeight;
      editor.scrollTop = ratio * editorMaxScroll;

      requestAnimationFrame(() => {
        scrollSourceRef.current = null;
      });
    });
  }, [editorRef, previewRef]);

  return { onEditorScroll, onPreviewScroll };
}

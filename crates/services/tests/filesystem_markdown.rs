#[cfg(test)]
mod markdown_tests {
    use std::{fs, path::Path};

    use services::services::filesystem::FilesystemService;
    use tempfile::TempDir;

    /// Helper to create a file with content
    fn create_file(base: &Path, relative: &str, content: &str) {
        let full_path = base.join(relative);
        if let Some(parent) = full_path.parent() {
            fs::create_dir_all(parent).unwrap();
        }
        fs::write(&full_path, content).unwrap();
    }

    /// Helper to create a directory
    fn create_dir(base: &Path, relative: &str) {
        let full_path = base.join(relative);
        fs::create_dir_all(&full_path).unwrap();
    }

    /// Builds a temp directory with a standard markdown test structure:
    /// temp_dir/
    ///   docs/
    ///     README.md
    ///     guide.md
    ///     api/
    ///       endpoints.md
    ///   src/
    ///     main.rs (not .md, should be excluded)
    ///   notes.md
    ///   .hidden/
    ///     secret.md (hidden dir, should be excluded)
    fn create_test_structure(base: &Path) {
        create_file(base, "docs/README.md", "# Docs README");
        create_file(base, "docs/guide.md", "# Guide\n\nSome content.");
        create_file(base, "docs/api/endpoints.md", "# API Endpoints");
        create_file(base, "src/main.rs", "fn main() {}");
        create_file(base, "notes.md", "# Notes");
        create_file(base, ".hidden/secret.md", "# Secret");
    }

    #[tokio::test]
    async fn test_list_markdown_files_returns_only_md() {
        let temp_dir = TempDir::new().unwrap();
        create_test_structure(temp_dir.path());

        let service = FilesystemService::new();
        let tree = service
            .list_markdown_files(&temp_dir.path().to_string_lossy())
            .await
            .unwrap();

        // Should have: docs/ (with children) and notes.md at top level
        // .hidden/ should be excluded, src/ should be excluded (no .md files)
        let top_level_names: Vec<&str> = tree.iter().map(|e| e.name.as_str()).collect();
        assert!(top_level_names.contains(&"docs"), "Should contain 'docs' directory");
        assert!(top_level_names.contains(&"notes.md"), "Should contain 'notes.md'");
        assert!(
            !top_level_names.contains(&".hidden"),
            "Should NOT contain '.hidden' directory"
        );
        assert!(
            !top_level_names.contains(&"src"),
            "Should NOT contain 'src' (no .md files)"
        );
    }

    #[tokio::test]
    async fn test_list_markdown_files_nested_structure() {
        let temp_dir = TempDir::new().unwrap();
        create_test_structure(temp_dir.path());

        let service = FilesystemService::new();
        let tree = service
            .list_markdown_files(&temp_dir.path().to_string_lossy())
            .await
            .unwrap();

        // Find docs directory and check its children
        let docs = tree.iter().find(|e| e.name == "docs").unwrap();
        assert!(docs.is_directory);
        let docs_names: Vec<&str> = docs.children.iter().map(|e| e.name.as_str()).collect();
        assert!(docs_names.contains(&"api"), "docs should contain 'api' subdir");
        assert!(docs_names.contains(&"README.md"), "docs should contain 'README.md'");
        assert!(docs_names.contains(&"guide.md"), "docs should contain 'guide.md'");
    }

    #[tokio::test]
    async fn test_read_file_content_success() {
        let temp_dir = TempDir::new().unwrap();
        create_file(temp_dir.path(), "test.md", "# Hello World\n\nContent here.");

        let service = FilesystemService::new();
        let result = service
            .read_file_content(&temp_dir.path().to_string_lossy(), "test.md")
            .await
            .unwrap();

        assert_eq!(result.content, "# Hello World\n\nContent here.");
        assert_eq!(result.path, "test.md");
    }

    #[tokio::test]
    async fn test_read_file_content_rejects_non_md() {
        let temp_dir = TempDir::new().unwrap();
        create_file(temp_dir.path(), "main.rs", "fn main() {}");

        let service = FilesystemService::new();
        let result = service
            .read_file_content(&temp_dir.path().to_string_lossy(), "main.rs")
            .await;

        assert!(result.is_err(), "Should reject non-.md files");
    }

    #[tokio::test]
    async fn test_read_file_content_prevents_path_traversal() {
        let temp_dir = TempDir::new().unwrap();
        create_file(temp_dir.path(), "legit.md", "ok");

        let service = FilesystemService::new();
        let result = service
            .read_file_content(&temp_dir.path().to_string_lossy(), "../../../etc/passwd.md")
            .await;

        assert!(result.is_err(), "Should prevent path traversal");
    }

    #[tokio::test]
    async fn test_write_file_content_success() {
        let temp_dir = TempDir::new().unwrap();
        create_file(temp_dir.path(), "editable.md", "original content");

        let service = FilesystemService::new();
        service
            .write_file_content(
                &temp_dir.path().to_string_lossy(),
                "editable.md",
                "updated content",
            )
            .await
            .unwrap();

        let content = fs::read_to_string(temp_dir.path().join("editable.md")).unwrap();
        assert_eq!(content, "updated content");
    }

    #[tokio::test]
    async fn test_create_file_success() {
        let temp_dir = TempDir::new().unwrap();

        let service = FilesystemService::new();
        service
            .create_file(&temp_dir.path().to_string_lossy(), "new-file.md")
            .await
            .unwrap();

        assert!(temp_dir.path().join("new-file.md").exists());
        let content = fs::read_to_string(temp_dir.path().join("new-file.md")).unwrap();
        assert_eq!(content, "", "New file should be empty");
    }

    #[tokio::test]
    async fn test_create_file_rejects_non_md() {
        let temp_dir = TempDir::new().unwrap();

        let service = FilesystemService::new();
        let result = service
            .create_file(&temp_dir.path().to_string_lossy(), "bad.txt")
            .await;

        assert!(result.is_err(), "Should reject non-.md extension");
    }

    #[tokio::test]
    async fn test_create_directory_success() {
        let temp_dir = TempDir::new().unwrap();

        let service = FilesystemService::new();
        service
            .create_directory(&temp_dir.path().to_string_lossy(), "new-folder")
            .await
            .unwrap();

        assert!(temp_dir.path().join("new-folder").is_dir());
    }

    #[tokio::test]
    async fn test_rename_entry_success() {
        let temp_dir = TempDir::new().unwrap();
        create_file(temp_dir.path(), "old-name.md", "content");

        let service = FilesystemService::new();
        let result = service
            .rename_entry(&temp_dir.path().to_string_lossy(), "old-name.md", "new-name.md")
            .await
            .unwrap();

        assert!(!temp_dir.path().join("old-name.md").exists());
        assert!(temp_dir.path().join("new-name.md").exists());
        assert_eq!(result.new_path, "new-name.md");
    }

    #[tokio::test]
    async fn test_rename_rejects_path_separators() {
        let temp_dir = TempDir::new().unwrap();
        create_file(temp_dir.path(), "file.md", "content");

        let service = FilesystemService::new();
        let result = service
            .rename_entry(
                &temp_dir.path().to_string_lossy(),
                "file.md",
                "../escape.md",
            )
            .await;

        assert!(result.is_err(), "Should reject names with path separators");
    }

    #[tokio::test]
    async fn test_delete_file_success() {
        let temp_dir = TempDir::new().unwrap();
        create_file(temp_dir.path(), "to-delete.md", "bye");

        let service = FilesystemService::new();
        service
            .delete_entry(&temp_dir.path().to_string_lossy(), "to-delete.md")
            .await
            .unwrap();

        assert!(!temp_dir.path().join("to-delete.md").exists());
    }

    #[tokio::test]
    async fn test_delete_empty_directory_success() {
        let temp_dir = TempDir::new().unwrap();
        create_dir(temp_dir.path(), "empty-dir");

        let service = FilesystemService::new();
        service
            .delete_entry(&temp_dir.path().to_string_lossy(), "empty-dir")
            .await
            .unwrap();

        assert!(!temp_dir.path().join("empty-dir").exists());
    }

    #[tokio::test]
    async fn test_delete_non_empty_directory_fails() {
        let temp_dir = TempDir::new().unwrap();
        create_file(temp_dir.path(), "non-empty/file.md", "content");

        let service = FilesystemService::new();
        let result = service
            .delete_entry(&temp_dir.path().to_string_lossy(), "non-empty")
            .await;

        assert!(result.is_err(), "Should reject deleting non-empty directories");
    }

    #[tokio::test]
    async fn test_sort_order_directories_first() {
        let temp_dir = TempDir::new().unwrap();
        create_file(temp_dir.path(), "zebra.md", "z");
        create_file(temp_dir.path(), "alpha/a.md", "a");
        create_file(temp_dir.path(), "beta.md", "b");

        let service = FilesystemService::new();
        let tree = service
            .list_markdown_files(&temp_dir.path().to_string_lossy())
            .await
            .unwrap();

        // alpha/ directory should come before beta.md and zebra.md
        assert_eq!(tree[0].name, "alpha", "Directory should sort first");
        assert!(tree[0].is_directory);
        assert!(!tree[1].is_directory, "Files should follow directories");
    }
}

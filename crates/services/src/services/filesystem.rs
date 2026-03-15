#[cfg(not(feature = "qa-mode"))]
use std::collections::HashSet;
use std::{
    fs,
    path::{Path, PathBuf},
};

#[cfg(not(feature = "qa-mode"))]
use ignore::WalkBuilder;
use serde::{Deserialize, Serialize};
use thiserror::Error;
#[cfg(not(feature = "qa-mode"))]
use tokio_util::sync::CancellationToken;
use ts_rs::TS;

#[derive(Clone)]
pub struct FilesystemService {}

#[derive(Debug, Error)]
pub enum FilesystemError {
    #[error("Directory does not exist")]
    DirectoryDoesNotExist,
    #[error("Path is not a directory")]
    PathIsNotDirectory,
    #[error("Failed to read directory: {0}")]
    Io(#[from] std::io::Error),
    #[error("File not found: {0}")]
    FileNotFound(String),
    #[error("Path traversal attempt detected")]
    PathTraversal,
    #[error("Not a markdown file")]
    NotMarkdownFile,
    #[error("Invalid name: {0}")]
    InvalidName(String),
    #[error("Directory is not empty")]
    DirectoryNotEmpty,
}

/// A single entry in the markdown file tree
#[derive(Debug, Serialize, TS)]
pub struct FileTreeEntry {
    pub name: String,
    pub path: String,
    pub is_directory: bool,
    pub children: Vec<FileTreeEntry>,
}

/// Response containing file content
#[derive(Debug, Serialize, TS)]
pub struct FileContentResponse {
    pub content: String,
    pub path: String,
}

/// Request to write file content
#[derive(Debug, Deserialize)]
pub struct WriteFileContentRequest {
    pub path: String,
    pub content: String,
}

/// Request to create a file or directory
#[derive(Debug, Deserialize)]
pub struct CreateEntryRequest {
    pub base_path: String,
    pub relative_path: String,
}

/// Request to rename a file or directory
#[derive(Debug, Deserialize)]
pub struct RenameEntryRequest {
    pub base_path: String,
    pub old_path: String,
    pub new_name: String,
}

/// Response after renaming an entry
#[derive(Debug, Serialize, TS)]
pub struct RenameEntryResponse {
    pub new_path: String,
}

/// Request to delete a file or directory
#[derive(Debug, Deserialize)]
pub struct DeleteEntryRequest {
    pub base_path: String,
    pub relative_path: String,
}
#[derive(Debug, Serialize, TS)]
pub struct DirectoryListResponse {
    pub entries: Vec<DirectoryEntry>,
    pub current_path: String,
}

#[derive(Debug, Serialize, TS)]
pub struct DirectoryEntry {
    pub name: String,
    pub path: PathBuf,
    pub is_directory: bool,
    pub is_git_repo: bool,
    pub last_modified: Option<u64>,
}

impl Default for FilesystemService {
    fn default() -> Self {
        Self::new()
    }
}

impl FilesystemService {
    pub fn new() -> Self {
        FilesystemService {}
    }

    #[cfg(not(feature = "qa-mode"))]
    fn get_directories_to_skip() -> HashSet<String> {
        let mut skip_dirs = HashSet::from(
            [
                "node_modules",
                "target",
                "build",
                "dist",
                ".next",
                ".nuxt",
                ".cache",
                ".npm",
                ".yarn",
                ".pnpm-store",
                "Library",
                "AppData",
                "Applications",
            ]
            .map(String::from),
        );

        [
            dirs::executable_dir(),
            dirs::data_dir(),
            dirs::download_dir(),
            dirs::picture_dir(),
            dirs::video_dir(),
            dirs::audio_dir(),
        ]
        .into_iter()
        .flatten()
        .filter_map(|path| path.file_name()?.to_str().map(String::from))
        .for_each(|name| {
            skip_dirs.insert(name);
        });

        skip_dirs
    }

    #[cfg_attr(feature = "qa-mode", allow(unused_variables))]
    pub async fn list_git_repos(
        &self,
        path: Option<String>,
        timeout_ms: u64,
        hard_timeout_ms: u64,
        max_depth: Option<usize>,
    ) -> Result<Vec<DirectoryEntry>, FilesystemError> {
        #[cfg(feature = "qa-mode")]
        {
            tracing::info!("QA mode: returning hardcoded QA repos instead of scanning filesystem");
            super::qa_repos::get_qa_repos()
        }

        #[cfg(not(feature = "qa-mode"))]
        {
            let base_path = path
                .map(PathBuf::from)
                .unwrap_or_else(Self::get_home_directory);
            Self::verify_directory(&base_path)?;
            self.list_git_repos_with_timeout(
                vec![base_path],
                timeout_ms,
                hard_timeout_ms,
                max_depth,
            )
            .await
        }
    }

    #[cfg(not(feature = "qa-mode"))]
    async fn list_git_repos_with_timeout(
        &self,
        paths: Vec<PathBuf>,
        timeout_ms: u64,
        hard_timeout_ms: u64,
        max_depth: Option<usize>,
    ) -> Result<Vec<DirectoryEntry>, FilesystemError> {
        let cancel_token = CancellationToken::new();
        let cancel_after_delay = cancel_token.clone();
        tokio::spawn(async move {
            tokio::time::sleep(std::time::Duration::from_millis(timeout_ms)).await;
            cancel_after_delay.cancel();
        });
        let service = self.clone();
        let cancel_for_scan = cancel_token.clone();
        let mut scan_handle = tokio::spawn(async move {
            service
                .list_git_repos_inner(paths, max_depth, Some(&cancel_for_scan))
                .await
        });

        let hard_timeout = tokio::time::sleep(std::time::Duration::from_millis(hard_timeout_ms));
        tokio::pin!(hard_timeout);

        tokio::select! {
            res = &mut scan_handle => {
                match res {
                    Ok(Ok(repos)) => Ok(repos),
                    Ok(Err(err)) => Err(err),
                    Err(join_err) => Err(FilesystemError::Io(
                        std::io::Error::other(join_err.to_string())))
                }
                }
            _ = &mut hard_timeout => {
                scan_handle.abort();
                tracing::warn!("list_git_repos_with_timeout: hard timeout reached after {}ms", hard_timeout_ms);
                Err(FilesystemError::Io(std::io::Error::new(
                    std::io::ErrorKind::TimedOut,
                    "Operation forcibly terminated due to hard timeout",
                )))
            }
        }
    }

    #[cfg_attr(feature = "qa-mode", allow(unused_variables))]
    pub async fn list_common_git_repos(
        &self,
        timeout_ms: u64,
        hard_timeout_ms: u64,
        max_depth: Option<usize>,
    ) -> Result<Vec<DirectoryEntry>, FilesystemError> {
        #[cfg(feature = "qa-mode")]
        {
            tracing::info!(
                "QA mode: returning hardcoded QA repos instead of scanning common directories"
            );
            super::qa_repos::get_qa_repos()
        }

        #[cfg(not(feature = "qa-mode"))]
        {
            let search_strings = ["repos", "dev", "work", "code", "projects"];
            let home_dir = Self::get_home_directory();
            let mut paths: Vec<PathBuf> = search_strings
                .iter()
                .map(|s| home_dir.join(s))
                .filter(|p| p.exists() && p.is_dir())
                .collect();
            paths.insert(0, home_dir);
            if let Some(cwd) = std::env::current_dir().ok()
                && cwd.exists()
                && cwd.is_dir()
            {
                paths.insert(0, cwd);
            }
            self.list_git_repos_with_timeout(paths, timeout_ms, hard_timeout_ms, max_depth)
                .await
        }
    }

    #[cfg(not(feature = "qa-mode"))]
    async fn list_git_repos_inner(
        &self,
        path: Vec<PathBuf>,
        max_depth: Option<usize>,
        cancel: Option<&CancellationToken>,
    ) -> Result<Vec<DirectoryEntry>, FilesystemError> {
        let base_dir = match path.first() {
            Some(dir) => dir,
            None => return Ok(vec![]),
        };
        let skip_dirs = Self::get_directories_to_skip();
        let vibe_kanban_temp_dir = utils::path::get_vibe_kanban_temp_dir();
        let mut walker_builder = WalkBuilder::new(base_dir);
        walker_builder
            .follow_links(false)
            .hidden(true) // true to skip hidden files
            .git_ignore(true)
            .filter_entry({
                let cancel = cancel.cloned();
                move |entry| {
                    if let Some(token) = cancel.as_ref()
                        && token.is_cancelled()
                    {
                        tracing::debug!("Cancellation token triggered");
                        return false;
                    }

                    let path = entry.path();
                    if !path.is_dir() {
                        return false;
                    }

                    // Skip vibe-kanban temp directory and all subdirectories
                    // Normalize to handle macOS /private/var vs /var aliasing
                    if utils::path::normalize_macos_private_alias(path)
                        .starts_with(&vibe_kanban_temp_dir)
                    {
                        return false;
                    }

                    // Skip common non-git folders
                    if let Some(name) = path.file_name().and_then(|n| n.to_str())
                        && skip_dirs.contains(name)
                    {
                        return false;
                    }

                    true
                }
            })
            .max_depth(max_depth)
            .git_exclude(true);
        for p in path.iter().skip(1) {
            walker_builder.add(p);
        }
        let mut seen_dirs = HashSet::new();
        let mut git_repos: Vec<DirectoryEntry> = walker_builder
            .build()
            .filter_map(|entry| {
                let entry = entry.ok()?;
                if seen_dirs.contains(entry.path()) {
                    return None;
                }
                seen_dirs.insert(entry.path().to_owned());
                let name = entry.file_name().to_str()?;
                if !entry.path().join(".git").exists() {
                    return None;
                }
                let last_modified = entry
                    .metadata()
                    .ok()
                    .and_then(|m| m.modified().ok())
                    .map(|t| t.elapsed().unwrap_or_default().as_secs());
                Some(DirectoryEntry {
                    name: name.to_string(),
                    path: entry.into_path(),
                    is_directory: true,
                    is_git_repo: true,
                    last_modified,
                })
            })
            .collect();
        git_repos.sort_by_key(|entry| entry.last_modified.unwrap_or(0));
        Ok(git_repos)
    }

    fn get_home_directory() -> PathBuf {
        dirs::home_dir()
            .or_else(dirs::desktop_dir)
            .or_else(dirs::document_dir)
            .unwrap_or_else(|| {
                if cfg!(windows) {
                    std::env::var("USERPROFILE")
                        .map(PathBuf::from)
                        .unwrap_or_else(|_| PathBuf::from("C:\\"))
                } else {
                    PathBuf::from("/")
                }
            })
    }

    fn verify_directory(path: &Path) -> Result<(), FilesystemError> {
        if !path.exists() {
            return Err(FilesystemError::DirectoryDoesNotExist);
        }
        if !path.is_dir() {
            return Err(FilesystemError::PathIsNotDirectory);
        }
        Ok(())
    }

    pub async fn list_directory(
        &self,
        path: Option<String>,
    ) -> Result<DirectoryListResponse, FilesystemError> {
        let path = path
            .map(PathBuf::from)
            .unwrap_or_else(Self::get_home_directory);
        Self::verify_directory(&path)?;

        let entries = fs::read_dir(&path)?;
        let mut directory_entries = Vec::new();

        for entry in entries.flatten() {
            let path = entry.path();
            let metadata = entry.metadata().ok();
            if let Some(name) = path.file_name().and_then(|n| n.to_str()) {
                // Skip hidden files/directories
                if name.starts_with('.') && name != ".." {
                    continue;
                }

                let is_directory = metadata.is_some_and(|m| m.is_dir());
                let is_git_repo = if is_directory {
                    path.join(".git").exists()
                } else {
                    false
                };

                directory_entries.push(DirectoryEntry {
                    name: name.to_string(),
                    path,
                    is_directory,
                    is_git_repo,
                    last_modified: None,
                });
            }
        }
        // Sort: directories first, then files, both alphabetically
        directory_entries.sort_by(|a, b| match (a.is_directory, b.is_directory) {
            (true, false) => std::cmp::Ordering::Less,
            (false, true) => std::cmp::Ordering::Greater,
            _ => a.name.to_lowercase().cmp(&b.name.to_lowercase()),
        });

        Ok(DirectoryListResponse {
            entries: directory_entries,
            current_path: path.to_string_lossy().to_string(),
        })
    }

    // --- Markdown viewer methods ---

    /// Validates that a resolved path is within the given base directory.
    /// Returns the canonicalized path on success.
    fn validate_path_within_base(
        base_path: &Path,
        target_path: &Path,
    ) -> Result<PathBuf, FilesystemError> {
        tracing::debug!(
            "validate_path_within_base: base={}, target={}",
            base_path.display(),
            target_path.display()
        );
        let canonical_base = base_path
            .canonicalize()
            .map_err(|_| FilesystemError::DirectoryDoesNotExist)?;
        let canonical_target = target_path
            .canonicalize()
            .map_err(|_| FilesystemError::FileNotFound(target_path.display().to_string()))?;
        if !canonical_target.starts_with(&canonical_base) {
            tracing::warn!(
                "Path traversal attempt: {} is not within {}",
                canonical_target.display(),
                canonical_base.display()
            );
            return Err(FilesystemError::PathTraversal);
        }
        Ok(canonical_target)
    }

    /// Validates a path that may not yet exist (for create operations).
    /// Checks that the parent exists and is within the base.
    fn validate_new_path_within_base(
        base_path: &Path,
        target_path: &Path,
    ) -> Result<PathBuf, FilesystemError> {
        tracing::debug!(
            "validate_new_path_within_base: base={}, target={}",
            base_path.display(),
            target_path.display()
        );
        let canonical_base = base_path
            .canonicalize()
            .map_err(|_| FilesystemError::DirectoryDoesNotExist)?;
        let parent = target_path
            .parent()
            .ok_or_else(|| FilesystemError::InvalidName("No parent directory".to_string()))?;
        let canonical_parent = parent
            .canonicalize()
            .map_err(|_| FilesystemError::DirectoryDoesNotExist)?;
        if !canonical_parent.starts_with(&canonical_base) {
            return Err(FilesystemError::PathTraversal);
        }
        // Build the canonical path for the new entry
        let file_name = target_path
            .file_name()
            .ok_or_else(|| FilesystemError::InvalidName("No file name".to_string()))?;
        Ok(canonical_parent.join(file_name))
    }

    /// Recursively builds a file tree containing only .md files and their parent directories.
    fn build_markdown_tree(dir_path: &Path, base_path: &Path) -> Vec<FileTreeEntry> {
        tracing::debug!("build_markdown_tree: dir={}", dir_path.display());
        let entries = match fs::read_dir(dir_path) {
            Ok(e) => e,
            Err(_) => return vec![],
        };

        let mut result: Vec<FileTreeEntry> = Vec::new();

        for entry in entries.flatten() {
            let path = entry.path();
            let name = match path.file_name().and_then(|n| n.to_str()) {
                Some(n) => n.to_string(),
                None => continue,
            };

            // Skip hidden files and directories
            if name.starts_with('.') {
                continue;
            }

            let metadata = match entry.metadata() {
                Ok(m) => m,
                Err(_) => continue,
            };

            if metadata.is_dir() {
                // Skip common non-project directories
                if matches!(
                    name.as_str(),
                    "node_modules" | "target" | "build" | "dist" | ".git"
                ) {
                    continue;
                }
                // Recurse into directory
                let children = Self::build_markdown_tree(&path, base_path);
                // Only include directory if it has markdown descendants
                if !children.is_empty() {
                    let relative = path
                        .strip_prefix(base_path)
                        .unwrap_or(&path)
                        .to_string_lossy()
                        .to_string();
                    result.push(FileTreeEntry {
                        name,
                        path: relative,
                        is_directory: true,
                        children,
                    });
                }
            } else if name.ends_with(".md") {
                let relative = path
                    .strip_prefix(base_path)
                    .unwrap_or(&path)
                    .to_string_lossy()
                    .to_string();
                result.push(FileTreeEntry {
                    name,
                    path: relative,
                    is_directory: false,
                    children: vec![],
                });
            }
        }

        // Sort: directories first, then files, both alphabetically
        result.sort_by(|a, b| match (a.is_directory, b.is_directory) {
            (true, false) => std::cmp::Ordering::Less,
            (false, true) => std::cmp::Ordering::Greater,
            _ => a.name.to_lowercase().cmp(&b.name.to_lowercase()),
        });

        result
    }

    /// Lists only markdown files and their parent directories in a tree structure.
    pub async fn list_markdown_files(
        &self,
        base_path: &str,
    ) -> Result<Vec<FileTreeEntry>, FilesystemError> {
        tracing::info!("list_markdown_files: base_path={}", base_path);
        let path = PathBuf::from(base_path);
        Self::verify_directory(&path)?;
        let tree = Self::build_markdown_tree(&path, &path);
        tracing::info!(
            "list_markdown_files: completed, found {} top-level entries",
            tree.len()
        );
        Ok(tree)
    }

    /// Reads the content of a file, validating it is a .md file within the base path.
    pub async fn read_file_content(
        &self,
        base_path: &str,
        file_path: &str,
    ) -> Result<FileContentResponse, FilesystemError> {
        tracing::info!(
            "read_file_content: base={}, file={}",
            base_path,
            file_path
        );
        let base = PathBuf::from(base_path);
        let full_path = base.join(file_path);

        if !file_path.ends_with(".md") {
            return Err(FilesystemError::NotMarkdownFile);
        }

        let canonical = Self::validate_path_within_base(&base, &full_path)?;
        let content = fs::read_to_string(&canonical).map_err(|_| {
            FilesystemError::FileNotFound(file_path.to_string())
        })?;

        tracing::info!("read_file_content: read {} bytes", content.len());
        Ok(FileContentResponse {
            content,
            path: file_path.to_string(),
        })
    }

    /// Writes content to a .md file within the base path.
    pub async fn write_file_content(
        &self,
        base_path: &str,
        file_path: &str,
        content: &str,
    ) -> Result<(), FilesystemError> {
        tracing::info!(
            "write_file_content: base={}, file={}",
            base_path,
            file_path
        );
        let base = PathBuf::from(base_path);
        let full_path = base.join(file_path);

        if !file_path.ends_with(".md") {
            return Err(FilesystemError::NotMarkdownFile);
        }

        let canonical = Self::validate_path_within_base(&base, &full_path)?;
        fs::write(&canonical, content)?;

        tracing::info!("write_file_content: wrote {} bytes", content.len());
        Ok(())
    }

    /// Creates a new empty .md file at the given relative path.
    pub async fn create_file(
        &self,
        base_path: &str,
        relative_path: &str,
    ) -> Result<(), FilesystemError> {
        tracing::info!(
            "create_file: base={}, relative={}",
            base_path,
            relative_path
        );
        if !relative_path.ends_with(".md") {
            return Err(FilesystemError::NotMarkdownFile);
        }

        let base = PathBuf::from(base_path);
        let full_path = base.join(relative_path);

        // Validate the new path is within the base directory
        let canonical = Self::validate_new_path_within_base(&base, &full_path)?;

        if canonical.exists() {
            return Err(FilesystemError::InvalidName(format!(
                "File already exists: {}",
                relative_path
            )));
        }

        fs::write(&canonical, "")?;
        tracing::info!("create_file: created {}", canonical.display());
        Ok(())
    }

    /// Creates a new directory at the given relative path.
    pub async fn create_directory(
        &self,
        base_path: &str,
        relative_path: &str,
    ) -> Result<(), FilesystemError> {
        tracing::info!(
            "create_directory: base={}, relative={}",
            base_path,
            relative_path
        );
        let base = PathBuf::from(base_path);
        let full_path = base.join(relative_path);

        let canonical = Self::validate_new_path_within_base(&base, &full_path)?;

        if canonical.exists() {
            return Err(FilesystemError::InvalidName(format!(
                "Entry already exists: {}",
                relative_path
            )));
        }

        fs::create_dir(&canonical)?;
        tracing::info!("create_directory: created {}", canonical.display());
        Ok(())
    }

    /// Renames a file or directory. For files, the new name must end with .md.
    /// Returns the new relative path.
    pub async fn rename_entry(
        &self,
        base_path: &str,
        old_relative_path: &str,
        new_name: &str,
    ) -> Result<RenameEntryResponse, FilesystemError> {
        tracing::info!(
            "rename_entry: base={}, old={}, new_name={}",
            base_path,
            old_relative_path,
            new_name
        );

        // Validate new_name has no path separators
        if new_name.contains('/') || new_name.contains('\\') || new_name.contains("..") {
            return Err(FilesystemError::InvalidName(
                "Name cannot contain path separators or '..'".to_string(),
            ));
        }

        let base = PathBuf::from(base_path);
        let old_full = base.join(old_relative_path);
        let canonical_old = Self::validate_path_within_base(&base, &old_full)?;

        let is_file = canonical_old.is_file();
        if is_file && !new_name.ends_with(".md") {
            return Err(FilesystemError::NotMarkdownFile);
        }

        let new_full = canonical_old
            .parent()
            .ok_or_else(|| FilesystemError::InvalidName("No parent directory".to_string()))?
            .join(new_name);

        if new_full.exists() {
            return Err(FilesystemError::InvalidName(format!(
                "Entry already exists: {}",
                new_name
            )));
        }

        fs::rename(&canonical_old, &new_full)?;

        // Compute the new relative path
        let canonical_base = base.canonicalize().map_err(|_| FilesystemError::DirectoryDoesNotExist)?;
        let new_relative = new_full
            .strip_prefix(&canonical_base)
            .unwrap_or(&new_full)
            .to_string_lossy()
            .to_string();

        tracing::info!("rename_entry: renamed to {}", new_relative);
        Ok(RenameEntryResponse {
            new_path: new_relative,
        })
    }

    /// Deletes a file or empty directory within the base path.
    pub async fn delete_entry(
        &self,
        base_path: &str,
        relative_path: &str,
    ) -> Result<(), FilesystemError> {
        tracing::info!(
            "delete_entry: base={}, relative={}",
            base_path,
            relative_path
        );
        let base = PathBuf::from(base_path);
        let full_path = base.join(relative_path);
        let canonical = Self::validate_path_within_base(&base, &full_path)?;

        if canonical.is_dir() {
            // Only allow deleting empty directories
            let has_entries = fs::read_dir(&canonical)
                .map(|mut entries| entries.next().is_some())
                .unwrap_or(false);
            if has_entries {
                return Err(FilesystemError::DirectoryNotEmpty);
            }
            fs::remove_dir(&canonical)?;
        } else {
            fs::remove_file(&canonical)?;
        }

        tracing::info!("delete_entry: deleted {}", canonical.display());
        Ok(())
    }
}

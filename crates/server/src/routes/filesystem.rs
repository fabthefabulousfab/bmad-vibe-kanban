use axum::{
    Router,
    extract::{Query, State},
    response::Json as ResponseJson,
    routing::{delete, get, post},
};
use deployment::Deployment;
use serde::Deserialize;
use services::services::filesystem::{
    CreateEntryRequest, DeleteEntryRequest, DirectoryEntry, DirectoryListResponse,
    FileContentResponse, FileTreeEntry, FilesystemError, RenameEntryRequest,
    RenameEntryResponse,
};
use utils::response::ApiResponse;

use crate::{DeploymentImpl, error::ApiError};

#[derive(Debug, Deserialize)]
pub struct ListDirectoryQuery {
    path: Option<String>,
}

pub async fn list_directory(
    State(deployment): State<DeploymentImpl>,
    Query(query): Query<ListDirectoryQuery>,
) -> Result<ResponseJson<ApiResponse<DirectoryListResponse>>, ApiError> {
    match deployment.filesystem().list_directory(query.path).await {
        Ok(response) => Ok(ResponseJson(ApiResponse::success(response))),
        Err(err) => Ok(ResponseJson(ApiResponse::error(&map_filesystem_error(err)))),
    }
}

pub async fn list_git_repos(
    State(deployment): State<DeploymentImpl>,
    Query(query): Query<ListDirectoryQuery>,
) -> Result<ResponseJson<ApiResponse<Vec<DirectoryEntry>>>, ApiError> {
    let res = if let Some(ref path) = query.path {
        deployment
            .filesystem()
            .list_git_repos(Some(path.clone()), 800, 1200, Some(3))
            .await
    } else {
        deployment
            .filesystem()
            .list_common_git_repos(800, 1200, Some(4))
            .await
    };
    match res {
        Ok(response) => Ok(ResponseJson(ApiResponse::success(response))),
        Err(err) => Ok(ResponseJson(ApiResponse::error(&map_filesystem_error(err)))),
    }
}

/// Helper to map FilesystemError to ApiResponse error string
fn map_filesystem_error(err: FilesystemError) -> String {
    match err {
        FilesystemError::DirectoryDoesNotExist => "Directory does not exist".to_string(),
        FilesystemError::PathIsNotDirectory => "Path is not a directory".to_string(),
        FilesystemError::FileNotFound(p) => format!("File not found: {}", p),
        FilesystemError::PathTraversal => "Invalid path: access denied".to_string(),
        FilesystemError::NotMarkdownFile => "Only .md files are supported".to_string(),
        FilesystemError::InvalidName(msg) => format!("Invalid name: {}", msg),
        FilesystemError::DirectoryNotEmpty => "Directory is not empty".to_string(),
        FilesystemError::ContentTooLarge(max) => {
            format!("Content exceeds maximum allowed size of {} bytes", max)
        }
        FilesystemError::Io(e) => {
            tracing::error!("Filesystem IO error: {}", e);
            format!("IO error: {}", e)
        }
    }
}

#[derive(Debug, Deserialize)]
pub struct MarkdownTreeQuery {
    path: String,
}

/// GET /api/filesystem/markdown-tree?path=<workspace_path>
pub async fn list_markdown_tree(
    State(deployment): State<DeploymentImpl>,
    Query(query): Query<MarkdownTreeQuery>,
) -> Result<ResponseJson<ApiResponse<Vec<FileTreeEntry>>>, ApiError> {
    match deployment
        .filesystem()
        .list_markdown_files(&query.path)
        .await
    {
        Ok(tree) => Ok(ResponseJson(ApiResponse::success(tree))),
        Err(err) => Ok(ResponseJson(ApiResponse::error(&map_filesystem_error(err)))),
    }
}

#[derive(Debug, Deserialize)]
pub struct FileContentQuery {
    base_path: String,
    file_path: String,
}

/// GET /api/filesystem/file-content?base_path=<base>&file_path=<relative>
pub async fn get_file_content(
    State(deployment): State<DeploymentImpl>,
    Query(query): Query<FileContentQuery>,
) -> Result<ResponseJson<ApiResponse<FileContentResponse>>, ApiError> {
    match deployment
        .filesystem()
        .read_file_content(&query.base_path, &query.file_path)
        .await
    {
        Ok(response) => Ok(ResponseJson(ApiResponse::success(response))),
        Err(err) => Ok(ResponseJson(ApiResponse::error(&map_filesystem_error(err)))),
    }
}

#[derive(Debug, Deserialize)]
pub struct SaveFileContentBody {
    pub base_path: String,
    pub file_path: String,
    pub content: String,
}

/// PUT /api/filesystem/file-content
pub async fn save_file_content(
    State(deployment): State<DeploymentImpl>,
    ResponseJson(body): ResponseJson<SaveFileContentBody>,
) -> Result<ResponseJson<ApiResponse<()>>, ApiError> {
    match deployment
        .filesystem()
        .write_file_content(&body.base_path, &body.file_path, &body.content)
        .await
    {
        Ok(()) => Ok(ResponseJson(ApiResponse::success(()))),
        Err(err) => Ok(ResponseJson(ApiResponse::error(&map_filesystem_error(err)))),
    }
}

/// POST /api/filesystem/create-file
pub async fn create_file(
    State(deployment): State<DeploymentImpl>,
    ResponseJson(body): ResponseJson<CreateEntryRequest>,
) -> Result<ResponseJson<ApiResponse<()>>, ApiError> {
    match deployment
        .filesystem()
        .create_file(&body.base_path, &body.relative_path)
        .await
    {
        Ok(()) => Ok(ResponseJson(ApiResponse::success(()))),
        Err(err) => Ok(ResponseJson(ApiResponse::error(&map_filesystem_error(err)))),
    }
}

/// POST /api/filesystem/create-directory
pub async fn create_directory(
    State(deployment): State<DeploymentImpl>,
    ResponseJson(body): ResponseJson<CreateEntryRequest>,
) -> Result<ResponseJson<ApiResponse<()>>, ApiError> {
    match deployment
        .filesystem()
        .create_directory(&body.base_path, &body.relative_path)
        .await
    {
        Ok(()) => Ok(ResponseJson(ApiResponse::success(()))),
        Err(err) => Ok(ResponseJson(ApiResponse::error(&map_filesystem_error(err)))),
    }
}

/// POST /api/filesystem/rename
pub async fn rename_entry(
    State(deployment): State<DeploymentImpl>,
    ResponseJson(body): ResponseJson<RenameEntryRequest>,
) -> Result<ResponseJson<ApiResponse<RenameEntryResponse>>, ApiError> {
    match deployment
        .filesystem()
        .rename_entry(&body.base_path, &body.old_path, &body.new_name)
        .await
    {
        Ok(response) => Ok(ResponseJson(ApiResponse::success(response))),
        Err(err) => Ok(ResponseJson(ApiResponse::error(&map_filesystem_error(err)))),
    }
}

/// DELETE /api/filesystem/entry
pub async fn delete_entry(
    State(deployment): State<DeploymentImpl>,
    ResponseJson(body): ResponseJson<DeleteEntryRequest>,
) -> Result<ResponseJson<ApiResponse<()>>, ApiError> {
    match deployment
        .filesystem()
        .delete_entry(&body.base_path, &body.relative_path)
        .await
    {
        Ok(()) => Ok(ResponseJson(ApiResponse::success(()))),
        Err(err) => Ok(ResponseJson(ApiResponse::error(&map_filesystem_error(err)))),
    }
}

pub fn router() -> Router<DeploymentImpl> {
    Router::new()
        .route("/filesystem/directory", get(list_directory))
        .route("/filesystem/git-repos", get(list_git_repos))
        .route("/filesystem/markdown-tree", get(list_markdown_tree))
        .route("/filesystem/file-content", get(get_file_content).put(save_file_content))
        .route("/filesystem/create-file", post(create_file))
        .route("/filesystem/create-directory", post(create_directory))
        .route("/filesystem/rename", post(rename_entry))
        .route("/filesystem/entry", delete(delete_entry))
}

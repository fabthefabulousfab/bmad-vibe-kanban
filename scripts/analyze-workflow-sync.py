#!/usr/bin/env python3
"""
BMAD Workflow ↔ Story Semantic Sync Analyzer

This script uses LiteLLM to perform semantic analysis of BMAD workflows
vs existing stories, generating an actionable synchronization report.

Usage:
    python3 scripts/analyze-workflow-sync.py [OPTIONS]

Examples:
    # Dry run first to preview without LLM costs
    python3 scripts/analyze-workflow-sync.py --dry-run

    # Full analysis with verbose logging
    python3 scripts/analyze-workflow-sync.py --verbose

    # Analyze single scenario
    python3 scripts/analyze-workflow-sync.py --scenario workflow-complet

Options:
    --dry-run       Use cached data or mock data, no LLM API calls
    --verbose       Enable DEBUG logging (prompts, tokens, file ops)
    --scenario      Analyze single scenario: workflow-complet, quick-flow, document-project
    --help          Show this help message

Cost Warning:
    Full analysis costs ~$0.54 per run. Use --dry-run first to validate.
"""

import os
import sys
import logging
import argparse
import hashlib
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional
import time

try:
    import frontmatter
    from dotenv import load_dotenv
    import yaml
    from litellm import completion
except ImportError as e:
    print(f"ERROR: Missing required dependency: {e}")
    print("Install with: pip install -r scripts/requirements.txt")
    sys.exit(1)


# ============================================================================
# CONFIGURATION & LOGGING
# ============================================================================

def setup_logging(verbose: bool = False) -> logging.Logger:
    """Setup logging with appropriate level based on verbosity."""
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format='%(asctime)s [%(levelname)s] %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    return logging.getLogger(__name__)


def load_llm_config(logger: logging.Logger) -> Dict[str, str]:
    """
    Load and validate LiteLLM configuration from .env file.

    Security checks:
    - Verifies .env exists
    - Validates .env is in .gitignore
    - Checks required environment variables
    - Masks credentials in logs

    Returns:
        Dict with BASE_URL, BASE_KEY, BASE_MODEL

    Raises:
        SystemExit if configuration invalid or insecure
    """
    logger.info("Loading LLM configuration from .env")

    # Load .env file
    env_path = Path(".env")
    if not env_path.exists():
        logger.error(".env file not found in project root")
        logger.error("Create .env with: BASE_URL, BASE_KEY, BASE_MODEL")
        sys.exit(1)

    load_dotenv()

    # Verify .env is in .gitignore
    gitignore_path = Path(".gitignore")
    if gitignore_path.exists():
        gitignore_content = gitignore_path.read_text()
        if ".env" not in gitignore_content:
            logger.error("SECURITY: .env file is NOT in .gitignore!")
            logger.error("Add '.env' to .gitignore to prevent credential leaks")
            sys.exit(1)
    else:
        logger.warning(".gitignore not found - cannot verify .env exclusion")

    # Check file permissions (warn if world-readable)
    if os.name != 'nt':  # Unix-like systems
        env_stat = env_path.stat()
        if env_stat.st_mode & 0o004:  # World readable
            logger.warning(f".env file is world-readable (permissions: {oct(env_stat.st_mode)[-3:]})")
            logger.warning("Consider: chmod 600 .env")

    # Load required configuration
    config = {
        'BASE_URL': os.getenv('BASE_URL'),
        'BASE_KEY': os.getenv('BASE_KEY'),
        'BASE_MODEL': os.getenv('BASE_MODEL')
    }

    # Validate all required fields present
    missing = [k for k, v in config.items() if not v]
    if missing:
        logger.error(f"Missing required environment variables: {', '.join(missing)}")
        sys.exit(1)

    # Log masked credentials
    key = config['BASE_KEY']
    masked_key = f"{key[:4]}...{key[-4:]}" if len(key) > 8 else "****"
    logger.info(f"LLM Config loaded: {config['BASE_MODEL']} at {config['BASE_URL']}")
    logger.debug(f"API Key (masked): {masked_key}")

    return config


# ============================================================================
# FILE SCANNING & CHECKSUM
# ============================================================================

def compute_checksum(file_path: Path) -> str:
    """Compute SHA256 checksum of file content."""
    return hashlib.sha256(file_path.read_bytes()).hexdigest()[:16]


def validate_path_safety(path: Path, project_root: Path) -> bool:
    """
    Validate path is within project root (prevent directory traversal).

    Returns True if safe, False otherwise.
    """
    try:
        path.resolve().relative_to(project_root.resolve())
        return True
    except ValueError:
        return False


def scan_workflows(base_path: Path, logger: logging.Logger) -> Dict[str, Any]:
    """
    Recursively scan BMAD workflows and extract metadata with checksums.

    Returns dict structure:
    {
        'category': {
            'workflow_name': {
                'type': 'md' | 'yaml',
                'content': {...parsed frontmatter...},
                'checksum': 'sha256...',
                'path': 'relative/path'
            }
        }
    }
    """
    logger.info(f"Scanning workflows in {base_path}")

    project_root = Path.cwd()
    workflows = {}

    # Find all workflow.md and workflow.yaml files
    workflow_files = list(base_path.glob("**/workflow.md")) + list(base_path.glob("**/workflow.yaml"))

    logger.debug(f"Found {len(workflow_files)} workflow files")

    for wf_path in workflow_files:
        # Security: validate path
        if not validate_path_safety(wf_path, project_root):
            logger.warning(f"Skipping unsafe path: {wf_path}")
            continue

        try:
            # Determine category from path
            relative_path = wf_path.relative_to(base_path)
            parts = relative_path.parts
            category = parts[0] if len(parts) > 1 else "root"

            # Parse file based on type
            if wf_path.suffix == ".md":
                with open(wf_path, 'r', encoding='utf-8') as f:
                    fm = frontmatter.load(f)
                    content = {
                        'name': fm.get('name', ''),
                        'description': fm.get('description', ''),
                        'frontmatter': fm.metadata,
                        'body': fm.content[:2000]  # Increased to 2000 chars for step-based workflows
                    }
                    wf_type = 'md'
            else:  # .yaml
                with open(wf_path, 'r', encoding='utf-8') as f:
                    data = yaml.safe_load(f)
                    content = {
                        'name': data.get('name', ''),
                        'description': data.get('description', ''),
                        'config': data
                    }
                    wf_type = 'yaml'

            # Compute checksum
            checksum = compute_checksum(wf_path)

            # Store in structure
            if category not in workflows:
                workflows[category] = {}

            workflow_name = wf_path.parent.name if wf_path.name in ['workflow.md', 'workflow.yaml'] else wf_path.stem

            workflows[category][workflow_name] = {
                'type': wf_type,
                'content': content,
                'checksum': checksum,
                'path': str(relative_path)
            }

            logger.debug(f"Scanned {category}/{workflow_name}: {checksum}")

        except Exception as e:
            logger.warning(f"Failed to parse {wf_path}: {e}")
            continue

    logger.info(f"Scanned {len(workflows)} workflow categories")
    return workflows


def scan_stories(scenario_path: Path, logger: logging.Logger) -> List[Dict[str, Any]]:
    """
    Scan story files in a scenario directory and extract metadata.

    Returns list of story objects with:
    - file_path, wave, epic, story, slug
    - frontmatter metadata
    - content preview
    """
    logger.info(f"Scanning stories in {scenario_path}")

    if not scenario_path.exists():
        logger.warning(f"Scenario path does not exist: {scenario_path}")
        return []

    stories = []
    story_files = list(scenario_path.glob("*.md"))

    logger.debug(f"Found {len(story_files)} story files")

    for story_path in story_files:
        try:
            with open(story_path, 'r', encoding='utf-8') as f:
                fm = frontmatter.load(f)

                # Parse Wave-Epic-Story from filename (e.g., 1-1-0-quick-spec.md)
                filename = story_path.stem
                parts = filename.split('-')

                story_obj = {
                    'file_path': str(story_path),
                    'filename': story_path.name,
                    'wave': parts[0] if len(parts) > 0 else '',
                    'epic': parts[1] if len(parts) > 1 else '',
                    'story': parts[2] if len(parts) > 2 else '',
                    'slug': '-'.join(parts[3:]) if len(parts) > 3 else '',
                    'frontmatter': fm.metadata,
                    'content_preview': fm.content[:1000]  # Increased to 1000 chars for ACs and workflow refs
                }

                stories.append(story_obj)
                logger.debug(f"Scanned story: {story_path.name}")

        except Exception as e:
            logger.warning(f"Failed to parse {story_path}: {e}")
            continue

    logger.info(f"Scanned {len(stories)} stories")
    return stories


# ============================================================================
# CACHE MANAGEMENT
# ============================================================================

def get_cache_key(workflows_checksums: Dict, scenario_name: str, stories_data: List = None) -> str:
    """Generate cache key from workflow and story checksums and scenario."""
    # Flatten all workflow checksums
    all_checksums = []
    for category, wfs in workflows_checksums.items():
        for wf_name, wf_data in wfs.items():
            all_checksums.append(wf_data['checksum'])

    # Add story file checksums if provided
    if stories_data:
        for story in stories_data:
            # Compute checksum of story file
            story_checksum = hashlib.sha256(str(story).encode()).hexdigest()[:16]
            all_checksums.append(story_checksum)

    # Sort for consistency
    all_checksums.sort()
    combined = f"{scenario_name}:{''.join(all_checksums)}"

    return hashlib.sha256(combined.encode()).hexdigest()[:16]


def load_from_cache(cache_path: Path, cache_key: str, logger: logging.Logger) -> Optional[Dict]:
    """Load cached analysis result if exists and valid."""
    cache_file = cache_path / f"{cache_key}.json"

    if cache_file.exists():
        logger.info(f"Cache HIT: {cache_key}")
        try:
            with open(cache_file, 'r') as f:
                data = json.load(f)

            # Validate cache has required schema
            required_keys = ['stories_to_delete', 'stories_to_modify', 'stories_to_add']
            if all(key in data for key in required_keys):
                return data
            else:
                logger.warning(f"Cache invalid schema, ignoring: {cache_key}")
                return None
        except (json.JSONDecodeError, IOError) as e:
            logger.warning(f"Cache read error, ignoring: {e}")
            return None

    logger.info(f"Cache MISS: {cache_key}")
    return None


def save_to_cache(cache_path: Path, cache_key: str, data: Dict, logger: logging.Logger):
    """Save analysis result to cache."""
    cache_path.mkdir(parents=True, exist_ok=True)
    cache_file = cache_path / f"{cache_key}.json"

    with open(cache_file, 'w') as f:
        json.dump(data, f, indent=2)

    logger.debug(f"Saved to cache: {cache_key}")


# ============================================================================
# LLM ANALYSIS
# ============================================================================

def validate_llm_response(response: Dict, workflows_data: Dict, stories_data: List, logger: logging.Logger) -> bool:
    """
    Validate LLM response to ensure all referenced files exist.

    Checks:
    - stories_to_delete reference existing stories
    - stories_to_modify reference existing stories
    - stories_to_add follow naming convention
    - No duplicate filenames

    Returns True if valid, False otherwise.
    """
    logger.debug("Validating LLM response")

    # Validate top-level keys exist
    required_keys = ['stories_to_delete', 'stories_to_modify', 'stories_to_add']
    for key in required_keys:
        if key not in response:
            logger.error(f"Validation failed: missing required key '{key}' in LLM response")
            return False

    # Extract story filenames
    existing_story_files = {s['filename'] for s in stories_data}

    # Validate stories_to_delete
    for item in response.get('stories_to_delete', []):
        file_path = item.get('file_path', '')
        filename = Path(file_path).name
        if filename not in existing_story_files:
            logger.error(f"Validation failed: stories_to_delete references non-existent file: {filename}")
            return False

    # Validate stories_to_modify
    for item in response.get('stories_to_modify', []):
        file_path = item.get('file_path', '')
        filename = Path(file_path).name
        if filename not in existing_story_files:
            logger.error(f"Validation failed: stories_to_modify references non-existent file: {filename}")
            return False

    # Validate stories_to_add naming convention
    proposed_files = []
    for item in response.get('stories_to_add', []):
        filename = item.get('filename', '')
        if not filename:
            logger.error("Validation failed: stories_to_add missing filename")
            return False

        # Check naming convention: {wave}-{epic}-{story}-{slug}.md
        if not filename.endswith('.md'):
            logger.error(f"Validation failed: filename doesn't end with .md: {filename}")
            return False

        parts = filename[:-3].split('-')
        if len(parts) < 4:
            logger.error(f"Validation failed: filename doesn't follow {'{wave}-{epic}-{story}-{slug}'}.md: {filename}")
            return False

        # Check for duplicates
        if filename in proposed_files:
            logger.error(f"Validation failed: duplicate filename proposed: {filename}")
            return False

        proposed_files.append(filename)

    # Warn about suspicious patterns
    if len(response.get('stories_to_delete', [])) > len(existing_story_files) * 0.5:
        logger.warning(f"Suspicious: proposing to delete {len(response['stories_to_delete'])} of {len(existing_story_files)} stories (>50%)")

    if not response.get('stories_to_modify') and not response.get('stories_to_add') and not response.get('stories_to_delete'):
        logger.warning("No changes detected in LLM response")

    logger.debug("LLM response validation passed")
    return True


def analyze_scenario(
    workflows_data: Dict,
    stories_data: List,
    scenario_name: str,
    llm_config: Dict,
    logger: logging.Logger
) -> Dict:
    """
    Perform LLM-based semantic analysis of workflows vs stories.

    Returns structured dict with:
    - stories_to_delete: [{'file_path': str, 'reason': str}]
    - stories_to_modify: [{'file_path': str, 'changes': str, 'diff': str}]
    - stories_to_add: [{'filename': str, 'content': str}]
    """
    logger.info(f"Analyzing scenario: {scenario_name}")

    # Construct prompt
    prompt = f"""You are analyzing BMAD workflow synchronization for the "{scenario_name}" scenario.

WORKFLOWS DATA:
{json.dumps(workflows_data, indent=2)}

EXISTING STORIES:
{json.dumps([{
    'filename': s['filename'],
    'wave': s['wave'],
    'epic': s['epic'],
    'story': s['story'],
    'frontmatter': s['frontmatter'],
    'content_preview': s['content_preview']
} for s in stories_data], indent=2)}

CONTEXT - META-BMAD FRAMEWORK:
These stories are META-STORIES to generate BMAD itself in Vibe Kanban.
The goal: execute BMAD workflows to generate COMPLETE STORY FILES that will be re-imported into Vibe Kanban.

A COMPLETE STORY FILE contains the ENTIRE lifecycle in ONE file:
- ATDD (acceptance tests before dev)
- Dev (implementation)
- Code review
- Test review
- Trace/traceability
All these steps are EMBEDDED in the story file, not separate stories.

STORY TYPES TO VERIFY:
1. PREPARATION STORIES (Waves 0-3):
   - Wave 0-1: Project setup, analysis, research, product brief
   - Wave 2: Planning (PRD, UX design, architecture)
   - Wave 3: Solutioning (epics/stories generation, implementation readiness)
   These create the INPUTS needed to generate complete stories.

2. STORY GENERATION (Wave 4):
   - Workflows that CREATE complete story files (with embedded ATDD, dev, review, trace)
   - Sprint planning, create-story workflows generate stories
   - dev-story workflow EXECUTES stories in Vibe Kanban - NOT a meta-story itself
   - After import-vibe-kanban, stories are executed ONE BY ONE in Vibe Kanban using dev-story
   - TEA workflows (atdd, test-review, trace) should be INTEGRATED into story generation, NOT separate stories
   - Code-review workflow is INTEGRATED into dev-story execution, NOT a separate story
   - Sprint-status, retrospective, correct-course are ORCHESTRATION workflows, NOT separate stories per feature

3. DOCUMENTATION (Wave 2-3, NOT after dev):
   - Diagrams (excalidraw) belong in architecture phase (Wave 2-3)
   - NOT in Wave 6 - they're needed BEFORE development

4. INFRASTRUCTURE & TOOLING (Valid meta-stories):
   - renumber-waves: Manual reorganization task for wave structure
   - import-vibe-kanban: External tooling integration scripts
   - Templates (X-X-X-*): Template files for story generation
   These are NORMAL and should NOT be deleted - they're part of the meta-framework

TASK:
Compare workflows with existing stories. Identify synchronization needs.

CRITICAL RULES:
- DO NOT propose separate stories for workflows that are EMBEDDED or EXECUTED in Vibe Kanban:
  * dev-story - executes stories IN Vibe Kanban after import, NOT a meta-story
  * code-review - runs automatically after dev-story
  * test-review - embedded in story completion
  * trace - embedded in story lifecycle
  * atdd - embedded in create-story
  * sprint-status - orchestration tool, not a feature story
  * retrospective - orchestration, runs after epic completion
  * correct-course - orchestration, triggered by changes
- DO NOT propose diagram stories in Wave 6 (they belong in Wave 2-3)
- DO NOT delete infrastructure stories: renumber-waves, import-vibe-kanban, template files (X-X-X-*)
  (These are valid meta-framework components)
- TEA workflows should enhance existing story generation, not create new stories
- One story can cover multiple workflow steps
- Only reference files that exist in provided data
- Follow naming: {{wave}}-{{epic}}-{{story}}-{{slug}}.md

CROSS-SCENARIO AWARENESS:
- For delete/modify: Check if story exists in OTHER scenarios (workflow-complet, quick-flow, document-project)
  - If YES: list them in "affects_other_scenarios"
  - If NO: use empty array []
- For add: Specify ALL scenarios where this story should be added in "target_scenarios"
  - Example: qa-automate story → ["workflow-complet"] only
  - Example: project-context story → ["workflow-complet", "document-project"]

Return JSON with this exact structure:
{{
  "stories_to_delete": [
    {{
      "file_path": "stories/.../file.md",
      "reason": "specific reason",
      "affects_other_scenarios": ["scenario-name-1", "scenario-name-2"] or [] if only this scenario
    }}
  ],
  "stories_to_modify": [
    {{
      "file_path": "stories/.../file.md",
      "current_summary": "what it currently covers",
      "changes_needed": ["specific change 1", "specific change 2"],
      "diff": "diff content WITHOUT code fences - just the raw diff lines",
      "affects_other_scenarios": ["scenario-name-1"] or [] if only this scenario
    }}
  ],
  "stories_to_add": [
    {{
      "filename": "1-2-3-new-feature.md",
      "wave": "1",
      "epic": "2",
      "story": "3",
      "summary": "brief summary of what this story should cover",
      "target_scenarios": ["workflow-complet"] or ["workflow-complet", "quick-flow"] if applies to multiple
    }}
  ]
}}

CRITICAL:
- Return valid JSON only
- Do NOT include actual newlines in string values - keep all text on single lines
- Do NOT wrap diff content in markdown code fences (```diff...```) - the report generator will add them
- Diff should be raw text without any wrapping"""

    logger.debug(f"Prompt length: {len(prompt)} chars")
    logger.debug(f"Calling LLM: {llm_config['BASE_MODEL']}")
    logger.debug(f"Full prompt:\n{prompt}")

    # Call LLM with retry logic
    max_retries = 3
    retry_delay = 1  # seconds
    total_cost = 0.0  # Track accumulated cost across retries

    for attempt in range(max_retries):
        try:
            # For OpenAI-compatible proxies - force OpenAI compatibility mode
            # This prevents litellm from trying Vertex AI authentication
            # Note: response_format may not be supported by all proxies, so we handle text responses
            response = completion(
                model=llm_config['BASE_MODEL'],
                messages=[{"role": "user", "content": prompt}],
                api_base=llm_config['BASE_URL'],
                api_key=llm_config['BASE_KEY'],
                custom_llm_provider="openai"  # Force OpenAI-compatible mode, no Google auth
            )

            # Log token usage
            usage = response.usage
            input_tokens = usage.prompt_tokens
            output_tokens = usage.completion_tokens
            total_tokens = usage.total_tokens

            # Rough cost estimate for Claude Opus 4.5
            # $15/1M input, $75/1M output (as of Feb 2026, approximation)
            cost_estimate = (input_tokens * 15 / 1_000_000) + (output_tokens * 75 / 1_000_000)
            total_cost += cost_estimate

            logger.info(f"LLM usage: {input_tokens} input + {output_tokens} output = {total_tokens} tokens")
            logger.info(f"Estimated cost: ${cost_estimate:.4f}")

            # Parse response
            response_content = response.choices[0].message.content
            logger.debug(f"Raw LLM response content (first 500 chars):\n{response_content[:500]}")

            # Handle JSON wrapped in markdown code fences
            if response_content.strip().startswith('```'):
                # Remove markdown code fences
                lines = response_content.strip().split('\n')
                # Remove first line (```json or ```) and last line (```)
                response_content = '\n'.join(lines[1:-1])
                logger.debug("Removed markdown code fences from response")

            try:
                result = json.loads(response_content)
            except json.JSONDecodeError as e:
                logger.error(f"Failed to parse LLM response as JSON on first attempt: {e}")
                # Show the problematic area
                if hasattr(e, 'pos'):
                    start = max(0, e.pos - 200)
                    end = min(len(response_content), e.pos + 200)
                    logger.error(f"JSON error near position {e.pos}:\n...{response_content[start:end]}...")

                # Try to fix common JSON issues
                import re
                # First, escape newlines within string values
                # This is a common issue where LLM puts actual newlines in strings
                # We need to be careful to only escape newlines inside quoted strings

                # Remove trailing commas before } or ]
                cleaned = re.sub(r',(\s*[}\]])', r'\1', response_content)
                try:
                    result = json.loads(cleaned)
                    logger.warning("JSON parsed after fixing trailing commas")
                except json.JSONDecodeError as e2:
                    logger.error(f"Failed to parse even after cleaning: {e2}")
                    # Try one more aggressive fix: extract just the JSON object
                    json_match = re.search(r'\{.*\}', cleaned, re.DOTALL)
                    if json_match:
                        try:
                            result = json.loads(json_match.group(0))
                            logger.warning("JSON parsed after extracting object")
                        except:
                            logger.error(f"Response content (full): {response_content}")
                            raise e2
                    else:
                        logger.error(f"Response content (full): {response_content}")
                        raise e2

            logger.debug(f"Full LLM response:\n{json.dumps(result, indent=2)}")

            # Validate response
            if not validate_llm_response(result, workflows_data, stories_data, logger):
                raise ValueError("LLM response validation failed")

            return result

        except Exception as e:
            logger.error(f"LLM call failed (attempt {attempt + 1}/{max_retries}): {e}")
            if attempt < max_retries - 1:
                wait_time = retry_delay * (2 ** attempt)  # Exponential backoff
                logger.info(f"Retrying in {wait_time}s...")
                time.sleep(wait_time)
            else:
                logger.error(f"All retry attempts exhausted. Total cost incurred: ${total_cost:.4f}")
                raise


def detect_new_scenarios(
    all_workflows: Dict,
    existing_scenarios: List[str],
    llm_config: Dict,
    logger: logging.Logger
) -> List[Dict]:
    """
    Detect workflow categories without matching story scenarios.

    Returns list of proposed new scenarios.
    """
    logger.info("Detecting new scenarios")

    # Find uncovered categories
    covered_categories = set()
    for scenario in existing_scenarios:
        # Map scenario to workflow categories
        if 'workflow-complet' in scenario:
            covered_categories.update(['1-analysis', '2-plan-workflows', '3-solutioning', '4-implementation'])
            # TEA workflows are INTEGRATED into story generation, not separate scenarios
            covered_categories.add('testarch')
            # QA automation enriches workflow-complet
            covered_categories.add('qa')
        elif 'quick-flow' in scenario:
            covered_categories.add('bmad-quick-flow')
        elif 'document-project' in scenario:
            covered_categories.add('document-project')
            # These enrich document-project scenario
            covered_categories.add('generate-project-context')
            covered_categories.add('excalidraw-diagrams')

    uncovered = [cat for cat in all_workflows.keys() if cat not in covered_categories]

    if not uncovered:
        logger.info("No uncovered workflow categories found")
        return []

    logger.info(f"Uncovered categories: {uncovered}")

    # Use LLM to propose scenarios
    prompt = f"""You have uncovered BMAD workflow categories: {uncovered}

Workflows in these categories:
{json.dumps({cat: all_workflows[cat] for cat in uncovered}, indent=2)}

CONTEXT - META-BMAD:
These are META-STORIES to generate BMAD. Stories create COMPLETE story files with embedded lifecycle.

EXISTING SCENARIOS & THEIR COVERAGE:
1. workflow-complet: Full development cycle (analysis, planning, solutioning, implementation)
   - Already includes: TEA workflows, QA automation
2. quick-flow: Rapid atomic feature additions (spec + dev)
   - Already includes: quick-spec, quick-dev workflows
3. document-project: Brownfield project documentation
   - Already includes: project-context generation, diagrams (excalidraw)

IMPORTANT:
- DO NOT propose scenarios that would enrich existing ones
- ONLY propose truly DIFFERENT scenarios (new use cases, different workflows)
- If a workflow fits an existing scenario, it should be added to that scenario's stories, NOT a new scenario

Propose ONLY truly new scenarios (not enrichments of existing ones).

Return JSON:
{{
  "new_scenarios": [
    {{
      "scenario_name": "descriptive-name",
      "description": "what this scenario covers",
      "suggested_stories": [
        {{"filename": "1-1-0-story-name.md", "summary": "what it covers"}}
      ]
    }}
  ]
}}"""

    try:
        response = completion(
            model=llm_config['BASE_MODEL'],
            messages=[{"role": "user", "content": prompt}],
            api_base=llm_config['BASE_URL'],
            api_key=llm_config['BASE_KEY'],
            custom_llm_provider="openai"  # Force OpenAI-compatible mode, no Google auth
        )

        # Parse response with markdown fence handling
        response_content = response.choices[0].message.content
        logger.debug(f"New scenarios response (first 500 chars):\n{response_content[:500]}")

        # Handle JSON wrapped in markdown code fences
        if response_content.strip().startswith('```'):
            # Remove markdown code fences
            lines = response_content.strip().split('\n')
            # Remove first line (```json or ```) and last line (```)
            response_content = '\n'.join(lines[1:-1])
            logger.debug("Removed markdown code fences from new scenarios response")

        result = json.loads(response_content)
        return result.get('new_scenarios', [])

    except Exception as e:
        logger.error(f"Failed to detect new scenarios: {e}")
        return []


# ============================================================================
# REPORT GENERATION
# ============================================================================

def get_git_commit() -> str:
    """Get current git commit hash."""
    try:
        import subprocess
        result = subprocess.run(['git', 'rev-parse', 'HEAD'],
                              capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except Exception:
        return "NO_GIT"


def generate_report(
    analysis_results: Dict[str, Dict],
    new_scenarios: List[Dict],
    workflows_checksums: Dict,
    output_path: Path,
    logger: logging.Logger
):
    """
    Generate markdown synchronization report.

    Structure:
    - Frontmatter with metadata
    - Summary statistics
    - Per-scenario sections (delete/modify/add)
    - New scenarios section
    """
    logger.info(f"Generating report at {output_path}")

    # Ensure output directory exists
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Compute summary statistics
    total_deletes = sum(len(r.get('stories_to_delete', [])) for r in analysis_results.values())
    total_modifies = sum(len(r.get('stories_to_modify', [])) for r in analysis_results.values())
    total_adds = sum(len(r.get('stories_to_add', [])) for r in analysis_results.values())
    total_actions = total_deletes + total_modifies + total_adds

    # Get git commit
    commit_hash = get_git_commit()

    # Build report
    report_lines = []

    # Frontmatter
    report_lines.append("---")
    report_lines.append(f"title: BMAD Workflow ↔ Story Synchronization Report")
    report_lines.append(f"generated: {datetime.now().isoformat()}")
    report_lines.append(f"git_commit: {commit_hash}")
    report_lines.append(f"total_actions: {total_actions}")
    report_lines.append("---")
    report_lines.append("")

    # Summary
    report_lines.append("# BMAD Workflow ↔ Story Synchronization Report")
    report_lines.append("")
    report_lines.append(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    report_lines.append(f"**Git Commit:** `{commit_hash}`")
    report_lines.append("")
    report_lines.append("## Summary")
    report_lines.append("")
    report_lines.append(f"- **Total Actions:** {total_actions}")
    report_lines.append(f"  - Stories to Delete: {total_deletes}")
    report_lines.append(f"  - Stories to Modify: {total_modifies}")
    report_lines.append(f"  - Stories to Add: {total_adds}")
    report_lines.append(f"- **New Scenarios Proposed:** {len(new_scenarios)}")
    report_lines.append("")

    # Per-scenario sections
    for scenario_name, results in analysis_results.items():
        report_lines.append(f"## Scenario: {scenario_name}")
        report_lines.append("")

        # Stories to Delete
        if results.get('stories_to_delete'):
            report_lines.append("### Stories to Delete")
            report_lines.append("")
            for item in results['stories_to_delete']:
                report_lines.append(f"- **{item['file_path']}**")
                report_lines.append(f"  - Reason: {item['reason']}")
                # Show cross-scenario impact
                affects = item.get('affects_other_scenarios', [])
                if affects:
                    report_lines.append(f"  - ⚠️ **Also exists in:** {', '.join(affects)}")
                report_lines.append("")

        # Stories to Modify
        if results.get('stories_to_modify'):
            report_lines.append("### Stories to Modify")
            report_lines.append("")
            for item in results['stories_to_modify']:
                report_lines.append(f"#### {item['file_path']}")
                report_lines.append("")
                report_lines.append(f"**Current Summary:** {item.get('current_summary', 'N/A')}")
                report_lines.append("")
                # Show cross-scenario impact
                affects = item.get('affects_other_scenarios', [])
                if affects:
                    report_lines.append(f"⚠️ **Also exists in:** {', '.join(affects)}")
                    report_lines.append("")
                report_lines.append("**Changes Needed:**")
                for change in item.get('changes_needed', []):
                    report_lines.append(f"- {change}")
                report_lines.append("")
                if item.get('diff'):
                    report_lines.append("**Diff:**")
                    # Escape triple backticks in diff content to avoid nesting issues
                    diff_content = item['diff'].replace('```', '\\`\\`\\`')
                    report_lines.append("```diff")
                    report_lines.append(diff_content)
                    report_lines.append("```")
                    report_lines.append("")

        # Stories to Add
        if results.get('stories_to_add'):
            report_lines.append("### Stories to Add")
            report_lines.append("")
            for item in results['stories_to_add']:
                report_lines.append(f"#### New Story: {item['filename']}")
                report_lines.append("")
                report_lines.append(f"**Wave:** {item.get('wave', 'N/A')} | **Epic:** {item.get('epic', 'N/A')} | **Story:** {item.get('story', 'N/A')}")
                report_lines.append("")
                # Show target scenarios
                targets = item.get('target_scenarios', [scenario_name])
                if len(targets) == 1:
                    report_lines.append(f"**Target Scenario:** {targets[0]}")
                else:
                    report_lines.append(f"**Target Scenarios:** {', '.join(targets)}")
                report_lines.append("")
                report_lines.append(f"**Summary:** {item.get('summary', 'N/A')}")
                report_lines.append("")

    # New Scenarios
    if new_scenarios:
        report_lines.append("## Proposed New Scenarios")
        report_lines.append("")
        for scenario in new_scenarios:
            report_lines.append(f"### {scenario['scenario_name']}")
            report_lines.append("")
            report_lines.append(f"**Description:** {scenario.get('description', 'N/A')}")
            report_lines.append("")
            report_lines.append("**Suggested Stories:**")
            for story in scenario.get('suggested_stories', []):
                report_lines.append(f"- `{story['filename']}`: {story.get('summary', 'N/A')}")
            report_lines.append("")

    # Write report
    with open(output_path, 'w') as f:
        f.write('\n'.join(report_lines))

    logger.info(f"Report generated: {output_path}")


# ============================================================================
# MAIN ORCHESTRATION
# ============================================================================

def main():
    """Main orchestration flow."""
    parser = argparse.ArgumentParser(
        description='BMAD Workflow ↔ Story Semantic Sync Analyzer',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    parser.add_argument('--dry-run', action='store_true',
                       help='Use cached/mock data, no LLM API calls')
    parser.add_argument('--verbose', action='store_true',
                       help='Enable DEBUG logging')
    parser.add_argument('--scenario', type=str,
                       help='Analyze single scenario: workflow-complet, quick-flow, document-project')

    args = parser.parse_args()

    # Setup logging
    logger = setup_logging(args.verbose)

    logger.info("=" * 60)
    logger.info("BMAD Workflow ↔ Story Synchronization Analyzer")
    logger.info("=" * 60)

    if args.dry_run:
        logger.info("DRY RUN MODE: No LLM API calls will be made")

    # Load configuration
    llm_config = load_llm_config(logger)

    # Setup paths
    project_root = Path.cwd()
    bmm_workflows_path = project_root / "_bmad" / "bmm" / "workflows"
    tea_workflows_path = project_root / "_bmad" / "tea" / "workflows"
    stories_base = project_root / "stories"
    output_base = project_root / "_bmad-output" / "planning-artifacts"
    cache_base = project_root / "_bmad-output" / ".cache" / "workflow-sync"

    # Create cache directory
    cache_base.mkdir(parents=True, exist_ok=True)

    # TODO: Implement cache cleanup - remove files older than 30 days
    # Currently cache grows indefinitely - consider: find cache_base -type f -mtime +30 -delete

    # Scan workflows from both BMM and TEA
    logger.info("Scanning BMM workflows...")
    bmm_workflows = scan_workflows(bmm_workflows_path, logger)

    logger.info("Scanning TEA workflows...")
    tea_workflows = scan_workflows(tea_workflows_path, logger)

    # Merge workflows from both sources
    all_workflows = {**bmm_workflows, **tea_workflows}
    logger.info(f"Total workflow categories: {len(all_workflows)} (BMM: {len(bmm_workflows)}, TEA: {len(tea_workflows)})")

    # Define scenarios
    scenarios = {
        'workflow-complet': stories_base / 'workflow-complet',
        'quick-flow': stories_base / 'quick-flow',
        'document-project': stories_base / 'document-project'
    }

    # Filter to single scenario if specified
    if args.scenario:
        if args.scenario not in scenarios:
            logger.error(f"Unknown scenario: {args.scenario}")
            logger.error(f"Valid scenarios: {', '.join(scenarios.keys())}")
            sys.exit(1)
        scenarios = {args.scenario: scenarios[args.scenario]}

    # Analyze each scenario
    analysis_results = {}

    for scenario_name, scenario_path in scenarios.items():
        logger.info(f"\n{'='*60}")
        logger.info(f"Processing scenario: {scenario_name}")
        logger.info(f"{'='*60}")

        # Scan stories
        stories = scan_stories(scenario_path, logger)

        # Check cache (include story checksums for proper invalidation)
        cache_key = get_cache_key(all_workflows, scenario_name, stories)
        cached_result = load_from_cache(cache_base, cache_key, logger)

        if args.dry_run:
            if cached_result:
                logger.info("Using cached analysis result")
                analysis_results[scenario_name] = cached_result
            else:
                logger.warning("No cache found for dry-run, using mock data")
                analysis_results[scenario_name] = {
                    'stories_to_delete': [],
                    'stories_to_modify': [],
                    'stories_to_add': []
                }
        elif cached_result:
            logger.info("Using cached analysis result")
            analysis_results[scenario_name] = cached_result
        else:
            # Perform LLM analysis
            result = analyze_scenario(all_workflows, stories, scenario_name, llm_config, logger)
            analysis_results[scenario_name] = result

            # Save to cache
            save_to_cache(cache_base, cache_key, result, logger)

    # Detect new scenarios
    logger.info(f"\n{'='*60}")
    logger.info("Detecting new scenarios")
    logger.info(f"{'='*60}")

    if args.dry_run:
        logger.info("Skipping new scenario detection in dry-run mode")
        new_scenarios = []
    else:
        new_scenarios = detect_new_scenarios(
            all_workflows,
            list(scenarios.keys()),
            llm_config,
            logger
        )

    # Generate report
    timestamp = datetime.now().strftime('%Y-%m-%d-%H%M')
    report_filename = f"workflow-sync-report-{timestamp}.md"
    if args.dry_run:
        report_filename = f"[DRY-RUN]-{report_filename}"

    report_path = output_base / report_filename

    generate_report(analysis_results, new_scenarios, all_workflows, report_path, logger)

    # Final summary
    logger.info(f"\n{'='*60}")
    logger.info("ANALYSIS COMPLETE")
    logger.info(f"{'='*60}")
    logger.info(f"Report saved to: {report_path}")
    logger.info("Review the report and implement the suggested changes.")


if __name__ == "__main__":
    main()

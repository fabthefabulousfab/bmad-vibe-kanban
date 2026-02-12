#!/bin/bash
# Script to patch the "Open in Old UI" button behavior
# This script modifies the OpenInOldUI action to:
# 1. Use window.location.href instead of ctx.navigate() for cross-design navigation
# 2. Navigate to the project tasks page instead of a specific attempt
#
# Usage: ./scripts/patch-open-in-old-ui.sh

set -e

ACTIONS_FILE="frontend/src/components/ui-new/actions/index.ts"

# Check if the file exists
if [ ! -f "$ACTIONS_FILE" ]; then
    echo "Error: $ACTIONS_FILE not found"
    echo "Make sure you're running this script from the project root directory"
    exit 1
fi

# Check if the patch has already been applied
if grep -q "window.location.href = \`/local-projects/\${task.project_id}/tasks\`" "$ACTIONS_FILE"; then
    echo "Patch already applied. The OpenInOldUI action is already configured correctly."
    exit 0
fi

# Check if the OpenInOldUI action exists
if ! grep -q "OpenInOldUI:" "$ACTIONS_FILE"; then
    echo "Error: OpenInOldUI action not found in $ACTIONS_FILE"
    echo "The action may have been removed or renamed"
    exit 1
fi

echo "Patching OpenInOldUI action in $ACTIONS_FILE..."

# Create backup
cp "$ACTIONS_FILE" "${ACTIONS_FILE}.backup"

# Apply the patch using sed
# This replaces the execute function content for OpenInOldUI

# macOS sed requires different syntax than GNU sed
if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_INPLACE="sed -i ''"
else
    SED_INPLACE="sed -i"
fi

# Use a more robust approach with a temporary file
cat > /tmp/patch-open-in-old-ui.py << 'PYTHON_SCRIPT'
import re
import sys

filename = sys.argv[1]

with open(filename, 'r') as f:
    content = f.read()

# Pattern to match the OpenInOldUI execute function
old_pattern = r'''(OpenInOldUI:\s*\{[^}]*execute:\s*async\s*\(ctx\)\s*=>\s*\{)[^}]*(\n\s*// If no workspace is selected)[^}]*?ctx\.navigate\('/'\);[^}]*?ctx\.navigate\('/'\);[^}]*?ctx\.navigate\([^)]*\);[^}]*?ctx\.navigate\('/'\);[^}]*?\}'''

new_execute = r'''\1
      // If no workspace is selected, navigate to root (legacy design)
      if (!ctx.currentWorkspaceId) {
        // Use window.location for cross-design navigation (new design -> legacy design)
        window.location.href = '/';
        return;
      }

      const workspace = await getWorkspace(
        ctx.queryClient,
        ctx.currentWorkspaceId
      );
      if (!workspace?.task_id) {
        window.location.href = '/';
        return;
      }

      // Fetch task to get project_id
      const task = await tasksApi.getById(workspace.task_id);
      if (task?.project_id) {
        // Navigate to the project tasks page (shows all stories)
        // Use window.location for cross-design navigation (new design -> legacy design)
        window.location.href = `/local-projects/${task.project_id}/tasks`;
      } else {
        window.location.href = '/';
      }
    }'''

# Simpler approach: find and replace specific lines
# Replace ctx.navigate with window.location.href in OpenInOldUI section

# Find the OpenInOldUI section
start_marker = "OpenInOldUI: {"
end_marker = "// === Diff Actions"  # Next section

start_idx = content.find(start_marker)
if start_idx == -1:
    print("OpenInOldUI action not found")
    sys.exit(1)

end_idx = content.find(end_marker, start_idx)
if end_idx == -1:
    end_idx = len(content)

section = content[start_idx:end_idx]

# Replace ctx.navigate with window.location.href
new_section = section.replace("ctx.navigate('/')", "window.location.href = '/'")

# Replace the attempts URL with tasks URL
new_section = re.sub(
    r"ctx\.navigate\(\s*`/local-projects/\$\{task\.project_id\}/tasks/\$\{workspace\.task_id\}/attempts/\$\{ctx\.currentWorkspaceId\}`\s*\)",
    "window.location.href = `/local-projects/${task.project_id}/tasks`",
    new_section
)

# Also handle single-line version
new_section = re.sub(
    r"ctx\.navigate\(\s*`/local-projects/\$\{task\.project_id\}/tasks/\$\{workspace\.task_id\}/attempts/\$\{ctx\.currentWorkspaceId\}`\s*\);",
    "window.location.href = `/local-projects/${task.project_id}/tasks`;",
    new_section
)

# Update comments
new_section = new_section.replace(
    "// If no workspace is selected, navigate to root",
    "// If no workspace is selected, navigate to root (legacy design)"
)
new_section = new_section.replace(
    "// Fetch task lazily to get project_id",
    "// Fetch task to get project_id"
)

# Add comment about cross-design navigation if not present
if "cross-design navigation" not in new_section:
    new_section = new_section.replace(
        "window.location.href = '/';\n        return;\n      }",
        "// Use window.location for cross-design navigation (new design -> legacy design)\n        window.location.href = '/';\n        return;\n      }",
        1  # Only first occurrence
    )

# Add comment about project tasks page if not present
if "Navigate to the project tasks page" not in new_section:
    new_section = new_section.replace(
        "window.location.href = `/local-projects/${task.project_id}/tasks`",
        "// Navigate to the project tasks page (shows all stories)\n        // Use window.location for cross-design navigation (new design -> legacy design)\n        window.location.href = `/local-projects/${task.project_id}/tasks`"
    )

new_content = content[:start_idx] + new_section + content[end_idx:]

with open(filename, 'w') as f:
    f.write(new_content)

print("Patch applied successfully")
PYTHON_SCRIPT

python3 /tmp/patch-open-in-old-ui.py "$ACTIONS_FILE"

# Verify the patch was applied
if grep -q "window.location.href = \`/local-projects/\${task.project_id}/tasks\`" "$ACTIONS_FILE"; then
    echo "Patch verified successfully!"
    echo "Backup saved to ${ACTIONS_FILE}.backup"
    rm /tmp/patch-open-in-old-ui.py
else
    echo "Warning: Patch may not have been applied correctly"
    echo "Please verify the changes manually"
    echo "Restoring backup..."
    mv "${ACTIONS_FILE}.backup" "$ACTIONS_FILE"
    exit 1
fi

echo ""
echo "Done! The 'Open in Old UI' button will now:"
echo "  - Navigate to /local-projects/{project_id}/tasks (shows all stories)"
echo "  - Use window.location.href for proper cross-design navigation"

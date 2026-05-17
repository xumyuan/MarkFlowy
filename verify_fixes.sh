#!/bin/bash

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Flutter Markdown Editor - Fix Verification Script             ║"
echo "║  AppFlowy Editor 6.2.0 WYSIWYG Editor Integration Verification ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0

# Test 1: EditorState renamed to AppEditorState
echo "TEST 1: EditorState → AppEditorState renaming"
echo "─────────────────────────────────────────────"

if grep -q "class AppEditorState {" lib/providers/editor_provider.dart; then
    echo -e "${GREEN}✓${NC} AppEditorState class found"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗${NC} AppEditorState class NOT found"
    ((FAIL_COUNT++))
fi

if ! grep -q "class EditorState {" lib/providers/editor_provider.dart; then
    echo -e "${GREEN}✓${NC} Old EditorState class successfully removed"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗${NC} Old EditorState class still present"
    ((FAIL_COUNT++))
fi

if grep -q "Notifier<AppEditorState>" lib/providers/editor_provider.dart; then
    echo -e "${GREEN}✓${NC} Notifier uses AppEditorState"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗${NC} Notifier does not use AppEditorState"
    ((FAIL_COUNT++))
fi

if grep -q "NotifierProvider<EditorNotifier, AppEditorState>" lib/providers/editor_provider.dart; then
    echo -e "${GREEN}✓${NC} NotifierProvider uses AppEditorState"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗${NC} NotifierProvider does not use AppEditorState"
    ((FAIL_COUNT++))
fi

echo ""
echo "TEST 2: editor_screen.dart updated"
echo "───────────────────────────────────"

if grep -q "Widget _buildEditorByMode(AppEditorState state" lib/screens/editor_screen.dart; then
    echo -e "${GREEN}✓${NC} _buildEditorByMode uses AppEditorState"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗${NC} _buildEditorByMode does not use AppEditorState"
    ((FAIL_COUNT++))
fi

if grep -A 2 "_buildStatusBar(" lib/screens/editor_screen.dart | grep -q "AppEditorState state"; then
    echo -e "${GREEN}✓${NC} _buildStatusBar uses AppEditorState"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗${NC} _buildStatusBar signature not properly updated"
    ((FAIL_COUNT++))
fi

echo ""
echo "TEST 3: wysiwyg_editor.dart enhancements"
echo "────────────────────────────────────────"

if grep -q "standardBlockComponentBuilderMap" lib/widgets/editor/wysiwyg_editor.dart; then
    echo -e "${GREEN}✓${NC} standardBlockComponentBuilderMap added"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗${NC} standardBlockComponentBuilderMap NOT found"
    ((FAIL_COUNT++))
fi

if grep -q "Directionality(" lib/widgets/editor/wysiwyg_editor.dart; then
    echo -e "${GREEN}✓${NC} Directionality widget added"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗${NC} Directionality widget NOT found"
    ((FAIL_COUNT++))
fi

if grep -q "textDirection: TextDirection.ltr" lib/widgets/editor/wysiwyg_editor.dart; then
    echo -e "${GREEN}✓${NC} Directionality configured with TextDirection.ltr"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗${NC} Directionality not properly configured"
    ((FAIL_COUNT++))
fi

echo ""
echo "TEST 4: No naming conflicts"
echo "──────────────────────────"

# Count how many times "class EditorState" appears (should be 0 in our files)
CONFLICT_COUNT=$(grep -r "class EditorState" lib/providers lib/screens lib/widgets/editor/wysiwyg_editor.dart 2>/dev/null | wc -l)

if [ "$CONFLICT_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No EditorState naming conflicts detected"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗${NC} EditorState naming conflicts detected ($CONFLICT_COUNT occurrences)"
    ((FAIL_COUNT++))
fi

echo ""
echo "═════════════════════════════════════════════════════════════════"
echo "RESULTS"
echo "═════════════════════════════════════════════════════════════════"
echo -e "${GREEN}PASSED: $PASS_COUNT${NC}"
echo -e "${RED}FAILED: $FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED!${NC}"
    echo ""
    echo "The fixes have been successfully applied. Next steps:"
    echo "  1. Run: flutter clean && flutter pub get"
    echo "  2. Run: flutter run"
    echo "  3. Test cursor visibility and editing capability in the editor"
    exit 0
else
    echo -e "${RED}✗ SOME TESTS FAILED${NC}"
    echo ""
    echo "Please review the failures above and reapply fixes if needed."
    exit 1
fi

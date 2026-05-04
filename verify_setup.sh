#!/bin/bash

# Zebra Scanner Plugin - Setup Verification Script

echo "🔍 Verifying Zebra Scanner Plugin Setup..."
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check counters
PASSED=0
FAILED=0

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $1 (MISSING)"
        ((FAILED++))
        return 1
    fi
}

# Function to check directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $1/ (MISSING)"
        ((FAILED++))
        return 1
    fi
}

echo "📦 Core Plugin Files:"
check_file "lib/zebra_scanner_plugin.dart"
check_file "lib/src/zebra_scanner.dart"
check_file "lib/src/models/scan_result.dart"
check_file "lib/src/models/scanner_status.dart"
echo ""

echo "🤖 Android Implementation:"
check_file "android/build.gradle.kts"
check_file "android/src/main/AndroidManifest.xml"
check_file "android/src/main/kotlin/com/zebra_scanner/ZebraScannerPlugin.kt"
check_file "android/app/src/main/kotlin/com/zebra_scanner/MainActivity.kt"
echo ""

echo "📱 Main Demo App:"
check_file "lib/main.dart"
check_file "lib/example_app.dart"
echo ""

echo "📂 Example Project:"
check_dir "example"
check_file "example/lib/main.dart"
check_file "example/android/app/src/main/kotlin/com/example/zebra_scanner_example/MainActivity.kt"
echo ""

echo "📚 Documentation:"
check_file "README.md"
check_file "GETTING_STARTED.md"
check_file "QUICK_REFERENCE.md"
check_file "TROUBLESHOOTING.md"
check_file "INDEX.md"
echo ""

echo "🧪 Tests:"
check_file "test/widget_test.dart"
check_file "example/test/widget_test.dart"
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ Setup verification passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Run main demo: flutter run"
    echo "  2. Run examples: cd example && flutter run"
    echo "  3. Read docs: cat README.md"
    exit 0
else
    echo -e "${RED}✗ Setup verification failed!${NC}"
    echo ""
    echo "Some files are missing. Please check:"
    echo "  1. Did you clone the complete repository?"
    echo "  2. Run: flutter pub get"
    echo "  3. Check TROUBLESHOOTING.md for help"
    exit 1
fi

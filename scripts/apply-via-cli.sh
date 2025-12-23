#!/bin/bash

PROJECT_REF="vzhrsabilcdrcgismpbc"
MIGRATION_FILE="supabase/migrations/20251223102959_canonical_schema.sql"

echo "=========================================="
echo "Applying Migration via Supabase CLI"
echo "=========================================="
echo "Project: $PROJECT_REF"
echo ""

# The Supabase CLI requires either:
# 1. Linked project (supabase link)
# 2. Database password for direct connection
# 3. Access token for Management API

echo "Attempting to apply migration..."
echo ""

# Try db push if linked
if [ -f "supabase/.temp/project-ref" ] || supabase status &>/dev/null; then
    echo "Project appears to be linked. Pushing migration..."
    supabase db push
else
    echo "Project not linked. To link:"
    echo "  supabase link --project-ref $PROJECT_REF"
    echo ""
    echo "Or apply manually via Dashboard:"
    echo "  https://app.supabase.com/project/$PROJECT_REF/sql/new"
fi

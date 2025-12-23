#!/bin/bash

# Apply Desktop Supabase Migration
# Project: vzhrsabilcdrcgismpbc.supabase.co

PROJECT_REF="vzhrsabilcdrcgismpbc"
MIGRATION_FILE="supabase/migrations/20251223102959_canonical_schema.sql"

echo "=========================================="
echo "Applying 560 Tables to Supabase"
echo "=========================================="
echo "Project: $PROJECT_REF.supabase.co"
echo "Migration: $MIGRATION_FILE"
echo ""

# Check if psql is available
if command -v psql &> /dev/null; then
    echo "psql found. To apply via command line:"
    echo ""
    echo "1. Get database password from:"
    echo "   https://app.supabase.com/project/$PROJECT_REF/settings/database"
    echo ""
    echo "2. Run:"
    echo "   psql 'postgresql://postgres:[PASSWORD]@db.$PROJECT_REF.supabase.co:5432/postgres' -f $MIGRATION_FILE"
    echo ""
fi

echo "=========================================="
echo "RECOMMENDED: Use Supabase Dashboard"
echo "=========================================="
echo ""
echo "1. Open: https://app.supabase.com/project/$PROJECT_REF"
echo "2. Go to: SQL Editor (left sidebar)"
echo "3. Click: New Query"
echo "4. Copy/paste the contents of: $MIGRATION_FILE"
echo "5. Click: Run (or Cmd/Ctrl + Enter)"
echo ""
echo "The migration will create 560 tables across 18 schemas."
echo "This may take a few minutes to complete."
echo ""
echo "=========================================="

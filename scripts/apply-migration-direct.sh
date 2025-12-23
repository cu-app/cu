#!/bin/bash

# Apply migration directly using Supabase CLI or psql
PROJECT_REF="vzhrsabilcdrcgismpbc"
MIGRATION_FILE="supabase/migrations/20251223102959_canonical_schema.sql"

echo "=========================================="
echo "Applying 560 Tables Migration"
echo "=========================================="
echo "Project: $PROJECT_REF.supabase.co"
echo ""

# Try Supabase CLI db push
if command -v supabase &> /dev/null; then
    echo "Attempting to use Supabase CLI..."
    supabase db push --db-url "postgresql://postgres:[PASSWORD]@db.$PROJECT_REF.supabase.co:5432/postgres" 2>&1 || {
        echo ""
        echo "Supabase CLI requires database password."
        echo ""
    }
fi

# If psql is available, try that
if command -v psql &> /dev/null; then
    if [ -n "$DATABASE_URL" ]; then
        echo "Using DATABASE_URL from environment..."
        psql "$DATABASE_URL" -f "$MIGRATION_FILE" && {
            echo ""
            echo "✅ Migration applied successfully!"
            exit 0
        }
    else
        echo ""
        echo "To use psql, set DATABASE_URL:"
        echo "  export DATABASE_URL='postgresql://postgres:[PASSWORD]@db.$PROJECT_REF.supabase.co:5432/postgres'"
        echo ""
    fi
fi

echo "=========================================="
echo "RECOMMENDED: Use Supabase Dashboard"
echo "=========================================="
echo ""
echo "1. Open: https://app.supabase.com/project/$PROJECT_REF/sql/new"
echo "2. Copy/paste contents of: $MIGRATION_FILE"
echo "3. Click Run"
echo ""

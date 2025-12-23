const fs = require('fs');
const https = require('https');

const SUPABASE_URL = 'https://vzhrsabilcdrcgismpbc.supabase.co';
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ6aHJzYWJpbGNkcmNnaXNtcGJjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NjM2NDA5NywiZXhwIjoyMDgxOTQwMDk3fQ.2-NFIz9qEJnnif_cJ6u_6d1Lx7iUx1sQ_-TxFmQS-HQ';
const MIGRATION_FILE = 'supabase/migrations/20251223102959_canonical_schema.sql';

const sql = fs.readFileSync(MIGRATION_FILE, 'utf8');

// Split SQL into smaller chunks to avoid timeout
const statements = sql.split(';').filter(s => s.trim().length > 0);

console.log('========================================');
console.log('Applying Migration to Supabase');
console.log('========================================');
console.log(`Project: ${SUPABASE_URL}`);
console.log(`Migration: ${MIGRATION_FILE}`);
console.log(`Total statements: ${statements.length}`);
console.log('');

// Try using Supabase REST API to execute via RPC
// Note: This requires a function that can execute SQL, which Supabase doesn't provide by default
// So we'll need to use the Management API or direct database connection

console.log('⚠️  Supabase REST API does not support arbitrary SQL execution for security reasons.');
console.log('');
console.log('To apply this migration, please use one of these methods:');
console.log('');
console.log('METHOD 1: Supabase Dashboard (Easiest)');
console.log('  1. Open: https://app.supabase.com/project/vzhrsabilcdrcgismpbc/sql/new');
console.log(`  2. Copy/paste contents of: ${MIGRATION_FILE}`);
console.log('  3. Click Run');
console.log('');
console.log('METHOD 2: psql (Requires database password)');
console.log('  1. Get password from: https://app.supabase.com/project/vzhrsabilcdrcgismpbc/settings/database');
console.log('  2. Run: psql "postgresql://postgres:[PASSWORD]@db.vzhrsabilcdrcgismpbc.supabase.co:5432/postgres" -f ' + MIGRATION_FILE);
console.log('');
console.log('========================================');

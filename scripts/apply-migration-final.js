const fs = require('fs');
const { execSync } = require('child_process');

const PROJECT_REF = 'vzhrsabilcdrcgismpbc';
const MIGRATION_FILE = 'supabase/migrations/20251223102959_canonical_schema.sql';

console.log('========================================');
console.log('Applying 560 Tables Migration');
console.log('========================================');
console.log(`Project: ${PROJECT_REF}.supabase.co`);
console.log(`Migration: ${MIGRATION_FILE}`);
console.log('');

// Read the SQL file
const sql = fs.readFileSync(MIGRATION_FILE, 'utf8');
console.log(`SQL file size: ${(sql.length / 1024).toFixed(2)} KB`);
console.log(`Total statements: ${sql.split(';').filter(s => s.trim().length > 0).length}`);
console.log('');

console.log('========================================');
console.log('⚠️  IMPORTANT: Direct SQL Execution Required');
console.log('========================================');
console.log('');
console.log('Supabase does not allow arbitrary SQL execution via REST API');
console.log('for security reasons. You need to use one of these methods:');
console.log('');
console.log('METHOD 1: Supabase Dashboard (Easiest - No password needed)');
console.log(`  1. Open: https://app.supabase.com/project/${PROJECT_REF}/sql/new`);
console.log(`  2. Copy the entire contents of: ${MIGRATION_FILE}`);
console.log('  3. Paste into SQL Editor');
console.log('  4. Click "Run" (or Cmd/Ctrl + Enter)');
console.log('');
console.log('METHOD 2: psql (Requires database password)');
console.log(`  1. Get password from: https://app.supabase.com/project/${PROJECT_REF}/settings/database`);
console.log('  2. Run:');
console.log(`     export DATABASE_URL="postgresql://postgres:[PASSWORD]@db.${PROJECT_REF}.supabase.co:5432/postgres"`);
console.log(`     node scripts/apply-desktop-migration.js`);
console.log('');
console.log('========================================');
console.log('Migration file is ready at:');
console.log(`  ${process.cwd()}/${MIGRATION_FILE}`);
console.log('========================================');

const fs = require('fs');
const { Client } = require('pg');

const PROJECT_REF = 'vzhrsabilcdrcgismpbc';
const MIGRATION_FILE = 'supabase/migrations/20251223102959_canonical_schema.sql';

async function applyMigration() {
  // Try to get DATABASE_URL from environment
  const databaseUrl = process.env.DATABASE_URL;
  
  if (!databaseUrl) {
    console.log('========================================');
    console.log('Migration Application Script');
    console.log('========================================');
    console.log(`Project: ${PROJECT_REF}.supabase.co`);
    console.log(`Migration: ${MIGRATION_FILE}`);
    console.log('');
    console.log('❌ DATABASE_URL not found in environment.');
    console.log('');
    console.log('To apply this migration automatically:');
    console.log('');
    console.log('1. Get your database password from:');
    console.log(`   https://app.supabase.com/project/${PROJECT_REF}/settings/database`);
    console.log('');
    console.log('2. Set DATABASE_URL environment variable:');
    console.log(`   export DATABASE_URL="postgresql://postgres:[PASSWORD]@db.${PROJECT_REF}.supabase.co:5432/postgres"`);
    console.log('');
    console.log('3. Run this script again:');
    console.log('   node scripts/apply-desktop-migration.js');
    console.log('');
    console.log('========================================');
    console.log('OR use Supabase Dashboard:');
    console.log('========================================');
    console.log(`1. Open: https://app.supabase.com/project/${PROJECT_REF}/sql/new`);
    console.log(`2. Copy/paste contents of: ${MIGRATION_FILE}`);
    console.log('3. Click Run');
    console.log('');
    process.exit(1);
  }

  const sql = fs.readFileSync(MIGRATION_FILE, 'utf8');
  const client = new Client({
    connectionString: databaseUrl,
    ssl: { rejectUnauthorized: false }
  });

  try {
    console.log('========================================');
    console.log('Applying Migration to Supabase');
    console.log('========================================');
    console.log(`Project: ${PROJECT_REF}.supabase.co`);
    console.log(`Migration: ${MIGRATION_FILE}`);
    console.log(`SQL size: ${(sql.length / 1024).toFixed(2)} KB`);
    console.log('');
    
    console.log('Connecting to database...');
    await client.connect();
    console.log('✅ Connected!');
    
    console.log('\nExecuting migration...');
    console.log('This may take a few minutes...\n');
    
    await client.query(sql);
    
    console.log('✅ Migration applied successfully!');
    console.log('✅ 560 tables created across 18 schemas');
    
    // Verify tables were created
    const result = await client.query(`
      SELECT 
        schemaname,
        COUNT(*) as table_count
      FROM pg_tables
      WHERE schemaname IN ('adapters', 'app', 'attest', 'audit', 'billing', 'consent', 'cu_os', 'legal', 'ops', 'public', 'qfx', 'realtime', 'registry', 'storage', 'tenancy', 'vault', 'work')
      GROUP BY schemaname
      ORDER BY schemaname;
    `);
    
    console.log('\n📊 Tables created by schema:');
    let total = 0;
    result.rows.forEach(row => {
      console.log(`   ${row.schemaname.padEnd(20)}: ${row.table_count.toString().padStart(3)} tables`);
      total += parseInt(row.table_count);
    });
    console.log(`   ${''.padEnd(20, '-')}   ${''.padEnd(3, '-')}`);
    console.log(`   ${'TOTAL'.padEnd(20)}: ${total.toString().padStart(3)} tables`);
    console.log('\n✅ Migration complete!');
    
  } catch (error) {
    console.error('\n❌ Error applying migration:');
    console.error(error.message);
    if (error.message.includes('password') || error.message.includes('authentication')) {
      console.error('\n💡 Make sure your DATABASE_URL includes the correct password.');
      console.error('   Get it from: https://app.supabase.com/project/' + PROJECT_REF + '/settings/database');
    }
    process.exit(1);
  } finally {
    await client.end();
  }
}

applyMigration();

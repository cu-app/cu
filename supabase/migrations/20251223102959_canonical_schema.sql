-- ================================================================
-- COMPREHENSIVE DATABASE SCHEMA MIGRATION
-- ================================================================
-- Auto-generated from: database.types.ts
-- Generated at: 2025-12-23T15:29:59.584Z
--
-- This migration creates the complete canonical schema for the application
-- including all tables across all schemas.
--
-- Total Schemas: 23
-- Total Tables: 560
-- ================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "postgis";


-- ================================================================
-- SCHEMA: adapters
-- Tables: 6
-- ================================================================

CREATE SCHEMA IF NOT EXISTS adapters;

-- Table: adapters.catalog
CREATE TABLE IF NOT EXISTS adapters.catalog (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  description TEXT,
  key TEXT NOT NULL,
  name TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  versions JSONB NOT NULL
);

-- Table: adapters.configs
CREATE TABLE IF NOT EXISTS adapters.configs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  adapter_key TEXT NOT NULL,
  config JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  status TEXT NOT NULL,
  tenant_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: adapters.connections
CREATE TABLE IF NOT EXISTS adapters.connections (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  adapter_key TEXT NOT NULL,
  auth JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  status TEXT NOT NULL,
  tenant_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: adapters.lineage
CREATE TABLE IF NOT EXISTS adapters.lineage (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  notes TEXT,
  org_id UUID NOT NULL,
  output_id UUID,
  output_table TEXT NOT NULL,
  source_id UUID NOT NULL
);

-- Table: adapters.mapping_runs
CREATE TABLE IF NOT EXISTS adapters.mapping_runs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  finished_at TIMESTAMP WITH TIME ZONE,
  org_id UUID NOT NULL,
  run_key TEXT NOT NULL,
  started_at TIMESTAMP WITH TIME ZONE NOT NULL,
  stats JSONB,
  status TEXT NOT NULL
);

-- Table: adapters.raw_ingest
CREATE TABLE IF NOT EXISTS adapters.raw_ingest (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  error TEXT,
  org_id UUID NOT NULL,
  payload JSONB NOT NULL,
  processed_at TIMESTAMP WITH TIME ZONE,
  received_at TIMESTAMP WITH TIME ZONE NOT NULL,
  source TEXT NOT NULL,
  status TEXT NOT NULL
);


-- ================================================================
-- SCHEMA: app
-- Tables: 24
-- ================================================================

CREATE SCHEMA IF NOT EXISTS app;

-- Table: app.api_keys
CREATE TABLE IF NOT EXISTS app.api_keys (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  hashed_key TEXT NOT NULL,
  last_used_at TIMESTAMP WITH TIME ZONE,
  name TEXT NOT NULL,
  tenant_id UUID NOT NULL
);

-- Table: app.atms
CREATE TABLE IF NOT EXISTS app.atms (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  atm_id UUID NOT NULL,
  branch_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  details JSONB,
  geom GEOMETRY NOT NULL,
  tenant_id UUID NOT NULL
);

-- Table: app.audit_events
CREATE TABLE IF NOT EXISTS app.audit_events (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  action TEXT NOT NULL,
  actor_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  tenant_id UUID
);

-- Table: app.branches
CREATE TABLE IF NOT EXISTS app.branches (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  address JSONB NOT NULL,
  branch_code TEXT NOT NULL,
  branch_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  geom GEOMETRY NOT NULL,
  hours JSONB,
  location JSONB,
  services JSONB,
  status TEXT NOT NULL,
  tenant_id UUID NOT NULL
);

-- Table: app.branding
CREATE TABLE IF NOT EXISTS app.branding (
  colors JSONB,
  contact JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  legal_name TEXT,
  logos JSONB,
  mobile_app JSONB,
  name TEXT,
  short_name TEXT,
  social JSONB,
  tenant_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: app.call_logs
CREATE TABLE IF NOT EXISTS app.call_logs (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  call_sid TEXT NOT NULL,
  duration NUMERIC,
  ended_at TIMESTAMP WITH TIME ZONE,
  from_number TEXT NOT NULL,
  menu_path TEXT[],
  raw_event JSONB,
  recording_url TEXT,
  started_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  tenant_id UUID NOT NULL,
  to_number TEXT NOT NULL
);

-- Table: app.cms_api_keys
CREATE TABLE IF NOT EXISTS app.cms_api_keys (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  credit_union_id UUID NOT NULL,
  key_hash TEXT NOT NULL,
  name TEXT
);

-- Table: app.core_configs
CREATE TABLE IF NOT EXISTS app.core_configs (
  created_at TIMESTAMP WITH TIME ZONE,
  device_config JSONB,
  institution_number TEXT,
  provider_type TEXT NOT NULL,
  routing_number TEXT,
  tenant_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: app.itms
CREATE TABLE IF NOT EXISTS app.itms (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  branch_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  details JSONB,
  itm_id UUID NOT NULL,
  tenant_id UUID NOT NULL
);

-- Table: app.ivr_analysis
CREATE TABLE IF NOT EXISTS app.ivr_analysis (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  audio_url TEXT,
  conversation_id UUID,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  hume_job_id UUID,
  hume_result JSONB,
  sentiment JSONB,
  source TEXT NOT NULL,
  tenant_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: app.ivr_jobs
CREATE TABLE IF NOT EXISTS app.ivr_jobs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  error TEXT,
  kind TEXT NOT NULL,
  payload JSONB NOT NULL,
  status TEXT NOT NULL,
  tenant_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: app.ivr_menu_options
CREATE TABLE IF NOT EXISTS app.ivr_menu_options (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  action TEXT NOT NULL,
  action_value TEXT,
  description TEXT,
  digit TEXT NOT NULL,
  menu_id UUID NOT NULL
);

-- Table: app.ivr_menus
CREATE TABLE IF NOT EXISTS app.ivr_menus (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  entry_prompt TEXT NOT NULL,
  is_active BOOLEAN NOT NULL,
  language TEXT,
  name TEXT NOT NULL,
  record_calls BOOLEAN NOT NULL,
  tenant_id UUID NOT NULL,
  voice TEXT
);

-- Table: app.legal_documents
CREATE TABLE IF NOT EXISTS app.legal_documents (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  effective_at TIMESTAMP WITH TIME ZONE NOT NULL,
  key TEXT NOT NULL,
  supersedes_id UUID,
  title TEXT NOT NULL,
  url TEXT NOT NULL,
  version NUMERIC NOT NULL
);

-- Table: app.members
CREATE TABLE IF NOT EXISTS app.members (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  credit_union_id UUID NOT NULL,
  dob TIMESTAMP WITH TIME ZONE,
  kyc_status TEXT NOT NULL,
  ssn_last4 TEXT,
  user_id UUID
);

-- Table: app.membership_applications
CREATE TABLE IF NOT EXISTS app.membership_applications (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  answers JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  credit_union_id UUID NOT NULL,
  status TEXT NOT NULL,
  user_id UUID
);

-- Table: app.pillar_legal_requirements
CREATE TABLE IF NOT EXISTS app.pillar_legal_requirements (
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  legal_key TEXT NOT NULL,
  min_version NUMERIC NOT NULL,
  pillar_key TEXT NOT NULL,
  required BOOLEAN NOT NULL
);

-- Table: app.product_applications
CREATE TABLE IF NOT EXISTS app.product_applications (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  credit_union_id UUID NOT NULL,
  details JSONB NOT NULL,
  product_id UUID NOT NULL,
  status TEXT NOT NULL,
  user_id UUID
);

-- Table: app.product_offers
CREATE TABLE IF NOT EXISTS app.product_offers (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  credit_union_id UUID NOT NULL,
  product_id UUID NOT NULL,
  terms JSONB NOT NULL,
  visible BOOLEAN NOT NULL
);

-- Table: app.products
CREATE TABLE IF NOT EXISTS app.products (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  description TEXT,
  is_active BOOLEAN NOT NULL,
  metadata JSONB NOT NULL,
  name TEXT NOT NULL,
  sku TEXT NOT NULL
);

-- Table: app.tenant_legal_acceptances
CREATE TABLE IF NOT EXISTS app.tenant_legal_acceptances (
  accepted_at TIMESTAMP WITH TIME ZONE NOT NULL,
  actor_user_id UUID NOT NULL,
  ip INET NOT NULL,
  legal_key TEXT NOT NULL,
  tenant_id UUID NOT NULL,
  user_agent TEXT,
  version NUMERIC NOT NULL
);

-- Table: app.tenants
CREATE TABLE IF NOT EXISTS app.tenants (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  display_name TEXT NOT NULL,
  slug TEXT NOT NULL,
  status TEXT NOT NULL
);

-- Table: app.twilio_numbers
CREATE TABLE IF NOT EXISTS app.twilio_numbers (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  is_primary BOOLEAN NOT NULL,
  phone_number TEXT NOT NULL,
  tenant_id UUID NOT NULL,
  voice_webhook_secret TEXT
);

-- Table: app.user_pillar_entitlements
CREATE TABLE IF NOT EXISTS app.user_pillar_entitlements (
  pillar_slug TEXT NOT NULL,
  status TEXT NOT NULL,
  user_id UUID NOT NULL,
  valid_until TEXT
);


-- ================================================================
-- SCHEMA: attest
-- Tables: 1
-- ================================================================

CREATE SCHEMA IF NOT EXISTS attest;

-- Table: attest.api_calls
CREATE TABLE IF NOT EXISTS attest.api_calls (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  endpoint TEXT NOT NULL,
  method TEXT NOT NULL,
  org_id UUID,
  profile_id UUID,
  request_hash TEXT,
  response_hash TEXT,
  status NUMERIC NOT NULL
);


-- ================================================================
-- SCHEMA: audit
-- Tables: 2
-- ================================================================

CREATE SCHEMA IF NOT EXISTS audit;

-- Table: audit.id_verification_events
CREATE TABLE IF NOT EXISTS audit.id_verification_events (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  actor_id UUID,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  decision TEXT NOT NULL,
  doc_hash TEXT,
  provider TEXT,
  provider_score NUMERIC,
  reason_code TEXT,
  selfie_hash TEXT,
  session_id UUID NOT NULL
);

-- Table: audit.logs
CREATE TABLE IF NOT EXISTS audit.logs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  action TEXT NOT NULL,
  actor_id UUID,
  context JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  target TEXT,
  tenant_id UUID
);


-- ================================================================
-- SCHEMA: billing
-- Tables: 5
-- ================================================================

CREATE SCHEMA IF NOT EXISTS billing;

-- Table: billing.modules
CREATE TABLE IF NOT EXISTS billing.modules (
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  module_key TEXT NOT NULL,
  platform_fee_cents NUMERIC NOT NULL,
  title TEXT NOT NULL,
  usage_description TEXT NOT NULL
);

-- Table: billing.stripe_customers
CREATE TABLE IF NOT EXISTS billing.stripe_customers (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  email TEXT,
  metadata JSONB NOT NULL,
  name TEXT,
  stripe_customer_id UUID NOT NULL,
  tenant_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  user_id UUID
);

-- Table: billing.stripe_invoices
CREATE TABLE IF NOT EXISTS billing.stripe_invoices (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount_due_cents NUMERIC NOT NULL,
  amount_paid_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  hosted_invoice_url TEXT,
  invoice_url TEXT,
  metadata JSONB NOT NULL,
  pdf_url TEXT,
  status TEXT NOT NULL,
  stripe_customer_id UUID NOT NULL,
  stripe_invoice_id UUID NOT NULL,
  stripe_subscription_id UUID NOT NULL,
  tenant_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: billing.stripe_subscriptions
CREATE TABLE IF NOT EXISTS billing.stripe_subscriptions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount_cents NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  currency TEXT,
  current_period_end TEXT,
  current_period_start TEXT,
  metadata JSONB NOT NULL,
  plan_code TEXT,
  plan_name TEXT,
  status TEXT NOT NULL,
  stripe_customer_id UUID NOT NULL,
  stripe_subscription_id UUID NOT NULL,
  tenant_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: billing.table_ownership
CREATE TABLE IF NOT EXISTS billing.table_ownership (
  module_key TEXT NOT NULL,
  schema_name TEXT NOT NULL,
  table_name TEXT NOT NULL
);


-- ================================================================
-- SCHEMA: consent
-- Tables: 5
-- ================================================================

CREATE SCHEMA IF NOT EXISTS consent;

-- Table: consent.consent_receipts
CREATE TABLE IF NOT EXISTS consent.consent_receipts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  attestation_id UUID,
  consent_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  receipt_hash TEXT NOT NULL
);

-- Table: consent.consents
CREATE TABLE IF NOT EXISTS consent.consents (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  member_id UUID NOT NULL,
  not_before TEXT NOT NULL,
  org_id UUID NOT NULL,
  scopes TEXT[] NOT NULL,
  signature TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  version TEXT NOT NULL
);

-- Table: consent.grants
CREATE TABLE IF NOT EXISTS consent.grants (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE,
  granted_scopes TEXT[] NOT NULL,
  resource_id UUID NOT NULL,
  subject_id UUID NOT NULL
);

-- Table: consent.resources
CREATE TABLE IF NOT EXISTS consent.resources (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  owner_id UUID,
  resource_type TEXT NOT NULL,
  resource_uri TEXT NOT NULL,
  tenant_id UUID NOT NULL
);

-- Table: consent.revocations
CREATE TABLE IF NOT EXISTS consent.revocations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  consent_id UUID NOT NULL,
  reason TEXT,
  revoked_at TIMESTAMP WITH TIME ZONE NOT NULL
);


-- ================================================================
-- SCHEMA: cu_os
-- Tables: 71
-- ================================================================

CREATE SCHEMA IF NOT EXISTS cu_os;

-- Table: cu_os.account_types_cu_os
CREATE TABLE IF NOT EXISTS cu_os.account_types_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  default_product_id NUMERIC,
  display_name TEXT NOT NULL,
  features JSONB,
  type_code TEXT NOT NULL
);

-- Table: cu_os.accounts_cu_os
CREATE TABLE IF NOT EXISTS cu_os.accounts_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_number TEXT NOT NULL,
  available_balance NUMERIC,
  balance NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID,
  status TEXT,
  type TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: cu_os.ach_batches_cu_os
CREATE TABLE IF NOT EXISTS cu_os.ach_batches_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  batch_number NUMERIC NOT NULL,
  batch_number_check NUMERIC,
  company_descriptive_date TIMESTAMP WITH TIME ZONE,
  company_discretionary_data TEXT,
  company_entry_description TEXT,
  company_identification TEXT NOT NULL,
  company_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  effective_entry_date TIMESTAMP WITH TIME ZONE,
  entry_count NUMERIC,
  entry_hash NUMERIC,
  file_id UUID,
  originating_dfi_identification TEXT,
  originator_status_code TEXT,
  service_class_code TEXT,
  settlement_date TIMESTAMP WITH TIME ZONE,
  standard_entry_class TEXT,
  status TEXT,
  total_credit_amount NUMERIC,
  total_debit_amount NUMERIC
);

-- Table: cu_os.ach_entries_cu_os
CREATE TABLE IF NOT EXISTS cu_os.ach_entries_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID,
  addenda_record_indicator NUMERIC,
  addenda_records JSONB,
  amount NUMERIC NOT NULL,
  batch_id UUID,
  check_digit TEXT,
  corrected_data TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  dfi_account_number TEXT NOT NULL,
  discretionary_data TEXT,
  entry_status TEXT,
  individual_identification_number TEXT,
  individual_name TEXT NOT NULL,
  original_trace_number TEXT,
  processed_at TIMESTAMP WITH TIME ZONE,
  receiving_dfi_identification TEXT NOT NULL,
  return_reason_code TEXT,
  settlement_date TIMESTAMP WITH TIME ZONE,
  trace_number TEXT NOT NULL,
  transaction_code TEXT
);

-- Table: cu_os.ach_files_cu_os
CREATE TABLE IF NOT EXISTS cu_os.ach_files_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  batch_count NUMERIC,
  block_count NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  entry_addenda_count NUMERIC,
  error_message TEXT,
  file_hash TEXT,
  file_id_modifier TEXT,
  file_name TEXT NOT NULL,
  file_path TEXT,
  file_size NUMERIC,
  file_type TEXT NOT NULL,
  immediate_destination TEXT,
  immediate_origin TEXT,
  processed_at TIMESTAMP WITH TIME ZONE,
  settlement_date TIMESTAMP WITH TIME ZONE,
  status TEXT,
  total_credit_amount NUMERIC,
  total_debit_amount NUMERIC,
  transmission_date TIMESTAMP WITH TIME ZONE
);

-- Table: cu_os.ach_messages_cu_os
CREATE TABLE IF NOT EXISTS cu_os.ach_messages_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  ach_status TEXT,
  amount NUMERIC NOT NULL,
  company_entry_description TEXT,
  company_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  direction TEXT,
  effective_date TIMESTAMP WITH TIME ZONE,
  message_id UUID,
  return_code TEXT,
  return_reason TEXT,
  settlement_date TIMESTAMP WITH TIME ZONE,
  transaction_code TEXT,
  transaction_id UUID NOT NULL
);

-- Table: cu_os.ach_processing_queue_cu_os
CREATE TABLE IF NOT EXISTS cu_os.ach_processing_queue_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  attempts NUMERIC,
  completed_at TIMESTAMP WITH TIME ZONE,
  entry_id UUID,
  error_message TEXT,
  max_attempts NUMERIC,
  next_retry_at TIMESTAMP WITH TIME ZONE,
  operation TEXT,
  payload JSONB NOT NULL,
  priority NUMERIC,
  scheduled_at TIMESTAMP WITH TIME ZONE,
  started_at TIMESTAMP WITH TIME ZONE,
  status TEXT
);

-- Table: cu_os.ach_returns_cu_os
CREATE TABLE IF NOT EXISTS cu_os.ach_returns_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  addenda_information TEXT,
  corrected_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  dishonored_return BOOLEAN,
  original_entry_id UUID,
  original_trace_number TEXT,
  reinitiate BOOLEAN,
  return_date TIMESTAMP WITH TIME ZONE,
  return_reason_code TEXT NOT NULL,
  return_reason_description TEXT
);

-- Table: cu_os.ach_settlement_cu_os
CREATE TABLE IF NOT EXISTS cu_os.ach_settlement_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  batch_count NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  entry_count NUMERIC,
  file_count NUMERIC,
  net_amount NUMERIC,
  reconciled_at TIMESTAMP WITH TIME ZONE,
  return_amount NUMERIC,
  return_count NUMERIC,
  settlement_date TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT,
  total_credits NUMERIC,
  total_debits NUMERIC
);

-- Table: cu_os.audit_logs_cu_os
CREATE TABLE IF NOT EXISTS cu_os.audit_logs_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  action TEXT NOT NULL,
  actor TEXT NOT NULL,
  actor_type TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  entity_id UUID,
  entity_type TEXT,
  input JSONB,
  output JSONB
);

-- Table: cu_os.credit_bureau_data_cu_os
CREATE TABLE IF NOT EXISTS cu_os.credit_bureau_data_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  address_matches JSONB,
  bureau TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_score NUMERIC,
  data JSONB,
  deceased_indicator BOOLEAN,
  employment_matches JSONB,
  fraud_alerts JSONB,
  identity_verified BOOLEAN,
  inquiry_date TIMESTAMP WITH TIME ZONE,
  member_id UUID,
  phone_matches JSONB,
  report_type TEXT,
  security_freeze BOOLEAN,
  ssn_verified BOOLEAN
);

-- Table: cu_os.credit_card_accounts_cu_os
CREATE TABLE IF NOT EXISTS cu_os.credit_card_accounts_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  activation_date TIMESTAMP WITH TIME ZONE,
  available_credit NUMERIC NOT NULL,
  card_number TEXT,
  cash_advance_limit NUMERIC,
  cash_advance_rate NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_limit NUMERIC NOT NULL,
  current_balance NUMERIC,
  expiration_date TIMESTAMP WITH TIME ZONE,
  interest_rate NUMERIC NOT NULL,
  last_payment_amount NUMERIC,
  last_payment_date TIMESTAMP WITH TIME ZONE,
  last_statement_date TIMESTAMP WITH TIME ZONE,
  member_id UUID,
  minimum_payment NUMERIC,
  next_statement_date TIMESTAMP WITH TIME ZONE,
  payment_due_date TIMESTAMP WITH TIME ZONE,
  product_id NUMERIC,
  reward_cashback NUMERIC,
  reward_points NUMERIC,
  security_deposit NUMERIC,
  statement_balance NUMERIC,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: cu_os.device_fingerprints_cu_os
CREATE TABLE IF NOT EXISTS cu_os.device_fingerprints_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  browser_name TEXT,
  browser_plugins JSONB,
  browser_version TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  device_id UUID,
  device_type TEXT,
  fingerprint_hash TEXT,
  first_seen TEXT,
  fraud_indicators JSONB,
  geolocation JSONB,
  ip_address INET NOT NULL,
  is_mobile BOOLEAN,
  is_trusted_device BOOLEAN,
  language_settings JSONB,
  last_seen TEXT,
  member_id UUID,
  operating_system TEXT,
  risk_score NUMERIC,
  screen_resolution TEXT,
  session_id UUID,
  timezone TEXT,
  usage_count NUMERIC,
  user_agent TEXT
);

-- Table: cu_os.document_audit_cu_os
CREATE TABLE IF NOT EXISTS cu_os.document_audit_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  action TEXT NOT NULL,
  actor TEXT NOT NULL,
  actor_type TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  details JSONB,
  document_id UUID,
  ip_address INET NOT NULL,
  user_agent TEXT
);

-- Table: cu_os.document_reviews_cu_os
CREATE TABLE IF NOT EXISTS cu_os.document_reviews_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  annotations JSONB,
  document_id UUID,
  expires_at TIMESTAMP WITH TIME ZONE,
  findings TEXT[],
  next_actions TEXT[],
  recommendations TEXT,
  review_type TEXT,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  reviewer TEXT NOT NULL,
  score NUMERIC,
  status TEXT
);

-- Table: cu_os.document_types_cu_os
CREATE TABLE IF NOT EXISTS cu_os.document_types_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  allowed_formats TEXT[],
  auto_classification BOOLEAN,
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  display_name TEXT NOT NULL,
  max_file_size_mb NUMERIC,
  ocr_enabled BOOLEAN,
  required_for_membership BOOLEAN,
  retention_years NUMERIC,
  type_code TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  validation_rules JSONB
);

-- Table: cu_os.document_verification_cu_os
CREATE TABLE IF NOT EXISTS cu_os.document_verification_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  confidence_score NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  document_number TEXT,
  document_subtype TEXT,
  document_type TEXT,
  expiration_date TIMESTAMP WITH TIME ZONE,
  extracted_data JSONB,
  file_hash TEXT,
  file_path TEXT,
  fraud_indicators JSONB,
  issued_date TIMESTAMP WITH TIME ZONE,
  issuing_authority TEXT,
  member_id UUID,
  processed_at TIMESTAMP WITH TIME ZONE,
  session_id UUID,
  verification_flags JSONB,
  verification_status TEXT
);

-- Table: cu_os.documents_cu_os
CREATE TABLE IF NOT EXISTS cu_os.documents_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  checksum TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  document_name TEXT NOT NULL,
  document_type TEXT NOT NULL,
  file_path TEXT,
  file_size NUMERIC,
  member_id UUID,
  mime_type TEXT,
  status TEXT,
  uploaded_at TIMESTAMP WITH TIME ZONE,
  verification_data JSONB,
  verified_at TIMESTAMP WITH TIME ZONE
);

-- Table: cu_os.fraud_alerts_cu_os
CREATE TABLE IF NOT EXISTS cu_os.fraud_alerts_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID,
  alert_type TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  member_id UUID,
  metadata JSONB,
  resolved_at TIMESTAMP WITH TIME ZONE,
  severity TEXT,
  status TEXT
);

-- Table: cu_os.genesys_sessions_cu_os
CREATE TABLE IF NOT EXISTS cu_os.genesys_sessions_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  agent_id UUID,
  authentication_attempts NUMERIC,
  authentication_method TEXT,
  authentication_result TEXT,
  call_disposition TEXT,
  call_duration NUMERIC,
  call_end_time TEXT,
  call_recording_id UUID,
  call_start_time TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  customer_satisfaction_score NUMERIC,
  genesys_session_id UUID,
  interaction_id UUID,
  ivr_path JSONB,
  member_id UUID,
  metadata JSONB,
  queue_name TEXT,
  services_accessed JSONB,
  transfer_reason TEXT
);

-- Table: cu_os.idv_sessions_cu_os
CREATE TABLE IF NOT EXISTS cu_os.idv_sessions_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  completed_at TIMESTAMP WITH TIME ZONE,
  confidence_score NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE,
  member_id UUID,
  provider TEXT,
  provider_session_id UUID,
  session_token TEXT NOT NULL,
  status TEXT,
  verification_data JSONB,
  verification_type TEXT
);

-- Table: cu_os.ivr_sessions_cu_os
CREATE TABLE IF NOT EXISTS cu_os.ivr_sessions_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  ended_at TIMESTAMP WITH TIME ZONE,
  member_id UUID,
  phone_number TEXT,
  session_id UUID NOT NULL,
  status TEXT
);

-- Table: cu_os.kba_questions_cu_os
CREATE TABLE IF NOT EXISTS cu_os.kba_questions_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  answer_choices JSONB,
  answered_at TIMESTAMP WITH TIME ZONE,
  asked_at TIMESTAMP WITH TIME ZONE,
  correct_answer TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  data_source TEXT,
  difficulty_level NUMERIC,
  is_correct BOOLEAN,
  member_answer TEXT,
  question_text TEXT NOT NULL,
  question_type TEXT,
  session_id UUID,
  time_to_answer NUMERIC
);

-- Table: cu_os.loan_accounts_cu_os
CREATE TABLE IF NOT EXISTS cu_os.loan_accounts_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_number TEXT,
  application_id UUID,
  apr NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  current_balance NUMERIC NOT NULL,
  delinquency_days NUMERIC,
  escrow_analysis_date TIMESTAMP WITH TIME ZONE,
  escrow_balance NUMERIC,
  insurance_info JSONB,
  interest_accrued NUMERIC,
  interest_rate NUMERIC NOT NULL,
  last_payment_amount NUMERIC,
  last_payment_date TIMESTAMP WITH TIME ZONE,
  maturity_date TIMESTAMP WITH TIME ZONE NOT NULL,
  member_id UUID,
  next_payment_date TIMESTAMP WITH TIME ZONE NOT NULL,
  original_amount NUMERIC NOT NULL,
  payment_amount NUMERIC NOT NULL,
  payment_history JSONB,
  payments_made NUMERIC,
  principal_balance NUMERIC NOT NULL,
  product_id NUMERIC,
  status TEXT,
  term_months NUMERIC NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: cu_os.loan_applications_cu_os
CREATE TABLE IF NOT EXISTS cu_os.loan_applications_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  application_number TEXT,
  approved_amount NUMERIC,
  approved_apr NUMERIC,
  approved_rate NUMERIC,
  approved_term NUMERIC,
  asset_info JSONB,
  assigned_processor TEXT,
  closing_date TIMESTAMP WITH TIME ZONE,
  collateral_description TEXT,
  collateral_value NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_score NUMERIC,
  debt_to_income NUMERIC,
  decision_date TIMESTAMP WITH TIME ZONE,
  decision_reason TEXT,
  employment_info JSONB,
  first_payment_date TIMESTAMP WITH TIME ZONE,
  income_info JSONB,
  liability_info JSONB,
  loan_to_value NUMERIC,
  member_id UUID,
  product_id NUMERIC,
  purpose TEXT,
  requested_amount NUMERIC NOT NULL,
  requested_term NUMERIC,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  workflow_instance_id UUID
);

-- Table: cu_os.loan_payments_cu_os
CREATE TABLE IF NOT EXISTS cu_os.loan_payments_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount_paid NUMERIC NOT NULL,
  balance_after NUMERIC NOT NULL,
  confirmation_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  escrow_paid NUMERIC,
  fees_paid NUMERIC,
  interest_paid NUMERIC NOT NULL,
  late_charge NUMERIC,
  loan_account_id UUID,
  payment_date TIMESTAMP WITH TIME ZONE NOT NULL,
  payment_method TEXT,
  payment_number NUMERIC NOT NULL,
  payment_source_account TEXT,
  principal_paid NUMERIC NOT NULL
);

-- Table: cu_os.loan_products_cu_os
CREATE TABLE IF NOT EXISTS cu_os.loan_products_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amortization_type TEXT,
  base_rate NUMERIC,
  collateral_required BOOLEAN,
  collateral_type TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  dti_max NUMERIC,
  employment_verification_required BOOLEAN,
  features JSONB,
  income_verification_required BOOLEAN,
  is_active BOOLEAN,
  ltv_max NUMERIC,
  marketing_name TEXT,
  maximum_amount NUMERIC,
  min_credit_score NUMERIC,
  minimum_amount NUMERIC,
  origination_fee_percent NUMERIC,
  prepayment_penalty BOOLEAN,
  product_category TEXT,
  product_description TEXT,
  product_id NUMERIC NOT NULL,
  product_name TEXT NOT NULL,
  purpose_restrictions TEXT[],
  rate_type TEXT,
  term_max_months NUMERIC,
  term_min_months NUMERIC,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: cu_os.loan_rate_tables_cu_os
CREATE TABLE IF NOT EXISTS cu_os.loan_rate_tables_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  apr NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_score_max NUMERIC,
  credit_score_min NUMERIC,
  effective_date TIMESTAMP WITH TIME ZONE,
  expiration_date TIMESTAMP WITH TIME ZONE,
  ltv_max NUMERIC,
  ltv_min NUMERIC,
  points NUMERIC,
  product_id NUMERIC,
  rate NUMERIC NOT NULL,
  rate_lock_days NUMERIC,
  term_months NUMERIC
);

-- Table: cu_os.member_behavior_analytics_cu_os
CREATE TABLE IF NOT EXISTS cu_os.member_behavior_analytics_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  actions_performed JSONB,
  anomaly_score NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  device_consistency BOOLEAN,
  location_consistency BOOLEAN,
  login_time TEXT,
  member_id UUID,
  pages_visited JSONB,
  risk_factors JSONB,
  session_date TIMESTAMP WITH TIME ZONE,
  session_duration NUMERIC,
  time_consistency BOOLEAN,
  transaction_patterns JSONB,
  velocity_checks JSONB
);

-- Table: cu_os.members_cu_os
CREATE TABLE IF NOT EXISTS cu_os.members_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  alloy_decision TEXT,
  alloy_entity_id UUID,
  auth_provider TEXT NOT NULL,
  auth_user_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  email TEXT,
  name TEXT,
  phone TEXT,
  ssn_last4 TEXT,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: cu_os.message_delivery_cu_os
CREATE TABLE IF NOT EXISTS cu_os.message_delivery_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  attempted_at TIMESTAMP WITH TIME ZONE,
  channel TEXT,
  delivered_at TIMESTAMP WITH TIME ZONE,
  error_message TEXT,
  message_id UUID,
  metadata JSONB,
  opened_at TIMESTAMP WITH TIME ZONE,
  provider TEXT,
  provider_message_id UUID,
  status TEXT
);

-- Table: cu_os.message_template_versions_cu_os
CREATE TABLE IF NOT EXISTS cu_os.message_template_versions_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  a_b_test_weight NUMERIC,
  body_template TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN,
  performance_metrics JSONB,
  subject_template TEXT,
  template_id UUID,
  version_number NUMERIC NOT NULL
);

-- Table: cu_os.message_templates_cu_os
CREATE TABLE IF NOT EXISTS cu_os.message_templates_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  active BOOLEAN,
  body_template TEXT,
  channel TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  name TEXT NOT NULL,
  subject_template TEXT,
  type TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: cu_os.messages_cu_os
CREATE TABLE IF NOT EXISTS cu_os.messages_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  body TEXT NOT NULL,
  channel TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  priority TEXT,
  read_at TIMESTAMP WITH TIME ZONE,
  recipient TEXT NOT NULL,
  sent_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  subject TEXT,
  type TEXT
);

-- Table: cu_os.notification_preferences_cu_os
CREATE TABLE IF NOT EXISTS cu_os.notification_preferences_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  email_enabled BOOLEAN,
  frequency TEXT,
  in_app_enabled BOOLEAN,
  member_id UUID NOT NULL,
  notification_type TEXT,
  push_enabled BOOLEAN,
  quiet_hours_end TEXT,
  quiet_hours_start TEXT,
  sms_enabled BOOLEAN,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: cu_os.products_cu_os
CREATE TABLE IF NOT EXISTS cu_os.products_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  dividends_compounded TEXT,
  dividends_compounded_id NUMERIC,
  dividends_credited TEXT,
  dividends_credited_id NUMERIC,
  effective_date TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN,
  is_maturable BOOLEAN,
  ivr_description TEXT,
  marketing_copy TEXT,
  minimum_amount_to_open NUMERIC,
  minimum_balance_to_earn NUMERIC,
  product_description TEXT,
  product_id NUMERIC NOT NULL,
  product_name TEXT NOT NULL,
  product_notes TEXT,
  product_sub_type_id NUMERIC,
  product_sub_type_name TEXT,
  product_type_id NUMERIC NOT NULL,
  product_type_name TEXT NOT NULL,
  rate_type_id NUMERIC,
  rate_type_name TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: cu_os.promotion_manifest_cu_os
CREATE TABLE IF NOT EXISTS cu_os.promotion_manifest_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  approval_token TEXT,
  artifact_path TEXT NOT NULL,
  category TEXT,
  promoted_at TIMESTAMP WITH TIME ZONE,
  promoted_from TEXT,
  promoted_to TEXT,
  reviewer TEXT,
  source_refs TEXT[],
  tests_passing BOOLEAN
);

-- Table: cu_os.rate_tiers_cu_os
CREATE TABLE IF NOT EXISTS cu_os.rate_tiers_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  balance_max NUMERIC,
  balance_min NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  effective_date TIMESTAMP WITH TIME ZONE,
  product_id NUMERIC,
  rate NUMERIC
);

-- Table: cu_os.realtime_connections_cu_os
CREATE TABLE IF NOT EXISTS cu_os.realtime_connections_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  connected_at TIMESTAMP WITH TIME ZONE,
  disconnected_at TIMESTAMP WITH TIME ZONE,
  ip_address INET NOT NULL,
  last_activity TEXT,
  member_id UUID NOT NULL,
  metadata JSONB,
  socket_id UUID NOT NULL,
  user_agent TEXT
);

-- Table: cu_os.sanctions_screening_cu_os
CREATE TABLE IF NOT EXISTS cu_os.sanctions_screening_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  manual_review_required BOOLEAN,
  match_details JSONB,
  matches_found NUMERIC,
  member_id UUID,
  next_screening_due TEXT,
  review_decision TEXT,
  review_notes TEXT,
  reviewed_by TEXT,
  risk_level TEXT,
  screened_at TIMESTAMP WITH TIME ZONE,
  screening_type TEXT,
  search_terms JSONB
);

-- Table: cu_os.secure_messages_cu_os
CREATE TABLE IF NOT EXISTS cu_os.secure_messages_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  archived BOOLEAN,
  attachments JSONB,
  body TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE,
  parent_message_id UUID,
  read BOOLEAN,
  read_at TIMESTAMP WITH TIME ZONE,
  recipient_id UUID NOT NULL,
  sender_id UUID,
  starred BOOLEAN,
  subject TEXT NOT NULL,
  thread_id UUID
);

-- Table: cu_os.tool_registry_cu_os
CREATE TABLE IF NOT EXISTS cu_os.tool_registry_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  endpoint TEXT,
  status TEXT,
  tool_name TEXT NOT NULL,
  tool_type TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: cu_os.transactions_cu_os
CREATE TABLE IF NOT EXISTS cu_os.transactions_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID,
  amount NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  member_id UUID,
  merchant_name TEXT,
  status TEXT,
  transaction_date TIMESTAMP WITH TIME ZONE,
  transaction_type TEXT
);

-- Table: cu_os.voice_authentication_cu_os
CREATE TABLE IF NOT EXISTS cu_os.voice_authentication_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  audio_quality_score NUMERIC,
  authentication_method TEXT,
  background_noise_level NUMERIC,
  confidence_score NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE,
  member_id UUID,
  sample_duration NUMERIC,
  verification_status TEXT,
  verified_at TIMESTAMP WITH TIME ZONE,
  voice_sample_id UUID
);

-- Table: cu_os.workflow_actions_cu_os
CREATE TABLE IF NOT EXISTS cu_os.workflow_actions_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  action_data JSONB,
  action_name TEXT NOT NULL,
  actor TEXT NOT NULL,
  actor_type TEXT,
  automatic BOOLEAN,
  comments TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  from_state TEXT,
  to_state TEXT,
  workflow_instance_id UUID
);

-- Table: cu_os.workflow_definitions_cu_os
CREATE TABLE IF NOT EXISTS cu_os.workflow_definitions_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  active BOOLEAN,
  auto_transitions JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  display_name TEXT NOT NULL,
  required_roles TEXT[],
  sla_hours NUMERIC,
  states JSONB NOT NULL,
  transitions JSONB NOT NULL,
  trigger_events TEXT[],
  updated_at TIMESTAMP WITH TIME ZONE,
  workflow_name TEXT NOT NULL
);

-- Table: cu_os.workflow_instances_cu_os
CREATE TABLE IF NOT EXISTS cu_os.workflow_instances_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  assigned_to TEXT,
  completed_at TIMESTAMP WITH TIME ZONE,
  context JSONB,
  current_state TEXT NOT NULL,
  due_date TIMESTAMP WITH TIME ZONE,
  entity_id UUID NOT NULL,
  entity_type TEXT,
  last_action_at TIMESTAMP WITH TIME ZONE,
  previous_state TEXT,
  priority TEXT,
  started_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  workflow_id UUID
);

-- Table: cu_os.workflow_signals_cu_os
CREATE TABLE IF NOT EXISTS cu_os.workflow_signals_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  processed BOOLEAN,
  processed_at TIMESTAMP WITH TIME ZONE,
  signal_data JSONB,
  signal_name TEXT NOT NULL,
  workflow_instance_id UUID
);

-- Table: cu_os.workflow_tasks_cu_os
CREATE TABLE IF NOT EXISTS cu_os.workflow_tasks_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  assigned_to TEXT,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  due_date TIMESTAMP WITH TIME ZONE,
  result JSONB,
  status TEXT,
  task_data JSONB,
  task_name TEXT NOT NULL,
  task_type TEXT,
  workflow_instance_id UUID
);

-- Table: cu_os.workflow_templates_cu_os
CREATE TABLE IF NOT EXISTS cu_os.workflow_templates_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  definition JSONB NOT NULL,
  description TEXT,
  is_active BOOLEAN,
  template_name TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  version TEXT
);

-- Table: cu_os.zelle_enrollment_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_enrollment_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  email TEXT,
  enrollment_date TIMESTAMP WITH TIME ZONE,
  enrollment_status TEXT,
  last_activity TEXT,
  member_id UUID,
  phone TEXT
);

-- Table: cu_os.zelle_limits_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_limits_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  daily_limit NUMERIC,
  effective_date TIMESTAMP WITH TIME ZONE,
  member_id UUID,
  monthly_limit NUMERIC,
  transaction_limit NUMERIC
);

-- Table: cu_os.zelle_recipients_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_recipients_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  is_verified BOOLEAN,
  last_transaction_date TIMESTAMP WITH TIME ZONE,
  member_id UUID,
  recipient_email TEXT,
  recipient_name TEXT,
  recipient_phone TEXT,
  verification_date TIMESTAMP WITH TIME ZONE
);

-- Table: cu_os.zelle_settings_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_settings_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  auto_accept_requests BOOLEAN,
  created_at TIMESTAMP WITH TIME ZONE,
  email_notifications BOOLEAN,
  member_id UUID,
  privacy_level TEXT,
  push_notifications BOOLEAN,
  sms_notifications BOOLEAN,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: cu_os.zelle_transaction_audit_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transaction_audit_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  audit_data JSONB,
  audit_event TEXT,
  audit_timestamp TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  transaction_id UUID
);

-- Table: cu_os.zelle_transaction_compliance_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transaction_compliance_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  compliance_check TEXT,
  compliance_notes TEXT,
  compliance_score NUMERIC,
  compliance_status TEXT,
  compliance_timestamp TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  transaction_id UUID
);

-- Table: cu_os.zelle_transaction_fraud_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transaction_fraud_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  fraud_decision TEXT,
  fraud_indicators JSONB,
  fraud_reason TEXT,
  fraud_risk_score NUMERIC,
  fraud_timestamp TEXT,
  transaction_id UUID
);

-- Table: cu_os.zelle_transaction_history_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transaction_history_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount NUMERIC,
  archived_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID,
  recipient_email TEXT,
  recipient_name TEXT,
  recipient_phone TEXT,
  status TEXT,
  transaction_id UUID,
  transaction_type TEXT
);

-- Table: cu_os.zelle_transaction_limits_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transaction_limits_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  daily_receive_limit NUMERIC,
  daily_send_limit NUMERIC,
  effective_date TIMESTAMP WITH TIME ZONE,
  member_id UUID,
  monthly_receive_limit NUMERIC,
  monthly_send_limit NUMERIC,
  single_transaction_limit NUMERIC
);

-- Table: cu_os.zelle_transaction_monitoring_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transaction_monitoring_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  monitoring_data JSONB,
  monitoring_status TEXT,
  monitoring_timestamp TEXT,
  monitoring_type TEXT,
  transaction_id UUID
);

-- Table: cu_os.zelle_transaction_notes_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transaction_notes_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  note TEXT,
  transaction_id UUID
);

-- Table: cu_os.zelle_transaction_receipts_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transaction_receipts_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  receipt_data JSONB,
  receipt_url TEXT,
  transaction_id UUID
);

-- Table: cu_os.zelle_transaction_risk_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transaction_risk_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  risk_factors JSONB,
  risk_level TEXT,
  risk_mitigation TEXT,
  risk_score NUMERIC,
  risk_timestamp TEXT,
  transaction_id UUID
);

-- Table: cu_os.zelle_transaction_security_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transaction_security_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  security_data JSONB,
  security_event TEXT,
  security_timestamp TEXT,
  transaction_id UUID
);

-- Table: cu_os.zelle_transaction_status_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transaction_status_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  status_message TEXT,
  transaction_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: cu_os.zelle_transaction_tags_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transaction_tags_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  tag_name TEXT,
  tag_value TEXT,
  transaction_id UUID
);

-- Table: cu_os.zelle_transaction_timeline_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transaction_timeline_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  event_description TEXT,
  event_timestamp TEXT,
  event_type TEXT,
  transaction_id UUID
);

-- Table: cu_os.zelle_transaction_verification_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transaction_verification_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE,
  max_attempts NUMERIC,
  transaction_id UUID,
  verification_attempts NUMERIC,
  verification_code TEXT,
  verification_method TEXT,
  verification_status TEXT,
  verified_at TIMESTAMP WITH TIME ZONE
);

-- Table: cu_os.zelle_transaction_webhooks_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transaction_webhooks_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  last_attempt_at TIMESTAMP WITH TIME ZONE,
  max_attempts NUMERIC,
  next_retry_at TIMESTAMP WITH TIME ZONE,
  transaction_id UUID,
  webhook_attempts NUMERIC,
  webhook_payload JSONB,
  webhook_status TEXT,
  webhook_url TEXT
);

-- Table: cu_os.zelle_transaction_workflow_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transaction_workflow_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  started_at TIMESTAMP WITH TIME ZONE,
  transaction_id UUID,
  workflow_data JSONB,
  workflow_status TEXT,
  workflow_step TEXT
);

-- Table: cu_os.zelle_transactions_cu_os
CREATE TABLE IF NOT EXISTS cu_os.zelle_transactions_cu_os (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount NUMERIC NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  failed_reason TEXT,
  fee_amount NUMERIC,
  memo TEXT,
  recipient_email TEXT NOT NULL,
  recipient_phone TEXT,
  sender_id UUID,
  status TEXT,
  transaction_id UUID NOT NULL,
  zelle_reference_id UUID
);


-- ================================================================
-- SCHEMA: legal
-- Tables: 3
-- ================================================================

CREATE SCHEMA IF NOT EXISTS legal;

-- Table: legal.legal_acceptances
CREATE TABLE IF NOT EXISTS legal.legal_acceptances (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  document_id UUID NOT NULL,
  hash_sha256 TEXT NOT NULL,
  ip INET NOT NULL,
  signed_at TIMESTAMP WITH TIME ZONE NOT NULL,
  user_agent TEXT,
  user_id UUID NOT NULL,
  version TEXT NOT NULL
);

-- Table: legal.legal_documents
CREATE TABLE IF NOT EXISTS legal.legal_documents (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  hash_sha256 TEXT NOT NULL,
  html TEXT NOT NULL,
  is_active BOOLEAN NOT NULL,
  published_at TIMESTAMP WITH TIME ZONE,
  slug TEXT NOT NULL,
  title TEXT NOT NULL,
  version TEXT NOT NULL
);

-- Table: legal.plan_entitlements
CREATE TABLE IF NOT EXISTS legal.plan_entitlements (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  feature_key TEXT NOT NULL,
  limits JSONB NOT NULL,
  plan_code TEXT NOT NULL
);


-- ================================================================
-- SCHEMA: ops
-- Tables: 2
-- ================================================================

CREATE SCHEMA IF NOT EXISTS ops;

-- Table: ops.meters
CREATE TABLE IF NOT EXISTS ops.meters (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  dimensions JSONB NOT NULL,
  metric_key TEXT NOT NULL,
  observed_at TIMESTAMP WITH TIME ZONE NOT NULL,
  tenant_id UUID NOT NULL,
  value NUMERIC NOT NULL
);

-- Table: ops.outbox
CREATE TABLE IF NOT EXISTS ops.outbox (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  payload JSONB NOT NULL,
  retries NUMERIC NOT NULL,
  sent_at TIMESTAMP WITH TIME ZONE,
  status TEXT NOT NULL,
  topic TEXT NOT NULL
);


-- ================================================================
-- SCHEMA: public
-- Tables: 383
-- ================================================================

CREATE SCHEMA IF NOT EXISTS public;

-- Table: public._stg_ncua_minimal
CREATE TABLE IF NOT EXISTS public._stg_ncua_minimal (
  charter_number NUMERIC,
  city TEXT,
  join_number NUMERIC NOT NULL,
  members NUMERIC,
  name TEXT,
  state TEXT,
  street TEXT,
  total_assets NUMERIC,
  zip TEXT
);

-- Table: public.ab_test_configurations
CREATE TABLE IF NOT EXISTS public.ab_test_configurations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  end_date TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN,
  metadata JSONB,
  start_date TIMESTAMP WITH TIME ZONE,
  success_metric TEXT,
  tenant_id UUID,
  test_description TEXT,
  test_name TEXT NOT NULL,
  traffic_allocation JSONB NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  variants JSONB NOT NULL,
  widget_instance_id UUID
);

-- Table: public.ab_test_results
CREATE TABLE IF NOT EXISTS public.ab_test_results (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  conversion_event TEXT,
  conversion_value NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  session_id UUID,
  test_configuration_id UUID,
  user_id UUID,
  variant_name TEXT NOT NULL
);

-- Table: public.account_alerts
CREATE TABLE IF NOT EXISTS public.account_alerts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  alert_condition JSONB NOT NULL,
  alert_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN,
  member_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.account_beneficiaries
CREATE TABLE IF NOT EXISTS public.account_beneficiaries (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  beneficiary_account TEXT,
  beneficiary_bank TEXT,
  beneficiary_name TEXT NOT NULL,
  beneficiary_routing TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN,
  member_id UUID NOT NULL,
  relationship TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.account_fees
CREATE TABLE IF NOT EXISTS public.account_fees (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  charged_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  fee_amount_cents NUMERIC NOT NULL,
  fee_description TEXT,
  fee_type TEXT NOT NULL
);

-- Table: public.account_holders
CREATE TABLE IF NOT EXISTS public.account_holders (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  holder_type TEXT NOT NULL,
  is_primary BOOLEAN,
  member_id UUID NOT NULL
);

-- Table: public.account_limits
CREATE TABLE IF NOT EXISTS public.account_limits (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  effective_date TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN,
  limit_amount_cents NUMERIC NOT NULL,
  limit_period TEXT,
  limit_type TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.account_payees
CREATE TABLE IF NOT EXISTS public.account_payees (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN,
  member_id UUID NOT NULL,
  payee_account TEXT,
  payee_address TEXT,
  payee_bank TEXT,
  payee_name TEXT NOT NULL,
  payee_routing TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.account_services
CREATE TABLE IF NOT EXISTS public.account_services (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  activated_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  deactivated_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN,
  service_name TEXT NOT NULL,
  service_type TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.account_statements
CREATE TABLE IF NOT EXISTS public.account_statements (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  closing_balance_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  opening_balance_cents NUMERIC NOT NULL,
  statement_date TIMESTAMP WITH TIME ZONE NOT NULL,
  statement_period_end TEXT NOT NULL,
  statement_period_start TEXT NOT NULL,
  total_credits_cents NUMERIC,
  total_debits_cents NUMERIC
);

-- Table: public.account_types
CREATE TABLE IF NOT EXISTS public.account_types (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  display_name TEXT NOT NULL,
  features JSONB,
  fees JSONB,
  interest_rate NUMERIC,
  is_active BOOLEAN,
  membership_type_restrictions TEXT[],
  minimum_balance NUMERIC,
  name TEXT NOT NULL,
  org_id UUID NOT NULL,
  organization_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.accounts
CREATE TABLE IF NOT EXISTS public.accounts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_name TEXT NOT NULL,
  account_number_encrypted TEXT,
  account_number_last4 TEXT,
  account_type TEXT NOT NULL,
  apr NUMERIC,
  available_balance NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_limit NUMERIC,
  currency TEXT,
  current_balance NUMERIC,
  institution_id UUID,
  interest_rate NUMERIC,
  is_active BOOLEAN,
  is_primary BOOLEAN,
  last_synced_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  product_code TEXT,
  sync_status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);

-- Table: public.ach_transfers
CREATE TABLE IF NOT EXISTS public.ach_transfers (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  ach_id UUID NOT NULL,
  amount_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  effective_date TIMESTAMP WITH TIME ZONE,
  from_account_id UUID NOT NULL,
  member_id UUID NOT NULL,
  status TEXT,
  to_account_id UUID NOT NULL,
  transfer_type TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.adapter_download_logs
CREATE TABLE IF NOT EXISTS public.adapter_download_logs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  adapter_id UUID NOT NULL,
  bytes_downloaded NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  download_duration_ms NUMERIC,
  download_status TEXT,
  download_token TEXT,
  error_message TEXT,
  file_name TEXT NOT NULL,
  file_size_bytes NUMERIC,
  ip_address INET NOT NULL,
  referer TEXT,
  storage_path TEXT NOT NULL,
  user_adapter_access_id UUID,
  user_agent TEXT,
  user_id UUID
);

-- Table: public.adapter_products
CREATE TABLE IF NOT EXISTS public.adapter_products (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  adapter_id UUID NOT NULL,
  adapter_name TEXT NOT NULL,
  adapter_version TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  file_hash TEXT,
  file_name TEXT,
  file_size_bytes NUMERIC,
  is_active BOOLEAN,
  is_latest BOOLEAN,
  metadata JSONB,
  mime_type TEXT,
  pillar_required TEXT[],
  product_code TEXT NOT NULL,
  product_id UUID,
  requires_purchase BOOLEAN,
  requires_stripe_subscription BOOLEAN,
  storage_bucket TEXT NOT NULL,
  storage_path TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.admin_audit_log
CREATE TABLE IF NOT EXISTS public.admin_audit_log (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  action TEXT NOT NULL,
  admin_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  details JSONB,
  entity_id UUID,
  entity_type TEXT,
  ip_address INET NOT NULL,
  user_agent TEXT
);

-- Table: public.admin_users
CREATE TABLE IF NOT EXISTS public.admin_users (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  admin_level TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  departments TEXT[],
  email TEXT NOT NULL,
  is_active BOOLEAN,
  last_login TEXT,
  metadata JSONB,
  name TEXT,
  permissions JSONB,
  two_factor_enabled BOOLEAN,
  user_id UUID NOT NULL
);

-- Table: public.advocate_profiles
CREATE TABLE IF NOT EXISTS public.advocate_profiles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  availability_status TEXT,
  avatar_url TEXT,
  average_response_time NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  current_load NUMERIC,
  email TEXT,
  languages TEXT[],
  max_concurrent_chats NUMERIC,
  metadata JSONB,
  name TEXT NOT NULL,
  satisfaction_score NUMERIC,
  specialties TEXT[],
  total_conversations NUMERIC,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);

-- Table: public.ai_feedback
CREATE TABLE IF NOT EXISTS public.ai_feedback (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  confidence_before NUMERIC,
  corrected_value TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  feedback_type TEXT,
  metadata JSONB,
  original_value TEXT,
  transaction_id UUID,
  user_id UUID NOT NULL
);

-- Table: public.ai_model_metrics
CREATE TABLE IF NOT EXISTS public.ai_model_metrics (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  confidence_interval NUMERIC,
  measured_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  metric_type TEXT NOT NULL,
  metric_value NUMERIC,
  model_name TEXT NOT NULL,
  model_version TEXT NOT NULL,
  sample_size NUMERIC
);

-- Table: public.anomalies
CREATE TABLE IF NOT EXISTS public.anomalies (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  anomaly_type TEXT,
  confidence_score NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  is_false_positive BOOLEAN,
  metadata JSONB,
  recommended_actions JSONB,
  resolved_at TIMESTAMP WITH TIME ZONE,
  severity TEXT,
  transaction_id UUID,
  user_id UUID NOT NULL
);

-- Table: public.api_endpoints
CREATE TABLE IF NOT EXISTS public.api_endpoints (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  deprecated_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  is_deprecated BOOLEAN,
  is_public BOOLEAN,
  metadata JSONB,
  method TEXT NOT NULL,
  path TEXT NOT NULL,
  rate_limit_per_minute NUMERIC,
  rate_limit_tier TEXT,
  replacement_endpoint TEXT,
  request_schema JSONB,
  required_scopes TEXT[],
  requires_auth BOOLEAN,
  response_schema JSONB,
  tenant_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE,
  version TEXT
);

-- Table: public.api_events
CREATE TABLE IF NOT EXISTS public.api_events (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  actor_email TEXT,
  actor_id UUID,
  actor_name TEXT,
  actor_type TEXT NOT NULL,
  checksum_sha256 TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  current_hash TEXT NOT NULL,
  device_fingerprint TEXT,
  event_category TEXT NOT NULL,
  event_data JSONB NOT NULL,
  event_severity TEXT,
  event_timestamp TEXT NOT NULL,
  event_type TEXT NOT NULL,
  ip_address INET NOT NULL,
  metadata JSONB,
  previous_hash TEXT,
  request_id UUID,
  retention_until TEXT NOT NULL,
  session_id UUID,
  target_consumer_id UUID,
  target_id UUID,
  target_third_party_id UUID,
  target_type TEXT,
  tenant_id UUID NOT NULL,
  user_agent TEXT
);

-- Table: public.api_keys
CREATE TABLE IF NOT EXISTS public.api_keys (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  description TEXT,
  expires_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN,
  key_hash TEXT NOT NULL,
  key_prefix TEXT NOT NULL,
  last_used_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  name TEXT NOT NULL,
  rate_limit_tier TEXT,
  revoked_at TIMESTAMP WITH TIME ZONE,
  revoked_by TEXT,
  scopes TEXT[],
  tenant_id UUID,
  usage_count NUMERIC
);

-- Table: public.api_rate_limits
CREATE TABLE IF NOT EXISTS public.api_rate_limits (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  endpoint_path TEXT,
  identifier TEXT NOT NULL,
  identifier_type TEXT NOT NULL,
  limit_exceeded BOOLEAN,
  metadata JSONB,
  request_count NUMERIC,
  tenant_id UUID,
  window_duration_seconds NUMERIC NOT NULL,
  window_start TEXT NOT NULL
);

-- Table: public.api_request_logs
CREATE TABLE IF NOT EXISTS public.api_request_logs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  api_key_id UUID,
  client_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  endpoint_id UUID,
  error_message TEXT,
  ip_address INET NOT NULL,
  metadata JSONB,
  method TEXT NOT NULL,
  path TEXT NOT NULL,
  query_params JSONB,
  request_body JSONB,
  request_id UUID NOT NULL,
  response_body JSONB,
  response_status NUMERIC,
  response_time_ms NUMERIC,
  tenant_id UUID,
  user_agent TEXT,
  user_id UUID
);

-- Table: public.api_tokens
CREATE TABLE IF NOT EXISTS public.api_tokens (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  is_active BOOLEAN,
  last_used_at TIMESTAMP WITH TIME ZONE,
  name TEXT NOT NULL,
  permissions JSONB,
  role TEXT NOT NULL,
  token_hash TEXT NOT NULL,
  user_id UUID
);

-- Table: public.app_configs
CREATE TABLE IF NOT EXISTS public.app_configs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT NOT NULL,
  config_key TEXT NOT NULL,
  config_value JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.application_events
CREATE TABLE IF NOT EXISTS public.application_events (
  browser TEXT,
  device_type TEXT,
  event_action TEXT,
  event_category TEXT,
  event_label TEXT,
  event_name TEXT NOT NULL,
  event_value NUMERIC,
  experiment_id UUID,
  experiment_variant TEXT,
  feature_name TEXT,
  feature_version TEXT,
  load_time_ms NUMERIC,
  member_id UUID,
  os TEXT,
  page_path TEXT,
  page_title TEXT,
  properties JSONB,
  referrer TEXT,
  render_time_ms NUMERIC,
  screen_name TEXT,
  screen_resolution TEXT,
  session_id UUID,
  time TEXT NOT NULL,
  utm_campaign TEXT,
  utm_medium TEXT,
  utm_source TEXT
);

-- Table: public.archived_data
CREATE TABLE IF NOT EXISTS public.archived_data (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  archived_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  record_data JSONB NOT NULL,
  record_id UUID NOT NULL,
  retention_until TEXT,
  table_name TEXT NOT NULL,
  tenant_id UUID
);

-- Table: public.atm_locations
CREATE TABLE IF NOT EXISTS public.atm_locations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  address_line1 TEXT NOT NULL,
  address_line2 TEXT,
  atm_id UUID NOT NULL,
  city TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  installed_at TIMESTAMP WITH TIME ZONE,
  is_24_hours BOOLEAN,
  is_active BOOLEAN,
  latitude NUMERIC,
  location_name TEXT NOT NULL,
  longitude NUMERIC,
  postal_code TEXT NOT NULL,
  services_available TEXT[],
  state TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.audio_files
CREATE TABLE IF NOT EXISTS public.audio_files (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  duration_seconds NUMERIC,
  file_name TEXT NOT NULL,
  file_size NUMERIC NOT NULL,
  folder TEXT,
  metadata JSONB,
  mime_type TEXT,
  storage_path TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID
);

-- Table: public.audit_logs
CREATE TABLE IF NOT EXISTS public.audit_logs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  action TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  entity_id UUID,
  entity_type TEXT NOT NULL,
  ip_address INET NOT NULL,
  metadata JSONB,
  new_values JSONB,
  old_values JSONB,
  org_id UUID NOT NULL,
  organization_id UUID,
  profile_id UUID,
  user_agent TEXT
);

-- Table: public.audit_trails
CREATE TABLE IF NOT EXISTS public.audit_trails (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  action TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  entity_id UUID NOT NULL,
  entity_type TEXT NOT NULL,
  ip_address INET NOT NULL,
  new_values JSONB,
  old_values JSONB,
  performed_at TIMESTAMP WITH TIME ZONE,
  performed_by TEXT,
  user_agent TEXT
);

-- Table: public.auth_anomalies
CREATE TABLE IF NOT EXISTS public.auth_anomalies (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  anomaly_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  details JSONB NOT NULL,
  distance_km NUMERIC,
  location_current JSONB,
  location_previous JSONB,
  member_id UUID NOT NULL,
  resolved BOOLEAN,
  severity TEXT,
  time_delta_minutes NUMERIC
);

-- Table: public.authorized_third_parties
CREATE TABLE IF NOT EXISTS public.authorized_third_parties (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  active BOOLEAN,
  approved_at TIMESTAMP WITH TIME ZONE,
  approved_by TEXT,
  client_id UUID NOT NULL,
  client_secret_hash TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  fdx_certification_date TIMESTAMP WITH TIME ZONE,
  fdx_certified BOOLEAN,
  fdx_entity_id UUID,
  legal_entity TEXT NOT NULL,
  name TEXT NOT NULL,
  redirect_uris TEXT[],
  third_party_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  website TEXT
);

-- Table: public.background_jobs
CREATE TABLE IF NOT EXISTS public.background_jobs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  is_enabled BOOLEAN,
  job_name TEXT NOT NULL,
  job_type TEXT NOT NULL,
  last_run_at TIMESTAMP WITH TIME ZONE,
  last_run_duration_ms NUMERIC,
  last_run_error TEXT,
  last_run_status TEXT,
  max_retries NUMERIC,
  metadata JSONB,
  next_run_at TIMESTAMP WITH TIME ZONE,
  schedule_expression TEXT,
  tenant_id UUID,
  timeout_seconds NUMERIC,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.balance_history
CREATE TABLE IF NOT EXISTS public.balance_history (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  available_balance_cents NUMERIC NOT NULL,
  balance_cents NUMERIC NOT NULL,
  current_balance_cents NUMERIC NOT NULL,
  recorded_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.banking_events
CREATE TABLE IF NOT EXISTS public.banking_events (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  entity_id UUID NOT NULL,
  entity_type TEXT NOT NULL,
  event_data JSONB,
  event_type TEXT NOT NULL,
  member_id UUID
);

-- Table: public.banking_messages
CREATE TABLE IF NOT EXISTS public.banking_messages (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  from_member_id UUID NOT NULL,
  is_read BOOLEAN,
  message_type TEXT,
  subject TEXT,
  to_member_id UUID
);

-- Table: public.behavioral_events
CREATE TABLE IF NOT EXISTS public.behavioral_events (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  event_data JSONB NOT NULL,
  event_type TEXT NOT NULL,
  fraud_score NUMERIC,
  pattern_anomaly BOOLEAN,
  platform TEXT,
  screen_name TEXT,
  session_id UUID NOT NULL,
  timestamp TEXT,
  user_id UUID NOT NULL,
  velocity_score NUMERIC
);

-- Table: public.bill_pay
CREATE TABLE IF NOT EXISTS public.bill_pay (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  frequency TEXT,
  member_id UUID NOT NULL,
  payee_account TEXT NOT NULL,
  payee_name TEXT NOT NULL,
  payment_date TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.bill_pay_recipients
CREATE TABLE IF NOT EXISTS public.bill_pay_recipients (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_number TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  institution TEXT,
  is_active BOOLEAN,
  name TEXT NOT NULL,
  nickname TEXT,
  routing_number TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID
);

-- Table: public.bill_pay_schedules
CREATE TABLE IF NOT EXISTS public.bill_pay_schedules (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  frequency TEXT NOT NULL,
  metadata JSONB,
  next_payment_date TIMESTAMP WITH TIME ZONE NOT NULL,
  recipient_id UUID,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID
);

-- Table: public.bill_payments
CREATE TABLE IF NOT EXISTS public.bill_payments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  amount_cents NUMERIC NOT NULL,
  confirmation_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  payee_account TEXT,
  payee_name TEXT NOT NULL,
  payment_date TIMESTAMP WITH TIME ZONE,
  payment_id UUID NOT NULL,
  payment_method TEXT,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.billing_meter_events
CREATE TABLE IF NOT EXISTS public.billing_meter_events (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  event_type TEXT NOT NULL,
  metadata JSONB,
  occurred_at TIMESTAMP WITH TIME ZONE NOT NULL,
  quantity NUMERIC NOT NULL,
  tenant_id UUID NOT NULL,
  unit_price_cents NUMERIC NOT NULL
);

-- Table: public.branch_locations
CREATE TABLE IF NOT EXISTS public.branch_locations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  address_line1 TEXT NOT NULL,
  address_line2 TEXT,
  branch_code TEXT NOT NULL,
  branch_name TEXT NOT NULL,
  city TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  email TEXT,
  hours_of_operation JSONB,
  is_active BOOLEAN,
  manager_name TEXT,
  opened_at TIMESTAMP WITH TIME ZONE,
  phone TEXT,
  postal_code TEXT NOT NULL,
  services_offered TEXT[],
  state TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.budget_categories
CREATE TABLE IF NOT EXISTS public.budget_categories (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  budget_amount_cents NUMERIC NOT NULL,
  budget_period TEXT NOT NULL,
  category_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  period_end TEXT NOT NULL,
  period_start TEXT NOT NULL,
  spent_amount_cents NUMERIC NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.budgets
CREATE TABLE IF NOT EXISTS public.budgets (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  alert_threshold NUMERIC,
  amount NUMERIC NOT NULL,
  budget_type TEXT,
  category_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN,
  metadata JSONB,
  name TEXT NOT NULL,
  period_end TEXT NOT NULL,
  period_start TEXT NOT NULL,
  rollover_enabled BOOLEAN,
  spent NUMERIC,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);

-- Table: public.calculator_usage
CREATE TABLE IF NOT EXISTS public.calculator_usage (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  calculated_at TIMESTAMP WITH TIME ZONE,
  calculator_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  input_values JSONB NOT NULL,
  member_id UUID NOT NULL,
  result JSONB NOT NULL
);

-- Table: public.call_logs
CREATE TABLE IF NOT EXISTS public.call_logs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  advocate_id UUID,
  answered_at TIMESTAMP WITH TIME ZONE,
  call_data JSONB,
  call_direction TEXT NOT NULL,
  call_sid TEXT NOT NULL,
  call_status TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  duration NUMERIC,
  ended_at TIMESTAMP WITH TIME ZONE,
  member_id UUID,
  phone_number TEXT NOT NULL,
  recording_url TEXT,
  started_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.call_routing
CREATE TABLE IF NOT EXISTS public.call_routing (
  actual_wait_minutes NUMERIC,
  call_sid TEXT NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  estimated_wait_minutes NUMERIC,
  member_context JSONB,
  queue_name TEXT,
  queue_position NUMERIC,
  resolution TEXT,
  routed_to TEXT,
  routing_id UUID NOT NULL,
  routing_reason TEXT
);

-- Table: public.cards
CREATE TABLE IF NOT EXISTS public.cards (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID,
  activated_at TIMESTAMP WITH TIME ZONE,
  available_credit_cents NUMERIC,
  card_number_encrypted TEXT NOT NULL,
  card_number_last4 TEXT NOT NULL,
  card_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_limit_cents NUMERIC,
  cvv_encrypted TEXT,
  expiration_date TIMESTAMP WITH TIME ZONE NOT NULL,
  issued_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  pin_encrypted TEXT,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.cases
CREATE TABLE IF NOT EXISTS public.cases (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  assigned_to TEXT,
  case_number TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID,
  narrative TEXT,
  priority NUMERIC,
  queue TEXT,
  reason TEXT NOT NULL,
  sar_eligible BOOLEAN,
  sar_filed_at TIMESTAMP WITH TIME ZONE,
  status TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.cash_flow_forecasts
CREATE TABLE IF NOT EXISTS public.cash_flow_forecasts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  confidence_score NUMERIC,
  contributing_factors JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  forecast_date TIMESTAMP WITH TIME ZONE NOT NULL,
  model_version TEXT,
  predicted_balance NUMERIC,
  predicted_expenses NUMERIC,
  predicted_income NUMERIC,
  user_id UUID NOT NULL
);

-- Table: public.categories
CREATE TABLE IF NOT EXISTS public.categories (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  ai_confidence_threshold NUMERIC,
  category_type TEXT,
  color TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  display_order NUMERIC,
  icon TEXT,
  is_system BOOLEAN,
  keywords TEXT[],
  merchant_patterns TEXT[],
  metadata JSONB,
  name TEXT NOT NULL,
  parent_id UUID
);

-- Table: public.cfpb_1033_audit_log
CREATE TABLE IF NOT EXISTS public.cfpb_1033_audit_log (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  access_id UUID,
  actor_id UUID,
  actor_ip_address BYTEA NOT NULL,
  actor_type TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  data_categories TEXT[],
  error_message TEXT,
  event_category TEXT NOT NULL,
  event_type TEXT NOT NULL,
  record_count NUMERIC,
  request_id UUID,
  request_metadata JSONB,
  response_metadata JSONB,
  retention_until TEXT NOT NULL,
  success BOOLEAN,
  tenant_id UUID,
  user_id UUID
);

-- Table: public.cfpb_1033_data_requests
CREATE TABLE IF NOT EXISTS public.cfpb_1033_data_requests (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  authorization_method TEXT,
  authorized_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  date_range_end TEXT,
  date_range_start TEXT,
  download_count NUMERIC,
  download_expires_at TIMESTAMP WITH TIME ZONE,
  download_token TEXT,
  download_url TEXT,
  expires_at TIMESTAMP WITH TIME ZONE,
  export_format TEXT,
  metadata JSONB,
  request_type TEXT NOT NULL,
  revocation_reason TEXT,
  revoked_at TIMESTAMP WITH TIME ZONE,
  scope TEXT[],
  status TEXT,
  tenant_id UUID,
  third_party_client_id UUID,
  third_party_name TEXT,
  third_party_purpose TEXT,
  user_id UUID NOT NULL
);

-- Table: public.cfpb_1033_export_formats
CREATE TABLE IF NOT EXISTS public.cfpb_1033_export_formats (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  file_extension TEXT NOT NULL,
  format_code TEXT NOT NULL,
  format_name TEXT NOT NULL,
  is_active BOOLEAN,
  metadata JSONB,
  mime_type TEXT NOT NULL,
  schema_definition JSONB,
  supports_accounts BOOLEAN,
  supports_personal_info BOOLEAN,
  supports_statements BOOLEAN,
  supports_transactions BOOLEAN,
  template TEXT
);

-- Table: public.cfpb_1033_third_party_access
CREATE TABLE IF NOT EXISTS public.cfpb_1033_third_party_access (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  access_count NUMERIC,
  access_token TEXT NOT NULL,
  consent_text TEXT,
  consent_version TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE,
  granted_at TIMESTAMP WITH TIME ZONE,
  last_accessed_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  refresh_token TEXT,
  revocation_reason TEXT,
  revoked_at TIMESTAMP WITH TIME ZONE,
  scopes TEXT[],
  status TEXT,
  tenant_id UUID,
  third_party_client_id UUID NOT NULL,
  third_party_name TEXT NOT NULL,
  third_party_website TEXT,
  user_id UUID NOT NULL
);

-- Table: public.chat_channel_limits
CREATE TABLE IF NOT EXISTS public.chat_channel_limits (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  channel TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  current_day_count NUMERIC,
  current_hour_count NUMERIC,
  day_reset_at TIMESTAMP WITH TIME ZONE,
  hour_reset_at TIMESTAMP WITH TIME ZONE,
  max_messages_per_day NUMERIC,
  max_messages_per_hour NUMERIC,
  org_id UUID NOT NULL,
  org_id_norm TEXT,
  organization_id UUID
);

-- Table: public.chat_conversations
CREATE TABLE IF NOT EXISTS public.chat_conversations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  advocate_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  priority TEXT,
  status TEXT,
  subject TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID
);

-- Table: public.chat_messages
CREATE TABLE IF NOT EXISTS public.chat_messages (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  channel TEXT,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  role TEXT NOT NULL,
  session_id UUID NOT NULL
);

-- Table: public.chat_participants
CREATE TABLE IF NOT EXISTS public.chat_participants (
  added_at TIMESTAMP WITH TIME ZONE NOT NULL,
  chat_id UUID NOT NULL,
  user_id UUID NOT NULL
);

-- Table: public.chat_permission_audit
CREATE TABLE IF NOT EXISTS public.chat_permission_audit (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  action TEXT NOT NULL,
  change_reason TEXT,
  changed_by TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  new_values JSONB,
  old_values JSONB,
  org_id UUID NOT NULL,
  organization_id UUID,
  permission_id UUID
);

-- Table: public.chat_permissions
CREATE TABLE IF NOT EXISTS public.chat_permissions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  can_assign_agents BOOLEAN,
  can_escalate BOOLEAN,
  can_view_all_sessions BOOLEAN,
  channels TEXT[],
  created_at TIMESTAMP WITH TIME ZONE,
  max_concurrent_sessions NUMERIC,
  org_id UUID NOT NULL,
  permission_type TEXT NOT NULL,
  profile_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.chat_session_limits
CREATE TABLE IF NOT EXISTS public.chat_session_limits (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  current_sessions NUMERIC,
  last_updated TEXT,
  max_sessions NUMERIC,
  org_id UUID NOT NULL,
  organization_id UUID,
  profile_id UUID
);

-- Table: public.chat_sessions
CREATE TABLE IF NOT EXISTS public.chat_sessions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  assigned_agent_id UUID,
  channel TEXT,
  context_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  org_id UUID NOT NULL,
  organization_id UUID NOT NULL,
  priority TEXT,
  profile_id UUID NOT NULL,
  session_type TEXT,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.chats
CREATE TABLE IF NOT EXISTS public.chats (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  credit_union_id UUID NOT NULL,
  is_direct BOOLEAN NOT NULL
);

-- Table: public.check_images
CREATE TABLE IF NOT EXISTS public.check_images (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  image_back TEXT,
  image_format TEXT,
  image_front TEXT,
  image_size NUMERIC,
  transaction_id UUID
);

-- Table: public.check_processing_results
CREATE TABLE IF NOT EXISTS public.check_processing_results (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  ai_fraud_analysis JSONB,
  behavioral_fraud_score NUMERIC,
  check_amount NUMERIC,
  check_data JSONB NOT NULL,
  check_number TEXT,
  combined_risk_score NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  decision_reason TEXT,
  image_analysis JSONB,
  platform TEXT,
  processed_at TIMESTAMP WITH TIME ZONE,
  processing_decision TEXT,
  review_notes TEXT,
  reviewed_by TEXT,
  risk_factors TEXT[],
  session_id UUID NOT NULL,
  user_id UUID NOT NULL
);

-- Table: public.cms_content
CREATE TABLE IF NOT EXISTS public.cms_content (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  content JSONB NOT NULL,
  content_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  expire_at TIMESTAMP WITH TIME ZONE,
  is_published BOOLEAN,
  key TEXT NOT NULL,
  metadata JSONB,
  org_id UUID NOT NULL,
  org_id_norm TEXT,
  organization_id UUID NOT NULL,
  publish_at TIMESTAMP WITH TIME ZONE,
  target_membership_types TEXT[],
  title TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.cms_tokens
CREATE TABLE IF NOT EXISTS public.cms_tokens (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  effectiveness_score NUMERIC,
  en_text TEXT NOT NULL,
  es_text TEXT NOT NULL,
  metadata JSONB,
  token_key TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  usage_count NUMERIC,
  uxsjado_id UUID NOT NULL
);

-- Table: public.communication_preferences
CREATE TABLE IF NOT EXISTS public.communication_preferences (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  communication_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  frequency TEXT,
  member_id UUID NOT NULL,
  preference TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.compliance_reports
CREATE TABLE IF NOT EXISTS public.compliance_reports (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  generated_by TEXT NOT NULL,
  period_end TEXT NOT NULL,
  period_start TEXT NOT NULL,
  report_data JSONB NOT NULL,
  report_type TEXT NOT NULL
);

-- Table: public.component_catalog
CREATE TABLE IF NOT EXISTS public.component_catalog (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  accessibility_notes TEXT,
  component_name TEXT NOT NULL,
  component_schema JSONB NOT NULL,
  component_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  design_token_references JSONB,
  is_deprecated BOOLEAN,
  metadata JSONB,
  react_component_path TEXT,
  replacement_component TEXT,
  storybook_url TEXT,
  svelte_component_path TEXT,
  tags TEXT[],
  updated_at TIMESTAMP WITH TIME ZONE,
  version TEXT,
  vue_component_path TEXT
);

-- Table: public.component_composition
CREATE TABLE IF NOT EXISTS public.component_composition (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  child_component_key TEXT NOT NULL,
  constraints JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  default_props JSONB,
  order_index NUMERIC NOT NULL,
  parent_component_key TEXT NOT NULL,
  required BOOLEAN,
  slot_name TEXT
);

-- Table: public.component_definitions
CREATE TABLE IF NOT EXISTS public.component_definitions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  component_config JSONB NOT NULL,
  component_name TEXT NOT NULL,
  component_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  event_types TEXT[] NOT NULL,
  is_active BOOLEAN,
  tenant_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.component_props
CREATE TABLE IF NOT EXISTS public.component_props (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  component_key TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  default_value JSONB,
  deprecated BOOLEAN,
  description TEXT,
  prop_name TEXT NOT NULL,
  prop_type TEXT NOT NULL,
  prop_value_constraints JSONB,
  required BOOLEAN
);

-- Table: public.component_system
CREATE TABLE IF NOT EXISTS public.component_system (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  component_name TEXT NOT NULL,
  component_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  props JSONB,
  styles JSONB,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.component_tokens
CREATE TABLE IF NOT EXISTS public.component_tokens (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  accessibility_config JSONB,
  animation_token_refs JSONB,
  base_props JSONB,
  behavior_config JSONB,
  component_family TEXT NOT NULL,
  component_key TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  deprecated BOOLEAN,
  description TEXT,
  design_token_refs JSONB,
  display_name TEXT NOT NULL,
  event_types TEXT[],
  haptic_token_ref TEXT,
  replacement_component_key TEXT,
  sound_token_ref TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  version TEXT
);

-- Table: public.composition_instances
CREATE TABLE IF NOT EXISTS public.composition_instances (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  instance_key TEXT NOT NULL,
  instance_props JSONB,
  instance_state JSONB,
  parent_instance_id UUID,
  tenant_id UUID,
  token_key TEXT NOT NULL,
  token_type TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID
);

-- Table: public.configurations
CREATE TABLE IF NOT EXISTS public.configurations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  environment TEXT,
  key TEXT NOT NULL,
  tenant_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE,
  value JSONB NOT NULL
);

-- Table: public.consent_registry
CREATE TABLE IF NOT EXISTS public.consent_registry (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  access_count NUMERIC,
  consent_id UUID NOT NULL,
  consent_proof_hash TEXT NOT NULL,
  consent_purpose TEXT NOT NULL,
  consent_scope JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  device_id UUID,
  expires_at TIMESTAMP WITH TIME ZONE,
  fdx_consent_id UUID,
  fdx_entity_id UUID,
  granted_at TIMESTAMP WITH TIME ZONE NOT NULL,
  ip_address INET NOT NULL,
  last_accessed_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  member_signature TEXT NOT NULL,
  revoked_at TIMESTAMP WITH TIME ZONE,
  third_party_id UUID,
  third_party_name TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.content_blocks
CREATE TABLE IF NOT EXISTS public.content_blocks (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  block_type TEXT NOT NULL,
  body TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  cta_text TEXT,
  cta_url TEXT,
  display_order NUMERIC,
  icon TEXT,
  is_published BOOLEAN,
  metadata JSONB,
  tenant_key TEXT NOT NULL,
  title TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.conversations
CREATE TABLE IF NOT EXISTS public.conversations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  advocate_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  first_response_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  priority TEXT,
  resolved_at TIMESTAMP WITH TIME ZONE,
  satisfaction_rating NUMERIC,
  status TEXT,
  tags TEXT[],
  title TEXT,
  type TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);

-- Table: public.credit_card_transactions
CREATE TABLE IF NOT EXISTS public.credit_card_transactions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount_cents NUMERIC NOT NULL,
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_card_id UUID NOT NULL,
  description TEXT,
  member_id UUID NOT NULL,
  merchant_name TEXT NOT NULL,
  posted_date TIMESTAMP WITH TIME ZONE,
  status TEXT,
  transaction_date TIMESTAMP WITH TIME ZONE NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.credit_cards
CREATE TABLE IF NOT EXISTS public.credit_cards (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  available_credit_cents NUMERIC NOT NULL,
  card_number TEXT NOT NULL,
  card_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_limit_cents NUMERIC NOT NULL,
  current_balance_cents NUMERIC NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE,
  interest_rate NUMERIC NOT NULL,
  issued_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  minimum_payment_cents NUMERIC NOT NULL,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.credit_scores
CREATE TABLE IF NOT EXISTS public.credit_scores (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  bureau TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  factors JSONB,
  member_id UUID NOT NULL,
  report_date TIMESTAMP WITH TIME ZONE NOT NULL,
  score NUMERIC NOT NULL,
  score_type TEXT NOT NULL
);

-- Table: public.credit_unions
CREATE TABLE IF NOT EXISTS public.credit_unions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  ai_readiness_score NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  current_rating NUMERIC,
  name TEXT NOT NULL,
  potential_savings NUMERIC,
  state_id NUMERIC NOT NULL,
  total_members NUMERIC,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.cu_admins
CREATE TABLE IF NOT EXISTS public.cu_admins (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  access_granted_by TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  department TEXT,
  employee_id UUID NOT NULL,
  is_active BOOLEAN,
  permission_level TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID
);

-- Table: public.cu_animation_chunks
CREATE TABLE IF NOT EXISTS public.cu_animation_chunks (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  api_call BOOLEAN,
  chunk_id UUID NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  database_operation BOOLEAN,
  duration_ms NUMERIC,
  entities JSONB,
  frame_end NUMERIC,
  frame_start NUMERIC,
  interaction_type TEXT,
  keywords TEXT[],
  page TEXT,
  section TEXT NOT NULL,
  subsection TEXT,
  title TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_action TEXT
);

-- Table: public.cu_api_endpoints
CREATE TABLE IF NOT EXISTS public.cu_api_endpoints (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  auth_config JSONB,
  auth_required BOOLEAN,
  base_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  cu_id UUID NOT NULL,
  default_headers JSONB,
  deprecated_at TIMESTAMP WITH TIME ZONE,
  endpoint_key TEXT NOT NULL,
  is_active BOOLEAN,
  is_deprecated BOOLEAN,
  method TEXT NOT NULL,
  optional_params TEXT[],
  path TEXT NOT NULL,
  rate_limit_per_hour NUMERIC,
  rate_limit_per_minute NUMERIC,
  request_schema JSONB,
  required_params TEXT[],
  response_schema JSONB,
  sunset_date TIMESTAMP WITH TIME ZONE,
  timeout_seconds NUMERIC,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.cu_configurations
CREATE TABLE IF NOT EXISTS public.cu_configurations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  api_base_url TEXT,
  api_version TEXT,
  auth_method TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  cu_code TEXT NOT NULL,
  cu_name TEXT NOT NULL,
  display_name TEXT NOT NULL,
  email TEXT,
  institution_code TEXT,
  is_active BOOLEAN,
  is_sandbox BOOLEAN,
  last_sync_at TIMESTAMP WITH TIME ZONE,
  logo_url TEXT,
  metadata JSONB,
  phone TEXT,
  primary_color TEXT,
  rate_limit_per_hour NUMERIC,
  rate_limit_per_minute NUMERIC,
  routing_number TEXT,
  secondary_color TEXT,
  settings JSONB,
  swift_code TEXT,
  theme_config JSONB,
  updated_at TIMESTAMP WITH TIME ZONE,
  website TEXT
);

-- Table: public.cu_feature_flags
CREATE TABLE IF NOT EXISTS public.cu_feature_flags (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  cu_id UUID NOT NULL,
  default_value TEXT,
  description TEXT,
  flag_key TEXT NOT NULL,
  flag_name TEXT NOT NULL,
  flag_type TEXT,
  is_enabled BOOLEAN,
  metadata JSONB,
  rollout_percentage NUMERIC,
  targeting_rules JSONB,
  updated_at TIMESTAMP WITH TIME ZONE,
  variations JSONB
);

-- Table: public.cu_monthly_usage
CREATE TABLE IF NOT EXISTS public.cu_monthly_usage (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  api_calls NUMERIC,
  api_calls_overage NUMERIC,
  bandwidth_used_mb NUMERIC,
  base_subscription_charge NUMERIC,
  content_generations NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  cu_id UUID NOT NULL,
  deployments NUMERIC,
  invoice_id UUID,
  invoice_status TEXT,
  month TEXT NOT NULL,
  overage_charges NUMERIC,
  reported_revenue NUMERIC,
  revenue_share_owed NUMERIC,
  storage_used_mb NUMERIC,
  total_builds NUMERIC,
  total_charges NUMERIC,
  total_deployments NUMERIC,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.cu_product_marketing_configs
CREATE TABLE IF NOT EXISTS public.cu_product_marketing_configs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  badge_text TEXT,
  benefits JSONB,
  call_to_action TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_union_id UUID NOT NULL,
  description TEXT,
  display_name TEXT,
  display_order NUMERIC,
  features JSONB,
  is_enabled BOOLEAN,
  is_hidden BOOLEAN,
  marketing_copy TEXT,
  product_code TEXT NOT NULL,
  promotional_text TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.cu_subscriptions
CREATE TABLE IF NOT EXISTS public.cu_subscriptions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  activated_at TIMESTAMP WITH TIME ZONE,
  billing_cycle TEXT NOT NULL,
  cancellation_reason TEXT,
  cancelled_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  cu_id UUID NOT NULL,
  current_period_end TEXT NOT NULL,
  current_period_start TEXT NOT NULL,
  custom_features JSONB,
  custom_limits JSONB,
  is_trial BOOLEAN,
  last_content_generation_at TIMESTAMP WITH TIME ZONE,
  last_deployment_at TIMESTAMP WITH TIME ZONE,
  last_heartbeat_at TIMESTAMP WITH TIME ZONE,
  license_key TEXT NOT NULL,
  license_type TEXT NOT NULL,
  notes TEXT,
  plan_id UUID NOT NULL,
  status TEXT NOT NULL,
  trial_ends_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.cu_usage_logs
CREATE TABLE IF NOT EXISTS public.cu_usage_logs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  api_calls NUMERIC,
  bandwidth_used_mb NUMERIC,
  cu_id UUID NOT NULL,
  event_action TEXT,
  event_metadata JSONB,
  event_type TEXT NOT NULL,
  logged_at TIMESTAMP WITH TIME ZONE,
  source TEXT,
  source_ip BYTEA NOT NULL,
  source_version TEXT,
  storage_used_mb NUMERIC,
  subscription_id UUID,
  user_agent TEXT,
  window_end TEXT,
  window_start TEXT
);

-- Table: public.cursor_events
CREATE TABLE IF NOT EXISTS public.cursor_events (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  duration_ms NUMERIC,
  element_selector TEXT,
  event_type TEXT NOT NULL,
  interaction_zone TEXT,
  page_url TEXT NOT NULL,
  session_id UUID NOT NULL,
  timestamp TEXT NOT NULL,
  user_id UUID NOT NULL,
  viewport_height NUMERIC,
  viewport_width NUMERIC
);

-- Table: public.data_access_events
CREATE TABLE IF NOT EXISTS public.data_access_events (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  action TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  entity_id UUID,
  entity_schema TEXT NOT NULL,
  entity_table TEXT NOT NULL,
  metadata JSONB,
  org_id UUID NOT NULL,
  profile_id UUID
);

-- Table: public.data_export_requests
CREATE TABLE IF NOT EXISTS public.data_export_requests (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_ids TEXT[],
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  data_scope TEXT[] NOT NULL,
  delivery_method TEXT NOT NULL,
  download_expires_at TIMESTAMP WITH TIME ZONE,
  download_url TEXT,
  error_message TEXT,
  estimated_completion_at TIMESTAMP WITH TIME ZONE,
  file_size_bytes NUMERIC,
  format TEXT NOT NULL,
  member_id UUID NOT NULL,
  progress_percent NUMERIC,
  record_count NUMERIC,
  request_id UUID NOT NULL,
  request_type TEXT NOT NULL,
  requested_by TEXT NOT NULL,
  retry_count NUMERIC,
  status TEXT NOT NULL,
  time_range_end TEXT,
  time_range_start TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.data_retention_policies
CREATE TABLE IF NOT EXISTS public.data_retention_policies (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  archive_before_delete BOOLEAN,
  archive_location TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  delete_cascade BOOLEAN,
  is_active BOOLEAN,
  last_run_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  next_run_at TIMESTAMP WITH TIME ZONE,
  retention_period_days NUMERIC NOT NULL,
  table_name TEXT NOT NULL,
  tenant_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.deployments
CREATE TABLE IF NOT EXISTS public.deployments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  deployed_at TIMESTAMP WITH TIME ZONE,
  deployed_by TEXT,
  edge_function_id UUID,
  error_message TEXT,
  metadata JSONB,
  status TEXT,
  version NUMERIC NOT NULL
);

-- Table: public.deposits
CREATE TABLE IF NOT EXISTS public.deposits (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  amount_cents NUMERIC NOT NULL,
  check_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  deposit_date TIMESTAMP WITH TIME ZONE,
  deposit_method TEXT,
  deposit_number TEXT NOT NULL,
  deposit_type TEXT NOT NULL,
  member_id UUID NOT NULL,
  posted_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.design_faqs
CREATE TABLE IF NOT EXISTS public.design_faqs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  answer TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  display_order NUMERIC,
  figma_file_url TEXT,
  question TEXT NOT NULL,
  tags TEXT[],
  tool TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  visual_example_url TEXT
);

-- Table: public.design_system_tests
CREATE TABLE IF NOT EXISTS public.design_system_tests (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  accessibility_tests JSONB NOT NULL,
  component_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  information_architecture JSONB NOT NULL,
  test_script JSONB NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  usage_examples JSONB NOT NULL,
  variants JSONB NOT NULL
);

-- Table: public.design_tokens
CREATE TABLE IF NOT EXISTS public.design_tokens (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN,
  tenant_id UUID,
  token_name TEXT NOT NULL,
  token_type TEXT NOT NULL,
  token_value TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.developer_faqs
CREATE TABLE IF NOT EXISTS public.developer_faqs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  answer TEXT NOT NULL,
  category TEXT NOT NULL,
  code_example TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  deprecated_reason TEXT,
  difficulty_level TEXT,
  display_order NUMERIC,
  is_deprecated BOOLEAN,
  programming_language TEXT,
  question TEXT NOT NULL,
  related_docs TEXT[],
  tags TEXT[],
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.document_management
CREATE TABLE IF NOT EXISTS public.document_management (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  document_name TEXT NOT NULL,
  document_type TEXT NOT NULL,
  expiration_date TIMESTAMP WITH TIME ZONE,
  file_path TEXT NOT NULL,
  file_size NUMERIC NOT NULL,
  is_verified BOOLEAN,
  member_id UUID NOT NULL,
  mime_type TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  upload_date TIMESTAMP WITH TIME ZONE,
  verified_at TIMESTAMP WITH TIME ZONE,
  verified_by TEXT
);

-- Table: public.document_metadata
CREATE TABLE IF NOT EXISTS public.document_metadata (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  fps NUMERIC,
  performance_target TEXT,
  sections NUMERIC,
  timestamp TEXT NOT NULL,
  title TEXT NOT NULL,
  total_chunks NUMERIC,
  total_duration_ms NUMERIC,
  total_frames NUMERIC,
  version TEXT NOT NULL
);

-- Table: public.document_storage
CREATE TABLE IF NOT EXISTS public.document_storage (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  document_name TEXT NOT NULL,
  document_type TEXT NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE,
  file_path TEXT NOT NULL,
  file_size NUMERIC,
  member_id UUID,
  mime_type TEXT,
  uploaded_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.edge_functions
CREATE TABLE IF NOT EXISTS public.edge_functions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  code TEXT NOT NULL,
  config JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  deployed_at TIMESTAMP WITH TIME ZONE,
  name TEXT NOT NULL,
  slug TEXT NOT NULL,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  version NUMERIC
);

-- Table: public.emotion_events
CREATE TABLE IF NOT EXISTS public.emotion_events (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  call_sid TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  cryptographic_hash TEXT NOT NULL,
  delta JSONB NOT NULL,
  event_id UUID NOT NULL,
  metadata JSONB,
  new_state JSONB NOT NULL,
  previous_hash TEXT,
  previous_state JSONB,
  signature TEXT NOT NULL,
  timestamp TEXT NOT NULL
);

-- Table: public.employee_directory
CREATE TABLE IF NOT EXISTS public.employee_directory (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  branch_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  department TEXT NOT NULL,
  email TEXT NOT NULL,
  employee_id UUID NOT NULL,
  first_name TEXT NOT NULL,
  hire_date TIMESTAMP WITH TIME ZONE NOT NULL,
  is_active BOOLEAN,
  last_name TEXT NOT NULL,
  phone TEXT,
  position TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.employees
CREATE TABLE IF NOT EXISTS public.employees (
  created_at TIMESTAMP WITH TIME ZONE,
  current_calls NUMERIC,
  department TEXT NOT NULL,
  direct_line TEXT,
  employee_id UUID NOT NULL,
  max_calls NUMERIC,
  name TEXT NOT NULL,
  specialties TEXT[],
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.enum_labels
CREATE TABLE IF NOT EXISTS public.enum_labels (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  color_hex TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  display_label TEXT NOT NULL,
  enum_type TEXT NOT NULL,
  enum_value TEXT NOT NULL,
  icon_name TEXT,
  order_index NUMERIC,
  string_key TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.event_registrations
CREATE TABLE IF NOT EXISTS public.event_registrations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  attendance_status TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  event_id UUID NOT NULL,
  member_id UUID NOT NULL,
  notes TEXT,
  registration_date TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.event_snapshots
CREATE TABLE IF NOT EXISTS public.event_snapshots (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  aggregate_id UUID NOT NULL,
  aggregate_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  sequence_number NUMERIC NOT NULL,
  snapshot_data JSONB NOT NULL,
  tenant_id UUID
);

-- Table: public.event_store
CREATE TABLE IF NOT EXISTS public.event_store (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  aggregate_id UUID NOT NULL,
  aggregate_type TEXT NOT NULL,
  caused_by_event_id UUID,
  caused_by_user_id UUID,
  correlation_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  event_data JSONB NOT NULL,
  event_type TEXT NOT NULL,
  event_version NUMERIC,
  is_snapshot BOOLEAN,
  metadata JSONB,
  sequence_number NUMERIC NOT NULL,
  stream_position NUMERIC,
  tenant_id UUID
);

-- Table: public.event_subscriptions
CREATE TABLE IF NOT EXISTS public.event_subscriptions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  destination_queue TEXT,
  destination_url TEXT,
  event_types TEXT[],
  failure_count NUMERIC,
  filter_expression TEXT,
  is_active BOOLEAN,
  last_processed_at TIMESTAMP WITH TIME ZONE,
  last_processed_event_id UUID,
  metadata JSONB,
  subscriber_name TEXT NOT NULL,
  subscriber_type TEXT NOT NULL,
  tenant_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.expense_categories
CREATE TABLE IF NOT EXISTS public.expense_categories (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  budget_code TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  is_active BOOLEAN,
  keywords TEXT[],
  max_amount NUMERIC,
  name TEXT NOT NULL,
  org_id UUID NOT NULL,
  org_id_norm TEXT,
  organization_id UUID NOT NULL,
  requires_approval BOOLEAN,
  requires_receipt BOOLEAN,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.expense_report_items
CREATE TABLE IF NOT EXISTS public.expense_report_items (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  expense_id UUID NOT NULL,
  expense_report_id UUID NOT NULL,
  notes TEXT
);

-- Table: public.expense_reports
CREATE TABLE IF NOT EXISTS public.expense_reports (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  approved_amount NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  generated_report TEXT,
  generated_summary TEXT,
  org_id UUID NOT NULL,
  organization_id UUID NOT NULL,
  profile_id UUID NOT NULL,
  report_period_end TEXT NOT NULL,
  report_period_start TEXT NOT NULL,
  review_notes TEXT,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  reviewed_by TEXT,
  status TEXT,
  submitted_at TIMESTAMP WITH TIME ZONE,
  title TEXT NOT NULL,
  total_amount NUMERIC NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.expense_requests
CREATE TABLE IF NOT EXISTS public.expense_requests (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount NUMERIC NOT NULL,
  approved_at TIMESTAMP WITH TIME ZONE,
  approved_by TEXT,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT NOT NULL,
  notes TEXT,
  purchase_date TIMESTAMP WITH TIME ZONE NOT NULL,
  receipt_image_url TEXT,
  reimbursed_at TIMESTAMP WITH TIME ZONE,
  rejection_reason TEXT,
  status TEXT NOT NULL,
  submitted_at TIMESTAMP WITH TIME ZONE,
  teacher_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.expenses
CREATE TABLE IF NOT EXISTS public.expenses (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount NUMERIC NOT NULL,
  budget_code TEXT,
  category TEXT NOT NULL,
  confidence_score NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  currency TEXT,
  description TEXT,
  extracted_data JSONB,
  merchant TEXT NOT NULL,
  org_id UUID NOT NULL,
  organization_id UUID NOT NULL,
  profile_id UUID NOT NULL,
  purchase_date TIMESTAMP WITH TIME ZONE NOT NULL,
  receipt_image_url TEXT,
  receipt_metadata JSONB,
  reimbursement_amount NUMERIC,
  reimbursement_date TIMESTAMP WITH TIME ZONE,
  reimbursement_status TEXT,
  subcategory TEXT,
  tags TEXT[],
  updated_at TIMESTAMP WITH TIME ZONE,
  validated_at TIMESTAMP WITH TIME ZONE,
  validated_by TEXT,
  validation_notes TEXT,
  validation_status TEXT
);

-- Table: public.export_jobs
CREATE TABLE IF NOT EXISTS public.export_jobs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  created_by_ip BYTEA NOT NULL,
  date_range_end TEXT NOT NULL,
  date_range_start TEXT NOT NULL,
  error_details JSONB,
  error_message TEXT,
  expires_at TIMESTAMP WITH TIME ZONE,
  file_size_bytes NUMERIC,
  format TEXT NOT NULL,
  include_accounts BOOLEAN NOT NULL,
  include_transactions BOOLEAN NOT NULL,
  metadata JSONB,
  organization_id UUID NOT NULL,
  progress_percent NUMERIC,
  record_count NUMERIC,
  started_at TIMESTAMP WITH TIME ZONE,
  status TEXT NOT NULL,
  storage_path TEXT,
  tenant_daily_count NUMERIC,
  tenant_monthly_count NUMERIC,
  user_id UUID NOT NULL
);

-- Table: public.export_rate_limits
CREATE TABLE IF NOT EXISTS public.export_rate_limits (
  export_count NUMERIC NOT NULL,
  last_reset_at TIMESTAMP WITH TIME ZONE NOT NULL,
  limit_date TIMESTAMP WITH TIME ZONE NOT NULL,
  limit_type TEXT NOT NULL,
  organization_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: public.external_accounts
CREATE TABLE IF NOT EXISTS public.external_accounts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_name TEXT,
  account_number_encrypted TEXT NOT NULL,
  account_type TEXT NOT NULL,
  bank_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  linked_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  routing_number TEXT,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.feature_content_cache
CREATE TABLE IF NOT EXISTS public.feature_content_cache (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  cu_id UUID NOT NULL,
  feature_name TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.feature_flag_evaluations
CREATE TABLE IF NOT EXISTS public.feature_flag_evaluations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  context JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  evaluated_value TEXT,
  flag_id UUID,
  targeting_matched BOOLEAN,
  tenant_id UUID,
  user_id UUID
);

-- Table: public.feature_flags
CREATE TABLE IF NOT EXISTS public.feature_flags (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  default_value TEXT,
  description TEXT,
  flag_key TEXT NOT NULL,
  flag_name TEXT NOT NULL,
  flag_type TEXT,
  is_enabled BOOLEAN,
  metadata JSONB,
  rollout_percentage NUMERIC,
  targeting_rules JSONB,
  tenant_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE,
  variations JSONB
);

-- Table: public.feature_toggles
CREATE TABLE IF NOT EXISTS public.feature_toggles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  conditions JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  description TEXT,
  feature_key TEXT NOT NULL,
  feature_name TEXT NOT NULL,
  is_enabled BOOLEAN,
  org_id UUID NOT NULL,
  org_id_norm TEXT,
  organization_id UUID NOT NULL,
  rollout_percentage NUMERIC,
  target_membership_types TEXT[],
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.features_device
CREATE TABLE IF NOT EXISTS public.features_device (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  device_fingerprint TEXT NOT NULL,
  feature_name TEXT NOT NULL,
  feature_value NUMERIC,
  ip_address INET NOT NULL,
  member_id UUID,
  session_id UUID,
  user_agent TEXT
);

-- Table: public.features_member
CREATE TABLE IF NOT EXISTS public.features_member (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  feature_name TEXT NOT NULL,
  feature_type TEXT,
  feature_value NUMERIC,
  member_id UUID NOT NULL,
  window_end TEXT,
  window_start TEXT
);

-- Table: public.federally_insured_cus
CREATE TABLE IF NOT EXISTS public.federally_insured_cus (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  charter_number TEXT NOT NULL,
  city TEXT,
  credit_union_name TEXT NOT NULL,
  credit_union_type TEXT,
  low_income_designation TEXT,
  members TEXT,
  ncua_region NUMERIC,
  quarter NUMERIC NOT NULL,
  state TEXT,
  street TEXT,
  total_assets TEXT,
  total_loans TEXT,
  year NUMERIC NOT NULL,
  zip_code TEXT
);

-- Table: public.fee_schedules
CREATE TABLE IF NOT EXISTS public.fee_schedules (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  effective_date TIMESTAMP WITH TIME ZONE,
  fee_name TEXT NOT NULL,
  fee_type TEXT NOT NULL,
  is_active BOOLEAN,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.fees
CREATE TABLE IF NOT EXISTS public.fees (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID,
  amount_cents NUMERIC NOT NULL,
  charged_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  fee_type TEXT NOT NULL,
  member_id UUID NOT NULL,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.financial_calculators
CREATE TABLE IF NOT EXISTS public.financial_calculators (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  calculation_formula TEXT NOT NULL,
  calculator_name TEXT NOT NULL,
  calculator_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  input_fields JSONB NOT NULL,
  is_active BOOLEAN,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.financial_education
CREATE TABLE IF NOT EXISTS public.financial_education (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  difficulty_level TEXT NOT NULL,
  estimated_read_time NUMERIC,
  is_published BOOLEAN,
  published_at TIMESTAMP WITH TIME ZONE,
  title TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.financial_goals
CREATE TABLE IF NOT EXISTS public.financial_goals (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  auto_contribute BOOLEAN,
  contribution_amount NUMERIC,
  contribution_frequency TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  current_amount NUMERIC,
  goal_type TEXT,
  is_achieved BOOLEAN,
  linked_account_id UUID,
  metadata JSONB,
  name TEXT NOT NULL,
  progress_percentage NUMERIC,
  target_amount NUMERIC NOT NULL,
  target_date TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);

-- Table: public.financial_institutions
CREATE TABLE IF NOT EXISTS public.financial_institutions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  health_status TEXT,
  institution_type TEXT,
  last_sync TEXT,
  logo_url TEXT,
  metadata JSONB,
  name TEXT NOT NULL,
  routing_number TEXT,
  supported_features JSONB,
  swift_code TEXT,
  website TEXT
);

-- Table: public.financial_products
CREATE TABLE IF NOT EXISTS public.financial_products (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  interest_rate NUMERIC,
  is_active BOOLEAN,
  minimum_balance NUMERIC,
  monthly_fee NUMERIC,
  product_category TEXT,
  product_code TEXT NOT NULL,
  product_name TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.financial_recommendations
CREATE TABLE IF NOT EXISTS public.financial_recommendations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  action_required TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT NOT NULL,
  estimated_impact TEXT,
  is_completed BOOLEAN,
  is_read BOOLEAN,
  member_id UUID NOT NULL,
  priority TEXT NOT NULL,
  recommendation_type TEXT NOT NULL,
  title TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.financial_wellness_scores
CREATE TABLE IF NOT EXISTS public.financial_wellness_scores (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  budgeting_score NUMERIC NOT NULL,
  calculated_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_score NUMERIC NOT NULL,
  debt_score NUMERIC NOT NULL,
  member_id UUID NOT NULL,
  overall_score NUMERIC NOT NULL,
  saving_score NUMERIC NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.fraud_alerts
CREATE TABLE IF NOT EXISTS public.fraud_alerts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID,
  alert_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  org_id UUID NOT NULL,
  organization_id UUID NOT NULL,
  profile_id UUID,
  resolved_at TIMESTAMP WITH TIME ZONE,
  resolved_by TEXT,
  risk_score NUMERIC,
  severity TEXT NOT NULL,
  status TEXT,
  transaction_id UUID
);

-- Table: public.fraud_signals
CREATE TABLE IF NOT EXISTS public.fraud_signals (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  detected_at TIMESTAMP WITH TIME ZONE NOT NULL,
  detection_engine TEXT,
  detection_rules JSONB,
  member_id UUID,
  organization_id UUID,
  profile_id UUID,
  resolution_notes TEXT,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  reviewed_by TEXT,
  risk_score NUMERIC NOT NULL,
  severity TEXT NOT NULL,
  signal_category TEXT NOT NULL,
  signal_data JSONB,
  signal_type TEXT NOT NULL,
  status TEXT NOT NULL,
  transaction_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: public.global_widget_analytics
CREATE TABLE IF NOT EXISTS public.global_widget_analytics (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  conversion_value NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  event_type TEXT NOT NULL,
  funnel_stage TEXT,
  journey_step TEXT,
  metadata JSONB,
  session_id UUID,
  tenant_id UUID,
  user_id UUID,
  widget_id UUID,
  widget_type TEXT NOT NULL
);

-- Table: public.insights
CREATE TABLE IF NOT EXISTS public.insights (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  action_items JSONB,
  amount_impact NUMERIC,
  confidence_score NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE,
  insight_type TEXT NOT NULL,
  is_dismissed BOOLEAN,
  is_read BOOLEAN,
  metadata JSONB,
  potential_savings NUMERIC,
  related_accounts TEXT[],
  related_transactions TEXT[],
  severity TEXT,
  title TEXT NOT NULL,
  user_id UUID NOT NULL
);

-- Table: public.insurance_claims
CREATE TABLE IF NOT EXISTS public.insurance_claims (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  claim_amount_cents NUMERIC NOT NULL,
  claim_number TEXT NOT NULL,
  claim_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  deductible_amount_cents NUMERIC NOT NULL,
  incident_date TIMESTAMP WITH TIME ZONE NOT NULL,
  member_id UUID NOT NULL,
  policy_id UUID NOT NULL,
  resolved_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  submitted_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.insurance_policies
CREATE TABLE IF NOT EXISTS public.insurance_policies (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  coverage_amount_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  effective_date TIMESTAMP WITH TIME ZONE NOT NULL,
  expiration_date TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  policy_number TEXT NOT NULL,
  policy_type TEXT NOT NULL,
  premium_amount_cents NUMERIC NOT NULL,
  premium_frequency TEXT NOT NULL,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.interest_rates
CREATE TABLE IF NOT EXISTS public.interest_rates (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  effective_date TIMESTAMP WITH TIME ZONE,
  rate_type TEXT NOT NULL,
  rate_value NUMERIC NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.interface_bindings
CREATE TABLE IF NOT EXISTS public.interface_bindings (
  binding_data JSONB NOT NULL,
  binding_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  interface_key TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.interface_params
CREATE TABLE IF NOT EXISTS public.interface_params (
  created_at TIMESTAMP WITH TIME ZONE,
  default_value JSONB,
  description TEXT,
  interface_key TEXT NOT NULL,
  param_key TEXT NOT NULL,
  required BOOLEAN,
  source_of_truth TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  value_type TEXT NOT NULL,
  visibility TEXT NOT NULL
);

-- Table: public.interfaces
CREATE TABLE IF NOT EXISTS public.interfaces (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  contract JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  docs JSONB NOT NULL,
  governance JSONB NOT NULL,
  key TEXT NOT NULL,
  locator JSONB NOT NULL,
  pillar_key TEXT,
  type TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  version TEXT
);

-- Table: public.investment_accounts
CREATE TABLE IF NOT EXISTS public.investment_accounts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_number TEXT NOT NULL,
  account_type TEXT NOT NULL,
  balance_cents NUMERIC NOT NULL,
  contribution_limit_cents NUMERIC,
  contribution_year NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  opened_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.investment_holdings
CREATE TABLE IF NOT EXISTS public.investment_holdings (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  cost_basis_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  current_value_cents NUMERIC NOT NULL,
  investment_account_id UUID NOT NULL,
  last_updated TEXT,
  purchase_date TIMESTAMP WITH TIME ZONE NOT NULL,
  shares NUMERIC NOT NULL,
  symbol TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.iso20022_account_statements
CREATE TABLE IF NOT EXISTS public.iso20022_account_statements (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_iban TEXT,
  account_id UUID,
  account_other TEXT,
  balance_type TEXT,
  closing_balance NUMERIC,
  closing_balance_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  currency_code TEXT,
  entry_count NUMERIC,
  from_date TIMESTAMP WITH TIME ZONE,
  message_id UUID,
  metadata JSONB,
  opening_balance NUMERIC,
  opening_balance_date TIMESTAMP WITH TIME ZONE,
  statement_date TIMESTAMP WITH TIME ZONE NOT NULL,
  statement_id UUID NOT NULL,
  tenant_id UUID,
  to_date TIMESTAMP WITH TIME ZONE,
  total_credit_amount NUMERIC,
  total_debit_amount NUMERIC
);

-- Table: public.iso20022_credit_transfers
CREATE TABLE IF NOT EXISTS public.iso20022_credit_transfers (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  charge_bearer TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  creditor_account TEXT,
  creditor_agent_bic TEXT,
  creditor_name TEXT NOT NULL,
  currency_code TEXT,
  debtor_account TEXT,
  debtor_agent_bic TEXT,
  debtor_name TEXT NOT NULL,
  end_to_end_id UUID,
  exchange_rate NUMERIC,
  instructed_amount NUMERIC,
  interbank_settlement_amount NUMERIC NOT NULL,
  interbank_settlement_date TIMESTAMP WITH TIME ZONE,
  message_id UUID,
  metadata JSONB,
  remittance_info TEXT,
  settlement_priority TEXT,
  tenant_id UUID,
  transaction_id UUID
);

-- Table: public.iso20022_direct_debits
CREATE TABLE IF NOT EXISTS public.iso20022_direct_debits (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  creditor_account_iban TEXT,
  creditor_id UUID,
  creditor_name TEXT NOT NULL,
  currency_code TEXT,
  debtor_account_iban TEXT,
  debtor_agent_bic TEXT,
  debtor_name TEXT NOT NULL,
  end_to_end_id UUID,
  instructed_amount NUMERIC NOT NULL,
  local_instrument_code TEXT,
  mandate_id UUID NOT NULL,
  mandate_signature_date TIMESTAMP WITH TIME ZONE,
  message_id UUID,
  metadata JSONB,
  payment_info_id UUID NOT NULL,
  remittance_info TEXT,
  requested_collection_date TIMESTAMP WITH TIME ZONE,
  sequence_type TEXT,
  status TEXT,
  tenant_id UUID
);

-- Table: public.iso20022_messages
CREATE TABLE IF NOT EXISTS public.iso20022_messages (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  creation_datetime TEXT NOT NULL,
  direction TEXT NOT NULL,
  last_retry_at TIMESTAMP WITH TIME ZONE,
  message_id UUID NOT NULL,
  message_type TEXT NOT NULL,
  message_version TEXT,
  metadata JSONB,
  parsed_content JSONB,
  processed_at TIMESTAMP WITH TIME ZONE,
  processing_priority TEXT,
  receiver_bic TEXT,
  related_account_id UUID,
  related_transaction_id UUID,
  retry_count NUMERIC,
  sender_bic TEXT,
  settlement_date TIMESTAMP WITH TIME ZONE,
  status TEXT,
  tenant_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE,
  validation_errors JSONB,
  validation_status TEXT,
  xml_content TEXT NOT NULL
);

-- Table: public.iso20022_payment_initiations
CREATE TABLE IF NOT EXISTS public.iso20022_payment_initiations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  batch_booking BOOLEAN,
  charge_bearer TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  creditor_account_iban TEXT,
  creditor_account_other TEXT,
  creditor_bic TEXT,
  creditor_name TEXT NOT NULL,
  currency_code TEXT,
  debtor_account_iban TEXT,
  debtor_account_other TEXT,
  debtor_name TEXT NOT NULL,
  end_to_end_id UUID,
  instructed_amount NUMERIC NOT NULL,
  message_id UUID,
  metadata JSONB,
  payment_info_id UUID NOT NULL,
  payment_method TEXT,
  purpose_code TEXT,
  remittance_info TEXT,
  requested_execution_date TIMESTAMP WITH TIME ZONE,
  status TEXT,
  tenant_id UUID
);

-- Table: public.iso20022_payment_status
CREATE TABLE IF NOT EXISTS public.iso20022_payment_status (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  acceptance_datetime TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  creditor_name TEXT,
  currency_code TEXT,
  debtor_name TEXT,
  instructed_amount NUMERIC,
  message_id UUID,
  metadata JSONB,
  original_end_to_end_id UUID,
  original_message_id UUID,
  status_reason_code TEXT,
  status_reason_info TEXT,
  tenant_id UUID,
  transaction_status TEXT NOT NULL
);

-- Table: public.iso20022_statement_entries
CREATE TABLE IF NOT EXISTS public.iso20022_statement_entries (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_servicer_reference TEXT,
  amount NUMERIC NOT NULL,
  bank_transaction_code TEXT,
  booking_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_debit_indicator TEXT NOT NULL,
  creditor_account TEXT,
  creditor_name TEXT,
  currency_code TEXT,
  debtor_account TEXT,
  debtor_name TEXT,
  end_to_end_id UUID,
  entry_reference TEXT,
  metadata JSONB,
  remittance_info TEXT,
  statement_id UUID,
  status TEXT,
  transaction_domain_code TEXT,
  transaction_family_code TEXT,
  transaction_subfamily_code TEXT,
  value_date TIMESTAMP WITH TIME ZONE
);

-- Table: public.iso20022_validation_rules
CREATE TABLE IF NOT EXISTS public.iso20022_validation_rules (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  error_code TEXT,
  error_severity TEXT,
  is_active BOOLEAN,
  message_type TEXT NOT NULL,
  metadata JSONB,
  rule_description TEXT,
  rule_name TEXT NOT NULL,
  validation_type TEXT,
  xpath_expression TEXT
);

-- Table: public.ivr_sessions
CREATE TABLE IF NOT EXISTS public.ivr_sessions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_number TEXT,
  agent_user_id UUID,
  ani TEXT,
  call_direction TEXT,
  call_sid TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  current_step TEXT,
  dnis TEXT,
  duration_seconds NUMERIC,
  ended_at TIMESTAMP WITH TIME ZONE,
  from_number TEXT NOT NULL,
  member_id UUID,
  metadata JSONB,
  queue_name TEXT,
  recording_url TEXT,
  started_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  tenant_id UUID,
  to_number TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  verification_attempts NUMERIC,
  verification_method TEXT,
  verified BOOLEAN,
  voice_risk_score NUMERIC,
  watson_session_id UUID
);

-- Table: public.job_execution_history
CREATE TABLE IF NOT EXISTS public.job_execution_history (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  duration_ms NUMERIC,
  error_message TEXT,
  error_trace TEXT,
  job_id UUID,
  metadata JSONB,
  result JSONB,
  started_at TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT NOT NULL
);

-- Table: public.kv_store_32a1062e
CREATE TABLE IF NOT EXISTS public.kv_store_32a1062e (
  key TEXT NOT NULL,
  value JSONB NOT NULL
);

-- Table: public.kyc_events
CREATE TABLE IF NOT EXISTS public.kyc_events (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  confidence_score NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  event_type TEXT NOT NULL,
  member_id UUID NOT NULL,
  provider TEXT NOT NULL,
  raw_response JSONB,
  retry_count NUMERIC,
  status TEXT NOT NULL
);

-- Table: public.license_validation_logs
CREATE TABLE IF NOT EXISTS public.license_validation_logs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  cu_id UUID,
  is_valid BOOLEAN NOT NULL,
  license_key TEXT,
  requested_feature TEXT,
  response_message TEXT,
  response_metadata JSONB,
  source TEXT,
  source_ip BYTEA NOT NULL,
  source_version TEXT,
  subscription_id UUID,
  validated_at TIMESTAMP WITH TIME ZONE,
  validation_result TEXT
);

-- Table: public.loan_applications
CREATE TABLE IF NOT EXISTS public.loan_applications (
  amount NUMERIC NOT NULL,
  application_id UUID NOT NULL,
  conditions TEXT[],
  created_at TIMESTAMP WITH TIME ZONE,
  decision TEXT NOT NULL,
  interest_rate NUMERIC,
  party_id UUID,
  purpose TEXT,
  reason TEXT,
  term_months NUMERIC,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.loan_payments
CREATE TABLE IF NOT EXISTS public.loan_payments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  interest_amount_cents NUMERIC NOT NULL,
  loan_id UUID NOT NULL,
  member_id UUID NOT NULL,
  payment_amount_cents NUMERIC NOT NULL,
  payment_date TIMESTAMP WITH TIME ZONE NOT NULL,
  principal_amount_cents NUMERIC NOT NULL,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.loans
CREATE TABLE IF NOT EXISTS public.loans (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  closed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  interest_rate NUMERIC NOT NULL,
  loan_number TEXT NOT NULL,
  loan_subtype TEXT,
  loan_type TEXT NOT NULL,
  maturity_date TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  monthly_payment_cents NUMERIC NOT NULL,
  next_payment_date TIMESTAMP WITH TIME ZONE,
  opened_at TIMESTAMP WITH TIME ZONE,
  outstanding_balance_cents NUMERIC NOT NULL,
  principal_amount_cents NUMERIC NOT NULL,
  status TEXT,
  term_months NUMERIC NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.mcc_tool_executions
CREATE TABLE IF NOT EXISTS public.mcc_tool_executions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  actor_id UUID,
  channel TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  duration_ms NUMERIC,
  execution_id UUID NOT NULL,
  input_data JSONB,
  member_id UUID,
  output_data JSONB,
  pillar_number NUMERIC,
  session_id UUID,
  status TEXT,
  tenant_id UUID,
  tool_name TEXT NOT NULL
);

-- Table: public.member_activity_logs
CREATE TABLE IF NOT EXISTS public.member_activity_logs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  activity_data JSONB,
  activity_description TEXT NOT NULL,
  activity_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  ip_address INET NOT NULL,
  member_id UUID NOT NULL,
  session_id UUID,
  user_agent TEXT
);

-- Table: public.member_alerts
CREATE TABLE IF NOT EXISTS public.member_alerts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  alert_level TEXT NOT NULL,
  alert_message TEXT NOT NULL,
  alert_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE,
  is_dismissed BOOLEAN,
  is_read BOOLEAN,
  member_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_analytics
CREATE TABLE IF NOT EXISTS public.member_analytics (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  engagement_score NUMERIC,
  event_data JSONB,
  event_type TEXT NOT NULL,
  member_id UUID,
  page_views NUMERIC,
  session_duration NUMERIC
);

-- Table: public.member_backup_codes
CREATE TABLE IF NOT EXISTS public.member_backup_codes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  backup_code TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE,
  is_used BOOLEAN,
  member_id UUID NOT NULL,
  used_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_biometrics
CREATE TABLE IF NOT EXISTS public.member_biometrics (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  biometric_data_hash TEXT NOT NULL,
  biometric_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  enrolled_at TIMESTAMP WITH TIME ZONE,
  is_enrolled BOOLEAN,
  last_used TEXT,
  member_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_consent_records
CREATE TABLE IF NOT EXISTS public.member_consent_records (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  consent_date TIMESTAMP WITH TIME ZONE,
  consent_method TEXT NOT NULL,
  consent_status TEXT NOT NULL,
  consent_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  withdrawal_date TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_debt_tracking
CREATE TABLE IF NOT EXISTS public.member_debt_tracking (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  creditor_name TEXT NOT NULL,
  current_balance_cents NUMERIC NOT NULL,
  debt_type TEXT NOT NULL,
  interest_rate NUMERIC,
  is_paid_off BOOLEAN,
  member_id UUID NOT NULL,
  minimum_payment_cents NUMERIC,
  original_balance_cents NUMERIC NOT NULL,
  payment_due_date TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_demographics
CREATE TABLE IF NOT EXISTS public.member_demographics (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  age_range TEXT,
  annual_income_range TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  education_level TEXT,
  employment_status TEXT,
  ethnicity TEXT,
  gender TEXT,
  household_size NUMERIC,
  member_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_devices
CREATE TABLE IF NOT EXISTS public.member_devices (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  app_version TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  device_id UUID NOT NULL,
  device_name TEXT,
  device_type TEXT NOT NULL,
  is_trusted BOOLEAN,
  last_used TEXT,
  member_id UUID NOT NULL,
  os_version TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_education_progress
CREATE TABLE IF NOT EXISTS public.member_education_progress (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  completed_at TIMESTAMP WITH TIME ZONE,
  completion_percentage NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  education_id UUID NOT NULL,
  is_completed BOOLEAN,
  member_id UUID NOT NULL,
  started_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_events
CREATE TABLE IF NOT EXISTS public.member_events (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  end_time TEXT,
  event_date TIMESTAMP WITH TIME ZONE NOT NULL,
  event_name TEXT NOT NULL,
  event_type TEXT NOT NULL,
  is_active BOOLEAN,
  location TEXT,
  max_attendees NUMERIC,
  registration_deadline TEXT,
  registration_required BOOLEAN,
  start_time TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_faqs
CREATE TABLE IF NOT EXISTS public.member_faqs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  answer TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  cu_id UUID NOT NULL,
  display_order NUMERIC,
  helpful_count NUMERIC,
  is_featured BOOLEAN,
  question TEXT NOT NULL,
  search_keywords TEXT[],
  tags TEXT[],
  updated_at TIMESTAMP WITH TIME ZONE,
  view_count NUMERIC
);

-- Table: public.member_feedback
CREATE TABLE IF NOT EXISTS public.member_feedback (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  feedback_type TEXT NOT NULL,
  is_resolved BOOLEAN,
  member_id UUID NOT NULL,
  message TEXT NOT NULL,
  rating NUMERIC,
  resolved_at TIMESTAMP WITH TIME ZONE,
  resolved_by TEXT,
  subject TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_alerts
CREATE TABLE IF NOT EXISTS public.member_financial_alerts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  alert_level TEXT NOT NULL,
  alert_message TEXT NOT NULL,
  alert_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE,
  is_dismissed BOOLEAN,
  is_read BOOLEAN,
  member_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_bill_pay
CREATE TABLE IF NOT EXISTS public.member_financial_bill_pay (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  frequency TEXT,
  member_id UUID NOT NULL,
  payee_account TEXT NOT NULL,
  payee_name TEXT NOT NULL,
  payment_date TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_calculators
CREATE TABLE IF NOT EXISTS public.member_financial_calculators (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  calculated_at TIMESTAMP WITH TIME ZONE,
  calculation_results JSONB NOT NULL,
  calculator_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  input_parameters JSONB NOT NULL,
  member_id UUID NOT NULL
);

-- Table: public.member_financial_credit_card_transactions
CREATE TABLE IF NOT EXISTS public.member_financial_credit_card_transactions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount_cents NUMERIC NOT NULL,
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_card_id UUID NOT NULL,
  description TEXT,
  member_id UUID NOT NULL,
  merchant_name TEXT NOT NULL,
  posted_date TIMESTAMP WITH TIME ZONE,
  status TEXT,
  transaction_date TIMESTAMP WITH TIME ZONE NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_credit_cards
CREATE TABLE IF NOT EXISTS public.member_financial_credit_cards (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  available_credit_cents NUMERIC NOT NULL,
  card_number TEXT NOT NULL,
  card_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_limit_cents NUMERIC NOT NULL,
  current_balance_cents NUMERIC NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE,
  interest_rate NUMERIC NOT NULL,
  issued_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  minimum_payment_cents NUMERIC NOT NULL,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_deposits
CREATE TABLE IF NOT EXISTS public.member_financial_deposits (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  amount_cents NUMERIC NOT NULL,
  check_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  deposit_method TEXT NOT NULL,
  deposit_type TEXT NOT NULL,
  deposited_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  processed_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_education
CREATE TABLE IF NOT EXISTS public.member_financial_education (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  completed_at TIMESTAMP WITH TIME ZONE,
  completion_percentage NUMERIC,
  content TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  education_type TEXT NOT NULL,
  is_completed BOOLEAN,
  member_id UUID NOT NULL,
  started_at TIMESTAMP WITH TIME ZONE,
  title TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_fees
CREATE TABLE IF NOT EXISTS public.member_financial_fees (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID,
  amount_cents NUMERIC NOT NULL,
  charged_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  fee_type TEXT NOT NULL,
  member_id UUID NOT NULL,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_goals
CREATE TABLE IF NOT EXISTS public.member_financial_goals (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  current_amount_cents NUMERIC,
  goal_name TEXT NOT NULL,
  goal_type TEXT NOT NULL,
  is_active BOOLEAN,
  member_id UUID NOT NULL,
  monthly_contribution_cents NUMERIC,
  target_amount_cents NUMERIC NOT NULL,
  target_date TIMESTAMP WITH TIME ZONE NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_insurance_claims
CREATE TABLE IF NOT EXISTS public.member_financial_insurance_claims (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  claim_amount_cents NUMERIC NOT NULL,
  claim_number TEXT NOT NULL,
  claim_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  deductible_amount_cents NUMERIC NOT NULL,
  incident_date TIMESTAMP WITH TIME ZONE NOT NULL,
  member_id UUID NOT NULL,
  policy_id UUID NOT NULL,
  resolved_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  submitted_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_insurance_policies
CREATE TABLE IF NOT EXISTS public.member_financial_insurance_policies (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  coverage_amount_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  effective_date TIMESTAMP WITH TIME ZONE NOT NULL,
  expiration_date TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  policy_number TEXT NOT NULL,
  policy_type TEXT NOT NULL,
  premium_amount_cents NUMERIC NOT NULL,
  premium_frequency TEXT NOT NULL,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_investment_accounts
CREATE TABLE IF NOT EXISTS public.member_financial_investment_accounts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_number TEXT NOT NULL,
  account_type TEXT NOT NULL,
  balance_cents NUMERIC NOT NULL,
  contribution_limit_cents NUMERIC,
  contribution_year NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  opened_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_investment_holdings
CREATE TABLE IF NOT EXISTS public.member_financial_investment_holdings (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  cost_basis_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  current_value_cents NUMERIC NOT NULL,
  investment_account_id UUID NOT NULL,
  last_updated TEXT,
  purchase_date TIMESTAMP WITH TIME ZONE NOT NULL,
  shares NUMERIC NOT NULL,
  symbol TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_loan_payments
CREATE TABLE IF NOT EXISTS public.member_financial_loan_payments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  interest_amount_cents NUMERIC NOT NULL,
  loan_id UUID NOT NULL,
  member_id UUID NOT NULL,
  payment_amount_cents NUMERIC NOT NULL,
  payment_date TIMESTAMP WITH TIME ZONE NOT NULL,
  principal_amount_cents NUMERIC NOT NULL,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_loans
CREATE TABLE IF NOT EXISTS public.member_financial_loans (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  interest_rate NUMERIC NOT NULL,
  loan_number TEXT NOT NULL,
  loan_type TEXT NOT NULL,
  maturity_date TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  monthly_payment_cents NUMERIC NOT NULL,
  opened_at TIMESTAMP WITH TIME ZONE,
  principal_amount_cents NUMERIC NOT NULL,
  remaining_balance_cents NUMERIC NOT NULL,
  status TEXT,
  term_months NUMERIC NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_milestones
CREATE TABLE IF NOT EXISTS public.member_financial_milestones (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  achieved_at TIMESTAMP WITH TIME ZONE,
  celebration_sent_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  is_celebrated BOOLEAN,
  member_id UUID NOT NULL,
  milestone_name TEXT NOT NULL,
  milestone_type TEXT NOT NULL,
  milestone_value TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_profile
CREATE TABLE IF NOT EXISTS public.member_financial_profile (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_score NUMERIC,
  debt_to_income_ratio NUMERIC,
  investment_experience TEXT,
  member_id UUID NOT NULL,
  monthly_expenses_cents NUMERIC,
  monthly_income_cents NUMERIC,
  net_worth_cents NUMERIC,
  risk_tolerance TEXT,
  total_assets_cents NUMERIC,
  total_liabilities_cents NUMERIC,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_recommendations
CREATE TABLE IF NOT EXISTS public.member_financial_recommendations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  action_required TEXT,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT NOT NULL,
  estimated_impact TEXT,
  is_completed BOOLEAN,
  is_read BOOLEAN,
  member_id UUID NOT NULL,
  priority TEXT NOT NULL,
  recommendation_type TEXT NOT NULL,
  title TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_reports
CREATE TABLE IF NOT EXISTS public.member_financial_reports (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  downloaded_at TIMESTAMP WITH TIME ZONE,
  generated_at TIMESTAMP WITH TIME ZONE,
  is_downloaded BOOLEAN,
  member_id UUID NOT NULL,
  report_data JSONB NOT NULL,
  report_period_end TEXT NOT NULL,
  report_period_start TEXT NOT NULL,
  report_type TEXT NOT NULL
);

-- Table: public.member_financial_tax_documents
CREATE TABLE IF NOT EXISTS public.member_financial_tax_documents (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  document_name TEXT NOT NULL,
  document_type TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_size NUMERIC NOT NULL,
  is_processed BOOLEAN,
  member_id UUID NOT NULL,
  processed_at TIMESTAMP WITH TIME ZONE,
  tax_year NUMERIC NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  upload_date TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_transactions
CREATE TABLE IF NOT EXISTS public.member_financial_transactions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  amount_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  member_id UUID NOT NULL,
  posted_at TIMESTAMP WITH TIME ZONE,
  reference_number TEXT,
  status TEXT,
  transaction_type TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_transfers
CREATE TABLE IF NOT EXISTS public.member_financial_transfers (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount_cents NUMERIC NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  from_account_id UUID NOT NULL,
  member_id UUID NOT NULL,
  scheduled_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  to_account_id UUID NOT NULL,
  transfer_type TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_financial_wellness
CREATE TABLE IF NOT EXISTS public.member_financial_wellness (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  budgeting_score NUMERIC NOT NULL,
  calculated_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_score NUMERIC NOT NULL,
  debt_score NUMERIC NOT NULL,
  investment_score NUMERIC NOT NULL,
  member_id UUID NOT NULL,
  overall_score NUMERIC NOT NULL,
  saving_score NUMERIC NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_goals_tracking
CREATE TABLE IF NOT EXISTS public.member_goals_tracking (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  current_value_cents NUMERIC,
  goal_id UUID NOT NULL,
  last_updated TEXT,
  member_id UUID NOT NULL,
  progress_percentage NUMERIC,
  target_value_cents NUMERIC NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_insurance_claims
CREATE TABLE IF NOT EXISTS public.member_insurance_claims (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  claim_amount_cents NUMERIC NOT NULL,
  claim_number TEXT NOT NULL,
  claim_status TEXT,
  claim_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  deductible_amount_cents NUMERIC NOT NULL,
  incident_date TIMESTAMP WITH TIME ZONE NOT NULL,
  member_id UUID NOT NULL,
  policy_id UUID NOT NULL,
  resolved_at TIMESTAMP WITH TIME ZONE,
  submitted_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_insurance_policies
CREATE TABLE IF NOT EXISTS public.member_insurance_policies (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  coverage_amount_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  insurance_company TEXT NOT NULL,
  is_active BOOLEAN,
  member_id UUID NOT NULL,
  policy_end_date TIMESTAMP WITH TIME ZONE,
  policy_number TEXT NOT NULL,
  policy_start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  policy_type TEXT NOT NULL,
  premium_amount_cents NUMERIC NOT NULL,
  premium_frequency TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_interactions
CREATE TABLE IF NOT EXISTS public.member_interactions (
  agent_id UUID,
  agent_type TEXT,
  channel TEXT NOT NULL,
  channel_details JSONB,
  device_id UUID,
  device_type TEXT,
  duration_seconds NUMERIC,
  feedback_text TEXT,
  interaction_category TEXT,
  interaction_details JSONB,
  interaction_type TEXT NOT NULL,
  ip_address INET NOT NULL,
  location_lat NUMERIC,
  location_lon NUMERIC,
  member_id UUID NOT NULL,
  metadata JSONB,
  resolution_status TEXT,
  response_time_ms NUMERIC,
  satisfaction_score NUMERIC,
  session_id UUID,
  time TEXT NOT NULL,
  user_agent TEXT
);

-- Table: public.member_investment_holdings
CREATE TABLE IF NOT EXISTS public.member_investment_holdings (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  cost_basis_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  current_value_cents NUMERIC NOT NULL,
  last_updated TEXT,
  portfolio_id UUID NOT NULL,
  purchase_date TIMESTAMP WITH TIME ZONE NOT NULL,
  shares NUMERIC NOT NULL,
  symbol TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_investment_portfolio
CREATE TABLE IF NOT EXISTS public.member_investment_portfolio (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  portfolio_name TEXT NOT NULL,
  portfolio_type TEXT NOT NULL,
  risk_level TEXT,
  total_cost_basis_cents NUMERIC,
  total_gain_loss_cents NUMERIC,
  total_value_cents NUMERIC,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_location_history
CREATE TABLE IF NOT EXISTS public.member_location_history (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  accuracy NUMERIC,
  activity_type TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  latitude NUMERIC NOT NULL,
  location_source TEXT,
  longitude NUMERIC NOT NULL,
  member_id UUID NOT NULL
);

-- Table: public.member_milestones
CREATE TABLE IF NOT EXISTS public.member_milestones (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  achieved_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  is_celebrated BOOLEAN,
  member_id UUID NOT NULL,
  milestone_name TEXT NOT NULL,
  milestone_type TEXT NOT NULL,
  milestone_value TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_preferences
CREATE TABLE IF NOT EXISTS public.member_preferences (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  preference_category TEXT NOT NULL,
  preference_key TEXT NOT NULL,
  preference_value TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_privacy_settings
CREATE TABLE IF NOT EXISTS public.member_privacy_settings (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  setting_category TEXT NOT NULL,
  setting_name TEXT NOT NULL,
  setting_value BOOLEAN NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_profiles
CREATE TABLE IF NOT EXISTS public.member_profiles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  display_name TEXT NOT NULL,
  interaction_count NUMERIC,
  star_rating NUMERIC,
  total_stars NUMERIC,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID
);

-- Table: public.member_recovery_questions
CREATE TABLE IF NOT EXISTS public.member_recovery_questions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  answer_hash TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN,
  member_id UUID NOT NULL,
  question_text TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_referrals
CREATE TABLE IF NOT EXISTS public.member_referrals (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  joined_at TIMESTAMP WITH TIME ZONE,
  referral_code TEXT NOT NULL,
  referral_status TEXT,
  referred_email TEXT NOT NULL,
  referred_name TEXT,
  referrer_member_id UUID NOT NULL,
  reward_amount_cents NUMERIC,
  reward_paid_at TIMESTAMP WITH TIME ZONE,
  reward_status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_rewards
CREATE TABLE IF NOT EXISTS public.member_rewards (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  earned_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  redeemed_at TIMESTAMP WITH TIME ZONE,
  reward_amount_cents NUMERIC NOT NULL,
  reward_name TEXT NOT NULL,
  reward_status TEXT,
  reward_type TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_savings_goals
CREATE TABLE IF NOT EXISTS public.member_savings_goals (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  current_amount_cents NUMERIC,
  goal_name TEXT NOT NULL,
  goal_type TEXT NOT NULL,
  is_active BOOLEAN,
  member_id UUID NOT NULL,
  monthly_contribution_cents NUMERIC,
  target_amount_cents NUMERIC NOT NULL,
  target_date TIMESTAMP WITH TIME ZONE NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_security_events
CREATE TABLE IF NOT EXISTS public.member_security_events (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  device_info JSONB,
  event_description TEXT NOT NULL,
  event_type TEXT NOT NULL,
  ip_address INET NOT NULL,
  is_resolved BOOLEAN,
  member_id UUID NOT NULL,
  resolved_at TIMESTAMP WITH TIME ZONE,
  risk_level TEXT
);

-- Table: public.member_services
CREATE TABLE IF NOT EXISTS public.member_services (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  availability_hours TEXT,
  contact_methods TEXT[],
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  is_active BOOLEAN,
  service_name TEXT NOT NULL,
  service_type TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_sessions
CREATE TABLE IF NOT EXISTS public.member_sessions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  device_info JSONB,
  ip_address INET NOT NULL,
  is_active BOOLEAN,
  last_activity TEXT,
  login_time TEXT,
  logout_time TEXT,
  member_id UUID NOT NULL,
  session_token TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_agent TEXT
);

-- Table: public.member_spending_categories
CREATE TABLE IF NOT EXISTS public.member_spending_categories (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  budget_amount_cents NUMERIC NOT NULL,
  budget_period TEXT NOT NULL,
  category_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  period_end TEXT NOT NULL,
  period_start TEXT NOT NULL,
  spent_amount_cents NUMERIC,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_spending_transactions
CREATE TABLE IF NOT EXISTS public.member_spending_transactions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount_cents NUMERIC NOT NULL,
  category_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  merchant_name TEXT,
  transaction_date TIMESTAMP WITH TIME ZONE NOT NULL,
  transaction_id UUID NOT NULL
);

-- Table: public.member_surveys
CREATE TABLE IF NOT EXISTS public.member_surveys (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  end_date TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN,
  questions JSONB NOT NULL,
  start_date TIMESTAMP WITH TIME ZONE,
  survey_name TEXT NOT NULL,
  survey_type TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.member_tax_documents
CREATE TABLE IF NOT EXISTS public.member_tax_documents (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  document_name TEXT NOT NULL,
  document_type TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_size NUMERIC NOT NULL,
  is_processed BOOLEAN,
  member_id UUID NOT NULL,
  processed_at TIMESTAMP WITH TIME ZONE,
  tax_year NUMERIC NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  upload_date TIMESTAMP WITH TIME ZONE
);

-- Table: public.members
CREATE TABLE IF NOT EXISTS public.members (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  address_line1 TEXT,
  address_line2 TEXT,
  city TEXT,
  country TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  date_of_birth TEXT,
  email TEXT NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  member_number TEXT NOT NULL,
  membership_date TIMESTAMP WITH TIME ZONE,
  middle_name TEXT,
  phone TEXT,
  risk_level risk_level_enum,
  ssn_encrypted TEXT,
  state TEXT,
  status member_status_enum,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL,
  zip_code TEXT
);

-- Table: public.members_2024
CREATE TABLE IF NOT EXISTS public.members_2024 (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  address_line1 TEXT,
  address_line2 TEXT,
  alloy_entity_id UUID,
  alloy_outcome TEXT,
  city TEXT,
  country TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  credit_score NUMERIC,
  date_of_birth TEXT,
  email TEXT NOT NULL,
  failed_login_count NUMERIC,
  first_name TEXT NOT NULL,
  identity_verified BOOLEAN,
  identity_verified_at TIMESTAMP WITH TIME ZONE,
  kyc_completed BOOLEAN,
  kyc_completed_at TIMESTAMP WITH TIME ZONE,
  last_activity TEXT,
  last_login_ip BYTEA NOT NULL,
  last_name TEXT NOT NULL,
  login_count NUMERIC,
  member_number TEXT NOT NULL,
  membership_type TEXT,
  middle_name TEXT,
  phone TEXT,
  phone_verified BOOLEAN,
  postal_code TEXT,
  risk_level TEXT,
  ssn_encrypted TEXT,
  ssn_last4 TEXT,
  state TEXT,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  updated_by TEXT
);

-- Table: public.members_2025
CREATE TABLE IF NOT EXISTS public.members_2025 (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  address_line1 TEXT,
  address_line2 TEXT,
  alloy_entity_id UUID,
  alloy_outcome TEXT,
  city TEXT,
  country TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  credit_score NUMERIC,
  date_of_birth TEXT,
  email TEXT NOT NULL,
  failed_login_count NUMERIC,
  first_name TEXT NOT NULL,
  identity_verified BOOLEAN,
  identity_verified_at TIMESTAMP WITH TIME ZONE,
  kyc_completed BOOLEAN,
  kyc_completed_at TIMESTAMP WITH TIME ZONE,
  last_activity TEXT,
  last_login_ip BYTEA NOT NULL,
  last_name TEXT NOT NULL,
  login_count NUMERIC,
  member_number TEXT NOT NULL,
  membership_type TEXT,
  middle_name TEXT,
  phone TEXT,
  phone_verified BOOLEAN,
  postal_code TEXT,
  risk_level TEXT,
  ssn_encrypted TEXT,
  ssn_last4 TEXT,
  state TEXT,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  updated_by TEXT
);

-- Table: public.members_2026
CREATE TABLE IF NOT EXISTS public.members_2026 (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  address_line1 TEXT,
  address_line2 TEXT,
  alloy_entity_id UUID,
  alloy_outcome TEXT,
  city TEXT,
  country TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  credit_score NUMERIC,
  date_of_birth TEXT,
  email TEXT NOT NULL,
  failed_login_count NUMERIC,
  first_name TEXT NOT NULL,
  identity_verified BOOLEAN,
  identity_verified_at TIMESTAMP WITH TIME ZONE,
  kyc_completed BOOLEAN,
  kyc_completed_at TIMESTAMP WITH TIME ZONE,
  last_activity TEXT,
  last_login_ip BYTEA NOT NULL,
  last_name TEXT NOT NULL,
  login_count NUMERIC,
  member_number TEXT NOT NULL,
  membership_type TEXT,
  middle_name TEXT,
  phone TEXT,
  phone_verified BOOLEAN,
  postal_code TEXT,
  risk_level TEXT,
  ssn_encrypted TEXT,
  ssn_last4 TEXT,
  state TEXT,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  updated_by TEXT
);

-- Table: public.membership_types
CREATE TABLE IF NOT EXISTS public.membership_types (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  benefits JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  display_name TEXT NOT NULL,
  fees JSONB,
  is_active BOOLEAN,
  maximum_age NUMERIC,
  minimum_age NUMERIC,
  name TEXT NOT NULL,
  org_id UUID NOT NULL,
  org_id_norm TEXT,
  organization_id UUID NOT NULL,
  requirements JSONB,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.memberships
CREATE TABLE IF NOT EXISTS public.memberships (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  can_chat BOOLEAN NOT NULL,
  can_pay BOOLEAN NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  credit_union_id UUID NOT NULL,
  user_id UUID NOT NULL
);

-- Table: public.merchants
CREATE TABLE IF NOT EXISTS public.merchants (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  is_verified BOOLEAN,
  logo_url TEXT,
  merchant_type TEXT,
  metadata JSONB,
  name TEXT NOT NULL,
  normalized_name TEXT NOT NULL,
  total_spent NUMERIC,
  transaction_count NUMERIC,
  website TEXT
);

-- Table: public.message_queue
CREATE TABLE IF NOT EXISTS public.message_queue (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  error_message TEXT,
  error_trace TEXT,
  max_retries NUMERIC,
  message_type TEXT NOT NULL,
  metadata JSONB,
  payload JSONB NOT NULL,
  priority NUMERIC,
  queue_name TEXT NOT NULL,
  retry_count NUMERIC,
  scheduled_for TEXT,
  started_processing_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  tenant_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.messages
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  attachments JSONB,
  content TEXT NOT NULL,
  conversation_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  edited_at TIMESTAMP WITH TIME ZONE,
  is_deleted BOOLEAN,
  is_edited BOOLEAN,
  message_type TEXT,
  metadata JSONB,
  sender_id UUID,
  sender_name TEXT,
  sender_type TEXT NOT NULL
);

-- Table: public.mfa_enrollments
CREATE TABLE IF NOT EXISTS public.mfa_enrollments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  method TEXT NOT NULL,
  secret TEXT NOT NULL,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);

-- Table: public.mfa_tokens
CREATE TABLE IF NOT EXISTS public.mfa_tokens (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  attempts NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  email TEXT,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  party_id UUID NOT NULL,
  phone_number TEXT,
  token_type TEXT NOT NULL,
  token_value TEXT NOT NULL,
  used_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.mobile_deposits
CREATE TABLE IF NOT EXISTS public.mobile_deposits (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  amount_cents NUMERIC NOT NULL,
  check_back_image TEXT,
  check_front_image TEXT,
  check_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  deposit_date TIMESTAMP WITH TIME ZONE,
  deposit_id UUID NOT NULL,
  member_id UUID NOT NULL,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.ncua_minimal
CREATE TABLE IF NOT EXISTS public.ncua_minimal (
  charter_number NUMERIC,
  city TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  join_number NUMERIC NOT NULL,
  members NUMERIC,
  name TEXT NOT NULL,
  state TEXT,
  street TEXT,
  total_assets NUMERIC,
  zip TEXT
);

-- Table: public.notification_templates
CREATE TABLE IF NOT EXISTS public.notification_templates (
  body_string_key TEXT,
  channel TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN,
  subject_string_key TEXT,
  template_key TEXT NOT NULL,
  template_name TEXT NOT NULL,
  template_type TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  variables JSONB
);

-- Table: public.notifications
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  is_read BOOLEAN,
  member_id UUID NOT NULL,
  message TEXT NOT NULL,
  notification_type TEXT NOT NULL,
  read_at TIMESTAMP WITH TIME ZONE,
  sent_at TIMESTAMP WITH TIME ZONE,
  title TEXT NOT NULL
);

-- Table: public.oauth_access_tokens
CREATE TABLE IF NOT EXISTS public.oauth_access_tokens (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  is_revoked BOOLEAN,
  last_used_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  revocation_reason TEXT,
  revoked_at TIMESTAMP WITH TIME ZONE,
  scopes TEXT[],
  tenant_id UUID,
  token TEXT NOT NULL,
  usage_count NUMERIC,
  user_id UUID
);

-- Table: public.oauth_authorization_codes
CREATE TABLE IF NOT EXISTS public.oauth_authorization_codes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id UUID NOT NULL,
  code TEXT NOT NULL,
  code_challenge TEXT,
  code_challenge_method TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  is_used BOOLEAN,
  redirect_uri TEXT NOT NULL,
  scopes TEXT[],
  tenant_id UUID,
  used_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);

-- Table: public.oauth_clients
CREATE TABLE IF NOT EXISTS public.oauth_clients (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  allowed_scopes TEXT[],
  client_id UUID NOT NULL,
  client_name TEXT NOT NULL,
  client_secret_hash TEXT NOT NULL,
  client_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  grant_types TEXT[],
  is_active BOOLEAN,
  is_first_party BOOLEAN,
  metadata JSONB,
  redirect_uris TEXT[],
  tenant_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.oauth_refresh_tokens
CREATE TABLE IF NOT EXISTS public.oauth_refresh_tokens (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  access_token_id UUID,
  client_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  is_revoked BOOLEAN,
  last_used_at TIMESTAMP WITH TIME ZONE,
  revoked_at TIMESTAMP WITH TIME ZONE,
  scopes TEXT[],
  tenant_id UUID,
  token TEXT NOT NULL,
  usage_count NUMERIC,
  user_id UUID
);

-- Table: public.object_tokens
CREATE TABLE IF NOT EXISTS public.object_tokens (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  analytics_funnel JSONB,
  completion_criteria JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  data_flow JSONB,
  description TEXT,
  display_name TEXT NOT NULL,
  navigation_rules JSONB,
  object_key TEXT NOT NULL,
  object_type TEXT NOT NULL,
  screen_sequence JSONB NOT NULL,
  state_machine JSONB,
  updated_at TIMESTAMP WITH TIME ZONE,
  version TEXT
);

-- Table: public.omni_channel_mappings
CREATE TABLE IF NOT EXISTS public.omni_channel_mappings (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  channel_type TEXT NOT NULL,
  interaction_data JSONB,
  session_id UUID,
  timestamp TEXT,
  user_id UUID NOT NULL
);

-- Table: public.online_users
CREATE TABLE IF NOT EXISTS public.online_users (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  cursor_x NUMERIC,
  cursor_y NUMERIC,
  last_seen TEXT,
  room_id UUID,
  user_id UUID
);

-- Table: public.org_usage_counters
CREATE TABLE IF NOT EXISTS public.org_usage_counters (
  count NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  day TEXT NOT NULL,
  metric TEXT NOT NULL,
  org_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: public.organizations
CREATE TABLE IF NOT EXISTS public.organizations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  address JSONB,
  charter_number TEXT,
  contact_info JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  domain TEXT,
  feature_flags JSONB,
  is_active BOOLEAN,
  logo_url TEXT,
  name TEXT NOT NULL,
  ncua_number TEXT,
  primary_color TEXT,
  routing_number TEXT,
  secondary_color TEXT,
  settings JSONB,
  slug TEXT NOT NULL,
  subscription_tier TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.parties
CREATE TABLE IF NOT EXISTS public.parties (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  email TEXT,
  external_id UUID,
  metadata JSONB,
  name TEXT,
  party_id UUID,
  party_type TEXT NOT NULL,
  phone TEXT,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.pattern_tokens
CREATE TABLE IF NOT EXISTS public.pattern_tokens (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  component_tree JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  dependencies JSONB,
  description TEXT,
  display_name TEXT NOT NULL,
  event_handlers JSONB,
  pattern_key TEXT NOT NULL,
  pattern_type TEXT NOT NULL,
  state_machine JSONB,
  updated_at TIMESTAMP WITH TIME ZONE,
  validation_rules JSONB,
  version TEXT
);

-- Table: public.payees
CREATE TABLE IF NOT EXISTS public.payees (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  email TEXT,
  name TEXT NOT NULL,
  phone TEXT,
  routing_number TEXT,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  user_id UUID NOT NULL
);

-- Table: public.payment_methods
CREATE TABLE IF NOT EXISTS public.payment_methods (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_number TEXT,
  card_brand TEXT,
  card_last_four TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  expiry_month NUMERIC,
  expiry_year NUMERIC,
  is_active BOOLEAN,
  is_default BOOLEAN,
  member_id UUID NOT NULL,
  method_type TEXT NOT NULL,
  provider TEXT NOT NULL,
  routing_number TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.payments
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  amount_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  loan_id UUID,
  member_id UUID NOT NULL,
  payment_date TIMESTAMP WITH TIME ZONE,
  payment_method TEXT,
  payment_number TEXT NOT NULL,
  payment_type TEXT NOT NULL,
  posted_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.pillars
CREATE TABLE IF NOT EXISTS public.pillars (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  adapter_access TEXT[],
  annual_price NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  display_order NUMERIC,
  features JSONB,
  is_active BOOLEAN,
  max_adapters NUMERIC,
  metadata JSONB,
  monthly_price NUMERIC,
  pillar_code TEXT NOT NULL,
  pillar_name TEXT NOT NULL,
  stripe_price_id_annual TEXT,
  stripe_price_id_monthly TEXT,
  stripe_product_id UUID,
  subscription_plan_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.platform_metrics
CREATE TABLE IF NOT EXISTS public.platform_metrics (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  dimensions JSONB,
  metric_name TEXT NOT NULL,
  metric_type TEXT NOT NULL,
  metric_value NUMERIC,
  timestamp TEXT
);

-- Table: public.playback_sessions
CREATE TABLE IF NOT EXISTS public.playback_sessions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  completion_rate NUMERIC,
  duration_seconds NUMERIC,
  ended_at TIMESTAMP WITH TIME ZONE,
  interactions_count NUMERIC,
  member_id UUID,
  metadata JSONB,
  quality_score NUMERIC,
  session_type TEXT NOT NULL,
  started_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.preferences
CREATE TABLE IF NOT EXISTS public.preferences (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  preference_key TEXT NOT NULL,
  preference_value JSONB NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.product_applications
CREATE TABLE IF NOT EXISTS public.product_applications (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  application_data JSONB NOT NULL,
  application_status TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  decision_reason TEXT,
  member_id UUID NOT NULL,
  product_id UUID NOT NULL,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  reviewed_by TEXT,
  submitted_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.product_catalog
CREATE TABLE IF NOT EXISTS public.product_catalog (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  benefits TEXT[],
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  features TEXT[],
  fees JSONB,
  is_active BOOLEAN,
  launch_date TIMESTAMP WITH TIME ZONE,
  product_code TEXT NOT NULL,
  product_name TEXT NOT NULL,
  product_type TEXT NOT NULL,
  rates JSONB,
  requirements JSONB,
  sunset_date TIMESTAMP WITH TIME ZONE,
  terms JSONB,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.product_categories
CREATE TABLE IF NOT EXISTS public.product_categories (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category_code TEXT NOT NULL,
  category_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  display_order NUMERIC,
  is_active BOOLEAN,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.product_features
CREATE TABLE IF NOT EXISTS public.product_features (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  feature_name TEXT NOT NULL,
  feature_value TEXT,
  is_premium BOOLEAN,
  product_id UUID
);

-- Table: public.profiles
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  address JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  date_of_birth TEXT,
  emergency_contact JSONB,
  employment_info JSONB,
  first_name TEXT,
  is_active BOOLEAN,
  kyc_data JSONB,
  kyc_status TEXT,
  last_name TEXT,
  member_number TEXT,
  membership_type_id UUID,
  org_id UUID NOT NULL,
  organization_id UUID NOT NULL,
  phone TEXT,
  preferences JSONB,
  risk_score NUMERIC,
  role TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.promotion_manifest
CREATE TABLE IF NOT EXISTS public.promotion_manifest (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  approval_token TEXT,
  artifact_path TEXT NOT NULL,
  category TEXT,
  promoted_at TIMESTAMP WITH TIME ZONE,
  promoted_from TEXT,
  promoted_to TEXT,
  reviewer TEXT,
  source_refs TEXT[],
  tests_passing BOOLEAN
);

-- Table: public.query_log
CREATE TABLE IF NOT EXISTS public.query_log (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  query_text TEXT NOT NULL,
  query_timestamp TEXT,
  response_time_ms NUMERIC,
  similarity_scores NUMERIC[],
  top_chunk_ids TEXT[]
);

-- Table: public.rate_limits
CREATE TABLE IF NOT EXISTS public.rate_limits (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_union_id UUID NOT NULL,
  current_usage NUMERIC,
  limit_type TEXT NOT NULL,
  limit_value NUMERIC NOT NULL,
  metadata JSONB,
  resource_type TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  window_start TEXT
);

-- Table: public.recurring_transactions
CREATE TABLE IF NOT EXISTS public.recurring_transactions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  average_amount NUMERIC,
  category_id UUID,
  confidence_score NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  frequency TEXT,
  is_active BOOLEAN,
  is_bill BOOLEAN,
  is_subscription BOOLEAN,
  last_amount NUMERIC,
  last_transaction_date TIMESTAMP WITH TIME ZONE,
  merchant_name TEXT NOT NULL,
  metadata JSONB,
  next_expected_date TIMESTAMP WITH TIME ZONE,
  transaction_ids TEXT[],
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);

-- Table: public.recurring_transfers
CREATE TABLE IF NOT EXISTS public.recurring_transfers (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  end_date TIMESTAMP WITH TIME ZONE,
  frequency TEXT NOT NULL,
  from_account_id UUID NOT NULL,
  member_id UUID NOT NULL,
  next_transfer_date TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT,
  to_account_id UUID NOT NULL,
  transfer_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.revoked_tokens
CREATE TABLE IF NOT EXISTS public.revoked_tokens (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  jti TEXT NOT NULL,
  revoked_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.risk_assessments
CREATE TABLE IF NOT EXISTS public.risk_assessments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  assessed_at TIMESTAMP WITH TIME ZONE,
  assessed_by TEXT NOT NULL,
  assessment_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  entity_id UUID NOT NULL,
  mitigation_actions TEXT[],
  next_review_date TIMESTAMP WITH TIME ZONE,
  risk_factors TEXT[],
  risk_level TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.risk_decisions
CREATE TABLE IF NOT EXISTS public.risk_decisions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  decision TEXT NOT NULL,
  member_id UUID,
  model_version TEXT,
  processing_time_ms NUMERIC,
  rules_hit JSONB,
  score NUMERIC NOT NULL,
  txn_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.rooms
CREATE TABLE IF NOT EXISTS public.rooms (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  description TEXT,
  name TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.saga_instances
CREATE TABLE IF NOT EXISTS public.saga_instances (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  compensation_data JSONB,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  current_step TEXT,
  error_message TEXT,
  failed_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  saga_data JSONB NOT NULL,
  saga_type TEXT NOT NULL,
  started_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  tenant_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.saga_steps
CREATE TABLE IF NOT EXISTS public.saga_steps (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  compensated_at TIMESTAMP WITH TIME ZONE,
  compensation_data JSONB,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  error_message TEXT,
  idempotency_key TEXT,
  metadata JSONB,
  request_data JSONB,
  response_data JSONB,
  retry_count NUMERIC,
  saga_instance_id UUID,
  started_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  step_name TEXT NOT NULL,
  step_order NUMERIC NOT NULL
);

-- Table: public.sanctions_hits
CREATE TABLE IF NOT EXISTS public.sanctions_hits (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  match_confidence NUMERIC NOT NULL,
  payload JSONB NOT NULL,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  reviewed_by TEXT,
  source TEXT NOT NULL,
  status TEXT,
  subject_id UUID NOT NULL,
  subject_type TEXT NOT NULL
);

-- Table: public.scheduled_payments
CREATE TABLE IF NOT EXISTS public.scheduled_payments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  description TEXT,
  frequency TEXT,
  from_account_id UUID NOT NULL,
  scheduled_date TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT,
  to_payee_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  user_id UUID NOT NULL
);

-- Table: public.screen_content
CREATE TABLE IF NOT EXISTS public.screen_content (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  content_html TEXT,
  content_key TEXT NOT NULL,
  content_markdown TEXT,
  content_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  order_index NUMERIC,
  screen_route TEXT NOT NULL,
  string_key TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  visibility_rules JSONB
);

-- Table: public.screen_tokens
CREATE TABLE IF NOT EXISTS public.screen_tokens (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  analytics_events TEXT[],
  compliance_category TEXT,
  component_tree JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  data_requirements JSONB,
  description TEXT,
  display_name TEXT NOT NULL,
  layout_config JSONB,
  navigation_config JSONB,
  pattern_refs TEXT[],
  permissions_required TEXT[],
  screen_key TEXT NOT NULL,
  screen_route TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  version TEXT
);

-- Table: public.sent_notifications
CREATE TABLE IF NOT EXISTS public.sent_notifications (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  body TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  delivered_at TIMESTAMP WITH TIME ZONE,
  delivery_status TEXT,
  member_id UUID NOT NULL,
  notification_type TEXT NOT NULL,
  sent_at TIMESTAMP WITH TIME ZONE,
  subject TEXT,
  template_id UUID NOT NULL
);

-- Table: public.service_requests
CREATE TABLE IF NOT EXISTS public.service_requests (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  assigned_to TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT NOT NULL,
  member_id UUID NOT NULL,
  priority TEXT,
  request_type TEXT NOT NULL,
  resolution TEXT,
  resolved_at TIMESTAMP WITH TIME ZONE,
  service_id UUID NOT NULL,
  status TEXT,
  subject TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.session_analytics
CREATE TABLE IF NOT EXISTS public.session_analytics (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  analyzed_at TIMESTAMP WITH TIME ZONE,
  avg_fraud_score NUMERIC,
  copy_paste_count NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  max_fraud_score NUMERIC,
  perfect_lines NUMERIC,
  permission_denials NUMERIC,
  rapid_clicks NUMERIC,
  risk_level TEXT,
  screenshot_attempts NUMERIC,
  session_id UUID NOT NULL,
  session_summary JSONB,
  suspicious_events NUMERIC,
  total_duration NUMERIC,
  total_events NUMERIC,
  user_id UUID NOT NULL,
  velocity_spikes NUMERIC
);

-- Table: public.shared_cases
CREATE TABLE IF NOT EXISTS public.shared_cases (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  accepted_at TIMESTAMP WITH TIME ZONE,
  attachments JSONB,
  case_type TEXT,
  completed_at TIMESTAMP WITH TIME ZONE,
  conversation_id UUID,
  description TEXT,
  from_advocate_id UUID NOT NULL,
  member_number TEXT,
  notes TEXT,
  priority TEXT,
  shared_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  to_advocate_id UUID NOT NULL
);

-- Table: public.spatial_ref_sys
CREATE TABLE IF NOT EXISTS public.spatial_ref_sys (
  auth_name TEXT,
  auth_srid NUMERIC,
  proj4text TEXT,
  srid NUMERIC NOT NULL,
  srtext TEXT
);

-- Table: public.spending_patterns
CREATE TABLE IF NOT EXISTS public.spending_patterns (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  average_amount NUMERIC,
  category_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  day_of_month NUMERIC,
  day_of_week NUMERIC,
  frequency_count NUMERIC,
  merchant_id UUID,
  metadata JSONB,
  month_of_year NUMERIC,
  pattern_type TEXT,
  seasonality_score NUMERIC,
  time_of_day TEXT,
  trend TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);

-- Table: public.sql_features
CREATE TABLE IF NOT EXISTS public.sql_features (
  comments TEXT,
  feature_id UUID,
  feature_name TEXT,
  is_supported TEXT,
  is_verified_by TEXT,
  sub_feature_id UUID,
  sub_feature_name TEXT
);

-- Table: public.sql_implementation_info
CREATE TABLE IF NOT EXISTS public.sql_implementation_info (
  character_value TEXT,
  comments TEXT,
  implementation_info_id UUID,
  implementation_info_name TEXT,
  integer_value NUMERIC
);

-- Table: public.sql_languages
CREATE TABLE IF NOT EXISTS public.sql_languages (
  sql_language_binding_style TEXT,
  sql_language_conformance TEXT,
  sql_language_implementation TEXT,
  sql_language_integrity TEXT,
  sql_language_programming_language TEXT,
  sql_language_source TEXT,
  sql_language_year TEXT
);

-- Table: public.sql_packages
CREATE TABLE IF NOT EXISTS public.sql_packages (
  comments TEXT,
  feature_id UUID,
  feature_name TEXT,
  is_supported TEXT,
  is_verified_by TEXT
);

-- Table: public.sql_parts
CREATE TABLE IF NOT EXISTS public.sql_parts (
  comments TEXT,
  feature_id UUID,
  feature_name TEXT,
  is_supported TEXT,
  is_verified_by TEXT
);

-- Table: public.sql_sizing
CREATE TABLE IF NOT EXISTS public.sql_sizing (
  comments TEXT,
  sizing_id NUMERIC,
  sizing_name TEXT,
  supported_value NUMERIC
);

-- Table: public.sql_sizing_profiles
CREATE TABLE IF NOT EXISTS public.sql_sizing_profiles (
  comments TEXT,
  profile_id UUID,
  required_value NUMERIC,
  sizing_id NUMERIC,
  sizing_name TEXT
);

-- Table: public.staff_training_faqs
CREATE TABLE IF NOT EXISTS public.staff_training_faqs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  answer TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  cu_id UUID NOT NULL,
  display_order NUMERIC,
  escalation_procedure TEXT,
  is_mandatory_training BOOLEAN,
  question TEXT NOT NULL,
  related_policies TEXT[],
  role TEXT,
  tags TEXT[],
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.states
CREATE TABLE IF NOT EXISTS public.states (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  abbreviation TEXT NOT NULL,
  active_voters NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  name TEXT NOT NULL,
  total_teachers NUMERIC
);

-- Table: public.stop_payments
CREATE TABLE IF NOT EXISTS public.stop_payments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  amount_cents NUMERIC,
  check_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  payee_name TEXT,
  status TEXT,
  stop_date TIMESTAMP WITH TIME ZONE,
  stop_payment_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.string_ab_tests
CREATE TABLE IF NOT EXISTS public.string_ab_tests (
  active BOOLEAN,
  conversion_metric TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  end_date TIMESTAMP WITH TIME ZONE,
  start_date TIMESTAMP WITH TIME ZONE,
  string_key TEXT,
  test_id UUID NOT NULL,
  test_name TEXT NOT NULL,
  traffic_split JSONB NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  variant_a_text TEXT NOT NULL,
  variant_b_text TEXT NOT NULL,
  variant_c_text TEXT,
  winner TEXT
);

-- Table: public.stripe_customers
CREATE TABLE IF NOT EXISTS public.stripe_customers (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  email TEXT,
  metadata JSONB,
  name TEXT,
  stripe_customer_id UUID NOT NULL,
  tenant_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID
);

-- Table: public.stripe_invoices
CREATE TABLE IF NOT EXISTS public.stripe_invoices (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount_due_cents NUMERIC NOT NULL,
  amount_paid_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  hosted_invoice_url TEXT,
  invoice_url TEXT,
  metadata JSONB,
  pdf_url TEXT,
  status TEXT NOT NULL,
  stripe_customer_id UUID NOT NULL,
  stripe_invoice_id UUID NOT NULL,
  stripe_subscription_id UUID NOT NULL,
  tenant_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.stripe_subscriptions
CREATE TABLE IF NOT EXISTS public.stripe_subscriptions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount_cents NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  currency TEXT,
  current_period_end TEXT,
  current_period_start TEXT,
  metadata JSONB,
  plan_code TEXT,
  plan_name TEXT,
  status TEXT NOT NULL,
  stripe_customer_id UUID NOT NULL,
  stripe_subscription_id UUID NOT NULL,
  tenant_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.subscription_plans
CREATE TABLE IF NOT EXISTS public.subscription_plans (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  api_calls_per_month NUMERIC,
  bandwidth_mb NUMERIC,
  content_generations_per_month NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  deployments_per_month NUMERIC,
  description TEXT,
  features JSONB,
  is_active BOOLEAN,
  is_trial BOOLEAN,
  plan_code TEXT NOT NULL,
  plan_name TEXT NOT NULL,
  price_annual NUMERIC,
  price_monthly NUMERIC NOT NULL,
  storage_mb NUMERIC,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.survey_responses
CREATE TABLE IF NOT EXISTS public.survey_responses (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  completion_percentage NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  responses JSONB NOT NULL,
  submitted_at TIMESTAMP WITH TIME ZONE,
  survey_id UUID NOT NULL
);

-- Table: public.system_configurations
CREATE TABLE IF NOT EXISTS public.system_configurations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  config_key TEXT NOT NULL,
  config_type TEXT NOT NULL,
  config_value TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  is_encrypted BOOLEAN,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.system_health_checks
CREATE TABLE IF NOT EXISTS public.system_health_checks (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  check_name TEXT NOT NULL,
  check_type TEXT NOT NULL,
  checked_at TIMESTAMP WITH TIME ZONE,
  details JSONB,
  error_message TEXT,
  response_time_ms NUMERIC,
  status TEXT NOT NULL
);

-- Table: public.system_logs
CREATE TABLE IF NOT EXISTS public.system_logs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  component TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  details JSONB,
  ip_address INET NOT NULL,
  log_level TEXT NOT NULL,
  message TEXT NOT NULL,
  session_id UUID,
  user_id UUID
);

-- Table: public.teachers
CREATE TABLE IF NOT EXISTS public.teachers (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  email TEXT NOT NULL,
  first_name TEXT,
  last_name TEXT,
  school_district TEXT,
  state TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  verified BOOLEAN
);

-- Table: public.tenant_benchmarks
CREATE TABLE IF NOT EXISTS public.tenant_benchmarks (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  metric_category TEXT NOT NULL,
  metric_name TEXT NOT NULL,
  percentile_25 NUMERIC,
  percentile_50 NUMERIC,
  percentile_75 NUMERIC,
  percentile_90 NUMERIC,
  period_end TEXT NOT NULL,
  period_start TEXT NOT NULL,
  sample_size NUMERIC
);

-- Table: public.tenant_domain_verifications
CREATE TABLE IF NOT EXISTS public.tenant_domain_verifications (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  domain TEXT NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE,
  is_verified BOOLEAN,
  last_checked_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  tenant_id UUID NOT NULL,
  verification_token TEXT NOT NULL,
  verification_type TEXT NOT NULL,
  verification_value TEXT,
  verified_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.tenant_onboarding_steps
CREATE TABLE IF NOT EXISTS public.tenant_onboarding_steps (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  completed_at TIMESTAMP WITH TIME ZONE,
  completed_by TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  data JSONB,
  metadata JSONB,
  status TEXT,
  step_name TEXT NOT NULL,
  step_order NUMERIC NOT NULL,
  tenant_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.tenant_pillar_access
CREATE TABLE IF NOT EXISTS public.tenant_pillar_access (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  monthly_price NUMERIC,
  pillar_count NUMERIC,
  pillars_enabled NUMERIC[],
  status TEXT,
  stripe_subscription_id UUID,
  tenant_id UUID NOT NULL,
  tier TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.tenant_string_overrides
CREATE TABLE IF NOT EXISTS public.tenant_string_overrides (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  active BOOLEAN,
  created_at TIMESTAMP WITH TIME ZONE,
  locale TEXT NOT NULL,
  override_text TEXT NOT NULL,
  string_key TEXT,
  tenant_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.tenant_users
CREATE TABLE IF NOT EXISTS public.tenant_users (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  joined_at TIMESTAMP WITH TIME ZONE,
  last_active_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  permissions JSONB,
  role TEXT,
  tenant_id UUID NOT NULL,
  user_id UUID NOT NULL
);

-- Table: public.tenants
CREATE TABLE IF NOT EXISTS public.tenants (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  branding JSONB,
  charter_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  deactivated_at TIMESTAMP WITH TIME ZONE,
  features JSONB,
  full_domain TEXT NOT NULL,
  is_verified BOOLEAN,
  legal_name TEXT NOT NULL,
  metadata JSONB,
  ncua_number TEXT,
  routing_number TEXT,
  settings JSONB,
  slug TEXT NOT NULL,
  status TEXT,
  tier TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  verification_method TEXT,
  verification_token TEXT,
  verified_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.terms_acceptances
CREATE TABLE IF NOT EXISTS public.terms_acceptances (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  accepted_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  email TEXT,
  ip_address TEXT,
  terms_version TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  user_id UUID,
  verification_id UUID
);

-- Table: public.tickets
CREATE TABLE IF NOT EXISTS public.tickets (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  assigned_to TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  description TEXT,
  priority TEXT,
  resolved_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  subject TEXT NOT NULL,
  tenant_key TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.token_dependencies
CREATE TABLE IF NOT EXISTS public.token_dependencies (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  dependency_relationship TEXT NOT NULL,
  depends_on_key TEXT NOT NULL,
  depends_on_type TEXT NOT NULL,
  optional BOOLEAN,
  token_key TEXT NOT NULL,
  token_type TEXT NOT NULL
);

-- Table: public.token_inheritance
CREATE TABLE IF NOT EXISTS public.token_inheritance (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  inheritance_config JSONB,
  inherits_from_key TEXT NOT NULL,
  token_key TEXT NOT NULL,
  token_type TEXT NOT NULL
);

-- Table: public.token_overrides
CREATE TABLE IF NOT EXISTS public.token_overrides (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  active BOOLEAN,
  created_at TIMESTAMP WITH TIME ZONE,
  override_config JSONB NOT NULL,
  override_reason TEXT,
  tenant_id UUID,
  token_key TEXT NOT NULL,
  token_type TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.token_versions
CREATE TABLE IF NOT EXISTS public.token_versions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  ab_test_config JSONB,
  changelog TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  effective_from TEXT,
  effective_until TEXT,
  release_status TEXT,
  token_config JSONB NOT NULL,
  token_key TEXT NOT NULL,
  token_type TEXT NOT NULL,
  version TEXT NOT NULL
);

-- Table: public.tool_registry
CREATE TABLE IF NOT EXISTS public.tool_registry (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  display_name TEXT NOT NULL,
  enabled BOOLEAN,
  endpoint TEXT NOT NULL,
  method TEXT,
  parameters JSONB,
  rate_limit NUMERIC,
  required_permissions TEXT[],
  tool_name TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.tracking_sessions
CREATE TABLE IF NOT EXISTS public.tracking_sessions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  completion_percentage NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  ended_at TIMESTAMP WITH TIME ZONE,
  engagement_score NUMERIC,
  page_views TEXT[],
  session_type TEXT,
  started_at TIMESTAMP WITH TIME ZONE NOT NULL,
  total_interactions NUMERIC,
  user_id UUID NOT NULL
);

-- Table: public.transaction_alerts
CREATE TABLE IF NOT EXISTS public.transaction_alerts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  acknowledged_at TIMESTAMP WITH TIME ZONE,
  acknowledged_by TEXT,
  alert_message TEXT,
  alert_severity TEXT,
  alert_type TEXT NOT NULL,
  member_id UUID,
  transaction_id UUID,
  triggered_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.transaction_categories
CREATE TABLE IF NOT EXISTS public.transaction_categories (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category_name TEXT NOT NULL,
  color TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  icon TEXT,
  is_system BOOLEAN,
  parent_category_id UUID
);

-- Table: public.transaction_disputes
CREATE TABLE IF NOT EXISTS public.transaction_disputes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  dispute_amount NUMERIC,
  dispute_reason TEXT NOT NULL,
  member_id UUID,
  resolution TEXT,
  resolved_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  submitted_at TIMESTAMP WITH TIME ZONE,
  transaction_id UUID
);

-- Table: public.transaction_enrichment
CREATE TABLE IF NOT EXISTS public.transaction_enrichment (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  confidence_score NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  location JSONB,
  merchant_category TEXT,
  merchant_logo_url TEXT,
  merchant_name TEXT,
  tags TEXT[],
  transaction_id UUID
);

-- Table: public.transaction_fees
CREATE TABLE IF NOT EXISTS public.transaction_fees (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  fee_amount NUMERIC NOT NULL,
  fee_description TEXT,
  fee_type TEXT NOT NULL,
  transaction_id UUID
);

-- Table: public.transactions
CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  ai_category_id UUID,
  ai_confidence NUMERIC,
  ai_insights JSONB,
  amount NUMERIC NOT NULL,
  category_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  currency TEXT,
  description TEXT NOT NULL,
  external_id UUID,
  is_discretionary BOOLEAN,
  is_essential BOOLEAN,
  is_recurring BOOLEAN,
  location_city TEXT,
  location_coords BYTEA NOT NULL,
  location_country TEXT,
  location_state TEXT,
  merchant_id UUID,
  merchant_name TEXT,
  metadata JSONB,
  pending BOOLEAN,
  plaid_transaction_id UUID,
  posted_date TIMESTAMP WITH TIME ZONE,
  recurring_pattern TEXT,
  tags TEXT[],
  transaction_date TIMESTAMP WITH TIME ZONE NOT NULL,
  transaction_type TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);

-- Table: public.transfers
CREATE TABLE IF NOT EXISTS public.transfers (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  from_account_id UUID NOT NULL,
  member_id UUID NOT NULL,
  posted_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  to_account_id UUID NOT NULL,
  transfer_date TIMESTAMP WITH TIME ZONE,
  transfer_number TEXT NOT NULL,
  transfer_type TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.transformation_requests
CREATE TABLE IF NOT EXISTS public.transformation_requests (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  branding_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  cu_name TEXT NOT NULL,
  deployment_data JSONB,
  domain TEXT NOT NULL,
  email TEXT NOT NULL,
  package TEXT NOT NULL,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  validation_result JSONB
);

-- Table: public.translation_strings
CREATE TABLE IF NOT EXISTS public.translation_strings (
  category TEXT,
  context TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  default_text TEXT NOT NULL,
  description TEXT,
  string_key TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  variable_placeholders JSONB
);

-- Table: public.translation_values
CREATE TABLE IF NOT EXISTS public.translation_values (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  locale TEXT NOT NULL,
  reviewed BOOLEAN,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  reviewed_by TEXT,
  string_key TEXT,
  translated_text TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.typing_indicators
CREATE TABLE IF NOT EXISTS public.typing_indicators (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  conversation_id UUID NOT NULL,
  is_typing BOOLEAN,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);

-- Table: public.uc_access_tokens
CREATE TABLE IF NOT EXISTS public.uc_access_tokens (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  component_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  expires_at TIMESTAMP WITH TIME ZONE,
  permissions TEXT[] NOT NULL,
  token_hash TEXT NOT NULL
);

-- Table: public.uc_component_tags
CREATE TABLE IF NOT EXISTS public.uc_component_tags (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  component_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  tag TEXT NOT NULL
);

-- Table: public.uc_component_versions
CREATE TABLE IF NOT EXISTS public.uc_component_versions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  component_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  generated_flutter_code TEXT,
  generated_react_code TEXT,
  ucdl_definition JSONB NOT NULL,
  version TEXT NOT NULL
);

-- Table: public.uc_components
CREATE TABLE IF NOT EXISTS public.uc_components (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT NOT NULL,
  description TEXT,
  generated_flutter_code TEXT,
  generated_react_code TEXT,
  name TEXT NOT NULL,
  security_config JSONB NOT NULL,
  ucdl_definition JSONB NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  version TEXT NOT NULL
);

-- Table: public.ucx_actions_log
CREATE TABLE IF NOT EXISTS public.ucx_actions_log (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  action TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  details TEXT,
  status TEXT NOT NULL,
  target JSONB NOT NULL
);

-- Table: public.ucx_feature_flags
CREATE TABLE IF NOT EXISTS public.ucx_feature_flags (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  app_id UUID NOT NULL,
  enabled BOOLEAN NOT NULL,
  key TEXT NOT NULL,
  rollout JSONB,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  value JSONB NOT NULL
);

-- Table: public.ucx_feedback
CREATE TABLE IF NOT EXISTS public.ucx_feedback (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  app_id UUID NOT NULL,
  body TEXT NOT NULL,
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  effort_score NUMERIC,
  linked_incident_id UUID,
  metadata JSONB,
  sentiment TEXT,
  tenant_id UUID,
  user_id UUID,
  value_score NUMERIC
);

-- Table: public.ucx_incidents
CREATE TABLE IF NOT EXISTS public.ucx_incidents (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  app_id UUID NOT NULL,
  category TEXT,
  context JSONB,
  effort_score NUMERIC,
  error_kind TEXT,
  error_message TEXT,
  fingerprint TEXT NOT NULL,
  first_seen_at TIMESTAMP WITH TIME ZONE NOT NULL,
  github_issue_url TEXT,
  last_seen_at TIMESTAMP WITH TIME ZONE NOT NULL,
  occurrences NUMERIC NOT NULL,
  severity NUMERIC,
  status TEXT NOT NULL,
  tenant_id UUID,
  value_score NUMERIC,
  volume_score NUMERIC
);

-- Table: public.ui_component_strings
CREATE TABLE IF NOT EXISTS public.ui_component_strings (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  component_id UUID NOT NULL,
  component_type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  order_index NUMERIC,
  required BOOLEAN,
  string_key TEXT,
  string_type TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.ui_strings
CREATE TABLE IF NOT EXISTS public.ui_strings (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  language_code TEXT,
  max_length NUMERIC,
  metadata JSONB,
  string_key TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  value TEXT NOT NULL
);

-- Table: public.unified_components
CREATE TABLE IF NOT EXISTS public.unified_components (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT NOT NULL,
  description TEXT,
  generated_flutter_code TEXT,
  generated_react_code TEXT,
  name TEXT NOT NULL,
  security_config JSONB NOT NULL,
  ucdl_definition JSONB NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  version TEXT NOT NULL
);

-- Table: public.usage_logs
CREATE TABLE IF NOT EXISTS public.usage_logs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  count NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  day TEXT NOT NULL,
  metric TEXT NOT NULL,
  organization_id UUID NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: public.user_adapter_access
CREATE TABLE IF NOT EXISTS public.user_adapter_access (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  access_expires_at TIMESTAMP WITH TIME ZONE,
  access_granted_at TIMESTAMP WITH TIME ZONE,
  access_source TEXT NOT NULL,
  adapter_id UUID NOT NULL,
  adapter_product_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  download_count NUMERIC,
  download_token TEXT,
  download_token_expires_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN,
  last_accessed_at TIMESTAMP WITH TIME ZONE,
  last_downloaded_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  pillar_id UUID,
  profile_id UUID,
  purchase_id UUID,
  storage_bucket TEXT NOT NULL,
  storage_path TEXT NOT NULL,
  stripe_subscription_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);

-- Table: public.user_analytics
CREATE TABLE IF NOT EXISTS public.user_analytics (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  avg_engagement_score NUMERIC,
  channels_used TEXT[],
  completion_rates JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  date TEXT NOT NULL,
  total_interactions NUMERIC,
  total_sessions NUMERIC,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);

-- Table: public.user_security
CREATE TABLE IF NOT EXISTS public.user_security (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_locked_until TEXT,
  backup_codes TEXT[],
  created_at TIMESTAMP WITH TIME ZONE,
  device_fingerprints JSONB,
  failed_login_attempts NUMERIC,
  last_password_change TEXT,
  mfa_enabled BOOLEAN,
  mfa_secret TEXT,
  phone TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);

-- Table: public.user_sessions
CREATE TABLE IF NOT EXISTS public.user_sessions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  app_version TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  device_fingerprint TEXT,
  device_info JSONB,
  end_time TEXT,
  ip_address INET NOT NULL,
  location_data JSONB,
  platform TEXT,
  screen_resolution TEXT,
  session_id UUID NOT NULL,
  start_time TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_agent TEXT,
  user_id UUID NOT NULL
);

-- Table: public.user_settings
CREATE TABLE IF NOT EXISTS public.user_settings (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  animations_enabled BOOLEAN,
  can_override_settings BOOLEAN,
  color_scheme TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  font_scale NUMERIC,
  force_accessibility_mode BOOLEAN,
  haptics_enabled BOOLEAN,
  high_contrast BOOLEAN,
  last_synced_at TIMESTAMP WITH TIME ZONE,
  reduce_motion BOOLEAN,
  screen_reader_optimized BOOLEAN,
  sound_enabled BOOLEAN,
  sound_volume NUMERIC,
  synced_from TEXT,
  theme_mode TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);

-- Table: public.user_tenants
CREATE TABLE IF NOT EXISTS public.user_tenants (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  role TEXT NOT NULL,
  tenant_id UUID NOT NULL,
  user_id UUID NOT NULL
);

-- Table: public.users
CREATE TABLE IF NOT EXISTS public.users (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  date_of_birth TEXT,
  email TEXT NOT NULL,
  full_name TEXT,
  metadata JSONB,
  phone TEXT,
  preferences JSONB,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.validation_logs
CREATE TABLE IF NOT EXISTS public.validation_logs (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  cu_name TEXT NOT NULL,
  domain TEXT,
  email TEXT,
  error_message TEXT,
  is_valid BOOLEAN NOT NULL,
  suggestions TEXT[],
  validated_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.validation_message_templates
CREATE TABLE IF NOT EXISTS public.validation_message_templates (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  message_template TEXT NOT NULL,
  severity TEXT NOT NULL,
  string_key TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  validation_type TEXT NOT NULL,
  variable_placeholders JSONB
);

-- Table: public.vendor_api_keys
CREATE TABLE IF NOT EXISTS public.vendor_api_keys (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN,
  key_hash TEXT NOT NULL,
  key_name TEXT NOT NULL,
  key_prefix TEXT NOT NULL,
  last_used_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  permissions JSONB,
  rate_limit_per_hour NUMERIC,
  rate_limit_per_minute NUMERIC,
  scopes TEXT[],
  updated_at TIMESTAMP WITH TIME ZONE,
  usage_count NUMERIC,
  vendor_id UUID NOT NULL
);

-- Table: public.vendor_brand_guidelines
CREATE TABLE IF NOT EXISTS public.vendor_brand_guidelines (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  accent_colors JSONB,
  brand_description TEXT,
  brand_name TEXT NOT NULL,
  brand_tagline TEXT,
  brand_tone TEXT,
  brand_voice TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  do_not_examples JSONB,
  font_weights JSONB,
  is_active BOOLEAN,
  logo_clear_space JSONB,
  logo_minimum_size JSONB,
  logo_restrictions TEXT[],
  messaging_guidelines TEXT,
  metadata JSONB,
  primary_colors JSONB,
  primary_font TEXT,
  secondary_colors JSONB,
  secondary_font TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  usage_examples JSONB,
  vendor_id UUID NOT NULL,
  version TEXT
);

-- Table: public.vendor_branding_assets
CREATE TABLE IF NOT EXISTS public.vendor_branding_assets (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  asset_dimensions JSONB,
  asset_format TEXT,
  asset_name TEXT NOT NULL,
  asset_size_bytes NUMERIC,
  asset_type TEXT NOT NULL,
  asset_url TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  is_active BOOLEAN,
  is_default BOOLEAN,
  metadata JSONB,
  tags TEXT[],
  theme_variant TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  usage_context TEXT[],
  vendor_id UUID NOT NULL
);

-- Table: public.vendor_domains
CREATE TABLE IF NOT EXISTS public.vendor_domains (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  dns_configured BOOLEAN,
  domain_name TEXT NOT NULL,
  domain_type TEXT,
  is_active BOOLEAN,
  is_verified BOOLEAN,
  metadata JSONB,
  ssl_certificate_url TEXT,
  ssl_expires_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE,
  vendor_id UUID NOT NULL,
  verified_at TIMESTAMP WITH TIME ZONE
);

-- Table: public.vendor_logos
CREATE TABLE IF NOT EXISTS public.vendor_logos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  accent_color TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  favicon_url TEXT,
  is_active BOOLEAN,
  is_verified BOOLEAN,
  last_used_at TIMESTAMP WITH TIME ZONE,
  logo_dimensions JSONB,
  logo_format TEXT,
  logo_primary_url TEXT,
  logo_secondary_url TEXT,
  logo_size_bytes NUMERIC,
  logo_square_url TEXT,
  logo_wide_url TEXT,
  metadata JSONB,
  primary_color TEXT,
  secondary_color TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  usage_count NUMERIC,
  vendor_id UUID NOT NULL,
  vendor_type TEXT NOT NULL
);

-- Table: public.vendor_subscriptions
CREATE TABLE IF NOT EXISTS public.vendor_subscriptions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  billing_cycle TEXT,
  canceled_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  currency TEXT,
  current_period_end TEXT,
  current_period_start TEXT,
  metadata JSONB,
  plan_code TEXT NOT NULL,
  plan_name TEXT NOT NULL,
  price_cents NUMERIC NOT NULL,
  status TEXT,
  stripe_customer_id UUID,
  stripe_price_id UUID,
  stripe_subscription_id UUID,
  trial_end TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  vendor_id UUID NOT NULL
);

-- Table: public.vendors
CREATE TABLE IF NOT EXISTS public.vendors (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  address_line1 TEXT,
  address_line2 TEXT,
  api_endpoint TEXT,
  api_version TEXT,
  asset_size NUMERIC,
  auth_method TEXT,
  charter_number TEXT,
  city TEXT,
  contact_person TEXT,
  country TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  ein TEXT,
  established_year NUMERIC,
  features JSONB,
  last_activity_at TIMESTAMP WITH TIME ZONE,
  legal_name TEXT NOT NULL,
  member_count NUMERIC,
  metadata JSONB,
  ncua_number TEXT,
  onboarding_completed BOOLEAN,
  onboarding_step NUMERIC,
  postal_code TEXT,
  routing_number TEXT,
  settings JSONB,
  state TEXT,
  status TEXT,
  support_email TEXT,
  support_phone TEXT,
  tier TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  vendor_code TEXT NOT NULL,
  vendor_name TEXT NOT NULL,
  vendor_type TEXT NOT NULL,
  verified BOOLEAN,
  verified_at TIMESTAMP WITH TIME ZONE,
  website_url TEXT
);

-- Table: public.verification_attempts
CREATE TABLE IF NOT EXISTS public.verification_attempts (
  attempt_id UUID NOT NULL,
  attempts_count NUMERIC,
  call_sid TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  expected_answer TEXT,
  max_attempts NUMERIC,
  party_id UUID,
  provided_answer TEXT,
  question_text TEXT,
  question_type TEXT,
  success BOOLEAN
);

-- Table: public.votes
CREATE TABLE IF NOT EXISTS public.votes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  state_id NUMERIC NOT NULL,
  teacher_id UUID NOT NULL,
  vote_value NUMERIC NOT NULL
);

-- Table: public.webhook_deliveries
CREATE TABLE IF NOT EXISTS public.webhook_deliveries (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  attempt_number NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  delivered_at TIMESTAMP WITH TIME ZONE,
  error_message TEXT,
  event_id UUID NOT NULL,
  event_type TEXT NOT NULL,
  http_status NUMERIC,
  next_retry_at TIMESTAMP WITH TIME ZONE,
  payload JSONB NOT NULL,
  response_body TEXT,
  response_time_ms NUMERIC,
  success BOOLEAN,
  webhook_endpoint_id UUID
);

-- Table: public.webhook_endpoints
CREATE TABLE IF NOT EXISTS public.webhook_endpoints (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  description TEXT,
  event_types TEXT[],
  failure_count NUMERIC,
  is_active BOOLEAN,
  last_triggered_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  retry_policy JSONB,
  secret TEXT NOT NULL,
  success_count NUMERIC,
  tenant_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE,
  url TEXT NOT NULL
);

-- Table: public.webhook_events
CREATE TABLE IF NOT EXISTS public.webhook_events (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  attempts NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  event_type TEXT NOT NULL,
  last_attempt_at TIMESTAMP WITH TIME ZONE,
  payload JSONB NOT NULL,
  response_body TEXT,
  response_code NUMERIC,
  status TEXT,
  webhook_id UUID NOT NULL
);

-- Table: public.webhooks
CREATE TABLE IF NOT EXISTS public.webhooks (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  credit_union_id UUID NOT NULL,
  events TEXT[] NOT NULL,
  failure_count NUMERIC,
  is_active BOOLEAN,
  last_success_at TIMESTAMP WITH TIME ZONE,
  last_triggered_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB,
  retry_attempts NUMERIC,
  secret TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  url TEXT NOT NULL,
  webhook_id UUID NOT NULL
);

-- Table: public.widget_ab_tests
CREATE TABLE IF NOT EXISTS public.widget_ab_tests (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  confidence_level NUMERIC,
  control_widget_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  ended_at TIMESTAMP WITH TIME ZONE,
  hypothesis TEXT,
  metadata JSONB,
  results JSONB,
  started_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  success_metric TEXT,
  success_threshold NUMERIC,
  tenant_id UUID,
  test_name TEXT NOT NULL,
  test_slug TEXT NOT NULL,
  traffic_split JSONB,
  updated_at TIMESTAMP WITH TIME ZONE,
  variant_widgets JSONB,
  winning_variant TEXT
);

-- Table: public.widget_analytics
CREATE TABLE IF NOT EXISTS public.widget_analytics (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  event_type TEXT NOT NULL,
  metadata JSONB,
  session_id UUID,
  tenant_id UUID,
  user_id UUID,
  widget_instance_id UUID
);

-- Table: public.widget_analytics_events
CREATE TABLE IF NOT EXISTS public.widget_analytics_events (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  ab_test_id UUID,
  ab_test_variant TEXT,
  browser TEXT,
  conversion_value NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  device_type TEXT,
  element_id UUID,
  element_type TEXT,
  event_data JSONB,
  event_name TEXT,
  event_type TEXT NOT NULL,
  metadata JSONB,
  os TEXT,
  page_url TEXT,
  referrer_url TEXT,
  session_id UUID,
  tenant_id UUID,
  user_id UUID,
  viewport_height NUMERIC,
  viewport_width NUMERIC,
  widget_instance_id UUID
);

-- Table: public.widget_instances
CREATE TABLE IF NOT EXISTS public.widget_instances (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  ab_test_variant TEXT,
  config JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  environment TEXT,
  instance_name TEXT NOT NULL,
  instance_slug TEXT NOT NULL,
  is_active BOOLEAN,
  metadata JSONB,
  placement TEXT,
  position_order NUMERIC,
  template_id UUID,
  tenant_id UUID,
  traffic_percentage NUMERIC,
  updated_at TIMESTAMP WITH TIME ZONE,
  version TEXT,
  wdl_schema JSONB NOT NULL
);

-- Table: public.widget_templates
CREATE TABLE IF NOT EXISTS public.widget_templates (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  category TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  default_config JSONB,
  description TEXT,
  is_featured BOOLEAN,
  is_public BOOLEAN,
  metadata JSONB,
  preview_image_url TEXT,
  tags TEXT[],
  template_name TEXT NOT NULL,
  template_slug TEXT NOT NULL,
  tenant_id UUID,
  updated_at TIMESTAMP WITH TIME ZONE,
  usage_count NUMERIC,
  wdl_schema JSONB NOT NULL,
  wdl_version TEXT
);

-- Table: public.widget_versions
CREATE TABLE IF NOT EXISTS public.widget_versions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  change_description TEXT,
  config JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  created_by TEXT,
  deployed_at TIMESTAMP WITH TIME ZONE,
  rolled_back_at TIMESTAMP WITH TIME ZONE,
  version TEXT NOT NULL,
  wdl_schema JSONB NOT NULL,
  widget_instance_id UUID
);

-- Table: public.wire_transfers
CREATE TABLE IF NOT EXISTS public.wire_transfers (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount_cents NUMERIC NOT NULL,
  beneficiary_account TEXT NOT NULL,
  beneficiary_bank TEXT NOT NULL,
  beneficiary_bank_address TEXT,
  beneficiary_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  currency_code TEXT,
  from_account_id UUID NOT NULL,
  intermediary_bank TEXT,
  intermediary_bank_address TEXT,
  member_id UUID NOT NULL,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  wire_date TIMESTAMP WITH TIME ZONE,
  wire_id UUID NOT NULL
);

-- Table: public.withdrawals
CREATE TABLE IF NOT EXISTS public.withdrawals (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  account_id UUID NOT NULL,
  amount_cents NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  member_id UUID NOT NULL,
  posted_at TIMESTAMP WITH TIME ZONE,
  status TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  withdrawal_date TIMESTAMP WITH TIME ZONE,
  withdrawal_method TEXT,
  withdrawal_number TEXT NOT NULL,
  withdrawal_type TEXT NOT NULL
);

-- Table: public.zelle_payment_requests
CREATE TABLE IF NOT EXISTS public.zelle_payment_requests (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  accepted_at TIMESTAMP WITH TIME ZONE,
  amount NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  declined_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  memo TEXT,
  recipient_id UUID NOT NULL,
  requester_email TEXT NOT NULL,
  requester_id UUID NOT NULL,
  requester_name TEXT NOT NULL,
  status TEXT NOT NULL
);

-- Table: public.zelle_recipients
CREATE TABLE IF NOT EXISTS public.zelle_recipients (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  email TEXT NOT NULL,
  is_enrolled BOOLEAN,
  is_favorite BOOLEAN,
  last_payment_amount NUMERIC,
  last_payment_date TIMESTAMP WITH TIME ZONE,
  name TEXT NOT NULL,
  phone TEXT,
  profile_image TEXT,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);

-- Table: public.zelle_recurring_payments
CREATE TABLE IF NOT EXISTS public.zelle_recurring_payments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  amount NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  end_date TIMESTAMP WITH TIME ZONE,
  frequency TEXT NOT NULL,
  is_active BOOLEAN,
  last_execution_date TIMESTAMP WITH TIME ZONE,
  memo TEXT,
  next_execution_date TIMESTAMP WITH TIME ZONE,
  recipient_id UUID,
  recipient_name TEXT NOT NULL,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE,
  user_id UUID NOT NULL
);


-- ================================================================
-- SCHEMA: qfx
-- Tables: 25
-- ================================================================

CREATE SCHEMA IF NOT EXISTS qfx;

-- Table: qfx.ab_tests
CREATE TABLE IF NOT EXISTS qfx.ab_tests (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  ended_at TIMESTAMP WITH TIME ZONE,
  started_at TIMESTAMP WITH TIME ZONE,
  test_key TEXT NOT NULL,
  traffic_split JSONB,
  variant_a JSONB NOT NULL,
  variant_b JSONB NOT NULL
);

-- Table: qfx.alex_simulation
CREATE TABLE IF NOT EXISTS qfx.alex_simulation (
  financial_state JSONB NOT NULL,
  goals JSONB NOT NULL,
  life_event TEXT,
  month NUMERIC NOT NULL,
  outcomes JSONB NOT NULL,
  qfx_actions JSONB NOT NULL,
  qfx_recommendations JSONB NOT NULL,
  satisfaction_score NUMERIC,
  simulation_id UUID NOT NULL,
  timestamp TEXT,
  trust_score NUMERIC
);

-- Table: qfx.annotations
CREATE TABLE IF NOT EXISTS qfx.annotations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  annotator TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  labels JSONB,
  model_run_id UUID,
  notes TEXT
);

-- Table: qfx.data_provenance
CREATE TABLE IF NOT EXISTS qfx.data_provenance (
  audit_trail JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  data_hash TEXT NOT NULL,
  integrity_score NUMERIC,
  lineage_graph JSONB NOT NULL,
  provenance_id UUID NOT NULL,
  source_systems TEXT[] NOT NULL,
  transformations JSONB[] NOT NULL
);

-- Table: qfx.datasets
CREATE TABLE IF NOT EXISTS qfx.datasets (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  dataset_key TEXT NOT NULL,
  description TEXT,
  schema JSONB
);

-- Table: qfx.ethical_validations
CREATE TABLE IF NOT EXISTS qfx.ethical_validations (
  bias_metrics JSONB NOT NULL,
  fairness_score NUMERIC NOT NULL,
  model_version TEXT NOT NULL,
  passed BOOLEAN NOT NULL,
  red_team_results JSONB,
  test_type TEXT NOT NULL,
  timestamp TEXT,
  validation_id UUID NOT NULL
);

-- Table: qfx.eval_results
CREATE TABLE IF NOT EXISTS qfx.eval_results (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  eval_id UUID NOT NULL,
  metrics JSONB NOT NULL,
  model_run_id UUID,
  pass BOOLEAN
);

-- Table: qfx.evals
CREATE TABLE IF NOT EXISTS qfx.evals (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  dataset_id UUID,
  eval_key TEXT NOT NULL,
  metric_defs JSONB NOT NULL
);

-- Table: qfx.examples
CREATE TABLE IF NOT EXISTS qfx.examples (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  dataset_id UUID,
  expected JSONB,
  input JSONB NOT NULL,
  tags TEXT[]
);

-- Table: qfx.fiduciary_decisions
CREATE TABLE IF NOT EXISTS qfx.fiduciary_decisions (
  compliance_check JSONB NOT NULL,
  compliance_passed BOOLEAN NOT NULL,
  decision_id UUID NOT NULL,
  decision_outcome TEXT NOT NULL,
  intent_analysis JSONB NOT NULL,
  intent_confidence NUMERIC NOT NULL,
  justification TEXT NOT NULL,
  regulatory_citations TEXT[],
  risk_assessment JSONB NOT NULL,
  risk_score NUMERIC NOT NULL,
  session_id UUID NOT NULL,
  timestamp TEXT,
  user_id UUID NOT NULL
);

-- Table: qfx.generated_interfaces
CREATE TABLE IF NOT EXISTS qfx.generated_interfaces (
  accessibility_score NUMERIC,
  animation_params JSONB NOT NULL,
  color_scheme JSONB NOT NULL,
  component_tree JSONB NOT NULL,
  context_hash TEXT,
  generated_at TIMESTAMP WITH TIME ZONE,
  information_density NUMERIC,
  interface_id UUID NOT NULL,
  layout_config JSONB NOT NULL,
  personalization_score NUMERIC,
  render_time_ms NUMERIC,
  session_id UUID NOT NULL,
  typography_settings JSONB NOT NULL,
  user_id UUID NOT NULL
);

-- Table: qfx.guardrail_violations
CREATE TABLE IF NOT EXISTS qfx.guardrail_violations (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  details JSONB,
  guardrail_id UUID,
  model_run_id UUID,
  violation_type TEXT
);

-- Table: qfx.guardrails
CREATE TABLE IF NOT EXISTS qfx.guardrails (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  policy JSONB NOT NULL,
  rail_key TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: qfx.metrics
CREATE TABLE IF NOT EXISTS qfx.metrics (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  extra JSONB,
  model_run_id UUID,
  name TEXT NOT NULL,
  value NUMERIC
);

-- Table: qfx.model_runs
CREATE TABLE IF NOT EXISTS qfx.model_runs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  completed_at TIMESTAMP WITH TIME ZONE,
  input JSONB NOT NULL,
  metadata JSONB,
  model_id UUID,
  output JSONB,
  prompt_version_id UUID,
  request_id UUID,
  started_at TIMESTAMP WITH TIME ZONE,
  usage JSONB
);

-- Table: qfx.models
CREATE TABLE IF NOT EXISTS qfx.models (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  capabilities TEXT[],
  context_window_tokens NUMERIC,
  cost_completion_per_1k NUMERIC,
  cost_prompt_per_1k NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  is_active BOOLEAN,
  model_key TEXT NOT NULL,
  provider TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: qfx.multimodal_inputs
CREATE TABLE IF NOT EXISTS qfx.multimodal_inputs (
  behavioral_signals JSONB,
  context_snapshot JSONB,
  fusion_confidence NUMERIC,
  fusion_result JSONB,
  input_id UUID NOT NULL,
  processed_at TIMESTAMP WITH TIME ZONE,
  session_id UUID NOT NULL,
  text_data TEXT,
  text_embedding TEXT,
  user_id UUID NOT NULL,
  voice_data TEXT,
  voice_features JSONB
);

-- Table: qfx.policies
CREATE TABLE IF NOT EXISTS qfx.policies (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  policy_key TEXT NOT NULL,
  rules JSONB NOT NULL,
  title TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: qfx.policy_checks
CREATE TABLE IF NOT EXISTS qfx.policy_checks (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  details JSONB,
  model_run_id UUID,
  policy_id UUID,
  result TEXT
);

-- Table: qfx.prompt_versions
CREATE TABLE IF NOT EXISTS qfx.prompt_versions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  notes TEXT,
  prompt_id UUID NOT NULL,
  template TEXT NOT NULL,
  version TEXT NOT NULL
);

-- Table: qfx.prompts
CREATE TABLE IF NOT EXISTS qfx.prompts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE,
  description TEXT,
  input_schema JSONB,
  output_schema JSONB,
  prompt_key TEXT NOT NULL,
  template TEXT NOT NULL,
  title TEXT,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: qfx.self_improvements
CREATE TABLE IF NOT EXISTS qfx.self_improvements (
  adopted BOOLEAN,
  adopted_at TIMESTAMP WITH TIME ZONE,
  control_group JSONB,
  experiment_config JSONB NOT NULL,
  experiment_type TEXT,
  hypothesis TEXT NOT NULL,
  improvement_id UUID NOT NULL,
  performance_delta NUMERIC,
  results JSONB NOT NULL,
  rollback_available BOOLEAN,
  statistical_significance NUMERIC,
  tested_at TIMESTAMP WITH TIME ZONE,
  treatment_group JSONB
);

-- Table: qfx.user_personas
CREATE TABLE IF NOT EXISTS qfx.user_personas (
  communication_preference JSONB,
  evolution_history JSONB[],
  financial_archetype TEXT,
  goals_hierarchy JSONB,
  investment_style TEXT,
  journey_state JSONB,
  last_updated TEXT,
  learning_style TEXT,
  persona_id UUID NOT NULL,
  personality_vector TEXT,
  risk_tolerance NUMERIC,
  user_id UUID NOT NULL,
  values_framework JSONB
);

-- Table: qfx.validation_checkpoints
CREATE TABLE IF NOT EXISTS qfx.validation_checkpoints (
  auto_fixed BOOLEAN,
  checkpoint_id UUID NOT NULL,
  checks_performed JSONB NOT NULL,
  error_details JSONB,
  fix_attempts NUMERIC,
  layer_number NUMERIC,
  passed BOOLEAN NOT NULL,
  performance_metrics JSONB,
  phase TEXT NOT NULL,
  results JSONB NOT NULL,
  timestamp TEXT,
  validation_level NUMERIC NOT NULL,
  validation_type TEXT NOT NULL
);

-- Table: qfx.zero_knowledge_proofs
CREATE TABLE IF NOT EXISTS qfx.zero_knowledge_proofs (
  created_at TIMESTAMP WITH TIME ZONE,
  proof_data JSONB NOT NULL,
  proof_id UUID NOT NULL,
  proving_key TEXT NOT NULL,
  statement_hash TEXT NOT NULL,
  validated_at TIMESTAMP WITH TIME ZONE,
  validation_confidence NUMERIC,
  validation_result JSONB,
  verification_key TEXT NOT NULL
);


-- ================================================================
-- SCHEMA: realtime
-- Tables: 9
-- ================================================================

CREATE SCHEMA IF NOT EXISTS realtime;

-- Table: realtime.messages
CREATE TABLE IF NOT EXISTS realtime.messages (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  event TEXT,
  extension TEXT NOT NULL,
  inserted_at TIMESTAMP WITH TIME ZONE NOT NULL,
  payload JSONB,
  private BOOLEAN,
  topic TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: realtime.messages_2025_10_27
CREATE TABLE IF NOT EXISTS realtime.messages_2025_10_27 (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  event TEXT,
  extension TEXT NOT NULL,
  inserted_at TIMESTAMP WITH TIME ZONE NOT NULL,
  payload JSONB,
  private BOOLEAN,
  topic TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: realtime.messages_2025_10_28
CREATE TABLE IF NOT EXISTS realtime.messages_2025_10_28 (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  event TEXT,
  extension TEXT NOT NULL,
  inserted_at TIMESTAMP WITH TIME ZONE NOT NULL,
  payload JSONB,
  private BOOLEAN,
  topic TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: realtime.messages_2025_10_29
CREATE TABLE IF NOT EXISTS realtime.messages_2025_10_29 (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  event TEXT,
  extension TEXT NOT NULL,
  inserted_at TIMESTAMP WITH TIME ZONE NOT NULL,
  payload JSONB,
  private BOOLEAN,
  topic TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: realtime.messages_2025_10_30
CREATE TABLE IF NOT EXISTS realtime.messages_2025_10_30 (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  event TEXT,
  extension TEXT NOT NULL,
  inserted_at TIMESTAMP WITH TIME ZONE NOT NULL,
  payload JSONB,
  private BOOLEAN,
  topic TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: realtime.messages_2025_10_31
CREATE TABLE IF NOT EXISTS realtime.messages_2025_10_31 (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  event TEXT,
  extension TEXT NOT NULL,
  inserted_at TIMESTAMP WITH TIME ZONE NOT NULL,
  payload JSONB,
  private BOOLEAN,
  topic TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: realtime.messages_2025_11_01
CREATE TABLE IF NOT EXISTS realtime.messages_2025_11_01 (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  event TEXT,
  extension TEXT NOT NULL,
  inserted_at TIMESTAMP WITH TIME ZONE NOT NULL,
  payload JSONB,
  private BOOLEAN,
  topic TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: realtime.schema_migrations
CREATE TABLE IF NOT EXISTS realtime.schema_migrations (
  inserted_at TIMESTAMP WITH TIME ZONE,
  version NUMERIC NOT NULL
);

-- Table: realtime.subscription
CREATE TABLE IF NOT EXISTS realtime.subscription (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  claims JSONB NOT NULL,
  claims_role BYTEA NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  entity BYTEA NOT NULL,
  filters JSONB NOT NULL,
  subscription_id UUID NOT NULL
);


-- ================================================================
-- SCHEMA: registry
-- Tables: 6
-- ================================================================

CREATE SCHEMA IF NOT EXISTS registry;

-- Table: registry.domain_inventory
CREATE TABLE IF NOT EXISTS registry.domain_inventory (
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  domain TEXT NOT NULL,
  is_credit_union BOOLEAN NOT NULL,
  notes TEXT,
  owner_label TEXT NOT NULL,
  source_url TEXT,
  status domain_status_enum NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: registry.exports
CREATE TABLE IF NOT EXISTS registry.exports (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  artifact TEXT NOT NULL,
  bytes NUMERIC NOT NULL,
  checksum TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  version TEXT NOT NULL
);

-- Table: registry.feature_flags
CREATE TABLE IF NOT EXISTS registry.feature_flags (
  enabled BOOLEAN NOT NULL,
  flag TEXT NOT NULL,
  notes TEXT,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: registry.institution_catalog
CREATE TABLE IF NOT EXISTS registry.institution_catalog (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  legal_name TEXT NOT NULL,
  metadata JSONB NOT NULL,
  regulator_id UUID,
  slug TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  website_url TEXT
);

-- Table: registry.migration_history
CREATE TABLE IF NOT EXISTS registry.migration_history (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  applied_at TIMESTAMP WITH TIME ZONE NOT NULL,
  checksum TEXT NOT NULL,
  log TEXT,
  name TEXT NOT NULL,
  status TEXT NOT NULL,
  version TEXT NOT NULL
);

-- Table: registry.settings
CREATE TABLE IF NOT EXISTS registry.settings (
  key TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  value JSONB NOT NULL
);


-- ================================================================
-- SCHEMA: storage
-- Tables: 9
-- ================================================================

CREATE SCHEMA IF NOT EXISTS storage;

-- Table: storage.buckets
CREATE TABLE IF NOT EXISTS storage.buckets (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  allowed_mime_types TEXT[],
  avif_autodetection BOOLEAN,
  created_at TIMESTAMP WITH TIME ZONE,
  file_size_limit NUMERIC,
  name TEXT NOT NULL,
  owner TEXT,
  owner_id UUID,
  public BOOLEAN,
  type buckettype NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: storage.buckets_analytics
CREATE TABLE IF NOT EXISTS storage.buckets_analytics (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMP WITH TIME ZONE,
  format TEXT NOT NULL,
  name TEXT NOT NULL,
  type buckettype NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: storage.buckets_vectors
CREATE TABLE IF NOT EXISTS storage.buckets_vectors (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  type buckettype NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: storage.migrations
CREATE TABLE IF NOT EXISTS storage.migrations (
  id BIGSERIAL NOT NULL PRIMARY KEY,
  executed_at TIMESTAMP WITH TIME ZONE,
  hash TEXT NOT NULL,
  name TEXT NOT NULL
);

-- Table: storage.objects
CREATE TABLE IF NOT EXISTS storage.objects (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  bucket_id UUID,
  created_at TIMESTAMP WITH TIME ZONE,
  last_accessed_at TIMESTAMP WITH TIME ZONE,
  level NUMERIC,
  metadata JSONB,
  name TEXT,
  owner TEXT,
  owner_id UUID,
  path_tokens TEXT[],
  updated_at TIMESTAMP WITH TIME ZONE,
  user_metadata JSONB,
  version TEXT
);

-- Table: storage.prefixes
CREATE TABLE IF NOT EXISTS storage.prefixes (
  bucket_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE,
  level NUMERIC NOT NULL,
  name TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Table: storage.s3_multipart_uploads
CREATE TABLE IF NOT EXISTS storage.s3_multipart_uploads (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  bucket_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  in_progress_size NUMERIC NOT NULL,
  key TEXT NOT NULL,
  owner_id UUID,
  upload_signature TEXT NOT NULL,
  user_metadata JSONB,
  version TEXT NOT NULL
);

-- Table: storage.s3_multipart_uploads_parts
CREATE TABLE IF NOT EXISTS storage.s3_multipart_uploads_parts (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  bucket_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  etag TEXT NOT NULL,
  key TEXT NOT NULL,
  owner_id UUID,
  part_number NUMERIC NOT NULL,
  size NUMERIC NOT NULL,
  upload_id UUID NOT NULL,
  version TEXT NOT NULL
);

-- Table: storage.vector_indexes
CREATE TABLE IF NOT EXISTS storage.vector_indexes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  bucket_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  data_type TEXT NOT NULL,
  dimension NUMERIC NOT NULL,
  distance_metric TEXT NOT NULL,
  metadata_configuration JSONB,
  name TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);


-- ================================================================
-- SCHEMA: supabase_migrations
-- Tables: 2
-- ================================================================

CREATE SCHEMA IF NOT EXISTS supabase_migrations;

-- Table: supabase_migrations.schema_migrations
CREATE TABLE IF NOT EXISTS supabase_migrations.schema_migrations (
  created_by TEXT,
  idempotency_key TEXT,
  name TEXT,
  rollback TEXT[],
  statements TEXT[],
  version TEXT NOT NULL
);

-- Table: supabase_migrations.seed_files
CREATE TABLE IF NOT EXISTS supabase_migrations.seed_files (
  hash TEXT NOT NULL,
  path TEXT NOT NULL
);


-- ================================================================
-- SCHEMA: tenancy
-- Tables: 2
-- ================================================================

CREATE SCHEMA IF NOT EXISTS tenancy;

-- Table: tenancy.api_keys
CREATE TABLE IF NOT EXISTS tenancy.api_keys (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  created_by TEXT,
  description TEXT,
  expires_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN NOT NULL,
  key_hash TEXT NOT NULL,
  key_prefix TEXT NOT NULL,
  last_used_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB NOT NULL,
  name TEXT NOT NULL,
  rate_limit_tier TEXT,
  revoked_at TIMESTAMP WITH TIME ZONE,
  revoked_by TEXT,
  scopes TEXT[] NOT NULL,
  tenant_id UUID NOT NULL,
  usage_count NUMERIC NOT NULL
);

-- Table: tenancy.tenants
CREATE TABLE IF NOT EXISTS tenancy.tenants (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  branding JSONB NOT NULL,
  charter_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  deactivated_at TIMESTAMP WITH TIME ZONE,
  full_domain TEXT,
  legal_name TEXT,
  ncua_number TEXT,
  routing_number TEXT,
  settings JSONB NOT NULL,
  slug TEXT,
  status tenant_status_enum NOT NULL,
  tier tier_enum NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);


-- ================================================================
-- SCHEMA: vault
-- Tables: 1
-- ================================================================

CREATE SCHEMA IF NOT EXISTS vault;

-- Table: vault.secrets
CREATE TABLE IF NOT EXISTS vault.secrets (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  description TEXT NOT NULL,
  key_id UUID,
  name TEXT,
  nonce TEXT,
  secret TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);


-- ================================================================
-- SCHEMA: work
-- Tables: 4
-- ================================================================

CREATE SCHEMA IF NOT EXISTS work;

-- Table: work.runs
CREATE TABLE IF NOT EXISTS work.runs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  finished_at TIMESTAMP WITH TIME ZONE,
  output JSONB,
  started_at TIMESTAMP WITH TIME ZONE,
  status workflow_status_enum NOT NULL,
  tenant_id UUID NOT NULL,
  workflow_id UUID NOT NULL
);

-- Table: work.signals
CREATE TABLE IF NOT EXISTS work.signals (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  data JSONB NOT NULL,
  key TEXT NOT NULL,
  run_id UUID NOT NULL
);

-- Table: work.tasks
CREATE TABLE IF NOT EXISTS work.tasks (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  attempts NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  key TEXT NOT NULL,
  payload JSONB NOT NULL,
  result JSONB,
  run_id UUID NOT NULL,
  status task_status_enum NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Table: work.workflows
CREATE TABLE IF NOT EXISTS work.workflows (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  definition JSONB NOT NULL,
  key TEXT NOT NULL,
  version TEXT NOT NULL
);


-- ================================================================
-- END OF MIGRATION
-- ================================================================

ledger/migrations/001_initial_schema.sql
```sql
-- Accounts table
CREATE TABLE accounts (
    id UUID PRIMARY KEY,
    account_type VARCHAR(20) NOT NULL CHECK (account_type IN ('Asset', 'Liability', 'Equity', 'Revenue', 'Expense')),
    currency VARCHAR(3) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata JSONB NOT NULL DEFAULT '{}',
    UNIQUE(id, currency)
);

-- Transactions table (append-only)
CREATE TABLE transactions (
    id UUID PRIMARY KEY,
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('Credit', 'Debit', 'Transfer', 'Reversal', 'Adjustment')),
    amount DECIMAL(20, 8) NOT NULL CHECK (amount > 0),
    source_account_id UUID REFERENCES accounts(id),
    destination_account_id UUID REFERENCES accounts(id),
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reason_code VARCHAR(50) NOT NULL,
    metadata JSONB NOT NULL DEFAULT '{}',
    idempotency_key VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CHECK (
        (transaction_type = 'Credit' AND destination_account_id IS NOT NULL) OR
        (transaction_type = 'Debit' AND source_account_id IS NOT NULL) OR
        (transaction_type = 'Transfer' AND source_account_id IS NOT NULL AND destination_account_id IS NOT NULL) OR
        (transaction_type IN ('Reversal', 'Adjustment'))
    )
);

-- Unique constraint for idempotency
CREATE UNIQUE INDEX idx_transactions_idempotency ON transactions(idempotency_key);

-- Entries table (double-entry bookkeeping)
CREATE TABLE entries (
    id UUID PRIMARY KEY,
    transaction_id UUID NOT NULL REFERENCES transactions(id) ON DELETE RESTRICT,
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,
    amount DECIMAL(20, 8) NOT NULL,
    entry_type VARCHAR(10) NOT NULL CHECK (entry_type IN ('Debit', 'Credit')),
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    balance_after DECIMAL(20, 8) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_entries_account_id ON entries(account_id);
CREATE INDEX idx_entries_transaction_id ON entries(transaction_id);
CREATE INDEX idx_entries_timestamp ON entries(timestamp);
CREATE INDEX idx_transactions_timestamp ON transactions(timestamp);

-- Balance view (materialized for performance)
CREATE MATERIALIZED VIEW account_balances AS
SELECT 
    a.id as account_id,
    a.currency,
    COALESCE(SUM(
        CASE 
            WHEN e.entry_type = 'Debit' THEN e.amount
            ELSE -e.amount
        END
    ), 0) as balance,
    MAX(e.timestamp) as last_activity
FROM accounts a
LEFT JOIN entries e ON a.id = e.account_id
GROUP BY a.id, a.currency;

CREATE UNIQUE INDEX idx_account_balances_account_id ON account_balances(account_id);
```


```markdown
<!-- Security Badges -->
![Security Foundational](https://img.shields.io/badge/security-foundational-blue)

<!-- Activity Badges -->
![Last Commit](https://img.shields.io/badge/commit-current-brightgreen)

<!-- Technology Badges -->
![License](https://img.shields.io/badge/license-MIT-yellow)
```
```markdown
<!-- Security Badges -->
![Security Foundational](https://img.shields.io/badge/security-foundational-blue)
![Security Scanning](https://img.shields.io/badge/security-scanning-inactive-red)

<!-- Activity Badges -->
![Last Commit](https://img.shields.io/badge/commit-recent-yellow)
![Release Status](https://img.shields.io/badge/releases-none-red)

<!-- Technology Badges -->
![License](https://img.shields.io/badge/license-MIT-yellow)

<!-- Quality Badges -->
![Documentation](https://img.shields.io/badge/docs-minimal-orange)

<!-- Community Badges -->
![Governance](https://img.shields.io/badge/governance-partial-orange)
```


**Core Badge Verification Workflow** (`.github/workflows/badge-verification.yml`):
```yaml
name: Badge Verification

on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight UTC
  push:
    paths:
      - '.github/workflows/**'
      - 'package.json'
      - 'requirements.txt'
  workflow_dispatch:

jobs:
  badge-verification:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Collect Repository Metrics
        run: |
          node scripts/collect-metrics.js
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Generate Badge Status
        run: |
          node scripts/compute-badges.js
      
      - name: Upload Badge Status
        uses: actions/upload-artifact@v4
        with:
          name: badge-status
          path: badge-status.json
```


```markdown
<!-- Security Badges -->
![Security Foundational](https://img.shields.io/badge/security-foundational-blue)

<!-- Activity Badges -->
![Last Commit](https://img.shields.io/badge/commit-current-brightgreen)

<!-- Technology Badges -->
![License](https://img.shields.io/badge/license-MIT-yellow)
```


```markdown
<!-- Security Badges -->
![Security Foundational](https://img.shields.io/badge/security-foundational-blue)
![Security Scanning](https://img.shields.io/badge/security-scanning-active-green)
![Dependency Status](https://img.shields.io/badge/deps-up--to--date-brightgreen)

<!-- Activity Badges -->
![Last Commit](https://img.shields.io/badge/commit-recent-yellow)
![Issues Health](https://img.shields.io/badge/issues-healthy-brightgreen)
![PR Velocity](https://img.shields.io/badge/PR-velocity-fast-brightgreen)

<!-- Maturity Badges -->
![CI Status](https://img.shields.io/badge/CI-passing-brightgreen)
![Versioning](https://img.shields.io/badge/versioning-semver-blue)
![Test Coverage](https://img.shields.io/badge/coverage-comprehensive-brightgreen)

<!-- Technology Badges -->
![Containerized](https://img.shields.io/badge/containerized-Docker-blue)
![CI Platform](https://img.shields.io/badge/CI-GitHub_Actions-blue)

<!-- Quality Badges -->
![Linting](https://img.shields.io/badge/linting-passing-brightgreen)
![Documentation](https://img.shields.io/badge/docs-complete-brightgreen)
![Code Owners](https://img.shields.io/badge/codeowners-defined-blue)

<!-- Community Badges -->
![License](https://img.shields.io/badge/license-MIT-yellow)
```


# Ledger
Core ledger and transaction
```markdown
# Ledger Service - Financial Source of Truth

## Overview
The Ledger service is the authoritative source for all financial transactions and balances in the system. It implements double-entry bookkeeping principles with full audit trails.

## Core Principles
- **Immutable Transactions**: Once recorded, transactions cannot be modified
- **Double-Entry Bookkeeping**: Every transaction affects at least two accounts
- **Balance Integrity**: Guaranteed through database constraints
- **Idempotency**: All operations are idempotent via idempotency keys
- **No Floating-Point**: Uses Decimal types for financial calculations

## Architecture
```

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│Transaction   │───▶│     Entry       │───▶│    Account      │
│(Journal)    │    │  (Ledger Post)  │    │   (Chart of    │
└─────────────────┘└─────────────────┘    │    Accounts)    │
│                                     └─────────────────┘
▼
┌─────────────────┐
│Reconciliation │
│Engine      │
└─────────────────┘

```

## API Endpoints (Internal Only)
- `POST /accounts` - Create new ledger account
- `POST /transactions` - Record new transaction
- `GET /accounts/:id/balance` - Get current balance
- `GET /accounts/:id/transactions` - Get transaction history
- `POST /reconcile` - Perform reconciliation

## Database Schema
See `migrations/001_initial_schema.sql` for complete schema.

## Transaction Types
1. **Credit** - Add funds to account (debit expense/liability, credit asset)
2. **Debit** - Remove funds from account (debit asset, credit revenue/liability)
3. **Transfer** - Move funds between accounts
4. **Reversal** - Reverse previous transaction
5. **Adjustment** - Manual adjustment with audit trail

## Safety Guarantees
- ACID transactions
- No negative balances (configurable per account type)
- Full audit trail
- Automatic reconciliation checks
```

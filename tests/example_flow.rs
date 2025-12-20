
```rust
#[cfg(test)]
mod tests {
    use super::*;
    use uuid::Uuid;
    use rust_decimal_macros::dec;

    #[tokio::test]
    async fn test_wallet_creation_and_transactions() {
        // 1. Create wallets for two users
        let wallet_service = setup_wallet_service();
        let ledger_service = setup_ledger_service();

        let user1_id = Uuid::new_v4();
        let user2_id = Uuid::new_v4();

        // Create wallet for user 1
        let wallet1 = wallet_service.create_wallet(
            user1_id,
            "USD",
            "Primary Wallet"
        ).await.expect("Failed to create wallet 1");

        // Create wallet for user 2
        let wallet2 = wallet_service.create_wallet(
            user2_id,
            "USD",
            "Primary Wallet"
        ).await.expect("Failed to create wallet 2");

        // 2. Deposit funds to wallet 1
        let deposit_intent = TransactionIntent::new(
            TransactionIntentType::Deposit,
            dec!(1000.00),
            None,
            Some(wallet1.id),
            "initial_deposit",
            "deposit_001",
        );

        let deposit_tx_id = wallet_service.execute_transaction(deposit_intent)
            .await
            .expect("Failed to deposit");

        // Verify balance
        let balance1 = ledger_service.get_account_balance(wallet1.id)
            .await
            .expect("Failed to get balance");
        assert_eq!(balance1, dec!(1000.00));

        // 3. Transfer from wallet 1 to wallet 2
        let transfer_intent = TransactionIntent::new(
            TransactionIntentType::Transfer,
            dec!(500.00),
            Some(wallet1.id),
            Some(wallet2.id),
            "peer_transfer",
            "transfer_001",
        );

        let transfer_tx_id = wallet_service.execute_transaction(transfer_intent)
            .await
            .expect("Failed to transfer");

        // Verify balances after transfer
        let balance1_after = ledger_service.get_account_balance(wallet1.id)
            .await
            .expect("Failed to get balance");
        let balance2_after = ledger_service.get_account_balance(wallet2.id)
            .await
            .expect("Failed to get balance");

        assert_eq!(balance1_after, dec!(500.00));
        assert_eq!(balance2_after, dec!(500.00));

        // 4. Attempt to transfer more than balance (should fail)
        let failed_intent = TransactionIntent::new(
            TransactionIntentType::Transfer,
            dec!(1000.00),
            Some(wallet1.id),
            Some(wallet2.id),
            "overdraft_attempt",
            "transfer_002",
        );

        let result = wallet_service.execute_transaction(failed_intent).await;
        assert!(result.is_err());

        // 5. Verify transaction history
        let transactions = ledger_service.get_account_transactions(wallet1.id, 10, 0)
            .await
            .expect("Failed to get transactions");

        assert_eq!(transactions.len(), 2); // Deposit and transfer

        println!("Test completed successfully!");
        println!("Wallet 1 final balance: {}", balance1_after);
        println!("Wallet 2 final balance: {}", balance2_after);
    }
}
```

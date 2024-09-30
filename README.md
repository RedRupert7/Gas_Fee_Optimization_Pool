# Gas Fee Optimization Pool Contract

## Overview

The **Gas Fee Optimization Pool Contract** is a Clarity smart contract designed to optimize STX transfers by batching multiple transactions into a pool, allowing efficient execution or cancellation of transactions. The contract enables users to queue their STX transfers, execute them in sequence, or cancel and refund transactions when necessary.

## Features

1. **Error Handling:**
   - Predefined error constants provide clear and consistent error messages:
     - `ERR_NO_TRANSACTIONS`: No transaction found.
     - `ERR_INSUFFICIENT_FUNDS`: Sender has insufficient funds.
     - `ERR_UNAUTHORIZED`: Unauthorized access.
     - `ERR_INVALID_AMOUNT`: Invalid transfer amount.
     - `ERR_INVALID_RECIPIENT`: Invalid recipient.
     - `ERR_INVALID_TX_ID`: Invalid transaction ID.

2. **Data Maps:**
   - **`tx-pool`**: Stores transaction details including the sender, recipient, and amount.

3. **Data Variables:**
   - **`tx-count`**: A counter that keeps track of the total number of transactions in the pool.

4. **Transaction Lifecycle:**
   - **Add Transaction**: Users can queue transactions into the pool.
   - **Execute Transaction**: Execute a specific transaction from the pool.
   - **Cancel Transaction**: Cancel and refund a transaction.
   - **Process Transactions in Batch**: Process multiple transactions in a specified range to optimize gas fees.

## Functions

### Private Functions

1. **`transfer-tx (tx-id uint)`**:
   - Transfers STX from the sender to the recipient and removes the transaction from the pool if successful.

2. **`refund-tx (tx-id uint)`**:
   - Refunds the transaction amount to the sender and removes the transaction from the pool.

### Public Functions

1. **`add-transaction (recipient principal, amount uint)`**:
   - Adds a transaction to the pool.
   - Checks for valid recipient and amount before transferring STX to the contract.

2. **`execute-single-tx (tx-id uint)`**:
   - Executes a transaction from the pool based on the given transaction ID.

3. **`cancel-single-tx (tx-id uint)`**:
   - Cancels a pending transaction and refunds the amount to the sender.

4. **`process-next-transaction (start-id uint, end-id uint)`**:
   - Processes the next transaction within the specified range to minimize gas fees.
   - Returns the next transaction ID to be processed.

5. **`get-pool-size ()`**:
   - Returns the current number of transactions in the pool.

## Usage

### Add a Transaction

```clarity
(add-transaction tx-recipient tx-amount)
```

- Adds a transaction to the pool.
- Parameters:
  - `recipient`: The principal address of the recipient.
  - `amount`: The amount of STX to transfer.

### Execute a Single Transaction

```clarity
(execute-single-tx tx-id)
```

- Executes a single transaction from the pool based on the provided `tx-id`.

### Cancel a Transaction

```clarity
(cancel-single-tx tx-id)
```

- Cancels the specified transaction and refunds the amount to the sender.

### Process Next Transaction

```clarity
(process-next-transaction start-id end-id)
```

- Processes the next transaction in the given range.

### Get Pool Size

```clarity
(get-pool-size)
```

- Returns the current size of the transaction pool.

## Error Handling

The contract implements robust error handling through constants:
- **ERR_NO_TRANSACTIONS**: No transaction found in the pool.
- **ERR_INSUFFICIENT_FUNDS**: Insufficient funds for the transfer.
- **ERR_UNAUTHORIZED**: Unauthorized transaction action.
- **ERR_INVALID_AMOUNT**: Invalid transaction amount (e.g., zero or negative).
- **ERR_INVALID_RECIPIENT**: Recipient is either the sender or the contract itself.
- **ERR_INVALID_TX_ID**: The transaction ID provided is invalid or does not exist.

## License

This contract is open-source and distributed under the MIT License. You are free to use, modify, and distribute this contract as needed.

---

Feel free to modify this README file to suit your project's needs!
;; Gas Fee Optimization Pool Contract

;; Constants
(define-constant ERR_NO_TRANSACTIONS (err u100))
(define-constant ERR_INSUFFICIENT_FUNDS (err u101))
(define-constant ERR_UNAUTHORIZED (err u102))
(define-constant ERR_INVALID_AMOUNT (err u103))
(define-constant ERR_INVALID_RECIPIENT (err u104))
(define-constant ERR_INVALID_TX_ID (err u105))

;; Data Maps
(define-map tx-pool
  { tx-id: uint }
  {
    sender: principal,
    recipient: principal,
    amount: uint
  }
)

;; Variables
(define-data-var tx-count uint u0)

;; Function Implementations
(define-private (transfer-tx (tx-id uint))
  (let ((tx-data (unwrap! (map-get? tx-pool {tx-id: tx-id}) ERR_NO_TRANSACTIONS)))
    (match (stx-transfer? (get amount tx-data) (get sender tx-data) (get recipient tx-data))
      success (begin
        (map-delete tx-pool {tx-id: tx-id})
        (ok success))
      error (err error))))

(define-private (refund-tx (tx-id uint))
  (let ((tx-data (unwrap! (map-get? tx-pool {tx-id: tx-id}) ERR_NO_TRANSACTIONS)))
    (match (as-contract (stx-transfer? (get amount tx-data) tx-sender (get sender tx-data)))
      success (begin
        (map-delete tx-pool {tx-id: tx-id})
        (ok success))
      error (err error))))

;; Public Functions
(define-public (add-transaction (recipient principal) (amount uint))
  (let (
    (sender tx-sender)
    (current-count (var-get tx-count))
  )
    ;; Check for valid amount
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    ;; Check for valid recipient (not sending to self or contract)
    (asserts! (and (not (is-eq recipient tx-sender)) (not (is-eq recipient (as-contract tx-sender)))) ERR_INVALID_RECIPIENT)
    ;; Perform the transfer
    (try! (stx-transfer? amount sender (as-contract tx-sender)))
    ;; Add to pool
    (map-set tx-pool
      {tx-id: current-count}
      {sender: sender, recipient: recipient, amount: amount})
    (var-set tx-count (+ current-count u1))
    (ok current-count)))

(define-public (execute-single-tx (tx-id uint))
  (begin
    (asserts! (< tx-id (var-get tx-count)) ERR_INVALID_TX_ID)
    (transfer-tx tx-id)))

(define-public (cancel-single-tx (tx-id uint))
  (begin
    (asserts! (< tx-id (var-get tx-count)) ERR_INVALID_TX_ID)
    (refund-tx tx-id)))

;; Instead of processing all at once, this processes only the next transaction in range
(define-public (process-next-transaction (start-id uint) (end-id uint))
  (begin
    (asserts! (< start-id (var-get tx-count)) ERR_INVALID_TX_ID)
    (asserts! (<= start-id end-id) ERR_INVALID_TX_ID)
    (if (<= start-id end-id)
      (let ((transfer-result (transfer-tx start-id)))
        (match transfer-result
          success (ok (+ start-id u1)) ;; Return the next tx-id to be processed
          error (err error))) ;; Return the error
      (ok end-id)))) ;; End of range or no transactions left to process

(define-public (get-pool-size)
  (ok (var-get tx-count)))
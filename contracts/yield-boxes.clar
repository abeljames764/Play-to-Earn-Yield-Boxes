(define-non-fungible-token yield-box uint)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-token-not-found (err u102))
(define-constant err-already-staking (err u103))
(define-constant err-not-staking (err u104))
(define-constant err-insufficient-balance (err u105))
(define-constant err-invalid-amount (err u106))

(define-data-var token-id-nonce uint u1)
(define-data-var base-reward-rate uint u100)
(define-data-var contract-balance uint u0)

(define-map token-metadata uint {
    rarity: (string-ascii 20),
    multiplier: uint,
    created-at: uint
})

(define-map staking-data uint {
    staked-at: uint,
    rewards-claimed: uint,
    is-staking: bool
})

(define-map user-stats principal {
    boxes-owned: uint,
    total-rewards: uint,
    boxes-staking: uint
})

(define-public (mint-yield-box (recipient principal) (rarity (string-ascii 20)))
    (let (
        (token-id (var-get token-id-nonce))
        (multiplier (get-rarity-multiplier rarity))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (nft-mint? yield-box token-id recipient))
    (map-set token-metadata token-id {
        rarity: rarity,
        multiplier: multiplier,
        created-at: stacks-block-height
    })
    (map-set user-stats recipient 
        (merge (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                (map-get? user-stats recipient))
               {boxes-owned: (+ (get boxes-owned (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                                                  (map-get? user-stats recipient))) u1)}))
    (var-set token-id-nonce (+ token-id u1))
    (ok token-id)))

(define-public (start-staking (token-id uint))
    (let (
        (token-owner (unwrap! (nft-get-owner? yield-box token-id) err-token-not-found))
        (current-staking (default-to {staked-at: u0, rewards-claimed: u0, is-staking: false}
                         (map-get? staking-data token-id)))
    )
    (asserts! (is-eq tx-sender token-owner) err-not-token-owner)
    (asserts! (not (get is-staking current-staking)) err-already-staking)
    (map-set staking-data token-id {
        staked-at: stacks-block-height,
        rewards-claimed: u0,
        is-staking: true
    })
    (map-set user-stats tx-sender
        (merge (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                (map-get? user-stats tx-sender))
               {boxes-staking: (+ (get boxes-staking (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                                                      (map-get? user-stats tx-sender))) u1)}))
    (ok true)))

(define-public (stop-staking (token-id uint))
    (let (
        (token-owner (unwrap! (nft-get-owner? yield-box token-id) err-token-not-found))
        (current-staking (unwrap! (map-get? staking-data token-id) err-not-staking))
    )
    (asserts! (is-eq tx-sender token-owner) err-not-token-owner)
    (asserts! (get is-staking current-staking) err-not-staking)
    (map-set staking-data token-id
        (merge current-staking {is-staking: false}))
    (map-set user-stats tx-sender
        (merge (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                (map-get? user-stats tx-sender))
               {boxes-staking: (- (get boxes-staking (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                                                      (map-get? user-stats tx-sender))) u1)}))
    (ok true)))

(define-public (claim-rewards (token-id uint))
    (let (
        (token-owner (unwrap! (nft-get-owner? yield-box token-id) err-token-not-found))
        (staking-info (unwrap! (map-get? staking-data token-id) err-not-staking))
        (token-meta (unwrap! (map-get? token-metadata token-id) err-token-not-found))
        (rewards (calculate-rewards token-id))
    )
    (asserts! (is-eq tx-sender token-owner) err-not-token-owner)
    (asserts! (get is-staking staking-info) err-not-staking)
    (asserts! (> rewards u0) err-invalid-amount)
    (asserts! (>= (var-get contract-balance) rewards) err-insufficient-balance)
    (try! (as-contract (stx-transfer? rewards tx-sender token-owner)))
    (map-set staking-data token-id
        (merge staking-info {rewards-claimed: (+ (get rewards-claimed staking-info) rewards)}))
    (map-set user-stats token-owner
        (merge (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                (map-get? user-stats token-owner))
               {total-rewards: (+ (get total-rewards (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                                                      (map-get? user-stats token-owner))) rewards)}))
    (var-set contract-balance (- (var-get contract-balance) rewards))
    (ok rewards)))

(define-public (deposit-rewards (amount uint))
    (begin
    (asserts! (> amount u0) err-invalid-amount)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set contract-balance (+ (var-get contract-balance) amount))
    (ok true)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (let (
        (current-staking (default-to {staked-at: u0, rewards-claimed: u0, is-staking: false}
                         (map-get? staking-data token-id)))
    )
    (if (get is-staking current-staking)
        (begin
        (map-set staking-data token-id
            (merge current-staking {is-staking: false}))
        (map-set user-stats sender
            (merge (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                    (map-get? user-stats sender))
                   {boxes-owned: (- (get boxes-owned (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                                                      (map-get? user-stats sender))) u1),
                    boxes-staking: (- (get boxes-staking (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                                                          (map-get? user-stats sender))) u1)}))
        (map-set user-stats recipient
            (merge (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                    (map-get? user-stats recipient))
                   {boxes-owned: (+ (get boxes-owned (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                                                      (map-get? user-stats recipient))) u1)})))
        (begin
        (map-set user-stats sender
            (merge (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                    (map-get? user-stats sender))
                   {boxes-owned: (- (get boxes-owned (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                                                      (map-get? user-stats sender))) u1)}))
        (map-set user-stats recipient
            (merge (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                    (map-get? user-stats recipient))
                   {boxes-owned: (+ (get boxes-owned (default-to {boxes-owned: u0, total-rewards: u0, boxes-staking: u0}
                                                      (map-get? user-stats recipient))) u1)}))))
    (nft-transfer? yield-box token-id sender recipient))))

(define-read-only (get-token-metadata (token-id uint))
    (map-get? token-metadata token-id))

(define-read-only (get-staking-data (token-id uint))
    (map-get? staking-data token-id))

(define-read-only (get-user-stats (user principal))
    (map-get? user-stats user))

(define-read-only (calculate-rewards (token-id uint))
    (let (
        (staking-info (default-to {staked-at: u0, rewards-claimed: u0, is-staking: false}
                      (map-get? staking-data token-id)))
        (token-meta (default-to {rarity: "", multiplier: u1, created-at: u0}
                    (map-get? token-metadata token-id)))
        (blocks-staked (if (get is-staking staking-info)
                          (- stacks-block-height (get staked-at staking-info))
                          u0))
        (base-reward (* blocks-staked (var-get base-reward-rate)))
        (multiplied-reward (* base-reward (get multiplier token-meta)))
    )
    (if (get is-staking staking-info)
        multiplied-reward
        u0)))

(define-read-only (get-contract-balance)
    (var-get contract-balance))

(define-read-only (get-next-token-id)
    (var-get token-id-nonce))

(define-private (get-rarity-multiplier (rarity (string-ascii 20)))
    (if (is-eq rarity "legendary")
        u5
        (if (is-eq rarity "epic")
            u3
            (if (is-eq rarity "rare")
                u2
                u1))))

(define-public (set-base-reward-rate (new-rate uint))
    (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set base-reward-rate new-rate)
    (ok true)))

(define-public (withdraw-excess (amount uint))
    (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= amount (var-get contract-balance)) err-insufficient-balance)
    (try! (as-contract (stx-transfer? amount tx-sender contract-owner)))
    (var-set contract-balance (- (var-get contract-balance) amount))
    (ok true)))

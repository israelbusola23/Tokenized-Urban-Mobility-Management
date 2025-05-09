;; Service Provider Verification Contract
;; This contract validates transportation operators in the system

(define-data-var admin principal tx-sender)

;; Map to store verified service providers
(define-map verified-providers
  principal
  {
    name: (string-utf8 100),
    verified: bool,
    verification-date: uint,
    rating: uint,
    active: bool
  }
)

;; Public function to register a new service provider (admin only)
(define-public (register-provider (provider principal) (name (string-utf8 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (asserts! (is-none (map-get? verified-providers provider)) (err u2))
    (ok (map-set verified-providers
      provider
      {
        name: name,
        verified: true,
        verification-date: block-height,
        rating: u0,
        active: true
      }
    ))
  )
)

;; Public function to update provider status (admin only)
(define-public (update-provider-status (provider principal) (active bool))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (asserts! (is-some (map-get? verified-providers provider)) (err u3))
    (ok (map-set verified-providers
      provider
      (merge (unwrap-panic (map-get? verified-providers provider)) { active: active })
    ))
  )
)

;; Public function to update provider rating (admin only)
(define-public (update-provider-rating (provider principal) (new-rating uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (asserts! (is-some (map-get? verified-providers provider)) (err u3))
    (asserts! (<= new-rating u5) (err u4))
    (ok (map-set verified-providers
      provider
      (merge (unwrap-panic (map-get? verified-providers provider)) { rating: new-rating })
    ))
  )
)

;; Read-only function to check if a provider is verified
(define-read-only (is-verified-provider (provider principal))
  (match (map-get? verified-providers provider)
    provider-data (and (get verified provider-data) (get active provider-data))
    false
  )
)

;; Read-only function to get provider details
(define-read-only (get-provider-details (provider principal))
  (map-get? verified-providers provider)
)

;; Function to transfer admin rights (admin only)
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (ok (var-set admin new-admin))
  )
)

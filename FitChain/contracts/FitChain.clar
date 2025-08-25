;; FitChain - Move. Earn. Achieve.
;; A decentralized fitness tracking and challenge platform
;; Features: Workout tracking, fitness challenges, health rewards

;; ===================================
;; CONSTANTS AND ERROR CODES
;; ===================================

(define-constant ERR-NOT-AUTHORIZED (err u90))
(define-constant ERR-CHALLENGE-NOT-FOUND (err u91))
(define-constant ERR-INVALID-WORKOUT (err u92))
(define-constant ERR-CHALLENGE-ENDED (err u93))
(define-constant ERR-ALREADY-JOINED (err u94))
(define-constant ERR-INSUFFICIENT-PROGRESS (err u95))

;; Contract constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant MAX-DAILY-WORKOUTS u5)
(define-constant MIN-WORKOUT_DURATION u10) ;; 10 minutes minimum
(define-constant CHALLENGE-DURATION u1440) ;; ~10 days
(define-constant FITNESS-MULTIPLIER u2)

;; ===================================
;; DATA VARIABLES
;; ===================================

(define-data-var platform-active bool true)
(define-data-var challenge-counter uint u0)
(define-data-var total-workouts uint u0)
(define-data-var total-rewards-earned uint u0)

;; ===================================
;; TOKEN DEFINITIONS
;; ===================================

;; Fitness reward tokens
(define-fungible-token fit-token)

;; ===================================
;; DATA MAPS
;; ===================================

;; Fitness challenges
(define-map challenges
  uint
  {
    title: (string-ascii 64),
    description: (string-ascii 128),
    goal-type: (string-ascii 32),
    target-amount: uint,
    reward-pool: uint,
    start-block: uint,
    end-block: uint,
    participants: uint,
    completed-count: uint,
    active: bool
  }
)

;; User fitness profiles
(define-map user-profiles
  principal
  {
    total-workouts: uint,
    total-duration: uint,
    calories-burned: uint,
    fitness-level: uint,
    current-streak: uint,
    best-streak: uint,
    last-workout: uint
  }
)

;; Daily fitness tracking
(define-map daily-fitness
  { user: principal, day: uint }
  {
    workouts-today: uint,
    duration-today: uint,
    calories-today: uint,
    goals-met: bool
  }
)

;; Challenge participation
(define-map challenge-participants
  { challenge-id: uint, user: principal }
  {
    joined-at: uint,
    progress-amount: uint,
    completed: bool,
    reward-claimed: bool
  }
)

;; Workout records
(define-map workout-records
  uint
  {
    user: principal,
    workout-type: (string-ascii 32),
    duration: uint,
    calories: uint,
    intensity: uint,
    recorded-at: uint
  }
)

;; ===================================
;; PRIVATE HELPER FUNCTIONS
;; ===================================

(define-private (is-contract-owner (user principal))
  (is-eq user CONTRACT-OWNER)
)

(define-private (get-current-day)
  (/ burn-block-height u144)
)

(define-private (calculate-user-level (workout-count uint) (avg-duration uint))
  (if (< workout-count u10) u1
    (if (< workout-count u50) u2
      (if (< avg-duration u30) u3
        (if (< avg-duration u60) u4 u5)
      )
    )
  )
)

(define-private (can-workout-today (user principal))
  (let (
    (current-day (get-current-day))
    (daily-data (default-to { workouts-today: u0, duration-today: u0, calories-today: u0, goals-met: false }
                            (map-get? daily-fitness { user: user, day: current-day })))
  )
    (< (get workouts-today daily-data) MAX-DAILY-WORKOUTS)
  )
)

(define-private (is-challenge-active (challenge-id uint))
  (match (map-get? challenges challenge-id)
    challenge-data
    (and
      (get active challenge-data)
      (>= burn-block-height (get start-block challenge-data))
      (<= burn-block-height (get end-block challenge-data))
    )
    false
  )
)

;; ===================================
;; READ-ONLY FUNCTIONS
;; ===================================

(define-read-only (get-platform-stats)
  {
    active: (var-get platform-active),
    total-challenges: (var-get challenge-counter),
    total-workouts: (var-get total-workouts),
    total-rewards: (var-get total-rewards-earned)
  }
)

(define-read-only (get-challenge (challenge-id uint))
  (map-get? challenges challenge-id)
)

(define-read-only (get-user-profile (user principal))
  (map-get? user-profiles user)
)

(define-read-only (get-daily-fitness (user principal) (day uint))
  (map-get? daily-fitness { user: user, day: day })
)

(define-read-only (get-challenge-participation (challenge-id uint) (user principal))
  (map-get? challenge-participants { challenge-id: challenge-id, user: user })
)

(define-read-only (get-workout-record (workout-id uint))
  (map-get? workout-records workout-id)
)

;; ===================================
;; ADMIN FUNCTIONS
;; ===================================

(define-public (toggle-platform (active bool))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR-NOT-AUTHORIZED)
    (var-set platform-active active)
    (print { action: "platform-toggled", active: active })
    (ok true)
  )
)

(define-public (create-fitness-challenge
  (title (string-ascii 64))
  (description (string-ascii 128))
  (goal-type (string-ascii 32))
  (target-amount uint)
  (reward-pool uint)
)
  (let (
    (challenge-id (+ (var-get challenge-counter) u1))
    (start-block (+ burn-block-height u144))
    (end-block (+ start-block CHALLENGE-DURATION))
  )
    (asserts! (is-contract-owner tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> target-amount u0) ERR-INVALID-WORKOUT)
    (asserts! (> reward-pool u0) ERR-INVALID-WORKOUT)
    
    ;; Mint reward tokens for challenge
    (try! (ft-mint? fit-token reward-pool (as-contract tx-sender)))
    
    ;; Create challenge
    (map-set challenges challenge-id {
      title: title,
      description: description,
      goal-type: goal-type,
      target-amount: target-amount,
      reward-pool: reward-pool,
      start-block: start-block,
      end-block: end-block,
      participants: u0,
      completed-count: u0,
      active: true
    })
    
    (var-set challenge-counter challenge-id)
    (print { action: "challenge-created", challenge-id: challenge-id, title: title, reward: reward-pool })
    (ok challenge-id)
  )
)

(define-public (fund-fitness-rewards (amount uint))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> amount u0) ERR-INVALID-WORKOUT)
    
    (try! (ft-mint? fit-token amount (as-contract tx-sender)))
    (print { action: "rewards-funded", amount: amount })
    (ok true)
  )
)

;; ===================================
;; FITNESS TRACKING FUNCTIONS
;; ===================================

(define-public (record-workout
  (workout-type (string-ascii 32))
  (duration uint)
  (calories uint)
  (intensity uint)
)
  (let (
    (workout-id (+ (var-get total-workouts) u1))
    (current-day (get-current-day))
    (user-stats (default-to { total-workouts: u0, total-duration: u0, calories-burned: u0, fitness-level: u0, current-streak: u0, best-streak: u0, last-workout: u0 }
                            (map-get? user-profiles tx-sender)))
    (daily-data (default-to { workouts-today: u0, duration-today: u0, calories-today: u0, goals-met: false }
                            (map-get? daily-fitness { user: tx-sender, day: current-day })))
    (new-streak (if (is-eq (get last-workout user-stats) (- current-day u1))
                   (+ (get current-streak user-stats) u1)
                   u1))
  )
    (asserts! (var-get platform-active) ERR-NOT-AUTHORIZED)
    (asserts! (>= duration MIN-WORKOUT_DURATION) ERR-INVALID-WORKOUT)
    (asserts! (can-workout-today tx-sender) ERR-INVALID-WORKOUT)
    (asserts! (<= intensity u5) ERR-INVALID-WORKOUT)
    
    ;; Record workout
    (map-set workout-records workout-id {
      user: tx-sender,
      workout-type: workout-type,
      duration: duration,
      calories: calories,
      intensity: intensity,
      recorded-at: burn-block-height
    })
    
    ;; Update user profile
    (let (
      (new-total-duration (+ (get total-duration user-stats) duration))
      (new-total-workouts (+ (get total-workouts user-stats) u1))
      (avg-duration (if (> new-total-workouts u0) (/ new-total-duration new-total-workouts) u0))
      (new-fitness-level (calculate-user-level new-total-workouts avg-duration))
      (new-best-streak (if (> new-streak (get best-streak user-stats)) new-streak (get best-streak user-stats)))
    )
      (map-set user-profiles tx-sender {
        total-workouts: new-total-workouts,
        total-duration: new-total-duration,
        calories-burned: (+ (get calories-burned user-stats) calories),
        fitness-level: new-fitness-level,
        current-streak: new-streak,
        best-streak: new-best-streak,
        last-workout: current-day
      })
    )
    
    ;; Update daily fitness
    (map-set daily-fitness { user: tx-sender, day: current-day } {
      workouts-today: (+ (get workouts-today daily-data) u1),
      duration-today: (+ (get duration-today daily-data) duration),
      calories-today: (+ (get calories-today daily-data) calories),
      goals-met: (>= (+ (get duration-today daily-data) duration) u30) ;; 30 min daily goal
    })
    
    ;; Award base fitness tokens
    (try! (ft-mint? fit-token (* intensity FITNESS-MULTIPLIER) tx-sender))
    
    ;; Update global stats
    (var-set total-workouts workout-id)
    
    (print { action: "workout-recorded", user: tx-sender, type: workout-type, duration: duration, calories: calories })
    (ok workout-id)
  )
)

;; ===================================
;; CHALLENGE FUNCTIONS
;; ===================================

(define-public (join-challenge (challenge-id uint))
  (let (
    (challenge-data (unwrap! (map-get? challenges challenge-id) ERR-CHALLENGE-NOT-FOUND))
    (existing-participation (map-get? challenge-participants { challenge-id: challenge-id, user: tx-sender }))
  )
    (asserts! (var-get platform-active) ERR-NOT-AUTHORIZED)
    (asserts! (is-challenge-active challenge-id) ERR-CHALLENGE-ENDED)
    (asserts! (is-none existing-participation) ERR-ALREADY-JOINED)
    
    ;; Add participant
    (map-set challenge-participants { challenge-id: challenge-id, user: tx-sender } {
      joined-at: burn-block-height,
      progress-amount: u0,
      completed: false,
      reward-claimed: false
    })
    
    ;; Update challenge participant count
    (map-set challenges challenge-id (merge challenge-data {
      participants: (+ (get participants challenge-data) u1)
    }))
    
    (print { action: "challenge-joined", challenge-id: challenge-id, user: tx-sender })
    (ok true)
  )
)

(define-public (update-challenge-progress (challenge-id uint) (progress uint))
  (let (
    (challenge-data (unwrap! (map-get? challenges challenge-id) ERR-CHALLENGE-NOT-FOUND))
    (participant-data (unwrap! (map-get? challenge-participants { challenge-id: challenge-id, user: tx-sender }) ERR-CHALLENGE-NOT-FOUND))
  )
    (asserts! (var-get platform-active) ERR-NOT-AUTHORIZED)
    (asserts! (is-challenge-active challenge-id) ERR-CHALLENGE-ENDED)
    (asserts! (not (get completed participant-data)) ERR-CHALLENGE-ENDED)
    
    ;; Update progress
    (let (
      (new-progress (+ (get progress-amount participant-data) progress))
      (is-completed (>= new-progress (get target-amount challenge-data)))
    )
      (map-set challenge-participants { challenge-id: challenge-id, user: tx-sender } (merge participant-data {
        progress-amount: new-progress,
        completed: is-completed
      }))
      
      ;; If completed, update challenge completion count
      (if (and is-completed (not (get completed participant-data)))
        (map-set challenges challenge-id (merge challenge-data {
          completed-count: (+ (get completed-count challenge-data) u1)
        }))
        true
      )
    )
    
    (print { action: "challenge-progress-updated", challenge-id: challenge-id, user: tx-sender, progress: progress })
    (ok true)
  )
)

(define-public (claim-challenge-reward (challenge-id uint))
  (let (
    (challenge-data (unwrap! (map-get? challenges challenge-id) ERR-CHALLENGE-NOT-FOUND))
    (participant-data (unwrap! (map-get? challenge-participants { challenge-id: challenge-id, user: tx-sender }) ERR-CHALLENGE-NOT-FOUND))
    (reward-share (if (> (get completed-count challenge-data) u0)
                    (/ (get reward-pool challenge-data) (get completed-count challenge-data))
                    u0))
  )
    (asserts! (var-get platform-active) ERR-NOT-AUTHORIZED)
    (asserts! (> burn-block-height (get end-block challenge-data)) ERR-CHALLENGE-ENDED)
    (asserts! (get completed participant-data) ERR-INSUFFICIENT-PROGRESS)
    (asserts! (not (get reward-claimed participant-data)) ERR-ALREADY-JOINED)
    
    ;; Transfer reward
    (try! (as-contract (ft-transfer? fit-token reward-share tx-sender tx-sender)))
    
    ;; Mark reward as claimed
    (map-set challenge-participants { challenge-id: challenge-id, user: tx-sender } (merge participant-data {
      reward-claimed: true
    }))
    
    ;; Update global stats
    (var-set total-rewards-earned (+ (var-get total-rewards-earned) reward-share))
    
    (print { action: "challenge-reward-claimed", challenge-id: challenge-id, user: tx-sender, reward: reward-share })
    (ok reward-share)
  )
)

;; Simplified personal goal function without complex logic
(define-public (set-fitness-goal
  (goal-type (string-ascii 32))
  (target-value uint)
)
  (begin
    (asserts! (var-get platform-active) ERR-NOT-AUTHORIZED)
    (asserts! (> target-value u0) ERR-INVALID-WORKOUT)
    
    ;; Award goal-setting bonus
    (try! (ft-mint? fit-token u25 tx-sender))
    
    (print { action: "fitness-goal-set", user: tx-sender, type: goal-type, target: target-value })
    (ok true)
  )
)

(define-public (earn-milestone-bonus (milestone-type (string-ascii 32)))
  (let (
    (milestone-reward (if (is-eq milestone-type "streak-week") u100
                        (if (is-eq milestone-type "level-up") u200 u50)))
  )
    (asserts! (var-get platform-active) ERR-NOT-AUTHORIZED)
    
    ;; Award milestone bonus
    (try! (ft-mint? fit-token milestone-reward tx-sender))
    
    (print { action: "milestone-bonus", user: tx-sender, type: milestone-type, reward: milestone-reward })
    (ok milestone-reward)
  )
)

;; ===================================
;; INITIALIZATION
;; ===================================

(begin
  (print "FitChain Platform Initialized")
  (print "Move. Earn. Achieve.")
)
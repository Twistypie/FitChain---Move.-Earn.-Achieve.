# 💪 FitChain - Move. Earn. Achieve.

A decentralized fitness tracking and challenge platform built on Stacks blockchain that rewards users with fit tokens for completing workouts, achieving fitness goals, and participating in community challenges.

## 📋 Overview

FitChain gamifies fitness by converting physical activity into measurable blockchain rewards. Track workouts, join community challenges, build fitness streaks, and earn tokens for maintaining an active lifestyle with transparent, verifiable progress.

## ✨ Key Features

### 🏃‍♂️ Comprehensive Workout Tracking
- Multi-type workout logging (cardio, strength, yoga, sports)
- Duration and intensity tracking with calorie estimation
- Daily workout limits (5 max) to encourage consistency
- Minimum 10-minute workouts for quality assurance

### 🏆 Gamified Fitness Progression
- 5-level fitness progression system based on activity
- Workout streaks with personal best tracking
- Daily fitness goals (30 minutes recommended)
- Milestone celebrations with bonus token rewards

### 🎯 Community Fitness Challenges
- Admin-created challenges with reward pools
- Various goal types (duration, calories, frequency)
- 10-day challenge periods for sustained engagement
- Shared rewards among successful participants

### 💰 Fit Token Reward System
- Earn tokens based on workout intensity (2x multiplier)
- Milestone bonuses for achievements and streaks
- Challenge completion rewards from shared pools
- Personal goal setting bonuses

## 🏗️ Architecture

### Core Components
```clarity
challenges          -> Community fitness challenges with reward pools
user-profiles       -> Personal fitness stats and progression
daily-fitness       -> Daily activity tracking and goal monitoring
challenge-participants -> Challenge enrollment and progress tracking
workout-records     -> Individual workout logging and verification
```

### Fitness Flow
1. **Workout Logging**: Record exercise activities with metrics
2. **Progress Tracking**: Build streaks and advance fitness levels
3. **Challenge Participation**: Join community fitness challenges
4. **Goal Achievement**: Complete personal and community objectives
5. **Reward Earning**: Receive fit tokens for consistent activity

## 🚀 Getting Started

### For Fitness Enthusiasts

1. **Log Workouts**: Record your fitness activities
   ```clarity
   (record-workout workout-type duration calories intensity)
   ```

2. **Join Challenges**: Participate in community fitness goals
   ```clarity
   (join-challenge challenge-id)
   ```

3. **Track Progress**: Update challenge advancement
   ```clarity
   (update-challenge-progress challenge-id progress)
   ```

4. **Claim Rewards**: Collect tokens for completed challenges
   ```clarity
   (claim-challenge-reward challenge-id)
   ```

### For Platform Administrators

1. **Create Challenges**: Design community fitness goals
   ```clarity
   (create-fitness-challenge title description goal-type target reward-pool)
   ```

2. **Fund Rewards**: Add tokens to reward ecosystem
   ```clarity
   (fund-fitness-rewards amount)
   ```

## 📈 Example Scenarios

### Daily Fitness Routine
```
1. Morning yoga session: 30 minutes, intensity 2 → 4 fit tokens
2. Afternoon strength training: 45 minutes, intensity 4 → 8 fit tokens
3. Evening walk: 20 minutes, intensity 1 → 2 fit tokens
4. Daily goal achieved (30+ minutes) → streak continues
5. Total daily rewards: 14 fit tokens + streak bonuses
```

### Community Challenge Success
```
1. "March Madness Cardio" challenge: 500 minutes in 10 days
2. User joins challenge, logs cardio workouts daily
3. Reaches 500 minutes by day 8 → challenge completed
4. 50 participants completed out of 100 joined
5. Reward pool: 1000 tokens ÷ 50 completers = 20 tokens each
```

### Fitness Level Progression
```
1. New user starts at Fitness Level 1 (Beginner)
2. Completes 10 workouts with good duration → Level 2
3. Maintains 45+ minute average workouts → Level 3
4. 50+ workouts with consistent intensity → Level 4
5. Advanced athlete status: Level 5 with premium rewards
```

## ⚙️ Configuration

### Workout Parameters
- **Daily Limit**: 5 workouts maximum per day
- **Minimum Duration**: 10 minutes per workout
- **Intensity Scale**: 1-5 (light to high intensity)
- **Daily Goal**: 30 minutes total activity

### Challenge Settings
- **Duration**: 10 days (~1,440 blocks)
- **Goal Types**: Duration, calories, workout count, streaks
- **Reward Distribution**: Equal sharing among completers
- **Participation**: Open enrollment during active period

### Token Economics
- **Base Rewards**: Intensity level × 2 fit tokens per workout
- **Milestone Bonuses**: 25-300 tokens for achievements
- **Challenge Rewards**: Varies by pool size and participants
- **Goal Setting**: 25 token bonus for creating personal goals

## 🔒 Security Features

### Workout Verification
- Minimum duration requirements prevent spam workouts
- Daily limits encourage quality over quantity
- Intensity validation ensures realistic activity levels
- Streak calculation prevents gaming through backdating

### Challenge Integrity
- Time-bound challenges with clear start/end periods
- Progress tracking prevents false completion claims
- Reward distribution only after challenge completion
- Participant verification for legitimate enrollment

### Error Handling
```clarity
ERR-NOT-AUTHORIZED (u90)        -> Insufficient permissions
ERR-CHALLENGE-NOT-FOUND (u91)   -> Invalid challenge ID
ERR-INVALID-WORKOUT (u92)       -> Invalid workout parameters
ERR-CHALLENGE-ENDED (u93)       -> Challenge period expired
ERR-ALREADY-JOINED (u94)        -> Already participating in challenge
ERR-INSUFFICIENT-PROGRESS (u95) -> Progress below completion threshold
```

## 📊 Analytics

### Platform Metrics
- Total fitness challenges created and completed
- Community workout count and participation rates
- Fit tokens distributed and milestone achievements
- User engagement and retention statistics

### Personal Fitness
- Individual workout history and progression
- Fitness level advancement and streak tracking
- Challenge participation and success rates
- Token earnings and milestone celebrations

### Challenge Performance
- Challenge completion rates and participant engagement
- Popular challenge types and goal preferences
- Reward distribution patterns and pool effectiveness
- Community motivation and social fitness trends

## 🛠️ Development

### Prerequisites
- Clarinet CLI installed
- Understanding of fitness tracking metrics
- Blockchain development environment

### Local Testing
```bash
# Validate contract
clarinet check

# Run fitness tracking tests
clarinet test

# Deploy to testnet
clarinet deploy --testnet
```

### Integration Examples
```clarity
;; Log cardio workout
(contract-call? .fitchain record-workout "Running" u45 u400 u3)

;; Join community challenge
(contract-call? .fitchain join-challenge u1)

;; Update challenge progress
(contract-call? .fitchain update-challenge-progress u1 u60)

;; Set personal fitness goal
(contract-call? .fitchain set-fitness-goal "weight-loss" u10)

;; Earn milestone bonus
(contract-call? .fitchain earn-milestone-bonus "streak-week")

;; Check personal fitness stats
(contract-call? .fitchain get-user-profile tx-sender)
```

## 🎯 Use Cases

### Personal Fitness
- Individual workout tracking and progression monitoring
- Fitness goal setting and achievement rewards
- Habit formation through streak building and daily goals
- Motivation through token rewards and level advancement

### Community Wellness
- Corporate fitness programs with team challenges
- Gym and fitness center member engagement platforms
- Health insurance incentive programs with verifiable activity
- Social fitness groups with shared goals and rewards

### Fitness Education
- Physical education programs in schools with gamified tracking
- Personal trainer client progress monitoring and motivation
- Rehabilitation and physical therapy progress measurement
- Wellness coaching with transparent progress verification

## 📋 Quick Reference

### Core Functions
```clarity
;; Workout Tracking
record-workout(type, duration, calories, intensity) -> workout-id
set-fitness-goal(type, target) -> success
earn-milestone-bonus(milestone-type) -> reward-amount

;; Challenge Management
join-challenge(challenge-id) -> success
update-challenge-progress(challenge-id, progress) -> success
claim-challenge-reward(challenge-id) -> reward-amount

;; Information Queries
get-user-profile(user) -> fitness-stats
get-challenge(challenge-id) -> challenge-data
get-daily-fitness(user, day) -> daily-activity
get-challenge-participation(challenge-id, user) -> participation-data
```

## 🚦 Deployment Guide

1. Deploy contract to target Stacks network
2. Fund initial fit token reward pools
3. Create engaging fitness challenges for launch
4. Integrate with fitness tracking apps and devices
5. Monitor user engagement and challenge completion
6. Scale challenge variety based on community preferences

## 🌟 Platform Benefits

### For Users
- **Motivation**: Token rewards provide tangible fitness incentives
- **Community**: Join others in shared fitness goals and challenges
- **Progress**: Clear tracking of fitness journey and achievements
- **Flexibility**: Various workout types and intensity levels supported

### For Fitness Industry
- **Engagement**: Gamification increases user retention and activity
- **Verification**: Blockchain provides transparent progress tracking
- **Incentives**: Token rewards supplement traditional fitness programs
- **Community**: Platform builds active, motivated user communities

## 🤝 Contributing

FitChain welcomes community contributions:
- New challenge types and fitness goal categories
- Integration with popular fitness tracking devices
- Advanced analytics and progress visualization features
- Community features and social fitness enhancements

---

**⚠️ Disclaimer**: FitChain is fitness gamification software. Always consult healthcare professionals before starting new exercise programs and ensure proper form and safety in all physical activities.

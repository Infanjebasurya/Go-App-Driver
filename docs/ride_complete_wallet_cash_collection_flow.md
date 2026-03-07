# Ride Completion, Cash Collection, GST, and Wallet Flow

## Scope
This document explains the current implementation for:
- Ride completion financial calculations
- GST extraction logic
- Cash vs QR collection behavior
- Wallet updates, constraints, and transaction history
- Key methods and storage involved in the flow

## High-Level Flow
1. Captain accepts an order.
2. Trip progresses through pickup, OTP verification, navigation, and trip completion.
3. `RideCompletedScreen` computes/normalizes monetary values and persists payment details.
4. Captain collects payment via one of two options:
   - `Collect Cash`
   - `Collect via QR`
5. Wallet is updated differently based on collection mode.
6. Captain submits rating; session is archived and flow returns to Home.

## Lifecycle and Method Trace

### 1) Order accepted
- File: `lib/features/home/presentation/pages/available_orders_page.dart`
- Methods:
  - `RideHistoryStore.startTrip(...)`
  - `TripSessionStore.startSession(...)`
- What gets saved:
  - Initial fare/distance labels
  - Pickup/drop addresses
  - Active trip identifiers

### 2) Trip progression
- Files:
  - `ride_arrived_page.dart` -> `RideHistoryStore.markPickedUpNow()`, `TripSessionStore.markArrivedAtPickup()`
  - `enter_ride_code_page.dart` -> `RideHistoryStore.markStartedNow()`, `TripSessionStore.markTripStarted(...)`
  - `passenger_onboard_page.dart` -> `TripSessionStore.markNavigationBegan(...)`

### 3) Trip completed
- File: `lib/features/home/presentation/pages/trip_navigation_page.dart`
- On complete action:
  - `TripSessionStore.markTripCompleted()`
  - `RideHistoryStore.markCompletedNowOrCreate(...)`
  - Navigate to `RideCompletedScreen`

### 4) Ride completed calculation sync
- File: `lib/features/ride_complete/presentation/pages/ride_completed_screen.dart`
- Startup method: `_syncSummaryAndPersist()`
- It performs:
  - Summary normalization from active session fare/distance when needed
  - GST extraction
  - Net earning recomputation
  - `RideHistoryStore.updateLatestCompletedDetails(...)`
  - `TripSessionStore.savePaymentDetails(...)`

### 5) Collection action (cash/QR)
- Same file: `ride_completed_screen.dart`
- Method: `_onCollectPaymentTap({required bool viaQr, ...})`
- Behavior:
  - `viaQr == true`:
    - Add full collectable amount to wallet: `DriverWalletStore.addAmount(totalCollectable)`
    - Mark payment received: `TripSessionStore.markPaymentReceived(method: 'online')`
  - `viaQr == false` (cash):
    - Subtract GST amount from wallet:
      - `next = currentWallet - gstAmount`
      - bounded by minimum allowed wallet balance (`-50.0`)
    - Save wallet: `DriverWalletStore.saveBalance(bounded)`
    - Mark payment received: `TripSessionStore.markPaymentReceived(method: 'cash')`

### 6) Feedback and closeout
- File: `lib/features/ride_complete/presentation/pages/rate_experience_screen.dart`
- On submit:
  - `TripSessionStore.savePassengerRating(...)` -> stage becomes `rated`, session archived
  - `RateExperienceCubit.submitFeedback()`
  - `HomeTripResumeStore.clear()` and navigate Home

## Financial Formula Definitions (Current Implementation)

### A) Collectable subtotal
- Method: `_collectableSubTotal(...)`
- Formula:
  - `collectableSubTotal = tripFare + tips - discountAmount`
  - If result <= 0, force `0`
  - Rounded to 2 decimals

### B) GST amount (inclusive extraction)
- Method: `_gstAmount(...)`
- Constants:
  - `_gstRate = 0.05` (5%)
- Formula used:
  - `gstAmount = (collectableSubTotal * 0.05) / 1.05`
  - Rounded to 2 decimals
- Note:
  - UI shows this as `GST (5%) ... (included)`

### C) Net earning shown/persisted
- In `_syncSummaryAndPersist()`:
  - `grossEarning` is taken from summary or fallback derivation
  - `netEarning = grossEarning - gstAmount`
  - Floor at `0`
- Saved to:
  - `RideHistoryStore.updateLatestCompletedDetails(... netEarningAmount: netEarning)`
  - `TripSessionStore.savePaymentDetails(totalEarnings: netEarning, ...)`

### D) Incentive derivation fallback
- Method: `_deriveIncentive(...)`
- Formula:
  - `incentive = summary.totalEarnings - tripAmount + discountAmount`
  - If negative, force `0`

### E) Gross earning fallback derivation
- Method: `_deriveNetEarning(...)` (name is legacy; it computes gross fallback first)
- Formula:
  - If `summary.totalEarnings > 0`: use it
  - Else: `tripAmount + incentiveAmount - discountAmount`
  - If negative, force `0`

## Wallet Rules

### Wallet store behavior
- File: `lib/core/storage/driver_wallet_store.dart`
- Rules:
  - Key: `driver_wallet_balance_v1`
  - Minimum allowed balance: `-50.0`
  - `addAmount(x)` adds if `x > 0`
  - `subtractAmount(x)` returns `null` if result would go below `-50.0`
  - `saveBalance(amount)` clamps below `-50.0` to `-50.0`

### Duty threshold behavior
- File: `lib/features/home/presentation/cubit/driver_status_state.dart`
- Constant: `kMinimumDutyWalletBalance = -50.0`
- At or below threshold can block going online and trigger warnings.

## Earnings and Wallet Reporting

### Earnings snapshot source
- File: `lib/features/earnings/data/datasources/earnings_wallet_mock_api.dart`
- Snapshot computes:
  - `todaysEarnings`
  - `totalEarned`
  - `totalRides`
  - `walletBalance`
- Trip earning uses `EarningsCalculator.totalEarning(...)`.

### Transaction list source
- Same file (`earnings_wallet_mock_api.dart`):
  - Trip earnings converted into credit transactions (`WalletTransactionType.earning`)
  - Recharge and withdrawal ops persisted under `earnings_wallet_ops_v1`

## SharedPreferences Keys Used in This Flow
- `driver_wallet_balance_v1` (wallet balance)
- `ride_history_items_v1` (ride history list)
- `ride_history_active_trip_id_v1` (active ride id)
- `trip_session_active_v1` (active trip session)
- `trip_session_archive_v1` (completed session archive)
- `home_trip_resume_stage_v1` (resume stage)
- `home_trip_navigation_start_ms_v1` (trip navigation time anchor)
- `earnings_wallet_ops_v1` (manual wallet recharge/withdraw operations)

## Worked Example (using current defaults)
Given:
- Trip Fare = 1300
- Tips = 50
- Discount = 100

Then:
1. `collectableSubTotal = 1300 + 50 - 100 = 1250`
2. `gstAmount = (1250 * 0.05) / 1.05 = 59.52` (rounded)

If captain taps:
- `Collect via QR`:
  - Wallet increases by `1250.00`
- `Collect Cash`:
  - Wallet decreases by `59.52` (GST component only)

## Important Implementation Notes
- GST is treated as included in collectable amount and extracted by inclusive formula.
- Cash and QR paths intentionally have different wallet effects.
- `RideCompletedScreen` currently owns a significant part of financial orchestration logic.
- Method naming note: `_deriveNetEarning` currently helps derive gross fallback before GST deduction.

## Suggested TL Talking Points
- Flow is fully persisted across app restarts via `RideHistoryStore`, `TripSessionStore`, and `HomeTripResumeStore`.
- Financial logic is deterministic and concentrated in `RideCompletedScreen`.
- Wallet safety is enforced via minimum bound `-50.0`.
- Reporting screens (`Earnings`, `Wallet`) read computed history + wallet store and remain consistent with persisted state.

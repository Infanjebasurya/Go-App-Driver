# GoApp Captain Architecture

## Rules
- Clean Architecture target: `data -> domain -> presentation`.
- UI pages must remain render-only; state changes happen via `Cubit/BLoC`.
- No business rules in widgets (validation, computation, persistence, API orchestration).
- Shared design tokens (colors) must come from `lib/core/theme/app_colors.dart`.

## Current Structure
```text
lib/
  core/
    constants/
    di/
    error/
    network/
    theme/
    usecase/
    utils/
    widgets/
  features/
    about/
    auth/
    city_vehicle/
    demand_planner/
    documents/
    document_verify/
    earnings/
    feedback/
    home/
    incentives/
    notifications/
    onboarding/
    payment/
    profile/
    rate_app/
    refer_earn/
    search/
    sos/
```

## Layering Status
- Fully layered (`data/domain/presentation`): `auth`, `home`.
- Domain + presentation focus: `profile`.
- Presentation-first modules (in progress): `documents`, `document_verify`, `demand_planner`, `earnings`, `incentives`, `sos`, `rate_app`, `about`, `refer_earn`.
- Placeholder layered modules (scaffolded with `.gitkeep`): `feedback`, `notifications`, `payment`, parts of `onboarding`.

## Refactor Direction
1. Move non-UI logic from screens/widgets into feature cubits/usecases.
2. Consolidate repeated color literals into `AppColors`.
3. Gradually backfill `data/domain` for presentation-first features.
4. Keep tests mirrored under `test/features/<feature_name>/`.

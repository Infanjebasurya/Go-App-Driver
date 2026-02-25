# API Spec

## Change Log

- 2026-02-24: Earnings/Wallet navigation and presentation flow refactor to clean architecture (data/domain/presentation). No backend API contract changes.
- 2026-02-20: Client now fetches Google Directions road polylines for captain map rendering (pickup/drop). No backend API contract changes.
- 2026-02-19: Home feature architecture refactor only. No backend API contract changes.

## Captain Profile

- Method: `GET`
- Path: `/v1/captain/profile`
- Auth: `Bearer <token>`

### Success Response `200`

```json
{
  "id": "captain-101",
  "name": "Sybrox Captain",
  "vehicle_type": "Bike",
  "is_online": true
}
```

### Error Response `500`

```json
{
  "message": "Internal server error"
}
```

## Duty Control

- Method: `PATCH`
- Path: `/v1/captain/duty-status`
- Auth: `Bearer <token>`

### Request Body

```json
{
  "is_online": true
}
```

### Success Response `200`

```json
{
  "captain_id": "captain-101",
  "is_online": true,
  "updated_at": "2026-02-17T08:20:00Z"
}
```

## Trip Offers

- Method: `GET`
- Path: `/v1/captain/trip-offers`
- Auth: `Bearer <token>`

### Success Response `200`

```json
[
  {
    "offer_id": "offer-501",
    "pickup_address": "Anna Nagar, Chennai",
    "drop_address": "T Nagar, Chennai",
    "distance_km": 7.8,
    "estimated_fare": 220.0
  }
]
```

## Accept Trip Offer

- Method: `POST`
- Path: `/v1/captain/trip-offers/{offer_id}/accept`
- Auth: `Bearer <token>`

### Success Response `200`

```json
{
  "trip_id": "trip-901",
  "status": "accepted"
}
```

## SOS Alert

- Method: `POST`
- Path: `/v1/sos/alert`
- Auth: `Bearer <token>`

### Request Body

```json
{
  "trip_id": "trip-901",
  "contacts": [
    {
      "name": "Elizabeth (Wife)",
      "phone": "+91XXXXXXXXXX"
    },
    {
      "name": "Michael (Assistant)",
      "phone": "+91YYYYYYYYYY"
    }
  ]
}
```

### Success Response `200`

```json
{
  "alert_id": "sos-1001",
  "status": "sent",
  "sent_contacts": 2
}
```

## SOS Mark Safe

- Method: `POST`
- Path: `/v1/sos/{alert_id}/safe`
- Auth: `Bearer <token>`

### Success Response `200`

```json
{
  "alert_id": "sos-1001",
  "status": "closed"
}
```

## Ride Completion Summary

- Method: `GET`
- Path: `/v1/trips/{trip_id}/completion-summary`
- Auth: `Bearer <token>`

### Success Response `200`

```json
{
  "trip_id": "trip-901",
  "distance_km": 2.5,
  "trip_fare": 1300.0,
  "tips": 50.0,
  "discount_percent": 10,
  "discount_amount": 100.0,
  "total_earnings": 1250.5,
  "payment_link": "https://your-payment-link.com/ride123"
}
```

## Ride Feedback Submission

- Method: `POST`
- Path: `/v1/trips/{trip_id}/feedback`
- Auth: `Bearer <token>`

### Request Body

```json
{
  "rating": 4,
  "tags": ["Professional", "Punctual"],
  "comment": "Smooth ride"
}
```

### Success Response `200`

```json
{
  "trip_id": "trip-901",
  "status": "submitted"
}
```

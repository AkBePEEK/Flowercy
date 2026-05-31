# AI Florist Backend API Documentation

This document describes the API and internal logic of the AI-powered bouquet recommendation and order management system. Use this to integrate the Android app (Flowercy) with the backend.

**Base URL:** `http://localhost:8000` (default)

---

## 1. Core Models (Data Schemas)

### UserPreferences
Used for manual filtering and recommendation requests.
```json
{
  "user_id": "string (optional)",
  "occasion": "string (e.g., Birthday, Wedding)",
  "colors": ["list of strings"],
  "mood": "string (e.g., Romantic, Tender)",
  "size": "string (S, M, L)",
  "flowers_include": ["list of strings"],
  "flowers_avoid": ["list of strings"],
  "budget_max": 25000.0,
  "top_n": 5,
  "include_external": false
}
```

### ProductCard (Bouquet)
Standard representation of a bouquet item.
```json
{
  "id": "string",
  "name": "string",
  "price": 0.0,
  "imageUrl": "string",
  "provider": "Internal | Firestore | Wolt | 2GIS",
  "storeId": "string",
  "inStock": true,
  "description": "string"
}
```

### Order
Lifecycle: `created` -> `accepted` -> `photo_uploaded` -> `approved` -> `paid` -> `delivering` -> `delivered`.
```json
{
  "order_id": "string",
  "status": "string",
  "user_id": "string",
  "product": { "ProductCard object" },
  "delivery": { "address": "string", "city": "string", "notes": "string" },
  "florist_photo_url": "string (uploaded after assembly)",
  "history": [ { "timestamp": "string", "status": "string", "note": "string" } ]
}
```

---

## 2. Endpoints

### A. Recommendations & AI
1. `POST /recommend`
   - **Request:** `UserPreferences`
   - **Response:** `List of BouquetResult` (local ML-based ranking).
2. `POST /ai/recommend-from-text`
   - **Query:** `{"query": "romantic pink roses under 20k", "user_id": "..."}`
   - **Logic:** Uses NLP parser to extract filters -> searches Firestore -> ranks with ML -> **Gemini AI** provides a natural language "reason" for each choice.
3. `POST /nlp/parse`
   - **Request:** `{"text": "string"}`
   - **Response:** Structured preferences (occasion, colors, etc.).

### B. Image & 3D Generation
1. `POST /generate-image`
   - **Request:** `GenerateImageRequest` (flowers, colors, mood).
   - **Response:** `base64_image` + `image_path`. Generates a unique bouquet visualization.
2. `POST /bouquets/3d-structure`
   - **Request:** `{"flowers": ["Rose", "Peony"], "count": 30}`
   - **Response:** Coordinates (x, y, z) and rotations for rendering flowers in a 3D scene.

### C. Order Management
1. `POST /orders` - Create a new order for a specific product.
2. `GET /orders/{order_id}` - Get full status and history.
3. `POST /orders/{order_id}/customer/review`
   - **Action:** Customer approves (`decision: "approve"`) or rejects the florist's photo.
4. `POST /orders/{order_id}/payment` - Mark as paid.

### D. Flower Catalog & Custom Composition
1. `GET /catalog/flowers` - List available stems with prices.
2. `POST /bouquets/compose`
   - **Request:** Selections of stems (id + count).
   - **Response:** Generates 3 bouquet variations with costs and AI-generated previews.

---

## 3. Integration Tips for Android (Retrofit/Ktor)
- Use `Gson` or `KotlinX Serialization` to map these JSONs to data classes.
- For 3D rendering, use the `/bouquets/3d-structure` response to position models in SceneView or Filament.
- Static images are served from `/outputs/`. Full URL: `http://localhost:8000/outputs/filename.png`.
- The `reason` field in AI recommendations is designed to be shown directly to the user (e.g., "Fits your budget and includes pink peonies").

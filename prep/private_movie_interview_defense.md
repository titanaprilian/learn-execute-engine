# Private Movie: Fullstack Technical Interview Defense Sheet
**Target Company:** PT Digdaya Olah Teknologi Indonesia (DOT Indonesia)  
**Role:** Fullstack Engineer  
**Project:** [private-movie](https://github.com/titanaprilian/private-movie) (Bun, Elysia, Drizzle ORM, PostgreSQL, React 19, TanStack Router/Query, Zustand, S3/B2)

---

## 🏛️ High-Level Architectural Pitch (Elevator Pitch - 90 Seconds)
- **Problem Statement:** Self-hosted private media streaming catalog serving both web and Android TV with instant response times and low server overhead.
- **Key Architectural Pattern:** **Deep Modules** architecture in a Bun + Turborepo monorepo.
  - Strict boundary enforcement: modules expose public services/hooks via `src/modules/<feature>/index.ts` and keep state/subcomponents in `internal/`.
  - Decoupled API contracts: shared DTOs/schemas in `packages/contracts/` ensure type safety across frontend and backend without tight coupling.

---

## 🎯 Sprint 1: Backend & Data Architecture Defense (50m)

### 1. Elysia + Bun Execution Model
- **Talking Point:** Why Bun + Elysia over Node.js + Express/NestJS?
  - *Response:* Extreme throughput, native TypeScript execution without transpilation lag, end-to-end type inference with Elysia's schema validation (TypeBox under the hood), and tiny cold start times.
- **Factory Composition Pattern:** Routes are composed in `src/app.ts` via dependency injection (`createApp(deps)`), making modules isolated and testable with Vitest.

### 2. Drizzle ORM & PostgreSQL Schema Design
- **Talking Point:** How did you structure the schema and database relations?
  - *Response:* Normalized PostgreSQL schema managed via Drizzle migrations (`packages/db/`). Clear foreign key constraints between titles, episodes, and media stream assets.
- **Talking Point:** How do you handle database transactions and concurrency?
  - *Response:* Multi-step ingestion (scraping metadata + saving episodes) wrapped in Drizzle transactions (`db.transaction(...)`) to avoid orphaned records if TMDB or scraping fails midway.

### 3. Media Ingestion & S3/B2 Storage Resolution
- **Talking Point:** How does video streaming work without choking the server?
  - *Response:* The backend does not buffer entire video files in RAM. It resolves stream URLs and delegates object storage delivery via signed URLs or chunked HTTP range requests from S3/Backblaze B2 (`packages/media-service/`).

---

## 🎨 Sprint 2: Frontend Architecture & State Management (50m)

### 1. TanStack Query vs. Zustand State Separation
- **Talking Point:** How do you decide what state goes where?
  - *Server State (TanStack Query):* Media catalogs, search queries, episode listings. Cached, deduped, and invalidated automatically.
  - *Client UI State (Zustand):* Player volume, playback speed, modal states, sidebar toggle. Minimal, localized in feature `internal/` stores.

### 2. React 19 & TanStack Router
- **Talking Point:** Why TanStack Router over Next.js / traditional React Router?
  - *Response:* Type-safe search params and route loaders. Data is fetched in parallel with route chunk loading before rendering, eliminating waterfall network delays.

---

## 🥊 Sprint 3: Tough Scenarios & Verbal Rehearsal (50m)

### Scenario Questions
1. **"What happens if the stream or remote media source fails mid-playback?"**
   - *Defense:* Frontend player catches media network errors via HTML5 video events, retries with exponential backoff, and falls back to alternate stream sources resolved by `media-service`.
2. **"How do you ensure coding standards and test coverage in a monorepo?"**
   - *Defense:* Turborepo pipeline with strict workspace-aware scripts (`bun run test:backend`, `bun run test:web`), unified ESLint/Prettier, and Vitest for unit & integration testing.
3. **"If the catalog grows to 500k titles, how do you optimize Postgres?"**
   - *Defense:* B-Tree indexing on foreign keys (`title_id`), GiST/GIN indexes for full-text title search, pagination via cursor-based keyset rather than high-offset `LIMIT/OFFSET`.

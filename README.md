# CampTrade — Production V1 foundation

CampTrade is a multi-campus student marketplace. This package moves the prototype toward a real application with Supabase authentication/database/storage and Paystack payment infrastructure.

## Included
- Next.js + TypeScript application
- Supabase email OTP authentication
- Multi-campus tenancy: FUT Minna, IBBU, Newgate University
- Real Postgres schema + Row Level Security
- Listings and wanted posts stored in the database
- Favorites, orders, conversations/messages, reports and verification-request tables
- Student-ID storage bucket with restricted access
- Listing-image storage bucket
- Paystack initialization API + signed webhook handler
- Safer profile permissions and campus-scoped marketplace access

## Run
1. Install Node.js 20+.
2. Create a Supabase project.
3. In Supabase SQL Editor, run `supabase/schema.sql`, then `supabase/storage.sql`.
4. Copy `.env.example` to `.env.local` and fill the Supabase keys.
5. For payments, add Paystack secret/public keys.
6. Run:
   npm install
   npm run dev
7. Open http://localhost:3000

## Important production steps
Before public launch, configure a custom domain, Supabase Auth redirect URLs, Paystack webhook URL, backups, monitoring, rate limiting, image moderation, ID-review admin screens, complete checkout/order UI, realtime chat UI, notifications, terms/privacy pages and a proper admin role bootstrap.

Never put `SUPABASE_SERVICE_ROLE_KEY` in browser code or commit `.env.local`.

## Android testing
You can run the project on a computer/VPS and open its URL from your Android phone. For local Android development, Termux can run Node projects if Node/npm installation is available, but a cloud deployment is usually easier for the first test.

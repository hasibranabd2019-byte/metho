# মেঠো ই-কমার্স স্টার্টার (Render + Supabase)

বাংলা মোবাইল-ফার্স্ট খেজুরের গুড়ের landing page ও Express API starter। এটি **প্রাথমিক প্রকল্প**, লাইভে দেওয়ার আগে security review, বাস্তব order test, privacy policy এবং Steadfast API contract যাচাই আবশ্যক।

## ফ্রি হোস্টিং আর্কিটেকচার
- Render Free Web Service: Node.js অ্যাপ এবং ফ্রি `onrender.com` সাবডোমেইন
- Supabase Free: PostgreSQL ডেটাবেস ও PostgreSQL-backed session store
- GitHub: কোড repository

ফ্রি প্ল্যানে sleep/pausing, quota, backup এবং availability সীমাবদ্ধতা থাকতে পারে। ব্যবসায়িক অর্ডার নিলে নিয়মিত ব্যাকআপ এবং restore test আলাদাভাবে সেট করুন।

## 1) Supabase তৈরি
1. https://supabase.com/ এ নতুন project তৈরি করুন।
2. Project Settings → Database থেকে connection string URI নিন। Render-এ দীর্ঘমেয়াদি server-side connection-এর জন্য Supabase-এর নির্দেশিত connection/pooler string ব্যবহার করুন।
3. URI-তে password সঠিকভাবে বসান; special character থাকলে URL-encode করতে হবে। URI কখনো GitHub-এ commit করবেন না।
4. অ্যাপ প্রথম চালু হলে `orders` table ও `user_sessions` table তৈরি হবে। কোনো public client থেকে database access দেবেন না; সব database query server-side-এ হয়।

## 2) Admin password hash তৈরি
লোকাল কম্পিউটারে Node.js ইনস্টল করে প্রকল্প ফোল্ডারে চালান:

```bash
npm install
node -e "console.log(require('bcryptjs').hashSync('REPLACE_WITH_A_LONG_UNIQUE_PASSWORD', 12))"
```

আউটপুটটি `ADMIN_PASSWORD_HASH`-এ দিন। বাস্তব পাসওয়ার্ড কোড বা README-তে লিখবেন না।

## 3) Render deploy
1. প্রকল্পের সব ফাইল GitHub repository-তে upload/push করুন; `.env` বা secret commit করবেন না।
2. Render dashboard → New → Web Service → GitHub repository নির্বাচন করুন।
3. Build command: `npm install`
4. Start command: `npm start`
5. Runtime Node 20 বা সমর্থিত নতুন LTS সংস্করণ দিন।
6. Environment Variables-এ `.env.example` থেকে মানগুলো পূরণ করুন: `DATABASE_URL`, `PGSSLMODE` (leave unset for TLS; use `disable` only for local non-TLS PostgreSQL), `NODE_ENV=production`, `SESSION_SECRET`, `ADMIN_USERNAME`, `ADMIN_PASSWORD_HASH` এবং পণ্যের মূল্য/ডেলিভারি চার্জ।
7. Deploy শেষে `https://YOUR-SERVICE.onrender.com/api/health` খুলুন। `ok:true` এবং `database:"connected"` দেখতে হবে।

## 4) লোকাল রান
```bash
cp .env.example .env
# .env-এ আসল Supabase URL এবং secrets বসান
npm install
npm start
```
তারপর `http://localhost:3000` এবং `http://localhost:3000/admin.html` খুলুন।

## 5) Admin
- URL: `/admin.html`
- username: `ADMIN_USERNAME`
- password: `ADMIN_PASSWORD_HASH`-এর plain-text password
- production-এ আলাদা শক্তিশালী পাসওয়ার্ড, session secret, HTTPS, rate limit এবং access control যাচাই করুন।

## 6) Steadfast
Admin panel থেকে শুধু ফোনে নিশ্চিত করা (`confirmed`) order-এর booking request করা যায়। `STEADFAST_API_BASE`, `/create_order`, headers, payload এবং response field এই প্রকল্পে **প্রাথমিক adapter**। Merchant panel/support থেকে বর্তমান API contract নিশ্চিত না করে real booking চালাবেন না। প্রথম পরীক্ষা merchant নির্দেশনা অনুযায়ী test/low-risk order-এ করুন।

## 7) Meta Pixel
Meta Events Manager-এ Pixel তৈরি করে `META_PIXEL_ID` দিন। Browser Pixel event-গুলি বাস্তব event-এর সঙ্গে মেলে কি না Events Manager Test Events-এ পরীক্ষা করুন। Browser Pixel ও Conversions API একসঙ্গে চালালে `event_id` deduplication দরকার। কাস্টমারের ব্যক্তিগত তথ্য URL/query string বা Pixel event-এ পাঠাবেন না।

## 8) Backup ও privacy
- Supabase Free-তে backup/restore সীমা থাকতে পারে; free tier-এ backup ধরে নেবেন না। নিয়মিত `pg_dump`-ভিত্তিক encrypted backup বা নিরাপদ managed backup ব্যবস্থা করুন এবং restore পরীক্ষা করুন।
- Customer name, phone, address সংবেদনশীলভাবে পরিচালনা করুন; staff access সীমিত করুন এবং প্রয়োজনের অতিরিক্ত তথ্য সংগ্রহ করবেন না।
- Database password, admin hash, session secret, Meta server token, Steadfast API keys GitHub-এ দেবেন না।
- Render Free service ঘুমিয়ে যেতে পারে; প্রথম ভিজিটে বিলম্ব হতে পারে। Free plan-এর সীমা বদলাতে পারে।

## API routes
- `GET /api/config`
- `POST /api/orders`
- `POST /api/admin/login`
- `POST /api/admin/logout`
- `GET /api/admin/orders`
- `PATCH /api/admin/orders/:id`
- `POST /api/admin/orders/:id/steadfast`
- `GET /api/health`

## Before taking real orders
1. Test validation, totals, duplicate clicks and DB persistence.
2. Review authentication/session/CSRF protections; add CSRF protection and production-grade monitoring before handling real customer data.
3. Verify shipping rates, policies, return/refund text, privacy notice and product claims.
4. Confirm Steadfast API contract and Meta event configuration.
5. Configure independent encrypted backups and restore testing.

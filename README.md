# মেঠো ই-কমার্স ওয়েব অ্যাপ

একটি responsive ওয়েবসাইট: কাস্টমার স্টোরফ্রন্ট `/` এবং একই সাইটের অ্যাডমিন প্যানেল `/admin`। Node.js + Express + Supabase PostgreSQL; Render-এ হোস্ট করার জন্য প্রস্তুত।

## বর্তমান কার্যকারিতা
- কাস্টমার অর্ডার: ঝোলা/পাটালি গুড়, ১ কেজি/২ কেজি প্যাক, পরিমাণ, জেলা ও ঠিকানা।
- COD এবং বিকাশ অগ্রিম পেমেন্টের Transaction ID জমা; বিকাশ পেমেন্ট অ্যাডমিন যাচাই করবেন। এটি এখন manual verification, bKash Payment Gateway API নয়।
- অর্ডার ডেটাবেজে Pending; স্টাফ পেমেন্ট যাচাইয়ের স্ট্যাটাস দিতে পারেন; কেবল অ্যাডমিন `confirmed` করে Steadfast বুকিং অনুমোদন করবেন।
- SteadFast Admin module: single booking, bulk booking (up to 50 selected orders per request), merchant balance lookup, status refresh by consignment ID/tracking code, return request, and booking history. API keys remain server-side in Render Environment. COD orders send total COD amount; prepaid bKash orders send COD amount 0.
- ২ জন পর্যন্ত অ্যাডমিন ও ৫ জন পর্যন্ত স্টাফ; প্রথম অ্যাডমিন ENV দিয়ে bootstrap হয়। অ্যাডমিন প্যানেল থেকে দ্বিতীয় অ্যাডমিন/স্টাফ তৈরি হয়।
- অ্যাডমিন প্যানেল থেকে পণ্য, মূল্য, ওয়েবসাইটের লেখা, লোগো/ব্যানার/ভিডিও URL, রং, বিকাশ নম্বর, যোগাযোগ ও ডেলিভারি চার্জ পরিবর্তন করা যায়।

## গুরুত্বপূর্ণ সীমাবদ্ধতা / লাইভের আগে
- ছবি বর্তমানে HTTPS image URL দিয়ে সেট করা যায়; সরাসরি ফাইল আপলোডের জন্য Supabase Storage bucket integration পরের ধাপে যুক্ত করতে হবে।
- bKash এখানে manual Transaction ID verification; স্বয়ংক্রিয় gateway checkout/callback নেই।
- Steadfast create-order contract আপনার Merchant API guide/screenshots অনুযায়ী; production booking-এর আগে merchant account-এ একটি test order করে response যাচাই করুন। Tracking status polling/cancel API এখনো যুক্ত নয়।
- SMS ও push notifications এখনো যুক্ত নয়।
- Admin user creation limit (২ admin/৫ staff) আছে; প্রথম bootstrap admin-সহ সক্রিয় অ্যাকাউন্টের সংখ্যা সীমিত।
- Production security review, privacy/return policy, backups, order lifecycle tests এবং payment/courier reconciliation সম্পন্ন না করে live sales শুরু করবেন না।

## লোকাল রান
1. Node.js 20+ ইনস্টল করুন।
2. `npm install`
3. `.env.example` কপি করে `.env` তৈরি করুন। Supabase PostgreSQL URI, অন্তত ৩২ অক্ষরের SESSION_SECRET এবং bcrypt admin hash বসান।
4. `npm start`
5. `http://localhost:3000` এবং `http://localhost:3000/admin` খুলুন।

Admin hash: `node -e "console.log(require('bcryptjs').hashSync('আপনার-শক্তিশালী-পাসওয়ার্ড', 12))"`

## Render + Supabase deployment
- GitHub-এ repository push করুন।
- Supabase-এ Free project তৈরি করে PostgreSQL connection string (pooler URI) নিন।
- Render-এ New → Web Service → GitHub repo নির্বাচন করুন; Build: `npm install`, Start: `npm start`.
- Render Environment-এ `DATABASE_URL`, `DATABASE_SSL=require`, `SESSION_SECRET`, `ADMIN_USERNAME`, `ADMIN_PASSWORD_HASH`, `NODE_ENV=production` দিন। Steadfast credentials কেবল Render Environment-এ private ভাবে দিন।
- Deploy শেষে `/api/health` পরীক্ষা করুন; `database: connected` প্রত্যাশিত।
- Free Render service idle হলে sleep করতে পারে; free tier production uptime guarantee নয়।

## API
- `GET /api/config`, `POST /api/orders`
- `POST /api/admin/login`, `GET /api/admin/me`, `POST /api/admin/logout`
- `GET /api/admin/orders`, `PATCH /api/admin/orders/:id`, `POST /api/admin/orders/:id/steadfast`, `POST /api/admin/steadfast/bulk`, `GET /api/admin/steadfast/balance`, `POST /api/admin/orders/:id/track`, `POST /api/admin/orders/:id/return`
- `GET/PUT /api/admin/settings`
- `GET/POST/PATCH /api/admin/products`
- `GET/POST/PATCH /api/admin/users`


## Admin improvements (email recovery and image upload)
- Login password show/hide and email OTP password reset (10-minute OTP; 5 attempts).
- Every admin/staff account must have a unique email address. Set `ADMIN_EMAIL` for the initial admin; add email when creating users.
- Configure SMTP environment variables (`SMTP_HOST`, `SMTP_PORT`, `SMTP_SECURE`, `SMTP_USER`, `SMTP_PASS`, optional `SMTP_FROM`). Gmail requires an App Password, not the normal account password.
- Create a **public** Supabase Storage bucket named `metho-assets` (or set `SUPABASE_STORAGE_BUCKET`). Set `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` in Render. Never expose the service-role key in browser code or commit it.
- Image uploads accept JPG/PNG/WEBP/GIF up to 5 MB.

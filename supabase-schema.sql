-- Metho e-commerce schema. The Node app also creates/upgrades these tables at startup.
CREATE TABLE IF NOT EXISTS staff_users (
 id BIGSERIAL PRIMARY KEY, username TEXT UNIQUE NOT NULL, display_name TEXT NOT NULL,
 password_hash TEXT NOT NULL, role TEXT NOT NULL CHECK(role IN ('admin','staff')),
 permissions JSONB NOT NULL DEFAULT '[]'::jsonb, active BOOLEAN NOT NULL DEFAULT TRUE,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS site_settings (key TEXT PRIMARY KEY, value JSONB NOT NULL, updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW());
CREATE TABLE IF NOT EXISTS products (
 id BIGSERIAL PRIMARY KEY, slug TEXT UNIQUE NOT NULL, name TEXT NOT NULL, description TEXT NOT NULL DEFAULT '',
 product_type TEXT NOT NULL DEFAULT 'ঝোলা গুড়', image_url TEXT NOT NULL DEFAULT '',
 price_1kg INTEGER NOT NULL DEFAULT 0, price_2kg INTEGER NOT NULL DEFAULT 0,
 active BOOLEAN NOT NULL DEFAULT TRUE, sort_order INTEGER NOT NULL DEFAULT 0, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS orders (
 id BIGSERIAL PRIMARY KEY, order_code TEXT UNIQUE NOT NULL, customer_name TEXT NOT NULL, phone TEXT NOT NULL,
 district TEXT NOT NULL, address TEXT NOT NULL, product_id BIGINT REFERENCES products(id) ON DELETE SET NULL,
 product_name TEXT NOT NULL DEFAULT '', package_kg INTEGER NOT NULL DEFAULT 1 CHECK(package_kg IN (1,2)),
 quantity INTEGER NOT NULL CHECK(quantity BETWEEN 1 AND 20), unit_price INTEGER NOT NULL,
 delivery_fee INTEGER NOT NULL, total_amount INTEGER NOT NULL, payment_method TEXT NOT NULL DEFAULT 'COD',
 payment_status TEXT NOT NULL DEFAULT 'unpaid', bkash_trx_id TEXT, status TEXT NOT NULL DEFAULT 'pending',
 courier_consignment_id TEXT, courier_tracking_code TEXT, courier_response TEXT, fbclid TEXT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS orders_created_at_idx ON orders(created_at DESC);
CREATE INDEX IF NOT EXISTS orders_status_idx ON orders(status);

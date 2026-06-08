-- Cardence PostgreSQL — ilk kurulum
-- Docker container ilk ayağa kalktığında otomatik çalışır.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

COMMENT ON DATABASE cardence IS 'Cardence mobile + .NET backend shared database';

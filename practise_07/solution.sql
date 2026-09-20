CREATE SCHEMA IF NOT EXISTS ecom;

-- Завдання 2.1
CREATE TABLE ecom.events_simple (
    event_id   BIGINT,
    event_type VARCHAR(30) NOT NULL,
    event_time TIMESTAMPTZ NOT NULL
) PARTITION BY RANGE (event_time);

-- Завдання 2.2
CREATE TABLE ecom.events_simple_q1 PARTITION OF ecom.events_simple
    FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');
CREATE TABLE ecom.events_simple_q2 PARTITION OF ecom.events_simple
    FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');
CREATE TABLE ecom.events_simple_q3 PARTITION OF ecom.events_simple
    FOR VALUES FROM ('2025-07-01') TO ('2025-10-01');
CREATE TABLE ecom.events_simple_q4 PARTITION OF ecom.events_simple
    FOR VALUES FROM ('2025-10-01') TO ('2026-01-01');

-- Завдання 2.3
INSERT INTO ecom.events_simple (event_id, event_type, event_time)
VALUES (99, 'view', '2024-06-01 12:00:00+00');
--SQL Error [23514]: ERROR: no partition of relation "events_simple" found for row
--  Detail: Partition key of the failing row contains (event_time) = (2024-06-01 12:00:00+00).

-- Завдання 2.4
CREATE TABLE ecom.events_simple_default
    PARTITION OF ecom.events_simple DEFAULT;

-- Завдання 2.5
INSERT INTO ecom.events_simple (event_id, event_type, event_time) VALUES
 (1, 'view',     '2025-02-14 10:00:00+00'),
 (2, 'click',    '2025-05-20 11:30:00+00'),
 (3, 'purchase', '2025-08-03 09:15:00+00'),
 (4, 'view',     '2025-11-11 18:45:00+00'),
 (5, 'logout',   '2024-12-31 23:59:00+00'),
 (6, 'view',     '2026-03-01 08:00:00+00');

-- Завдання 2.6
SELECT tableoid::regclass AS partition, event_id, event_type, event_time
FROM ecom.events_simple
ORDER BY event_id;

-- Завдання 2.7
SELECT relid::regclass AS partition,
       pg_get_expr(c.relpartbound, c.oid) AS bounds
FROM pg_partition_tree('ecom.events_simple') t
JOIN pg_class c ON c.oid = t.relid
WHERE t.isleaf
ORDER BY 1;

-- Завдання 3.1
CREATE TABLE ecom.bad_pk (
    event_id   BIGINT PRIMARY KEY,
    event_time TIMESTAMPTZ NOT NULL
) PARTITION BY RANGE (event_time);
--SQL Error [0A000]: ERROR: unique constraint on partitioned table must include all partitioning columns
--  Detail: PRIMARY KEY constraint on table "bad_pk" lacks column "event_time" which is part of the partition key.

-- Завдання 3.2
CREATE TABLE ecom.events (
    event_id   BIGSERIAL,
    event_type VARCHAR(30) NOT NULL,
    event_time TIMESTAMPTZ NOT NULL,
    user_id    INT NOT NULL,
    amount     NUMERIC(10,2),
    PRIMARY KEY (event_id, event_time)
) PARTITION BY RANGE (event_time);

-- Завдання 3.3
CREATE TABLE ecom.events_2025_01 PARTITION OF ecom.events
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE ecom.events_2025_02 PARTITION OF ecom.events
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
CREATE TABLE ecom.events_2025_03 PARTITION OF ecom.events
    FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');
CREATE TABLE ecom.events_2025_04 PARTITION OF ecom.events
    FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');
CREATE TABLE ecom.events_2025_05 PARTITION OF ecom.events
    FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');
CREATE TABLE ecom.events_2025_06 PARTITION OF ecom.events
    FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');
CREATE TABLE ecom.events_2025_07 PARTITION OF ecom.events
    FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');
CREATE TABLE ecom.events_2025_08 PARTITION OF ecom.events
    FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');
CREATE TABLE ecom.events_2025_09 PARTITION OF ecom.events
    FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');
CREATE TABLE ecom.events_2025_10 PARTITION OF ecom.events
    FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');
CREATE TABLE ecom.events_2025_11 PARTITION OF ecom.events
    FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');
CREATE TABLE ecom.events_2025_12 PARTITION OF ecom.events
    FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');

CREATE TABLE ecom.events_default PARTITION OF ecom.events DEFAULT;

-- Завдання 3.4
SELECT relid::regclass AS partition,
       pg_get_expr(c.relpartbound, c.oid) AS bounds
FROM pg_partition_tree('ecom.events') t
JOIN pg_class c ON c.oid = t.relid
WHERE t.isleaf
ORDER BY 1;

-- Завдання 3.5
select * from ecom.events
limit 2

-- Завдання 4.1
INSERT INTO ecom.events (event_type, event_time, user_id, amount)
SELECT (ARRAY['view','click','add_to_cart','purchase','logout'])[1 + floor(random()*5)],
       TIMESTAMPTZ '2025-01-01' + (random() * INTERVAL '364 days'),
       floor(random() * 50000)::int,
       round((random() * 500)::numeric, 2)
FROM generate_series(1, 3000000);

-- Завдання 4.2
CREATE TABLE ecom.events_flat AS SELECT * FROM ecom.events;

-- Завдання 4.3
SELECT relid::regclass AS partition,
       pg_size_pretty(pg_total_relation_size(relid)) AS size
FROM pg_partition_tree('ecom.events')
WHERE isleaf
ORDER BY 1;

-- Завдання 4.4
SELECT pg_size_pretty(sum(pg_total_relation_size(relid))) AS events_total
FROM pg_partition_tree('ecom.events')

SELECT pg_total_relation_size('ecom.events_flat');

-- Завдання 5.1
select count(*)
from ecom.events
where user_id = 777;

-- Завдання 5.2
CREATE INDEX idx_events_user ON ecom.events (user_id);

-- Завдання 5.3
SELECT tablename, indexname
FROM pg_indexes
WHERE schemaname = 'ecom' AND indexname LIKE '%user%'
ORDER BY tablename;

-- Завдання 5.4
select count(*)
from ecom.events
where user_id = 777;

-- Завдання 5.5
CREATE INDEX idx_events_event_type ON ecom.events (event_type);

SELECT tablename, indexname
FROM pg_indexes
WHERE schemaname = 'ecom' AND indexname LIKE '%type%'
ORDER BY tablename;

-- Завдання 6.1
ALTER TABLE ecom.events DETACH PARTITION ecom.events_2025_01

select count(*) from ecom.events
select count(*) from ecom.events_2025_01;

-- Завдання 6.2
ALTER TABLE ecom.events ATTACH PARTITION ecom.events_2025_01
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01')
    
select count(*) from ecom.events;

-- Завдання 6.3
INSERT INTO ecom.events (event_type, event_time, user_id, amount)
VALUES ('view', '2026-01-15 12:00:00+00', 1, 10.00);

-- Завдання 6.4
CREATE TABLE ecom.events_2026_01 PARTITION OF ecom.events
    FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
--SQL Error [23514]: ERROR: updated partition constraint for default partition "events_default" would be violated by some row

-- Завдання 6.5
BEGIN;

ALTER TABLE ecom.events DETACH PARTITION ecom.events_default;

CREATE TABLE ecom.events_2026_01 PARTITION OF ecom.events
    FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');

INSERT INTO ecom.events
SELECT * FROM ecom.events_default
WHERE event_time >= '2026-01-01' AND event_time < '2026-02-01';

DELETE FROM ecom.events_default
WHERE event_time >= '2026-01-01' AND event_time < '2026-02-01';

ALTER TABLE ecom.events ATTACH PARTITION ecom.events_default DEFAULT;

COMMIT;

select * from ecom.events_2026_01;

-- Завдання 6.6
select count(*)
FROM ecom.events
where extract(month from event_time) = 2

DROP TABLE ecom.events_2025_02

select count(*)
FROM ecom.events;

-- Завдання 7.1
CREATE TABLE ecom.timings (
    label       TEXT,
    row_count   BIGINT,
    duration    INTERVAL,
    measured_at TIMESTAMPTZ DEFAULT now()
);

-- Завдання 7.2
DO $$
DECLARE t0 timestamptz; n bigint;
BEGIN
    t0 := clock_timestamp();

    SELECT count(*) INTO n
    FROM ecom.events
    WHERE event_time >= '2025-03-01' AND event_time < '2025-04-01';

    INSERT INTO ecom.timings (label, row_count, duration)
    VALUES ('partitioned: березень', n, clock_timestamp() - t0);
END $$;

-- Завдання 7.3
DO $$
DECLARE t0 timestamptz; n bigint;
BEGIN
    t0 := clock_timestamp();

    SELECT count(*) INTO n
    FROM ecom.events_flat
    WHERE event_time >= '2025-03-01' AND event_time < '2025-04-01';

    INSERT INTO ecom.timings (label, row_count, duration)
    VALUES ('flat: березень', n, clock_timestamp() - t0);
END $$;

DO $$
DECLARE t0 timestamptz; n bigint;
BEGIN
    t0 := clock_timestamp();

    SELECT count(*) INTO n
    FROM ecom.events
    WHERE user_id = 777;

    INSERT INTO ecom.timings (label, row_count, duration)
    VALUES ('partitioned: user_id', n, clock_timestamp() - t0);
END $$;

DO $$
DECLARE t0 timestamptz; n bigint;
BEGIN
    t0 := clock_timestamp();

    SELECT count(*) INTO n
    FROM ecom.events_flat
    WHERE user_id = 777;

    INSERT INTO ecom.timings (label, row_count, duration)
    VALUES ('flat: user_id', n, clock_timestamp() - t0);
END $$;

-- Завдання 7.4
SELECT label, row_count,
       round((extract(epoch from duration) * 1000)::numeric, 1) AS ms
FROM ecom.timings
ORDER BY measured_at;

-- Завдання 7.5
EXPLAIN
SELECT count(*) FROM ecom.events
WHERE event_time >= '2025-03-01' AND event_time < '2025-04-01';
--1

-- Завдання 7.6
EXPLAIN
SELECT count(*) FROM ecom.events WHERE user_id = 777;
--14



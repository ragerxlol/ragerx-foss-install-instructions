CREATE TABLE users (
	uid SERIAL PRIMARY KEY,
	username TEXT NOT NULL UNIQUE,
	wallet TEXT NOT NULL,
	password CHAR(128) NOT NULL,
	anon_leader BOOLEAN NOT NULL DEFAULT TRUE,
	email_me SMALLINT NOT NULL DEFAULT 0,
	email VARCHAR(255),
	code_group SMALLINT NOT NULL DEFAULT 0,
	is_admin INTEGER NOT NULL DEFAULT 0,
	user_diff INTEGER NOT NULL DEFAULT 0,
	payment_threshold BIGINT DEFAULT '100000000000'::bigint NOT NULL,
	salt CHAR(12) DEFAULT '',
	user_hash CHAR(12) DEFAULT ''
);

CREATE TABLE rigs (
	rid SMALLINT NOT NULL,
	uid INTEGER NOT NULL,
	name VARCHAR(255) NOT NULL,
	PRIMARY KEY(uid, rid),
	UNIQUE(uid, name)
);

CREATE TABLE credits (
	crd_id SERIAL PRIMARY KEY,
	blk_id INTEGER NOT NULL,
	uid INTEGER NOT NULL,
	amount_reward BIGINT,
	amount_bonus BIGINT,
	amount_dev BIGINT,
	time INTEGER,
	status INTEGER,
	UNIQUE(uid, blk_id)
);

CREATE TABLE payments (
	pymt_id SERIAL PRIMARY KEY,
	uid INTEGER NOT NULL,
	amount_paid BIGINT,
	amount_fee BIGINT,
	txhash CHAR(64),
	txid CHAR(64),
	time INTEGER,
	status INTEGER
);
CREATE INDEX payment_idx ON payments(uid);

CREATE TABLE mined_blocks (
	blk_id SERIAL PRIMARY KEY,
	txid CHAR(64) UNIQUE,
	height INTEGER,
	time INTEGER,
	uid INTEGER,
	reward BIGINT,
	reward_total BIGINT,
	total_shares BIGINT,
	difficulty BIGINT,
	status INTEGER
);

CREATE TABLE network_blocks (
	blkid CHAR(64) PRIMARY KEY,
	time INTEGER,
	difficulty BIGINT,
	reward BIGINT,
	prev_id CHAR(64),
	height INTEGER
);

CREATE TABLE valid_shares (
	miner SMALLINT NOT NULL,
	rid   SMALLINT NOT NULL,
	uid   INTEGER  NOT NULL,
	time  INTEGER  NOT NULL,
	count INTEGER  NOT NULL
);
CREATE INDEX valid_shares_by_user_idx ON valid_shares(uid);
CREATE INDEX valid_shares_by_time ON valid_shares(time DESC);

CREATE TABLE bad_shares (
	miner SMALLINT NOT NULL,
	rid   SMALLINT NOT NULL,
	uid   INTEGER NOT NULL,
	time  INTEGER NOT NULL,
	count INTEGER NOT NULL
);
CREATE INDEX bad_shares_by_user_idx ON bad_shares(uid);
CREATE INDEX bad_shares_by_time ON bad_shares(time DESC);

CREATE TABLE reported_hashrate (
	rid   SMALLINT NOT NULL,
	uid   INTEGER NOT NULL,
	time  INTEGER NOT NULL,
	hps   INTEGER NOT NULL
);
CREATE INDEX reported_hashrate_by_user_idx ON reported_hashrate(uid);
CREATE INDEX reported_hashrate_by_time ON reported_hashrate(time DESC);

CREATE TABLE hashrate_5min (
	uid     INTEGER NOT NULL,
	rid     SMALLINT NOT NULL,
	count   INTEGER NOT NULL,
	tsample INTEGER NOT NULL,
	tstart  INTEGER NOT NULL,
	tend    INTEGER NOT NULL,
	UNIQUE(uid, rid, tsample)
);

CREATE TABLE hashrate_1hr (
	uid     INTEGER NOT NULL,
	rid     SMALLINT NOT NULL,
	count   INTEGER NOT NULL,
	tsample INTEGER NOT NULL,
	tstart  INTEGER NOT NULL,
	tend    INTEGER NOT NULL,
	UNIQUE(uid, rid, tsample)
);

CREATE TABLE user_ban (
	uid  INTEGER PRIMARY KEY,
	lift_time INTEGER,
	msg TEXT
);

CREATE TABLE ip_ban (
	ip_regex TEXT PRIMARY KEY,
	lift_time INTEGER,
	msg TEXT
);

CREATE TABLE log (
	uid INTEGER,
	ip_addr TEXT,
	type SMALLINT,
	time INTEGER,
	agent VARCHAR(255)
);

CREATE TABLE motd (
	id SERIAL PRIMARY KEY,
	message TEXT
);

CREATE TABLE scan_height (
	height INTEGER NOT NULL,
	time INTEGER
);
INSERT INTO scan_height (height, time) VALUES (0, 0);

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.2
-- Dumped by pg_dump version 9.5.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

--
-- Name: customer_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE customer_status AS ENUM (
    'signed_up',
    'verified',
    'inactive'
);


--
-- Name: refresh_customer_details(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION refresh_customer_details() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        REFRESH MATERIALIZED VIEW CONCURRENTLY customer_details;
        RETURN NULL;
      EXCEPTION
        WHEN feature_not_supported THEN
          RETURN NULL;
      END $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE addresses (
    id integer NOT NULL,
    street character varying NOT NULL,
    city character varying NOT NULL,
    state_id integer NOT NULL,
    zipcode character varying NOT NULL
);


--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE addresses_id_seq OWNED BY addresses.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE customers (
    id integer NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    email character varying NOT NULL,
    username character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    insights json DEFAULT '{}'::json,
    status customer_status DEFAULT 'signed_up'::customer_status NOT NULL,
    bio text
);


--
-- Name: customers_billing_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE customers_billing_addresses (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    address_id integer NOT NULL
);


--
-- Name: customers_shipping_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE customers_shipping_addresses (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    address_id integer NOT NULL,
    "primary" boolean DEFAULT false NOT NULL
);


--
-- Name: states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE states (
    id integer NOT NULL,
    code character varying NOT NULL,
    name character varying NOT NULL
);


--
-- Name: customer_details; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW customer_details AS
 SELECT customers.id AS customer_id,
    customers.first_name,
    customers.last_name,
    customers.email,
    customers.username,
    customers.created_at AS joined_at,
    billing_address.id AS billing_address_id,
    billing_address.street AS billing_street,
    billing_address.city AS billing_city,
    billing_state.code AS billing_state,
    billing_address.zipcode AS billing_zipcode,
    shipping_address.id AS shipping_address_id,
    shipping_address.street AS shipping_street,
    shipping_address.city AS shipping_city,
    shipping_state.code AS shipping_state,
    shipping_address.zipcode AS shipping_zipcode
   FROM ((((((customers
     JOIN customers_billing_addresses ON ((customers.id = customers_billing_addresses.customer_id)))
     JOIN addresses billing_address ON ((billing_address.id = customers_billing_addresses.address_id)))
     JOIN states billing_state ON ((billing_address.state_id = billing_state.id)))
     JOIN customers_shipping_addresses ON (((customers.id = customers_shipping_addresses.customer_id) AND (customers_shipping_addresses."primary" = true))))
     JOIN addresses shipping_address ON ((shipping_address.id = customers_shipping_addresses.address_id)))
     JOIN states shipping_state ON ((shipping_address.state_id = shipping_state.id)))
  WITH NO DATA;


--
-- Name: customers_billing_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE customers_billing_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_billing_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE customers_billing_addresses_id_seq OWNED BY customers_billing_addresses.id;


--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE customers_id_seq OWNED BY customers.id;


--
-- Name: customers_shipping_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE customers_shipping_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_shipping_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE customers_shipping_addresses_id_seq OWNED BY customers_shipping_addresses.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE states_id_seq OWNED BY states.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    roles character varying[] DEFAULT '{}'::character varying[],
    settings hstore,
    CONSTRAINT email_must_be_company_email CHECK (((email)::text ~* '^[^@]+@example\.com'::text))
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY addresses ALTER COLUMN id SET DEFAULT nextval('addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY customers ALTER COLUMN id SET DEFAULT nextval('customers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY customers_billing_addresses ALTER COLUMN id SET DEFAULT nextval('customers_billing_addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY customers_shipping_addresses ALTER COLUMN id SET DEFAULT nextval('customers_shipping_addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY states ALTER COLUMN id SET DEFAULT nextval('states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: customers_billing_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY customers_billing_addresses
    ADD CONSTRAINT customers_billing_addresses_pkey PRIMARY KEY (id);


--
-- Name: customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: customers_shipping_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY customers_shipping_addresses
    ADD CONSTRAINT customers_shipping_addresses_pkey PRIMARY KEY (id);


--
-- Name: states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: customer_details_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX customer_details_customer_id ON customer_details USING btree (customer_id);


--
-- Name: customers_bio_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customers_bio_index ON customers USING gin (to_tsvector('english'::regconfig, bio));


--
-- Name: customers_lower_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customers_lower_email ON customers USING btree (lower((email)::text));


--
-- Name: customers_lower_first_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customers_lower_first_name ON customers USING btree (lower((first_name)::text) varchar_pattern_ops);


--
-- Name: customers_lower_last_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customers_lower_last_name ON customers USING btree (lower((last_name)::text) varchar_pattern_ops);


--
-- Name: index_customers_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_customers_on_email ON customers USING btree (email);


--
-- Name: index_customers_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_customers_on_username ON customers USING btree (username);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: users_roles; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_roles ON users USING gin (roles);


--
-- Name: refresh_customer_details; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER refresh_customer_details AFTER INSERT OR DELETE OR UPDATE ON customers FOR EACH STATEMENT EXECUTE PROCEDURE refresh_customer_details();


--
-- Name: refresh_customer_details; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER refresh_customer_details AFTER INSERT OR DELETE OR UPDATE ON customers_shipping_addresses FOR EACH STATEMENT EXECUTE PROCEDURE refresh_customer_details();


--
-- Name: refresh_customer_details; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER refresh_customer_details AFTER INSERT OR DELETE OR UPDATE ON customers_billing_addresses FOR EACH STATEMENT EXECUTE PROCEDURE refresh_customer_details();


--
-- Name: refresh_customer_details; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER refresh_customer_details AFTER INSERT OR DELETE OR UPDATE ON addresses FOR EACH STATEMENT EXECUTE PROCEDURE refresh_customer_details();


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20160821165850');

INSERT INTO schema_migrations (version) VALUES ('20160823231528');

INSERT INTO schema_migrations (version) VALUES ('20160823233410');

INSERT INTO schema_migrations (version) VALUES ('20160824003654');

INSERT INTO schema_migrations (version) VALUES ('20161013213640');

INSERT INTO schema_migrations (version) VALUES ('20161014003447');

INSERT INTO schema_migrations (version) VALUES ('20161014012237');

INSERT INTO schema_migrations (version) VALUES ('20161020002100');

INSERT INTO schema_migrations (version) VALUES ('20161105213722');

INSERT INTO schema_migrations (version) VALUES ('20161105215528');

INSERT INTO schema_migrations (version) VALUES ('20161105215541');

INSERT INTO schema_migrations (version) VALUES ('20161105223433');

INSERT INTO schema_migrations (version) VALUES ('20161105224453');

INSERT INTO schema_migrations (version) VALUES ('20161105225225');


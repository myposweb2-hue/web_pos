--
-- PostgreSQL database dump
--

\restrict 41KKCmLxbGOGAv5i66DQkPjxBI0VXtD6qtuk6OOxHzoBzVAVqlkOk2qmFN0NgqH

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO pos_user;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.audit_logs (
    id integer NOT NULL,
    user_id integer,
    entity_type character varying(50) NOT NULL,
    entity_id integer,
    action character varying(50) NOT NULL,
    old_values text,
    new_values text,
    "timestamp" timestamp without time zone,
    ip_address character varying(45),
    user_agent character varying(255),
    company_id integer,
    description text
);


ALTER TABLE public.audit_logs OWNER TO pos_user;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.audit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_logs_id_seq OWNER TO pos_user;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: cheque_deposits; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.cheque_deposits (
    id integer NOT NULL,
    deposit_date date NOT NULL,
    bank_account character varying(100) NOT NULL,
    reference_number character varying(100),
    notes text,
    created_at timestamp without time zone,
    created_by integer,
    company_id integer
);


ALTER TABLE public.cheque_deposits OWNER TO pos_user;

--
-- Name: cheque_deposits_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.cheque_deposits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cheque_deposits_id_seq OWNER TO pos_user;

--
-- Name: cheque_deposits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.cheque_deposits_id_seq OWNED BY public.cheque_deposits.id;


--
-- Name: cheques; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.cheques (
    id integer NOT NULL,
    cheque_number character varying(50) NOT NULL,
    bank_name character varying(100) NOT NULL,
    branch character varying(100),
    cheque_date date NOT NULL,
    amount double precision NOT NULL,
    payer_name character varying(255),
    customer_id integer,
    supplier_id integer,
    notes text,
    image_front character varying(255),
    image_back character varying(255),
    status character varying(20),
    status_updated_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    created_by integer,
    updated_by integer,
    deposit_id integer,
    sale_id integer,
    purchase_id integer,
    is_partial boolean,
    company_id integer
);


ALTER TABLE public.cheques OWNER TO pos_user;

--
-- Name: cheques_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.cheques_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cheques_id_seq OWNER TO pos_user;

--
-- Name: cheques_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.cheques_id_seq OWNED BY public.cheques.id;


--
-- Name: companies; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.companies (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    address text,
    phone character varying(20),
    email character varying(255),
    business_name character varying(255),
    tax_id character varying(50),
    is_active boolean,
    created_at timestamp without time zone,
    default_currency character varying(10),
    timezone character varying(50)
);


ALTER TABLE public.companies OWNER TO pos_user;

--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.companies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.companies_id_seq OWNER TO pos_user;

--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: customer_feedback; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.customer_feedback (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    sale_id integer NOT NULL,
    rating integer NOT NULL,
    feedback_text text,
    feedback_date timestamp without time zone,
    company_id integer
);


ALTER TABLE public.customer_feedback OWNER TO pos_user;

--
-- Name: customer_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.customer_feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_feedback_id_seq OWNER TO pos_user;

--
-- Name: customer_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.customer_feedback_id_seq OWNED BY public.customer_feedback.id;


--
-- Name: customer_payments; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.customer_payments (
    id integer NOT NULL,
    date timestamp without time zone,
    customer_id integer NOT NULL,
    sale_id integer,
    amount double precision NOT NULL,
    payment_method character varying(20),
    reference_number character varying(50),
    notes text,
    user_id integer,
    company_id integer
);


ALTER TABLE public.customer_payments OWNER TO pos_user;

--
-- Name: customer_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.customer_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_payments_id_seq OWNER TO pos_user;

--
-- Name: customer_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.customer_payments_id_seq OWNED BY public.customer_payments.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.customers (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    phone character varying(20),
    email character varying(255),
    address text,
    loyalty_points integer,
    total_purchases double precision,
    last_purchase_date timestamp without time zone,
    registration_date timestamp without time zone,
    notes text,
    preferred_payment_method character varying(20),
    credit_limit double precision,
    current_balance double precision,
    is_active boolean DEFAULT true,
    archived_at timestamp without time zone,
    outstanding_0_30 double precision DEFAULT 0.0,
    outstanding_30_60 double precision DEFAULT 0.0,
    outstanding_60_90 double precision DEFAULT 0.0,
    outstanding_90_plus double precision DEFAULT 0.0,
    supply_stopped boolean DEFAULT false,
    last_balance_update timestamp without time zone,
    company_id integer,
    credit_days integer DEFAULT 0
);


ALTER TABLE public.customers OWNER TO pos_user;

--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.customers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_id_seq OWNER TO pos_user;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: exchange_items; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.exchange_items (
    id integer NOT NULL,
    exchange_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity double precision NOT NULL,
    price double precision NOT NULL,
    reason character varying(255),
    company_id integer
);


ALTER TABLE public.exchange_items OWNER TO pos_user;

--
-- Name: exchange_items_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.exchange_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.exchange_items_id_seq OWNER TO pos_user;

--
-- Name: exchange_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.exchange_items_id_seq OWNED BY public.exchange_items.id;


--
-- Name: exchanges; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.exchanges (
    id integer NOT NULL,
    date timestamp without time zone,
    original_sale_id integer,
    new_sale_id integer,
    customer character varying(255),
    notes text,
    user_id integer,
    company_id integer
);


ALTER TABLE public.exchanges OWNER TO pos_user;

--
-- Name: exchanges_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.exchanges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.exchanges_id_seq OWNER TO pos_user;

--
-- Name: exchanges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.exchanges_id_seq OWNED BY public.exchanges.id;


--
-- Name: expenses; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.expenses (
    id integer NOT NULL,
    date timestamp without time zone,
    category character varying(50) NOT NULL,
    description text,
    amount double precision NOT NULL,
    company_id integer
);


ALTER TABLE public.expenses OWNER TO pos_user;

--
-- Name: expenses_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.expenses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.expenses_id_seq OWNER TO pos_user;

--
-- Name: expenses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.expenses_id_seq OWNED BY public.expenses.id;


--
-- Name: held_bills; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.held_bills (
    id integer NOT NULL,
    bill_data text NOT NULL,
    held_date timestamp without time zone,
    user_id integer,
    notes text,
    company_id integer
);


ALTER TABLE public.held_bills OWNER TO pos_user;

--
-- Name: held_bills_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.held_bills_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.held_bills_id_seq OWNER TO pos_user;

--
-- Name: held_bills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.held_bills_id_seq OWNED BY public.held_bills.id;


--
-- Name: inventory_transactions; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.inventory_transactions (
    id integer NOT NULL,
    product_id integer NOT NULL,
    transaction_type character varying(20) NOT NULL,
    quantity double precision NOT NULL,
    previous_stock double precision NOT NULL,
    new_stock double precision NOT NULL,
    reference_id integer,
    date timestamp without time zone,
    notes text,
    company_id integer
);


ALTER TABLE public.inventory_transactions OWNER TO pos_user;

--
-- Name: inventory_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.inventory_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventory_transactions_id_seq OWNER TO pos_user;

--
-- Name: inventory_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.inventory_transactions_id_seq OWNED BY public.inventory_transactions.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    price double precision NOT NULL,
    cost_price double precision,
    stock double precision NOT NULL,
    unit_type character varying(10),
    category character varying(50),
    low_stock_threshold double precision,
    barcode character varying(50),
    description text,
    image_path character varying(255),
    last_updated timestamp without time zone,
    warehouse_id integer,
    price_per_kg double precision,
    product_code character varying(50),
    company_id integer,
    supplier_id integer
);


ALTER TABLE public.products OWNER TO pos_user;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO pos_user;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: promotions; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.promotions (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    discount_type character varying(20) NOT NULL,
    discount_value double precision NOT NULL,
    minimum_purchase double precision,
    applicable_products text,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    is_active boolean,
    usage_limit integer,
    usage_count integer,
    created_date timestamp without time zone,
    company_id integer
);


ALTER TABLE public.promotions OWNER TO pos_user;

--
-- Name: promotions_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.promotions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.promotions_id_seq OWNER TO pos_user;

--
-- Name: promotions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.promotions_id_seq OWNED BY public.promotions.id;


--
-- Name: purchase_items; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.purchase_items (
    id integer NOT NULL,
    purchase_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity double precision NOT NULL,
    cost_price double precision NOT NULL,
    total_cost double precision NOT NULL,
    company_id integer
);


ALTER TABLE public.purchase_items OWNER TO pos_user;

--
-- Name: purchase_items_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.purchase_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.purchase_items_id_seq OWNER TO pos_user;

--
-- Name: purchase_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.purchase_items_id_seq OWNED BY public.purchase_items.id;


--
-- Name: purchase_order_items; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.purchase_order_items (
    id integer NOT NULL,
    purchase_order_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity_ordered double precision NOT NULL,
    quantity_received double precision,
    unit_cost double precision NOT NULL,
    total_cost double precision NOT NULL,
    company_id integer
);


ALTER TABLE public.purchase_order_items OWNER TO pos_user;

--
-- Name: purchase_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.purchase_order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.purchase_order_items_id_seq OWNER TO pos_user;

--
-- Name: purchase_order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.purchase_order_items_id_seq OWNED BY public.purchase_order_items.id;


--
-- Name: purchase_orders; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.purchase_orders (
    id integer NOT NULL,
    date_created timestamp without time zone,
    supplier_id integer,
    status character varying(20),
    expected_delivery_date timestamp without time zone,
    total_amount double precision,
    notes text,
    company_id integer
);


ALTER TABLE public.purchase_orders OWNER TO pos_user;

--
-- Name: purchase_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.purchase_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.purchase_orders_id_seq OWNER TO pos_user;

--
-- Name: purchase_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.purchase_orders_id_seq OWNED BY public.purchase_orders.id;


--
-- Name: purchase_return_items; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.purchase_return_items (
    id integer NOT NULL,
    purchase_return_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity double precision NOT NULL,
    unit_cost double precision NOT NULL,
    total_cost double precision NOT NULL,
    company_id integer
);


ALTER TABLE public.purchase_return_items OWNER TO pos_user;

--
-- Name: purchase_return_items_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.purchase_return_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.purchase_return_items_id_seq OWNER TO pos_user;

--
-- Name: purchase_return_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.purchase_return_items_id_seq OWNED BY public.purchase_return_items.id;


--
-- Name: purchase_returns; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.purchase_returns (
    id integer NOT NULL,
    date timestamp without time zone,
    original_purchase_id integer NOT NULL,
    supplier_id integer NOT NULL,
    return_reason character varying(255),
    refund_amount double precision NOT NULL,
    notes text,
    user_id integer,
    company_id integer
);


ALTER TABLE public.purchase_returns OWNER TO pos_user;

--
-- Name: purchase_returns_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.purchase_returns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.purchase_returns_id_seq OWNER TO pos_user;

--
-- Name: purchase_returns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.purchase_returns_id_seq OWNED BY public.purchase_returns.id;


--
-- Name: purchases; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.purchases (
    id integer NOT NULL,
    date timestamp without time zone,
    supplier_id integer,
    invoice_number character varying(50),
    total_amount double precision,
    amount_paid double precision,
    status character varying(20),
    company_id integer
);


ALTER TABLE public.purchases OWNER TO pos_user;

--
-- Name: purchases_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.purchases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.purchases_id_seq OWNER TO pos_user;

--
-- Name: purchases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.purchases_id_seq OWNED BY public.purchases.id;


--
-- Name: return_items; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.return_items (
    id integer NOT NULL,
    return_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity double precision NOT NULL,
    price double precision NOT NULL,
    reason character varying(255),
    original_sale_item_id integer,
    company_id integer
);


ALTER TABLE public.return_items OWNER TO pos_user;

--
-- Name: return_items_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.return_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.return_items_id_seq OWNER TO pos_user;

--
-- Name: return_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.return_items_id_seq OWNED BY public.return_items.id;


--
-- Name: returns; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.returns (
    id integer NOT NULL,
    date timestamp without time zone,
    original_sale_id integer NOT NULL,
    customer character varying(255),
    return_reason character varying(255) NOT NULL,
    refund_method character varying(20) NOT NULL,
    refund_amount double precision NOT NULL,
    status character varying(20),
    notes text,
    user_id integer,
    company_id integer
);


ALTER TABLE public.returns OWNER TO pos_user;

--
-- Name: returns_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.returns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.returns_id_seq OWNER TO pos_user;

--
-- Name: returns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.returns_id_seq OWNED BY public.returns.id;


--
-- Name: sale_items; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.sale_items (
    id integer NOT NULL,
    sale_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity double precision NOT NULL,
    price double precision NOT NULL,
    discount double precision,
    tax double precision,
    company_id integer
);


ALTER TABLE public.sale_items OWNER TO pos_user;

--
-- Name: sale_items_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.sale_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sale_items_id_seq OWNER TO pos_user;

--
-- Name: sale_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.sale_items_id_seq OWNED BY public.sale_items.id;


--
-- Name: sales; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.sales (
    id integer NOT NULL,
    date timestamp without time zone,
    customer character varying(255),
    total double precision NOT NULL,
    payment character varying(20),
    cash_given double precision,
    balance double precision,
    user_id integer,
    discount double precision DEFAULT 0.0,
    tax double precision DEFAULT 0.0,
    company_id integer
);


ALTER TABLE public.sales OWNER TO pos_user;

--
-- Name: sales_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.sales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sales_id_seq OWNER TO pos_user;

--
-- Name: sales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.sales_id_seq OWNED BY public.sales.id;


--
-- Name: serial_numbers; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.serial_numbers (
    id integer NOT NULL,
    product_id integer NOT NULL,
    serial_number character varying(100) NOT NULL,
    lot_number character varying(50),
    expiry_date timestamp without time zone,
    purchase_date timestamp without time zone,
    status character varying(20),
    company_id integer
);


ALTER TABLE public.serial_numbers OWNER TO pos_user;

--
-- Name: serial_numbers_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.serial_numbers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.serial_numbers_id_seq OWNER TO pos_user;

--
-- Name: serial_numbers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.serial_numbers_id_seq OWNED BY public.serial_numbers.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.settings (
    id integer NOT NULL,
    setting_category character varying(50) NOT NULL,
    setting_key character varying(100) NOT NULL,
    setting_value text,
    updated_at timestamp without time zone,
    company_id integer
);


ALTER TABLE public.settings OWNER TO pos_user;

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.settings_id_seq OWNER TO pos_user;

--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.suppliers (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    contact_person character varying(255),
    phone character varying(20),
    email character varying(255),
    address text,
    company_id integer
);


ALTER TABLE public.suppliers OWNER TO pos_user;

--
-- Name: suppliers_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.suppliers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suppliers_id_seq OWNER TO pos_user;

--
-- Name: suppliers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.suppliers_id_seq OWNED BY public.suppliers.id;


--
-- Name: user_companies; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.user_companies (
    user_id integer NOT NULL,
    company_id integer NOT NULL,
    is_admin boolean,
    created_at timestamp without time zone
);


ALTER TABLE public.user_companies OWNER TO pos_user;

--
-- Name: users; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(255),
    password_hash character varying(255) NOT NULL,
    role character varying(20),
    last_login timestamp without time zone,
    can_access_sales boolean,
    can_access_purchases boolean,
    can_access_suppliers boolean,
    can_view_inventory boolean,
    can_edit_inventory boolean,
    can_view_sales_history boolean,
    can_view_reports boolean,
    can_access_expenses boolean,
    can_access_customers boolean,
    can_view_profit boolean,
    can_access_warehouse boolean,
    can_access_settings boolean,
    can_access_cheques boolean DEFAULT false,
    can_access_quotations boolean DEFAULT false,
    can_access_messages boolean DEFAULT false,
    can_access_audit_logs boolean DEFAULT false,
    can_access_scale boolean DEFAULT false,
    can_manage_returns boolean DEFAULT false,
    can_manage_purchase_returns boolean DEFAULT false,
    can_manage_customer_payments boolean DEFAULT false,
    profile_picture character varying(255),
    can_view_general_settings boolean DEFAULT false NOT NULL,
    can_view_receipt_settings boolean DEFAULT false NOT NULL,
    can_view_terminal_settings boolean DEFAULT false NOT NULL,
    can_view_backup_settings boolean DEFAULT false NOT NULL,
    can_view_hardware_settings boolean DEFAULT false NOT NULL,
    can_view_own_profile boolean DEFAULT true
);


ALTER TABLE public.users OWNER TO pos_user;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO pos_user;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: warehouses; Type: TABLE; Schema: public; Owner: pos_user
--

CREATE TABLE public.warehouses (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    location character varying(255),
    description text,
    created_at timestamp without time zone,
    company_id integer
);


ALTER TABLE public.warehouses OWNER TO pos_user;

--
-- Name: warehouses_id_seq; Type: SEQUENCE; Schema: public; Owner: pos_user
--

CREATE SEQUENCE public.warehouses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.warehouses_id_seq OWNER TO pos_user;

--
-- Name: warehouses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pos_user
--

ALTER SEQUENCE public.warehouses_id_seq OWNED BY public.warehouses.id;


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: cheque_deposits id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.cheque_deposits ALTER COLUMN id SET DEFAULT nextval('public.cheque_deposits_id_seq'::regclass);


--
-- Name: cheques id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.cheques ALTER COLUMN id SET DEFAULT nextval('public.cheques_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: customer_feedback id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.customer_feedback ALTER COLUMN id SET DEFAULT nextval('public.customer_feedback_id_seq'::regclass);


--
-- Name: customer_payments id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.customer_payments ALTER COLUMN id SET DEFAULT nextval('public.customer_payments_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: exchange_items id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.exchange_items ALTER COLUMN id SET DEFAULT nextval('public.exchange_items_id_seq'::regclass);


--
-- Name: exchanges id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.exchanges ALTER COLUMN id SET DEFAULT nextval('public.exchanges_id_seq'::regclass);


--
-- Name: expenses id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.expenses ALTER COLUMN id SET DEFAULT nextval('public.expenses_id_seq'::regclass);


--
-- Name: held_bills id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.held_bills ALTER COLUMN id SET DEFAULT nextval('public.held_bills_id_seq'::regclass);


--
-- Name: inventory_transactions id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.inventory_transactions ALTER COLUMN id SET DEFAULT nextval('public.inventory_transactions_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: promotions id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.promotions ALTER COLUMN id SET DEFAULT nextval('public.promotions_id_seq'::regclass);


--
-- Name: purchase_items id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_items ALTER COLUMN id SET DEFAULT nextval('public.purchase_items_id_seq'::regclass);


--
-- Name: purchase_order_items id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_order_items ALTER COLUMN id SET DEFAULT nextval('public.purchase_order_items_id_seq'::regclass);


--
-- Name: purchase_orders id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_orders ALTER COLUMN id SET DEFAULT nextval('public.purchase_orders_id_seq'::regclass);


--
-- Name: purchase_return_items id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_return_items ALTER COLUMN id SET DEFAULT nextval('public.purchase_return_items_id_seq'::regclass);


--
-- Name: purchase_returns id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_returns ALTER COLUMN id SET DEFAULT nextval('public.purchase_returns_id_seq'::regclass);


--
-- Name: purchases id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchases ALTER COLUMN id SET DEFAULT nextval('public.purchases_id_seq'::regclass);


--
-- Name: return_items id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.return_items ALTER COLUMN id SET DEFAULT nextval('public.return_items_id_seq'::regclass);


--
-- Name: returns id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.returns ALTER COLUMN id SET DEFAULT nextval('public.returns_id_seq'::regclass);


--
-- Name: sale_items id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.sale_items ALTER COLUMN id SET DEFAULT nextval('public.sale_items_id_seq'::regclass);


--
-- Name: sales id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.sales ALTER COLUMN id SET DEFAULT nextval('public.sales_id_seq'::regclass);


--
-- Name: serial_numbers id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.serial_numbers ALTER COLUMN id SET DEFAULT nextval('public.serial_numbers_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: suppliers id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.suppliers ALTER COLUMN id SET DEFAULT nextval('public.suppliers_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: warehouses id; Type: DEFAULT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.warehouses ALTER COLUMN id SET DEFAULT nextval('public.warehouses_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.alembic_version (version_num) FROM stdin;
add_profile_picture_to_users
002_add_company_id
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.audit_logs (id, user_id, entity_type, entity_id, action, old_values, new_values, "timestamp", ip_address, user_agent, company_id, description) FROM stdin;
92	12	Product	165	create	\N	{"name": "Product 1", "price": 1500.0, "cost_price": 0.0, "stock": 10.0, "category": "Phone"}	2026-04-07 09:28:26.476928	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	14	Product 'Product 1' created with price ₨1500.0
93	12	Customer	18	create	\N	{"name": "Credite sale customer", "phone": "", "email": "", "address": null, "credit_limit": 0.0}	2026-04-07 09:29:43.99186	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	14	Customer 'Credite sale customer' created
\.


--
-- Data for Name: cheque_deposits; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.cheque_deposits (id, deposit_date, bank_account, reference_number, notes, created_at, created_by, company_id) FROM stdin;
\.


--
-- Data for Name: cheques; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.cheques (id, cheque_number, bank_name, branch, cheque_date, amount, payer_name, customer_id, supplier_id, notes, image_front, image_back, status, status_updated_at, created_at, updated_at, created_by, updated_by, deposit_id, sale_id, purchase_id, is_partial, company_id) FROM stdin;
24	4589	HNB	\N	2026-04-07	1770	Walk-in Customer	\N	\N	\N	\N	\N	pending	2026-04-07 09:29:00.418216	2026-04-07 09:29:00.418228	2026-04-07 09:29:00.418235	12	\N	\N	158	\N	f	14
\.


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.companies (id, name, address, phone, email, business_name, tax_id, is_active, created_at, default_currency, timezone) FROM stdin;
14	Imicon						t	2026-04-06 18:30:08.259095	LKR	Asia/Colombo
18	New						t	2026-04-07 09:31:45.404424	LKR	Asia/Colombo
\.


--
-- Data for Name: customer_feedback; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.customer_feedback (id, customer_id, sale_id, rating, feedback_text, feedback_date, company_id) FROM stdin;
\.


--
-- Data for Name: customer_payments; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.customer_payments (id, date, customer_id, sale_id, amount, payment_method, reference_number, notes, user_id, company_id) FROM stdin;
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.customers (id, name, phone, email, address, loyalty_points, total_purchases, last_purchase_date, registration_date, notes, preferred_payment_method, credit_limit, current_balance, is_active, archived_at, outstanding_0_30, outstanding_30_60, outstanding_60_90, outstanding_90_plus, supply_stopped, last_balance_update, company_id, credit_days) FROM stdin;
18	Credite sale customer			\N	150	1500	2026-04-07 09:29:46.160115	2026-04-07 09:29:43.954906	\N	\N	0	1770	t	\N	1770	0	0	0	f	2026-04-07 09:29:46.160171	14	0
\.


--
-- Data for Name: exchange_items; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.exchange_items (id, exchange_id, product_id, quantity, price, reason, company_id) FROM stdin;
\.


--
-- Data for Name: exchanges; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.exchanges (id, date, original_sale_id, new_sale_id, customer, notes, user_id, company_id) FROM stdin;
\.


--
-- Data for Name: expenses; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.expenses (id, date, category, description, amount, company_id) FROM stdin;
7	2026-04-02 19:18:38.735754	Rent		80000	\N
\.


--
-- Data for Name: held_bills; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.held_bills (id, bill_data, held_date, user_id, notes, company_id) FROM stdin;
11	{"cart": [{"product_id": 49, "name": "Product 1", "price": 250000, "quantity": 1, "unit_type": "unit", "discount": 0, "tax": 0}, {"product_id": 58, "name": "Product 10", "price": 250000, "quantity": 2, "unit_type": "unit", "discount": 0, "tax": 0}, {"product_id": 61, "name": "Product 13", "price": 250000, "quantity": 1, "unit_type": "unit", "discount": 0, "tax": 0}], "customer": "Walk-in Customer", "subtotal": 1000000, "discount": 0, "tax": 0, "total": 1000000, "notes": "later"}	2026-03-31 15:07:09.961513	\N	later	\N
12	{"cart": [{"product_id": 66, "name": "Bread", "price": 35, "quantity": 2, "unit_type": "unit", "discount": 0, "tax": 0}], "customer": "Walk-in Customer", "subtotal": 70, "discount": 0, "tax": 0, "total": 70, "notes": "later"}	2026-04-02 09:35:44.243214	\N	later	\N
\.


--
-- Data for Name: inventory_transactions; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.inventory_transactions (id, product_id, transaction_type, quantity, previous_stock, new_stock, reference_id, date, notes, company_id) FROM stdin;
164	85	sale	1	100	99	113	2026-04-02 12:18:12.608042	Sold to New customer	\N
166	81	sale	1	77	76	117	2026-04-02 12:20:46.800234	Sold to Walk-in Customer	\N
167	75	sale	1	35	34	117	2026-04-02 12:20:46.800242	Sold to Walk-in Customer	\N
170	81	sale	1.5	76	74.5	119	2026-04-02 13:26:48.206554	Sold to Walk-in Customer	\N
171	75	sale	1	34	33	119	2026-04-02 13:26:48.206565	Sold to Walk-in Customer	\N
172	81	sale	1	74.5	73.5	120	2026-04-02 13:38:12.545888	Sold to Walk-in Customer	\N
175	81	sale	1	72.5	71.5	122	2026-04-02 13:49:50.320125	Sold to Walk-in Customer	\N
176	75	sale	1	32	31	122	2026-04-02 13:49:50.320134	Sold to Walk-in Customer	\N
177	95	sale	1	34	33	122	2026-04-02 13:49:50.320138	Sold to Walk-in Customer	\N
181	101	sale	1	77	76	124	2026-04-02 14:00:50.240411	Sold to Walk-in Customer	\N
182	95	sale	1	32	31	124	2026-04-02 14:00:50.24042	Sold to Walk-in Customer	\N
183	75	sale	1	30	29	124	2026-04-02 14:00:50.240424	Sold to Walk-in Customer	\N
184	66	sale	1	47	46	124	2026-04-02 14:00:50.240428	Sold to Walk-in Customer	\N
188	101	sale	2	75	73	126	2026-04-02 14:25:42.620674	Sold to Walk-in Customer	\N
189	75	sale	3	29	26	126	2026-04-02 14:25:42.620683	Sold to Walk-in Customer	\N
190	95	sale	2	30	28	126	2026-04-02 14:25:42.620687	Sold to Walk-in Customer	\N
191	100	sale	1	60	59	126	2026-04-02 14:25:42.620691	Sold to Walk-in Customer	\N
192	85	sale	1	99	98	126	2026-04-02 14:25:42.620695	Sold to Walk-in Customer	\N
193	86	sale	1	97	96	126	2026-04-02 14:25:42.620698	Sold to Walk-in Customer	\N
196	50	adjustment	0	3	0	\N	2026-04-02 14:55:08.29937	Manual stock adjustment via web interface	\N
199	81	sale	1	68.5	67.5	129	2026-04-02 18:52:41.330656	Sold to Walk-in Customer	\N
200	101	sale	1	73	72	129	2026-04-02 18:52:41.330663	Sold to Walk-in Customer	\N
203	101	sale	1	73	72	130	2026-04-02 20:08:33.975388	Sold to Walk-in Customer	\N
205	70	purchase_return	10	50	40	4	2026-04-02 21:08:14.671392	\N	\N
207	70	purchase	10	10	20	8	2026-04-02 21:13:51.572316	\N	\N
208	70	purchase	1	20	21	9	2026-04-02 21:16:32.631332	\N	\N
212	70	purchase_reversed	-10	21	11	6	2026-04-02 21:33:51.232441	Purchase #6 deleted - stock reversed	\N
218	70	purchase	1	-10	-9	10	2026-04-02 21:35:38.780323	\N	\N
220	70	purchase_reversed	-1	1	0	10	2026-04-02 21:37:01.722901	Purchase #10 deleted - stock reversed	\N
221	70	purchase	10	64	74	12	2026-04-02 21:47:17.229106	\N	\N
223	70	return_deleted	10	64	74	5	2026-04-02 22:02:50.059808	Purchase Return #5 deleted - stock reversed	\N
225	79	sale	1	9	8	132	2026-04-03 05:52:00.090286	Sold to Walk-in Customer	\N
226	79	return	1	8	9	25	2026-04-03 05:53:44.376904	Returned from Sale #132	\N
228	70	return_deleted	5	69	74	6	2026-04-03 06:07:34.478299	Purchase Return #6 deleted - stock reversed	\N
232	66	adjustment	100	0	100	\N	2026-04-04 10:22:38.243962	Manual stock adjustment via web interface	\N
234	81	adjustment	100	0	100	\N	2026-04-04 10:23:06.003025	Manual stock adjustment via web interface	\N
237	86	sale	1	100	99	134	2026-04-05 09:29:39.1699	Sold to Walk-in Customer	\N
239	81	sale	1	99	98	136	2026-04-05 12:27:40.919931	Sold to new credit sale	\N
240	91	sale	8	100	92	136	2026-04-05 12:27:40.919939	Sold to new credit sale	\N
242	86	sale	1	99	98	138	2026-04-05 12:42:23.936837	Sold to new credit sale	\N
244	86	sale	1	97	96	140	2026-04-05 12:45:36.551828	Sold to new credit sale	\N
246	95	adjustment	4	98	4	\N	2026-04-05 17:17:58.713963	Manual stock adjustment via web interface	\N
247	81	sale	1	98	97	142	2026-04-06 17:48:03.820944	Sold to Walk-in Customer	\N
128	49	adjustment	5	0	5	\N	2026-03-28 15:48:38.406521	Manual stock adjustment via web interface	\N
129	49	sale	1	5	4	86	2026-03-28 15:57:03.318644	Sold to new credit sale	\N
130	49	sale	1	4	3	87	2026-03-28 16:26:49.328276	Sold to New customer	\N
131	50	sale	1	4	3	88	2026-03-28 18:29:18.851493	Sold to new credit sale	\N
132	58	sale	1	4	3	89	2026-03-28 18:45:51.228237	Sold to new credit sale	\N
133	52	sale	1	4	3	90	2026-03-28 18:50:59.855555	Sold to new credit sale	\N
134	59	sale	1	4	3	91	2026-03-28 18:56:15.247388	Sold to Walk-in Customer	\N
135	55	sale	1	4	3	92	2026-03-28 19:04:58.756496	Sold to Walk-in Customer	\N
136	57	sale	1	4	3	93	2026-03-28 19:14:10.196028	Sold to Walk-in Customer	\N
137	57	sale	1	3	2	94	2026-03-28 19:23:53.560433	Sold to Walk-in Customer	\N
138	52	sale	1	3	2	95	2026-03-28 19:55:43.454673	Sold to Walk-in Customer	\N
139	58	sale	1	3	2	96	2026-03-28 20:04:33.511641	Sold to Walk-in Customer	\N
140	62	sale	1	4	3	98	2026-03-30 05:54:27.311188	Sold to Walk-in Customer	\N
141	59	sale	1	3	2	98	2026-03-30 05:54:27.311203	Sold to Walk-in Customer	\N
142	49	sale	1	4	3	99	2026-03-30 09:55:43.63786	Sold to Walk-in Customer	\N
143	86	purchase	51	50	101	4	2026-04-01 17:13:58.519008	\N	\N
144	81	sale	1	80	79	100	2026-04-02 06:35:25.090754	Sold to Walk-in Customer	\N
145	66	sale	1	50	49	100	2026-04-02 06:35:25.090764	Sold to Walk-in Customer	\N
146	101	sale	1	80	79	101	2026-04-02 07:02:19.89768	Sold to Walk-in Customer	\N
147	101	sale	1	79	78	102	2026-04-02 07:07:07.266096	Sold to Walk-in Customer	\N
148	81	sale	1	79	78	103	2026-04-02 07:19:04.450063	Sold to Walk-in Customer	\N
149	66	sale	1	49	48	104	2026-04-02 09:11:44.409963	Sold to Walk-in Customer	\N
150	79	purchase	5	200	205	5	2026-04-02 09:27:38.309086	\N	\N
154	81	sale	1	78	77	106	2026-04-02 09:55:12.305936	Sold to Walk-in Customer	\N
155	95	sale	1	35	34	106	2026-04-02 09:55:12.305947	Sold to Walk-in Customer	\N
156	66	sale	1	48	47	106	2026-04-02 09:55:12.305954	Sold to Walk-in Customer	\N
163	86	sale	1	100	99	111	2026-04-02 12:17:09.319962	Sold to Walk-in Customer	\N
158	86	sale	1	101	100	108	2026-04-02 10:34:58.938203	Sold to Walk-in Customer	\N
165	87	sale	2	80	78	116	2026-04-02 12:19:40.873744	Sold to new credit sale	\N
168	101	sale	1	78	77	118	2026-04-02 13:24:02.300244	Sold to Walk-in Customer	\N
169	86	sale	2	99	97	118	2026-04-02 13:24:02.300261	Sold to Walk-in Customer	\N
173	81	sale	1	73.5	72.5	121	2026-04-02 13:44:32.248887	Sold to Walk-in Customer	\N
174	75	sale	1	33	32	121	2026-04-02 13:44:32.248896	Sold to Walk-in Customer	\N
178	81	sale	1	71.5	70.5	123	2026-04-02 13:50:46.475679	Sold to Walk-in Customer	\N
179	95	sale	1	33	32	123	2026-04-02 13:50:46.475688	Sold to Walk-in Customer	\N
180	75	sale	1	31	30	123	2026-04-02 13:50:46.475692	Sold to Walk-in Customer	\N
185	101	sale	1	76	75	125	2026-04-02 14:16:02.966026	Sold to Walk-in Customer	\N
186	81	sale	1	70.5	69.5	125	2026-04-02 14:16:02.966035	Sold to Walk-in Customer	\N
187	95	sale	1	31	30	125	2026-04-02 14:16:02.966041	Sold to Walk-in Customer	\N
194	66	sale	1	46	45	127	2026-04-02 14:38:25.660488	Sold to Walk-in Customer	\N
195	95	sale	1	28	27	127	2026-04-02 14:38:25.6605	Sold to Walk-in Customer	\N
197	81	sale	1	69.5	68.5	128	2026-04-02 15:26:36.25049	Sold to Walk-in Customer	\N
198	96	sale	1	25	24	128	2026-04-02 15:26:36.250497	Sold to Walk-in Customer	\N
201	81	return	1	67.5	68.5	24	2026-04-02 18:58:19.915702	Returned from Sale #129	\N
202	101	return	1	72	73	24	2026-04-02 18:58:19.930389	Returned from Sale #129	\N
204	70	purchase	10	40	50	6	2026-04-02 21:06:39.777005	\N	\N
206	70	purchase	10	0	10	7	2026-04-02 21:09:45.337981	\N	\N
213	86	purchase_reversed	-51	96	45	4	2026-04-02 21:34:09.732528	Purchase #4 deleted - stock reversed	\N
214	79	purchase_reversed	-5	205	200	5	2026-04-02 21:34:17.790401	Purchase #5 deleted - stock reversed	\N
215	70	purchase_reversed	-1	11	10	9	2026-04-02 21:34:26.552084	Purchase #9 deleted - stock reversed	\N
216	70	purchase_reversed	-10	10	0	7	2026-04-02 21:34:35.474683	Purchase #7 deleted - stock reversed	\N
217	70	purchase_reversed	-10	0	-10	8	2026-04-02 21:34:43.431089	Purchase #8 deleted - stock reversed	\N
219	70	purchase	10	-9	1	11	2026-04-02 21:36:21.696714	\N	\N
222	70	purchase_return	10	74	64	5	2026-04-02 21:51:17.597043	\N	\N
224	79	sale	1	10	9	131	2026-04-03 05:51:40.130376	Sold to Walk-in Customer	\N
227	70	purchase_return	5	74	69	6	2026-04-03 06:07:17.271082	\N	\N
229	79	adjustment	5	9	5	\N	2026-04-03 06:35:52.120823	Manual stock adjustment via web interface	\N
230	51	adjustment	10	0	10	\N	2026-04-03 06:36:03.382359	Manual stock adjustment via web interface	\N
231	54	adjustment	10	0	10	\N	2026-04-03 06:36:30.484823	Manual stock adjustment via web interface	\N
233	75	adjustment	100	0	100	\N	2026-04-04 10:22:48.916882	Manual stock adjustment via web interface	\N
235	81	sale	1	100	99	133	2026-04-05 09:04:46.65069	Sold to Walk-in Customer	\N
236	101	sale	1	100	99	133	2026-04-05 09:04:46.650702	Sold to Walk-in Customer	\N
238	95	sale	2	100	98	135	2026-04-05 09:30:03.209662	Sold to Walk-in Customer	\N
241	91	sale	20	92	72	137	2026-04-05 12:40:27.063709	Sold to new credit sale	\N
243	86	sale	1	98	97	139	2026-04-05 12:45:00.512986	Sold to new credit sale	\N
245	86	sale	1	96	95	141	2026-04-05 13:35:29.568454	Sold to new credit sale	\N
248	101	sale	1	99	98	143	2026-04-06 20:45:56.581848	Sold to Walk-in Customer	\N
260	165	sale	1	10	9	156	2026-04-07 09:28:42.559701	Sold to Walk-in Customer	\N
261	165	sale	1	9	8	157	2026-04-07 09:28:49.065472	Sold to Walk-in Customer	\N
262	165	sale	1	8	7	158	2026-04-07 09:29:00.404598	Sold to Walk-in Customer	\N
263	165	sale	1	7	6	159	2026-04-07 09:29:17.441805	Sold to Walk-in Customer	\N
264	165	sale	1	6	5	160	2026-04-07 09:29:27.288313	Sold to Walk-in Customer	\N
265	165	sale	1	5	4	161	2026-04-07 09:29:46.152641	Sold to Credite sale customer	\N
266	165	sale	1	4	3	162	2026-04-07 10:49:29.132108	Sold to Walk-in Customer	14
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.products (id, name, price, cost_price, stock, unit_type, category, low_stock_threshold, barcode, description, image_path, last_updated, warehouse_id, price_per_kg, product_code, company_id, supplier_id) FROM stdin;
138	Product 15	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.950978	\N	\N	\N	\N	\N
139	Product 16	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.956889	\N	\N	\N	\N	\N
140	Product 17	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.960877	\N	\N	\N	\N	\N
141	Product 18	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.969093	\N	\N	\N	\N	\N
142	Product 19	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.973348	\N	\N	\N	\N	\N
143	Product 20	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.976861	\N	\N	\N	\N	\N
165	Product 1	1500	0	3	unit	Phone	5			\N	2026-04-07 09:28:26.399772	\N	\N	\N	14	\N
95	Butter	50	40	4	unit	Dairy	5		Butter 100g	\N	2026-04-05 17:17:58.677844	\N	\N	\N	\N	\N
70	Tea	80	60	100	unit	Beverages	5		Premium Tea 250g	\N	2026-04-04 10:08:51.015835	\N	\N	\N	\N	5
51	Product 3	250000	0	100	unit	Phone	7	1234569.0	\N	\N	2026-04-04 10:08:51.021082	\N	\N	\N	\N	\N
54	Product 6	250000	0	100	unit	Phone	10	1234572.0	\N	\N	2026-04-04 10:08:51.025297	\N	\N	\N	\N	\N
84	Ketchup	45	35	100	unit	Sauces	5	\N	Tomato Ketchup	\N	2026-04-04 10:08:51.033451	\N	\N	\N	\N	\N
102	Chocolate	50	35	100	unit	Snacks	5	\N	Dark Chocolate	\N	2026-04-04 10:08:51.050814	\N	\N	\N	\N	\N
49	Product 1	12000	0	100	unit	Phone	5	123456.0	\N	\N	2026-04-04 10:08:51.094574	\N	\N	\N	\N	\N
89	Sugar	45	35	100	kg	Grains	10	\N	Refined Sugar 1kg	\N	2026-04-04 10:08:51.123279	\N	\N	\N	\N	\N
92	Oil	150	130	100	L	Cooking	5	\N	Cooking Oil 1L	\N	2026-04-04 10:08:51.126195	\N	\N	\N	\N	\N
86	Bread	500000	25	95	unit	Bakery	5	123456	Whole Wheat Bread	\N	2026-04-05 17:21:19.964505	\N	\N	\N	\N	\N
55	Product 7	250000	0	100	unit	Phone	11	1234573.0	\N	\N	2026-04-04 10:08:50.915097	\N	\N	\N	\N	\N
58	Product 10	250000	0	100	unit	Phone	14	1234576.0	\N	\N	2026-04-04 10:08:50.934746	\N	\N	\N	\N	\N
59	Product 11	250000	0	100	unit	Phone	15	1234577.0	\N	\N	2026-04-04 10:08:50.940705	\N	\N	\N	\N	\N
60	Product 12	250000	0	100	unit	Phone	16	1234578.0	\N	\N	2026-04-04 10:08:50.945225	\N	\N	\N	\N	\N
52	Product 4	250000	0	100	unit	Phone	8	1234570.0	\N	\N	2026-04-04 10:08:50.955468	\N	\N	\N	\N	\N
53	Product 5	250000	0	100	unit	Phone	9	1234571.0	\N	\N	2026-04-04 10:08:50.961095	\N	\N	\N	\N	\N
56	Product 8	250000	0	100	unit	Phone	12	1234574.0	\N	\N	2026-04-04 10:08:50.968415	\N	\N	\N	\N	\N
57	Product 9	250000	0	100	unit	Phone	13	1234575.0	\N	\N	2026-04-04 10:08:50.9737	\N	\N	\N	\N	\N
61	Product 13	250000	0	100	unit	Phone	17	1234579.0	\N	\N	2026-04-04 10:08:50.977726	\N	\N	\N	\N	\N
50	Product 2	250000	0	100	unit	Phone	6	1234568.0	\N	\N	2026-04-04 10:08:50.981548	\N	\N	\N	\N	\N
62	Product 14	250000	0	100	unit	Phone	18	1234580.0	\N	\N	2026-04-04 10:08:50.987924	\N	\N	\N	\N	\N
94	Flour	40	30	100	kg	Grains	8	\N	Wheat Flour 1kg	\N	2026-04-04 10:08:51.129146	\N	\N	\N	\N	\N
97	Yogurt	40	30	100	unit	Dairy	8	\N	Plain Yogurt 500g	\N	2026-04-04 10:08:51.135395	\N	\N	\N	\N	\N
125	Product 2	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.876114	\N	\N	\N	\N	\N
126	Product 3	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.880471	\N	\N	\N	\N	\N
127	Product 4	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.885703	\N	\N	\N	\N	\N
128	Product 5	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.889373	\N	\N	\N	\N	\N
129	Product 6	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.892112	\N	\N	\N	\N	\N
130	Product 7	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.895128	\N	\N	\N	\N	\N
131	Product 8	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.904201	\N	\N	\N	\N	\N
132	Product 9	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.908766	\N	\N	\N	\N	\N
133	Product 10	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.917502	\N	\N	\N	\N	\N
134	Product 11	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.924703	\N	\N	\N	\N	\N
135	Product 12	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.928802	\N	\N	\N	\N	\N
136	Product 13	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.937604	\N	\N	\N	\N	\N
137	Product 14	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:26.942766	\N	\N	\N	\N	\N
91	Coffee	150	120	72	unit	Beverages	3	\N	Instant Coffee 100g	\N	2026-04-04 10:08:51.10588	\N	\N	\N	\N	\N
66	Bread	35	25	100	unit	Bakery	5	1234567	Whole Wheat Bread	\N	2026-04-05 17:21:38.178387	\N	\N	\N	\N	5
81	Biscuits	25	18	97	unit	Snacks	12		Cream Biscuits	\N	2026-04-04 10:23:05.999319	\N	\N	\N	\N	5
101	Biscuits	25	18	98	unit	Snacks	12	\N	Cream Biscuits	\N	2026-04-04 10:08:51.039505	\N	\N	\N	\N	\N
106	Product 2	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.378042	\N	\N	\N	\N	\N
107	Product 3	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.386968	\N	\N	\N	\N	\N
108	Product 4	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.396103	\N	\N	\N	\N	\N
109	Product 5	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.407625	\N	\N	\N	\N	\N
110	Product 6	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.41483	\N	\N	\N	\N	\N
111	Product 7	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.423268	\N	\N	\N	\N	\N
112	Product 8	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.42991	\N	\N	\N	\N	\N
113	Product 9	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.436507	\N	\N	\N	\N	\N
114	Product 10	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.443572	\N	\N	\N	\N	\N
75	Butter	50	40	100	unit	Dairy	5		Butter 100g	\N	2026-04-04 10:22:48.912873	\N	\N	\N	\N	5
115	Product 11	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.450665	\N	\N	\N	\N	\N
116	Product 12	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.460569	\N	\N	\N	\N	\N
117	Product 13	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.469614	\N	\N	\N	\N	\N
118	Product 14	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.476823	\N	\N	\N	\N	\N
119	Product 15	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.483319	\N	\N	\N	\N	\N
120	Product 16	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.490764	\N	\N	\N	\N	\N
121	Product 17	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.495521	\N	\N	\N	\N	\N
122	Product 18	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.504495	\N	\N	\N	\N	\N
79	Water	20	12	100	L	Beverages	20	\N	Mineral Water 1L	\N	2026-04-04 10:08:51.085457	\N	\N	\N	\N	\N
123	Product 19	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.508993	\N	\N	\N	\N	\N
85	Milk	45	40	100	unit	Dairy	10	\N	500ml Fresh Milk	\N	2026-04-04 10:08:51.097571	\N	\N	\N	\N	\N
88	Rice	120	95	100	kg	Grains	5	\N	Basmati Rice 1kg	\N	2026-04-04 10:08:51.100668	\N	\N	\N	\N	\N
124	Product 20	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:58:01.512123	\N	\N	\N	\N	\N
93	Salt	20	15	100	kg	Spices	15	\N	Pack Salt 1kg	\N	2026-04-04 10:08:51.10894	\N	\N	\N	\N	\N
96	Cheese	120	95	100	unit	Dairy	3	\N	Cheese Slices	\N	2026-04-04 10:08:51.112003	\N	\N	\N	\N	\N
98	Juice	80	60	100	L	Beverages	5	\N	Orange Juice 1L	\N	2026-04-04 10:08:51.11505	\N	\N	\N	\N	\N
87	Eggs	60	45	100	unit	Dairy	10	\N	Farm Fresh Eggs (12pcs)	\N	2026-04-04 10:08:51.118359	\N	\N	\N	\N	\N
100	Chips	30	20	100	unit	Snacks	10	\N	Potato Chips	\N	2026-04-04 10:08:51.138769	\N	\N	\N	\N	\N
144	Product 2	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.170125	\N	\N	\N	\N	\N
145	Product 3	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.180706	\N	\N	\N	\N	\N
146	Product 4	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.186529	\N	\N	\N	\N	\N
147	Product 5	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.196364	\N	\N	\N	\N	\N
148	Product 6	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.20151	\N	\N	\N	\N	\N
149	Product 7	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.211929	\N	\N	\N	\N	\N
150	Product 8	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.21677	\N	\N	\N	\N	\N
151	Product 9	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.22299	\N	\N	\N	\N	\N
152	Product 10	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.230507	\N	\N	\N	\N	\N
153	Product 11	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.234516	\N	\N	\N	\N	\N
154	Product 12	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.24312	\N	\N	\N	\N	\N
155	Product 13	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.248661	\N	\N	\N	\N	\N
156	Product 14	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.252382	\N	\N	\N	\N	\N
157	Product 15	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.264079	\N	\N	\N	\N	\N
158	Product 16	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.271117	\N	\N	\N	\N	\N
159	Product 17	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.281572	\N	\N	\N	\N	\N
160	Product 18	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.290735	\N	\N	\N	\N	\N
161	Product 19	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.298159	\N	\N	\N	\N	\N
162	Product 20	150	0	5	unit	General	5	\N	\N	\N	2026-04-06 20:59:28.300957	\N	\N	\N	\N	\N
\.


--
-- Data for Name: promotions; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.promotions (id, name, description, discount_type, discount_value, minimum_purchase, applicable_products, start_date, end_date, is_active, usage_limit, usage_count, created_date, company_id) FROM stdin;
\.


--
-- Data for Name: purchase_items; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.purchase_items (id, purchase_id, product_id, quantity, cost_price, total_cost, company_id) FROM stdin;
12	11	70	10	60	600	\N
13	12	70	10	60	600	\N
\.


--
-- Data for Name: purchase_order_items; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.purchase_order_items (id, purchase_order_id, product_id, quantity_ordered, quantity_received, unit_cost, total_cost, company_id) FROM stdin;
\.


--
-- Data for Name: purchase_orders; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.purchase_orders (id, date_created, supplier_id, status, expected_delivery_date, total_amount, notes, company_id) FROM stdin;
\.


--
-- Data for Name: purchase_return_items; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.purchase_return_items (id, purchase_return_id, product_id, quantity, unit_cost, total_cost, company_id) FROM stdin;
\.


--
-- Data for Name: purchase_returns; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.purchase_returns (id, date, original_purchase_id, supplier_id, return_reason, refund_amount, notes, user_id, company_id) FROM stdin;
\.


--
-- Data for Name: purchases; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.purchases (id, date, supplier_id, invoice_number, total_amount, amount_paid, status, company_id) FROM stdin;
11	2026-04-03 00:00:00	5	001	600	600	paid	\N
12	2026-04-03 00:00:00	5	002	600	600	paid	\N
\.


--
-- Data for Name: return_items; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.return_items (id, return_id, product_id, quantity, price, reason, original_sale_item_id, company_id) FROM stdin;
\.


--
-- Data for Name: returns; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.returns (id, date, original_sale_id, customer, return_reason, refund_method, refund_amount, status, notes, user_id, company_id) FROM stdin;
\.


--
-- Data for Name: sale_items; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.sale_items (id, sale_id, product_id, quantity, price, discount, tax, company_id) FROM stdin;
193	143	101	1	25	0	0.75	\N
204	156	165	1	1500	0	270	14
205	157	165	1	1500	0	270	14
206	158	165	1	1500	0	270	14
207	159	165	1	1500	0	270	14
208	160	165	1	1500	0	270	14
209	161	165	1	1500	0	270	14
210	162	165	1	1500	0	0	14
140	112	85	1	100	0	0	\N
141	113	85	1	100	0	0	\N
142	115	87	1	100	0	0	\N
143	116	87	2	150	0	0	\N
\.


--
-- Data for Name: sales; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.sales (id, date, customer, total, payment, cash_given, balance, user_id, discount, tax, company_id) FROM stdin;
156	2026-04-07 09:28:42.52307	Walk-in Customer	1770	Cash	2000	230	12	0	270	14
157	2026-04-07 09:28:49.058794	Walk-in Customer	1770	Card	0	0	12	0	270	14
158	2026-04-07 09:29:00.395579	Walk-in Customer	1770	Cheque	0	0	12	0	270	14
159	2026-04-07 09:29:17.434345	Walk-in Customer	1770	UPI	0	0	12	0	270	14
160	2026-04-07 09:29:27.278433	Walk-in Customer	1770	Bank Transfer	0	0	12	0	270	14
161	2026-04-07 09:29:46.149068	Credite sale customer	1770	Credit	0	1770	12	0	270	14
97	2026-03-30 05:45:35.238328	Walk-in Customer	0	Store Credit	0	0	\N	0	0	\N
112	2026-04-02 12:17:11.919491	New customer	100	Cheque	0	0	\N	0	0	\N
113	2026-04-02 12:18:12.603085	New customer	100	Cheque	0	0	\N	0	0	\N
115	2026-04-02 12:19:05.890974	new credit sale	100	Cheque	0	0	\N	0	0	\N
116	2026-04-02 12:19:40.865066	new credit sale	300	Cheque	0	0	\N	10	0	\N
143	2026-04-06 20:45:56.550078	Walk-in Customer	25.75	Cash	50	24.25	\N	0	0.75	\N
162	2026-04-07 10:49:29.11984	Walk-in Customer	1500	Cash	2000	500	12	0	0	14
\.


--
-- Data for Name: serial_numbers; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.serial_numbers (id, product_id, serial_number, lot_number, expiry_date, purchase_date, status, company_id) FROM stdin;
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.settings (id, setting_category, setting_key, setting_value, updated_at, company_id) FROM stdin;
92	receipt	business_name	Codilight	2026-04-04 12:12:16.706322	\N
88	tax	gstRate	18.0	2026-03-23 10:32:59.76429	\N
89	printing	receipt_footer	Thank you for your business!	2026-03-23 10:32:59.765203	\N
90	printing	show_logo	true	2026-03-23 10:32:59.765966	\N
93	receipt	business_address	Anderson road, dehiwala	2026-04-04 12:12:16.725042	\N
94	receipt	business_phone	77 411 6702	2026-04-04 12:12:16.727106	\N
95	receipt	business_email	sajas@codilight.com	2026-04-04 12:12:16.728965	\N
96	receipt	business_gst	GSTEST123	2026-04-04 12:12:16.731288	\N
110	receipt	default_format	a4	2026-04-04 12:12:16.733401	\N
97	receipt	show_qr_code	true	2026-04-04 12:12:16.735242	\N
98	receipt	thank_you_message	 Thank You	2026-04-04 12:12:16.738731	\N
99	receipt	warranty_info	API Test Warranty	2026-04-04 12:12:16.739915	\N
87	general	currency_symbol	$	2026-03-23 10:32:59.763217	\N
100	receipt	footer_text	API Test Footer	2026-04-04 12:12:16.740872	\N
109	general	business_name		2026-04-02 13:42:33.776485	\N
91	general	logo_path	/static/uploads/business_logo_1775118726_jazakallah-arabic-calligraphy1.png	2026-04-02 14:02:06.646696	\N
101	currency	symbol	Rs	2026-04-05 17:17:26.999567	\N
102	tax	rate	3	2026-04-05 17:17:27.008897	\N
103	tax	enable_tax	true	2026-04-05 17:17:27.01451	\N
104	tax	show_tax_in_sales	true	2026-04-05 17:17:27.020389	\N
105	datetime	date_format	YYYY-MM-DD	2026-04-05 17:17:27.024935	\N
106	datetime	time_format	hh:mm:ss A	2026-04-05 17:17:27.028622	\N
107	localization	language	en	2026-04-05 17:17:27.032168	\N
120	currency	symbol		2026-04-07 10:06:44.205905	14
121	tax	rate		2026-04-07 10:06:44.205918	14
122	tax	enable_tax	false	2026-04-07 10:06:44.205925	14
123	tax	show_tax_in_sales	false	2026-04-07 10:06:44.20593	14
124	datetime	date_format	YYYY-MM-DD	2026-04-07 10:06:44.205936	14
125	datetime	time_format	HH:mm:ss	2026-04-07 10:06:44.205941	14
126	localization	language	en	2026-04-07 10:06:44.205945	14
\.


--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.suppliers (id, name, contact_person, phone, email, address, company_id) FROM stdin;
5	New supplier	New	774116702	sajas@codilight.com	Colombo	\N
\.


--
-- Data for Name: user_companies; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.user_companies (user_id, company_id, is_admin, created_at) FROM stdin;
12	14	f	2026-04-07 07:37:58.83816
18	14	f	2026-04-07 09:50:55.595803
18	18	f	2026-04-07 09:51:41.422391
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.users (id, username, email, password_hash, role, last_login, can_access_sales, can_access_purchases, can_access_suppliers, can_view_inventory, can_edit_inventory, can_view_sales_history, can_view_reports, can_access_expenses, can_access_customers, can_view_profit, can_access_warehouse, can_access_settings, can_access_cheques, can_access_quotations, can_access_messages, can_access_audit_logs, can_access_scale, can_manage_returns, can_manage_purchase_returns, can_manage_customer_payments, profile_picture, can_view_general_settings, can_view_receipt_settings, can_view_terminal_settings, can_view_backup_settings, can_view_hardware_settings, can_view_own_profile) FROM stdin;
18	admin	admin@example.com	pbkdf2:sha256:600000$rNmqSmP231ZFfbjH$67d1c8eb40700544f835ca554f86f6b8c1b1de092b5488115dc48cf136980943	admin	2026-04-07 10:56:56.950454	t	t	t	t	t	t	t	t	t	t	t	t	t	f	f	f	f	f	f	f	uploads/profiles/5d3c799aae584dae9974fb605a20ff6a.png	f	f	f	f	f	t
12	Sajas	\N	pbkdf2:sha256:600000$9oLbFVOQBtPl1osO$9783245c614315617fc5718b44a9574e73df0f53c5aa6c87dbd33333ff516444	Cashier	2026-04-07 11:26:19.943357	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	f	f	t	uploads/profiles/70fa6a188252454aadd9f66d869ec9f2.png	t	t	t	t	t	t
\.


--
-- Data for Name: warehouses; Type: TABLE DATA; Schema: public; Owner: pos_user
--

COPY public.warehouses (id, name, location, description, created_at, company_id) FROM stdin;
\.


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 93, true);


--
-- Name: cheque_deposits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.cheque_deposits_id_seq', 1, false);


--
-- Name: cheques_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.cheques_id_seq', 24, true);


--
-- Name: companies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.companies_id_seq', 18, true);


--
-- Name: customer_feedback_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.customer_feedback_id_seq', 1, false);


--
-- Name: customer_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.customer_payments_id_seq', 5, true);


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.customers_id_seq', 18, true);


--
-- Name: exchange_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.exchange_items_id_seq', 1, false);


--
-- Name: exchanges_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.exchanges_id_seq', 1, false);


--
-- Name: expenses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.expenses_id_seq', 7, true);


--
-- Name: held_bills_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.held_bills_id_seq', 12, true);


--
-- Name: inventory_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.inventory_transactions_id_seq', 265, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.products_id_seq', 165, true);


--
-- Name: promotions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.promotions_id_seq', 1, false);


--
-- Name: purchase_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.purchase_items_id_seq', 13, true);


--
-- Name: purchase_order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.purchase_order_items_id_seq', 1, false);


--
-- Name: purchase_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.purchase_orders_id_seq', 1, false);


--
-- Name: purchase_return_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.purchase_return_items_id_seq', 7, true);


--
-- Name: purchase_returns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.purchase_returns_id_seq', 6, true);


--
-- Name: purchases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.purchases_id_seq', 12, true);


--
-- Name: return_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.return_items_id_seq', 31, true);


--
-- Name: returns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.returns_id_seq', 25, true);


--
-- Name: sale_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.sale_items_id_seq', 209, true);


--
-- Name: sales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.sales_id_seq', 161, true);


--
-- Name: serial_numbers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.serial_numbers_id_seq', 1, false);


--
-- Name: settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.settings_id_seq', 126, true);


--
-- Name: suppliers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.suppliers_id_seq', 5, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.users_id_seq', 18, true);


--
-- Name: warehouses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pos_user
--

SELECT pg_catalog.setval('public.warehouses_id_seq', 6, true);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: cheque_deposits cheque_deposits_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.cheque_deposits
    ADD CONSTRAINT cheque_deposits_pkey PRIMARY KEY (id);


--
-- Name: cheques cheques_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.cheques
    ADD CONSTRAINT cheques_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: customer_feedback customer_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.customer_feedback
    ADD CONSTRAINT customer_feedback_pkey PRIMARY KEY (id);


--
-- Name: customer_payments customer_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.customer_payments
    ADD CONSTRAINT customer_payments_pkey PRIMARY KEY (id);


--
-- Name: customers customers_name_key; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_name_key UNIQUE (name);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: exchange_items exchange_items_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.exchange_items
    ADD CONSTRAINT exchange_items_pkey PRIMARY KEY (id);


--
-- Name: exchanges exchanges_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.exchanges
    ADD CONSTRAINT exchanges_pkey PRIMARY KEY (id);


--
-- Name: expenses expenses_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_pkey PRIMARY KEY (id);


--
-- Name: held_bills held_bills_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.held_bills
    ADD CONSTRAINT held_bills_pkey PRIMARY KEY (id);


--
-- Name: inventory_transactions inventory_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: promotions promotions_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_pkey PRIMARY KEY (id);


--
-- Name: purchase_items purchase_items_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_items
    ADD CONSTRAINT purchase_items_pkey PRIMARY KEY (id);


--
-- Name: purchase_order_items purchase_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_pkey PRIMARY KEY (id);


--
-- Name: purchase_orders purchase_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_pkey PRIMARY KEY (id);


--
-- Name: purchase_return_items purchase_return_items_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_return_items
    ADD CONSTRAINT purchase_return_items_pkey PRIMARY KEY (id);


--
-- Name: purchase_returns purchase_returns_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_returns
    ADD CONSTRAINT purchase_returns_pkey PRIMARY KEY (id);


--
-- Name: purchases purchases_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT purchases_pkey PRIMARY KEY (id);


--
-- Name: return_items return_items_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.return_items
    ADD CONSTRAINT return_items_pkey PRIMARY KEY (id);


--
-- Name: returns returns_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.returns
    ADD CONSTRAINT returns_pkey PRIMARY KEY (id);


--
-- Name: sale_items sale_items_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.sale_items
    ADD CONSTRAINT sale_items_pkey PRIMARY KEY (id);


--
-- Name: sales sales_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (id);


--
-- Name: serial_numbers serial_numbers_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.serial_numbers
    ADD CONSTRAINT serial_numbers_pkey PRIMARY KEY (id);


--
-- Name: serial_numbers serial_numbers_serial_number_key; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.serial_numbers
    ADD CONSTRAINT serial_numbers_serial_number_key UNIQUE (serial_number);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_name_key; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_name_key UNIQUE (name);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: settings unique_setting_per_company; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT unique_setting_per_company UNIQUE (setting_category, setting_key, company_id);


--
-- Name: cheques uq_cheque_number_bank; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.cheques
    ADD CONSTRAINT uq_cheque_number_bank UNIQUE (cheque_number, bank_name);


--
-- Name: user_companies user_companies_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.user_companies
    ADD CONSTRAINT user_companies_pkey PRIMARY KEY (user_id, company_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: warehouses warehouses_name_key; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_name_key UNIQUE (name);


--
-- Name: warehouses warehouses_pkey; Type: CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: cheque_deposits cheque_deposits_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.cheque_deposits
    ADD CONSTRAINT cheque_deposits_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: cheque_deposits cheque_deposits_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.cheque_deposits
    ADD CONSTRAINT cheque_deposits_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: cheques cheques_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.cheques
    ADD CONSTRAINT cheques_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: cheques cheques_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.cheques
    ADD CONSTRAINT cheques_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: cheques cheques_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.cheques
    ADD CONSTRAINT cheques_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: cheques cheques_deposit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.cheques
    ADD CONSTRAINT cheques_deposit_id_fkey FOREIGN KEY (deposit_id) REFERENCES public.cheque_deposits(id);


--
-- Name: cheques cheques_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.cheques
    ADD CONSTRAINT cheques_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchases(id);


--
-- Name: cheques cheques_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.cheques
    ADD CONSTRAINT cheques_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- Name: cheques cheques_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.cheques
    ADD CONSTRAINT cheques_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id);


--
-- Name: cheques cheques_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.cheques
    ADD CONSTRAINT cheques_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: customer_feedback customer_feedback_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.customer_feedback
    ADD CONSTRAINT customer_feedback_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: customer_feedback customer_feedback_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.customer_feedback
    ADD CONSTRAINT customer_feedback_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: customer_feedback customer_feedback_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.customer_feedback
    ADD CONSTRAINT customer_feedback_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- Name: customer_payments customer_payments_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.customer_payments
    ADD CONSTRAINT customer_payments_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: customer_payments customer_payments_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.customer_payments
    ADD CONSTRAINT customer_payments_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: customer_payments customer_payments_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.customer_payments
    ADD CONSTRAINT customer_payments_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- Name: customer_payments customer_payments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.customer_payments
    ADD CONSTRAINT customer_payments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: customers customers_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: exchange_items exchange_items_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.exchange_items
    ADD CONSTRAINT exchange_items_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: exchange_items exchange_items_exchange_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.exchange_items
    ADD CONSTRAINT exchange_items_exchange_id_fkey FOREIGN KEY (exchange_id) REFERENCES public.exchanges(id);


--
-- Name: exchange_items exchange_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.exchange_items
    ADD CONSTRAINT exchange_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: exchanges exchanges_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.exchanges
    ADD CONSTRAINT exchanges_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: exchanges exchanges_new_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.exchanges
    ADD CONSTRAINT exchanges_new_sale_id_fkey FOREIGN KEY (new_sale_id) REFERENCES public.sales(id);


--
-- Name: exchanges exchanges_original_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.exchanges
    ADD CONSTRAINT exchanges_original_sale_id_fkey FOREIGN KEY (original_sale_id) REFERENCES public.sales(id);


--
-- Name: exchanges exchanges_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.exchanges
    ADD CONSTRAINT exchanges_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: expenses expenses_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: held_bills held_bills_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.held_bills
    ADD CONSTRAINT held_bills_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: held_bills held_bills_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.held_bills
    ADD CONSTRAINT held_bills_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: inventory_transactions inventory_transactions_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: inventory_transactions inventory_transactions_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.inventory_transactions
    ADD CONSTRAINT inventory_transactions_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: products products_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: products products_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id);


--
-- Name: products products_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id);


--
-- Name: promotions promotions_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: purchase_items purchase_items_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_items
    ADD CONSTRAINT purchase_items_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: purchase_items purchase_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_items
    ADD CONSTRAINT purchase_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: purchase_items purchase_items_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_items
    ADD CONSTRAINT purchase_items_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchases(id);


--
-- Name: purchase_order_items purchase_order_items_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: purchase_order_items purchase_order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: purchase_order_items purchase_order_items_purchase_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_purchase_order_id_fkey FOREIGN KEY (purchase_order_id) REFERENCES public.purchase_orders(id);


--
-- Name: purchase_orders purchase_orders_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: purchase_orders purchase_orders_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id);


--
-- Name: purchase_return_items purchase_return_items_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_return_items
    ADD CONSTRAINT purchase_return_items_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: purchase_return_items purchase_return_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_return_items
    ADD CONSTRAINT purchase_return_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: purchase_return_items purchase_return_items_purchase_return_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_return_items
    ADD CONSTRAINT purchase_return_items_purchase_return_id_fkey FOREIGN KEY (purchase_return_id) REFERENCES public.purchase_returns(id);


--
-- Name: purchase_returns purchase_returns_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_returns
    ADD CONSTRAINT purchase_returns_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: purchase_returns purchase_returns_original_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_returns
    ADD CONSTRAINT purchase_returns_original_purchase_id_fkey FOREIGN KEY (original_purchase_id) REFERENCES public.purchases(id);


--
-- Name: purchase_returns purchase_returns_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_returns
    ADD CONSTRAINT purchase_returns_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id);


--
-- Name: purchase_returns purchase_returns_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchase_returns
    ADD CONSTRAINT purchase_returns_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: purchases purchases_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT purchases_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: purchases purchases_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT purchases_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id);


--
-- Name: return_items return_items_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.return_items
    ADD CONSTRAINT return_items_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: return_items return_items_original_sale_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.return_items
    ADD CONSTRAINT return_items_original_sale_item_id_fkey FOREIGN KEY (original_sale_item_id) REFERENCES public.sale_items(id);


--
-- Name: return_items return_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.return_items
    ADD CONSTRAINT return_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: return_items return_items_return_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.return_items
    ADD CONSTRAINT return_items_return_id_fkey FOREIGN KEY (return_id) REFERENCES public.returns(id);


--
-- Name: returns returns_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.returns
    ADD CONSTRAINT returns_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: returns returns_original_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.returns
    ADD CONSTRAINT returns_original_sale_id_fkey FOREIGN KEY (original_sale_id) REFERENCES public.sales(id);


--
-- Name: returns returns_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.returns
    ADD CONSTRAINT returns_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: sale_items sale_items_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.sale_items
    ADD CONSTRAINT sale_items_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: sale_items sale_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.sale_items
    ADD CONSTRAINT sale_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: sale_items sale_items_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.sale_items
    ADD CONSTRAINT sale_items_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- Name: sales sales_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: sales sales_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: serial_numbers serial_numbers_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.serial_numbers
    ADD CONSTRAINT serial_numbers_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: serial_numbers serial_numbers_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.serial_numbers
    ADD CONSTRAINT serial_numbers_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: settings settings_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: suppliers suppliers_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: user_companies user_companies_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.user_companies
    ADD CONSTRAINT user_companies_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: user_companies user_companies_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.user_companies
    ADD CONSTRAINT user_companies_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: warehouses warehouses_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pos_user
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO pos_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO pos_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO pos_user;


--
-- PostgreSQL database dump complete
--

\unrestrict 41KKCmLxbGOGAv5i66DQkPjxBI0VXtD6qtuk6OOxHzoBzVAVqlkOk2qmFN0NgqH


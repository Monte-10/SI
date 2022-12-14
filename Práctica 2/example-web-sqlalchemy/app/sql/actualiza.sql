------------------------------------------------------------------------------------------------------------------------------

-- Uno inventario a productos
ALTER TABLE public.inventory ADD FOREIGN KEY (prod_id) REFERENCES public.products (prod_id);

-- Uno orders a customers
ALTER TABLE public.orders ADD FOREIGN KEY (customerid) REFERENCES public.customers (customerid);

-- Uno order_details a orders
ALTER TABLE public.orderdetail ADD FOREIGN KEY (orderid) REFERENCES public.orders (orderid);

-- Uno order_details a products
ALTER TABLE public.orderdetail ADD FOREIGN KEY (prod_id) REFERENCES public.products (prod_id);

-- Uno actormovies a actores
ALTER TABLE public.imdb_actormovies ADD FOREIGN KEY (actorid) REFERENCES public.imdb_actors(actorid);

-- Uno actormovies a movies
ALTER TABLE public.imdb_actormovies ADD FOREIGN KEY (movieid) REFERENCES public.imdb_movies(movieid);

-- Hago que sean primary keys
ALTER TABLE public.imdb_actormovies ADD PRIMARY KEY (actorid, movieid);

------------------------------------------------------------------------------------------------------------------------------

-- Creo la tabla ratings
CREATE TABLE IF NOT EXISTS public.imdb_ratings(
    movieid integer NOT NULL,
    customerid integer NOT NULL,
    rating integer NOT NULL,
    -- Los uno con movie y customer
    CONSTRAINT imdb_ratings_pkey PRIMARY KEY (movieid, customerid),
    CONSTRAINT imdb_ratings_movieid_fkey FOREIGN KEY (movieid) REFERENCES public.imdb_movies (movieid) MATCH SIMPLE,
    CONSTRAINT imdb_ratings_customerid_fkey FOREIGN KEY (customerid) REFERENCES public.customers (customerid) MATCH SIMPLE
);

-- Añado campos a la tabla movies, ratingmean y ratingcount
ALTER TABLE public.imdb_movies ADD ratingmean float DEFAULT 0;
ALTER TABLE public.imdb_movies ADD ratingcount integer DEFAULT 0;

------------------------------------------------------------------------------------------------------------------------------

-- Creo el campo balance en customers
ALTER TABLE public.customers ADD balance float;

-- Aumento el tamaño de la contraseña para customers
ALTER TABLE public.customers ALTER COLUMN password TYPE character varying(96);

------------------------------------------------------------------------------------------------------------------------------

-- Creo la secuencia para relacionar genre en la tabla movies
CREATE SEQUENCE IF NOT EXISTS public.imdb_genres_genreid_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

-- Creo la tabla genres
CREATE TABLE IF NOT EXISTS public.imdb_genres(
    genreid integer NOT NULL DEFAULT nextval('public.imdb_genres_genreid_seq'::regclass),
    genrename character varying(32) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT imdb_genres_pkey PRIMARY KEY (genreid)
)

TABLESPACE pg_default;

-- Relaciono la tabla genres con la tabla movies
INSERT INTO public.imdb_genres(genrename) SELECT DISTINCT genre FROM public.imdb_moviegenres ORDER BY genre;
ALTER SEQUENCE public.imdb_genres_genreid_seq OWNER TO alumnodb;
ALTER TABLE IF EXISTS public.imdb_genres OWNER TO alumnodb;
ALTER SEQUENCE public.imdb_genres_genreid_seq OWNED BY imdb_genres.genreid;
ALTER TABLE public.imdb_moviegenres ADD genreid integer;
UPDATE public.imdb_moviegenres SET genreid = imdb_genres.genreid FROM imdb_genres WHERE genre = imdb_genres.genrename;

ALTER TABLE public.imdb_moviegenres DROP COLUMN genre;
ALTER TABLE public.imdb_moviegenres ADD FOREIGN KEY (genreid) REFERENCES public.imdb_genres(genreid);
ALTER TABLE public.imdb_moviegenres ADD PRIMARY KEY (movieid, genreid);

------------------------------------------------------------------------------------------------------------------------------

-- Creo la secuencia para relacionar language en la tabla movies
CREATE SEQUENCE IF NOT EXISTS public.imdb_languages_languageid_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;
-- Creo la tabla languages
CREATE TABLE IF NOT EXISTS public.imdb_languages(
    languageid integer NOT NULL DEFAULT nextval('public.imdb_languages_languageid_seq'::regclass),
    languagename character varying(32) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT imdb_languages_pkey PRIMARY KEY (languageid)
)

TABLESPACE pg_default;

-- Relaciono la tabla languages con la tabla movies
INSERT INTO public.imdb_languages(languagename) SELECT DISTINCT language FROM public.imdb_movielanguages ORDER BY language;
ALTER SEQUENCE public.imdb_languages_languageid_seq OWNER TO alumnodb;
ALTER TABLE IF EXISTS public.imdb_languages OWNER TO alumnodb;
ALTER SEQUENCE public.imdb_languages_languageid_seq OWNED BY imdb_languages.languageid;
ALTER TABLE public.imdb_movielanguages ADD languageid integer;
UPDATE public.imdb_movielanguages SET languageid = imdb_languages.languageid FROM imdb_languages WHERE language = imdb_languages.languagename;

ALTER TABLE public.imdb_movielanguages DROP COLUMN language;
ALTER TABLE public.imdb_movielanguages ADD FOREIGN KEY (languageid) REFERENCES public.imdb_languages(languageid);
ALTER TABLE public.imdb_movielanguages ADD PRIMARY KEY (movieid, languageid);

------------------------------------------------------------------------------------------------------------------------------

-- Creo la secuencia para relacionar country en la tabla movies
CREATE SEQUENCE IF NOT EXISTS public.imdb_countries_countryid_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

-- Creo la tabla countries
CREATE TABLE IF NOT EXISTS public.imdb_countries(
    countryid integer NOT NULL DEFAULT nextval('public.imdb_countries_countryid_seq'::regclass),
    countryname character varying(32) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT imdb_countries_pkey PRIMARY KEY (countryid)
)

TABLESPACE pg_default;

-- Relaciono la tabla countries con la tabla movies
INSERT INTO public.imdb_countries(countryname) SELECT DISTINCT country FROM public.imdb_moviecountries ORDER BY country;
ALTER SEQUENCE public.imdb_countries_countryid_seq OWNER TO alumnodb;
ALTER TABLE IF EXISTS public.imdb_countries OWNER TO alumnodb;
ALTER SEQUENCE public.imdb_countries_countryid_seq OWNED BY imdb_countries.countryid;
ALTER TABLE public.imdb_moviecountries ADD countryid integer;
UPDATE public.imdb_moviecountries SET countryid = imdb_countries.countryid FROM imdb_countries WHERE country = imdb_countries.countryname;

ALTER TABLE public.imdb_moviecountries DROP COLUMN country;
ALTER TABLE public.imdb_moviecountries ADD FOREIGN KEY (countryid) REFERENCES public.imdb_countries(countryid);
ALTER TABLE public.imdb_moviecountries ADD PRIMARY KEY (movieid, countryid);

------------------------------------------------------------------------------------------------------------------------------

-- Creo la función setCustomerBalance

CREATE OR REPLACE FUNCTION public.setcustomerBalance(IN initialBalance bigint) RETURNS void LANGUAGE 'plpgsql' AS $BODY$
BEGIN
    UPDATE public.customers SET balance = (random() * initialBalance)::integer;
END; $BODY$;

-- Llama a setCustomerBalance
SELECT setcustomerBalance(100);

-- Cifra contraseña en sha384
UPDATE public.customers SET password = encode(sha384(password::bytea), 'hex');

UPDATE public.imdb_movies SET year = (regexp_split_to_array(year, '-'))[1] WHERE year LIKE '%-%';

ALTER TABLE public.imdb_movies ALTER COLUMN year TYPE integer USING year::integer;

SELECT setval('customers_customerid_seq', (SELECT MAX(customerid) FROM customers));
SELECT setval('orders_orderid_seq', (SELECT MAX(orderid) FROM orders));

INSERT INTO inventory (prod_id, stock, sales)
SELECT prod_id, 0, 0 FROM products WHERE prod_id NOT IN (SELECT prod_id FROM inventory);
    
------------------------------------------------------------------------------------------------------------------------------
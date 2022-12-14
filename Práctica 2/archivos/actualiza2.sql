 -- Añade foreign key a actormovies que referencie a actor
ALTER TABLE imdb_actormovies ADD CONSTRAINT imdb_actormovies_actorid_fkey FOREIGN KEY (actorid) REFERENCES imdb_actors(actorid);
-- -- Añade foreign key a actormovies que referencie a movie
ALTER TABLE imdb_actormovies ADD CONSTRAINT imdb_actormovies_movieid_fkey FOREIGN KEY (movieid) REFERENCES imdb_movies(movieid);
-- -- Haz que ambos campos sean primary key
ALTER TABLE imdb_actormovies ADD PRIMARY KEY (actorid, movieid);

-- -- Crea tabla de generos
CREATE TABLE imdb_genres (
   genreid character var,
   genrename VARCHAR(32) NOT NULL
);
-- -- Añade foreign key a moviegenres que referencie a genre
-- ALTER TABLE imdb_moviegenres ADD CONSTRAINT imdb_moviegenres_genreid_fkey FOREIGN KEY (genreid) REFERENCES imdb_genres(genreid);
-- -- Añade foreign key a moviegenres que referencie a movie
-- ALTER TABLE imdb_moviegenres ADD CONSTRAINT imdb_moviegenres_movieid_fkey FOREIGN KEY (movieid) REFERENCES imdb_movies(movieid);
-- -- Haz que ambos campos sean primary key
-- ALTER TABLE imdb_moviegenres ADD PRIMARY KEY (genreid, movieid);

-- -- Crea tabla de paises
-- CREATE TABLE imdb_countries (
--   countryid SERIAL PRIMARY KEY,
--   countryname VARCHAR(32) NOT NULL
-- );
-- -- Añade foreign key a moviecountries que referencie a country
-- ALTER TABLE imdb_moviecountries ADD CONSTRAINT imdb_moviecountries_countryid_fkey FOREIGN KEY (countryid) REFERENCES imdb_countries(countryid);
-- -- Añade foreign key a moviecountries que referencie a movie
-- ALTER TABLE imdb_moviecountries ADD CONSTRAINT imdb_moviecountries_movieid_fkey FOREIGN KEY (movieid) REFERENCES imdb_movies(movieid);
-- -- Haz que ambos campos sean primary key
-- ALTER TABLE imdb_moviecountries ADD PRIMARY KEY (countryid, movieid);

-- -- Crea tabla de idiomas
-- CREATE TABLE imdb_languages (
--   languageid SERIAL PRIMARY KEY,
--   languagename VARCHAR(32) NOT NULL
-- );

-- -- Añade foreign key a movielanguages que referencie a language
-- ALTER TABLE imdb_movielanguages ADD CONSTRAINT imdb_movielanguages_languageid_fkey FOREIGN KEY (languageid) REFERENCES imdb_languages(languageid);
-- -- Añade foreign key a movielanguages que referencie a movie
-- ALTER TABLE imdb_movielanguages ADD CONSTRAINT imdb_movielanguages_movieid_fkey FOREIGN KEY (movieid) REFERENCES imdb_movies(movieid);
-- -- Haz que ambos campos sean primary key
-- ALTER TABLE imdb_movielanguages ADD PRIMARY KEY (languageid, movieid);

-- -- Crea un campo ‘balance’ en la tabla ‘customers’, para guardar el saldo de los clientes.
-- ALTER TABLE customers ADD COLUMN balance NUMERIC(10,2) DEFAULT 0;

-- -- Crea una nueva tabla ‘ratings’ para guardar las valoraciones que ha dado cada usuario a cada película, de forma que se evite que un mismo usuario pueda valorar dos veces la misma película.
-- CREATE TABLE ratings (
--   userid INTEGER NOT NULL,
--   movieid INTEGER NOT NULL,
--   rating NUMERIC(2,1) NOT NULL,
--   PRIMARY KEY (userid, movieid),
--   FOREIGN KEY (userid) REFERENCES customers(customerid),
--   FOREIGN KEY (movieid) REFERENCES movies(movieid)
-- );
-- -- Añadir dos campos a la tabla ‘imdb_movies’, para contener la valoración media ‘ratingmean’ y el número de valoraciones ‘ratingcount’, de cada película.
-- ALTER TABLE imdb_movies ADD COLUMN ratingmean NUMERIC(2,1) DEFAULT 0;
-- ALTER TABLE imdb_movies ADD COLUMN ratingcount INTEGER DEFAULT 0;

-- -- Aumentar el tamaño del campo ‘password’ en la tabla ‘customers’ para poder 
-- -- almacenar las contraseñas con el formato de la práctica 1, 96 caractereshexadecimales.
-- ALTER TABLE customers ALTER COLUMN password TYPE VARCHAR(96);

-- -- Crear un procedimiento que inicialice el campo ‘balance’ de la tabla ‘customers’ a un número aleatorio entre 0 y N, con signatura 'function setCustomersBalance(IN initialBalance bigint)':
-- CREATE OR REPLACE FUNCTION setCustomersBalance(IN initialBalance bigint) RETURNS void AS $$
-- DECLARE
--   customerid INTEGER;
--   balance NUMERIC(10,2);
-- BEGIN
--     FOR customerid IN SELECT customerid FROM customers LOOP
--         balance := random() * initialBalance;
--         UPDATE customers SET balance = balance WHERE customerid = customerid;
--     END LOOP;
    
--     END;
-- $$ LANGUAGE plpgsql;

-- -- Añadir a actualiza.sql una llamada a dicho procedimiento, con N = 100.
-- SELECT setCustomersBalance(100);

-- -- Realizar una función postgreSQL, getTopSales, que reciba como argumentos dos años diferentes y devuelva las películas que más se han vendido entre esos dos años, una por año, ordenadas de mayor a menor por número de ventas, cuya signatura es 'function getTopSales(year1 INT, year2 INT, OUT Year INT, OUT Film CHAR, OUT sales bigint);'.
-- CREATE OR REPLACE FUNCTION getTopSales(year1 INT, year2 INT, OUT Year INT, OUT Film CHAR, OUT sales bigint) RETURNS SETOF RECORD AS $$
-- DECLARE
--   year INTEGER;
--   film CHAR;
--   sales bigint;
-- BEGIN
--     FOR year IN SELECT year FROM orders LOOP
--         FOR film IN SELECT film FROM orderdetail LOOP
--             sales := (SELECT COUNT(*) FROM orderdetail WHERE year = year AND film = film);
--             RETURN NEXT;
--         END LOOP;
--     END LOOP;
    
--     END;
-- $$ LANGUAGE plpgsql;
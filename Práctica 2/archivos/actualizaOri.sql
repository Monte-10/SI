/* complemento aspectos necesarios */

    /*RESTRICCIONES*/

    /*CLAVES EXTRANJERAS*/

    ALTER TABLE public.customers
    ADD CONSTRAINT PK_customerid PRIMARY KEY (customerid)
        /*primary key de customers : customerid*/

    ALTER TABLE public.imdb_actormovies
    ADD CONSTRAINT FK_actormovies_movieid FOREIGN KEY (movieid) REFERENCES imdb_movies (movieid)
    ON DELETE CASCADE;

    ALTER TABLE public.imdb_actormovies
    ADD CONSTRAINT FK_actormovies_actorid FOREIGN KEY (actorid) REFERENCES imdb_actors(actorid)
    ON DELETE CASCADE;

    ALTER TABLE public.imdb_actors
    ADD CONSTRAINT PK_actorid PRIMARY KEY (actorid)
   
    ALTER TABLE public.imdb_directormovies
    ADD CONSTRAINT FK_directormovies_movieid FOREIGN KEY (movieid) REFERENCES imdb_movies (movied)
    ON DELETE CASCADE;

    ALTER TABLE public.imdb_directormovies
    ADD CONSTRAINT FK_directormovies_directorid FOREIGN KEY (directorid) REFERENCES imdb_dircetors (directorid)
    ON DELETE CASCADE;

    ALTER TABLE public.imdb_directors
    ADD CONSTRAINT PK_directors_directorid PRIMARY KEY (directorid)

    ALTER TABLE public.imdb_moviecountries
    ADD CONSTRAINT FK_movieid FOREIGN KEY (movieid) REFERENCES imdb_movies(movieid)
    ON DELETE CASCADE;

    ALTER TABLE public.imdb_moviegenres
    ADD CONSTRAINT FK_movieid FOREIGN KEY (movied) REFERENCES imdb_movies (movied)
    ON DELETE CASCADE;

    ALTER TABLE public.imdb_movielanguages
    ADD CONSTRAINT FK_movied FOREIGN KEY (movieid) REFERENCES imdb_movies (movieid)
    ON DELETE CASCADE;

    ALTER TABLE public.imdb_movies
    ADD CONSTRAINT PK_movieid PRIMARY KEY (movieid);

    ALTER TABLE public.inventory
    ADD CONSTRAINT FK_productid FOREIGN KEY (prod_id) REFERENCES products (prod_id);
    ON DELETE CASCADE;

    ALTER TABLE public.orderdetail
    ADD CONSTRAINT FK_orderid FOREIGN KEY (orderid) REFERENCES orders (orderid);
    ON DELETE CASCADE;

    ALTER TABLE public.orderdetail
    ADD CONSTRAINT FK_prod_id FOREIGN KEY (prod_id) REFERENCES products (prod_id);
    ON DELETE CASCADE;

    ALTER TABLE public.orders
    ADD CONSTRAINT PK_orderid PRIMARY KEY (orderid);

    ALTER TABLE public.products
    ADD CONSTRAINT PK_prod_id PRIMARY KEY (prod_id);

    /*CAMBIOS EN CASCADA = anadir a cada foreign key "ON DELETE CASCADE;" para suprimir todo lo que depende de la primary*/

    /*CAMPO BALANCE (en la tabla customers)*/
    ALTER TABLE public.customers
    ADD balance integer;

    ALTER TABLE public.customers
    ALTER COLUMN balance SET DEFAULT 0;

    /*tabla ‘ratings’ para guardar las 
    valoraciones que ha dado cada usuario a cada película*/

    CREATE TABLE public.rating(
        customerid integer NOT NULL,
        valoración text NOT NULL
        );

    ALTER TABLE public.rating OWNER TO alumnodb;
    ALTER TABLE public.rating
        ADD CONSTRAINT PK_customerid FOREIGN KEY (customerid) REFERENCES customers (customerid) 

    /*EVALUACIÓN DE LA PELÍCULA(en la tabla imdb_movies)*/

        /*valoración media ‘ratingmean’ */

        ALTER TABLE imdb_movies 
        ADD COLUMN ratingmean integer(0,5);
        ALTER TABLE imdb_movies 
        ALTER COLUMN ratingmean SET DEFAULT 0;

        /*número de valoraciones ‘ratingcount’ */

        ALTER TABLE imdb_movies
            ADD COLUMN ratingcount integer NOT NULL;
        ALTER TABLE imdb_movies
            ALTER COLUMN ratingcount SET DEFAULT 0;

    /*Aumentacion del tamaño del campo ‘password' (en la tabla customeres)*/
    ALTER TABLE public.customers
    MODIFY password hex(96);


    
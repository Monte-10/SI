
CREATE OR REPLACE FUNCTION getTopActors(char)

    RETURNS TABLE (
        actor varchar(128),
        film varchar (128),
        ano int,
        Num int,
        director varchar (128)
    )AS $$ /*alias to simlify but temporary*/

    DECLARE 
        genero ALIAS FOR $1;
    
    begin

    RETURN QUERY(

        SELECT actor1 AS actor,
                film2   AS film,
                CAST (ano1 AS int) AS ano,
                CAST (Num1 AS int) AS Num,
                director2 AS director

        FROM (

            SELECT actorname AS actor1,
                    COUNT(actorname) AS Num1,
                    MIN (imdb_movies.year) AS ano1

            FROM imdb_actors
				JOIN imdb_actormovies 
				  ON imdb_actors.actorid = imdb_actormovies.actorid
				JOIN imdb_movies
				  ON imdb_actormovies.movieid = imdb_movies.movieid
				JOIN imdb_moviegenres
				  ON imdb_movies.movieid = imdb_moviegenres.movieid
				JOIN imdb_directormovies
				  ON imdb_moviegenres.movieid = imdb_directormovies.movieid
				JOIN imdb_directors
				  ON imdb_directormovies.directorid = imdb_directors.directorid


            WHERE genre =  genero

            GROUP BY actorname HAVING COUNT (actorname) > 4

        )AS q1,
        (
            SELECT actorname AS actor2,
                movietitle   AS film2,
                directorname AS director1,
                year         AS Year2

            FROM imdb_actors
                JOIN imdb_directors
                    ON imdb_directormovies.directorid = imdb_directors.directorid
                JOIN imdb_actormovies
                    ON imdb_actors.actorid = imdb_actormovies.actorid
                JOIN imdb_directormovies
                    ON imdb_moviegenres.movieid = imdb_directormovies.movieid
                JOIN imdb_movies
                    ON imdb_actormovies.movieid = imdb_movies.movieid
                JOIN imdb_moviegenres
                    ON imdb_movies.movieid = imdb_moviegenres.movieid

            WHERE genre =  genero

        ) AS q2

        WHERE q1.actor1 = q2.actor2 AND q1.ano1 = p2.Year2
        ORDER BY Num1 DESC
    );

    END; $$
    LANGUAGE plpgsql;
    
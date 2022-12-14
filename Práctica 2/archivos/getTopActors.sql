CREATE 
OR REPLACE FUNCTION getTopActors (
  genre char, 
  OUT Actor varchar(128), 
  OUT Num int, 
  OUT Debut int, 
  OUT Film char(255), 
  OUT Director char(128)
) RETURNS SETOF RECORD AS $$ BEGIN RETURN QUERY WITH all_data AS (
  SELECT 
    imdb_actors.actorname, 
    imdb_actors.actorid, 
    imdb_movies.movieid, 
    imdb_movies.movietitle, 
    imdb_movies.year, 
    imdb_genres.genre 
  FROM 
    imdb_movies 
    JOIN imdb_moviegenres ON imdb_movies.movieid = imdb_moviegenres.movieid 
    JOIN imdb_genres ON imdb_moviegenres.genreid = imdb_genres.genreid 
    AND imdb_genres.genre = genre
    JOIN imdb_actormovies ON imdb_actormovies.movieid = imdb_movies.movieid 
    JOIN imdb_actors ON imdb_actormovies.actorid = imdb_actors.actorid
), 
filter_count AS (
  SELECT 
    all_data.*, 
    actor_count.count 
  FROM 
    all_data 
    JOIN (
      SELECT 
        actorid, 
        COUNT(*) 
      FROM 
        all_data 
      GROUP BY 
        actorid 
      HAVING 
        COUNT(*) >= 4
    ) AS actor_count ON actor_count.actorid = all_data.actorid
) 
SELECT 
  filter_count.actorname AS actor, 
  filter_count.count AS Num, 
  filter_count.year AS Debut, 
  filter_count.movietitle AS Film, 
  imdb_directors.directorname AS Director 
FROM 
  filter_count 
  JOIN (
    SELECT 
      actorid, 
      MIN(year) AS min_y 
    FROM 
      filter_count 
    GROUP BY 
      actorid
  ) AS min_year ON min_year.actorid = filter_count.actorid 
  AND min_year.min_y = filter_count.year 
  JOIN imdb_directormovies ON imdb_directormovies.movieid = filter_count.movieid 
  JOIN imdb_directors ON imdb_directors.directorid = imdb_directormovies.directorid 
ORDER BY 
  count DESC;
END;
$$ LANGUAGE 'plpgsql' STRICT;
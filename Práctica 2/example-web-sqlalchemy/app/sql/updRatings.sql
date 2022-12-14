CREATE OR REPLACE FUNCTION public.updRatings() RETURNS trigger LANGUAGE 'plpgsql' AS $BODY$
BEGIN
    UPDATE public.imdb_movies SET ratingmean = (SELECT AVG(rating) FROM public.imdb_movie_ratings WHERE imdb_movie_ratings.movieid = imdb_movies.movieid),
    ratingcount = (SELECT COUNT(rating) FROM public.imdb_movie_ratings WHERE imdb_movie_ratings.movieid = imdb_movies.movieid)
    WHERE imdb_movies.movieid = imdb_movie_ratings.movieid;
    RETURN NULL;
END;$BODY$;

CREATE TRIGGER updRating AFTER INSERT OR UPDATE ON public.imdb_movie_ratings FOR EACH ROW EXECUTE PROCEDURE public.updRatings();
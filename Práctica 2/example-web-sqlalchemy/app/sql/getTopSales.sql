CREATE 
OR REPLACE FUNCTION getTopSales (
  year1 int, year2 int, OUT Year int, OUT Film char, 
  OUT sales bigint
) RETURNS SETOF RECORD AS $$ BEGIN RETURN QUERY WITH all_data AS (
  SELECT 
    imdb_movies.movieid AS movieid, 
    imdb_movies.movietitle AS title, 
    products.prod_id AS prod_id, 
    orderdetail.quantity AS quantity, 
    orders.orderdate AS orderdate 
  FROM 
    imdb_movies 
    JOIN products ON products.movieid = imdb_movies.movieid 
    JOIN orderdetail ON products.prod_id = orderdetail.prod_id 
    JOIN orders ON orders.orderid = orderdetail.orderid 
  WHERE 
    (
      cast(
        EXTRACT(
          YEAR 
          FROM 
            orders.orderdate
        ) AS int
      ) BETWEEN year1 
      AND year2
    ) 
    OR (
      cast(
        EXTRACT(
          YEAR 
          FROM 
            orders.orderdate
        ) AS int
      ) BETWEEN year2 
      AND year1
    )
), 
sale_filter AS (
  SELECT 
    cast(
      EXTRACT(
        YEAR 
        FROM 
          all_data.orderdate
      ) AS int
    ) AS year_date, 
    cast(
      all_data.title AS char(50)
    ) AS title, 
    sum(all_data.quantity) AS sum 
  FROM 
    all_data 
  GROUP BY 
    year_date, 
    title 
  ORDER BY 
    sum DESC
) 
SELECT 
  a.date_year, 
  a.title, 
  a.sum 
FROM 
  (
    SELECT 
      sale_filter.year_date AS date_year, 
      sale_filter.title AS title, 
      sale_filter.sum AS sum, 
      ROW_NUMBER() OVER (
        PARTITION BY sale_filter.year_date 
        ORDER BY 
          sum DESC
      ) AS rownumber 
    FROM 
      sale_filter
  ) a 
WHERE 
  rownumber = 1 
ORDER BY 
  sum DESC;
END;
$$ LANGUAGE 'plpgsql' STRICT;



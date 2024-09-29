
USE OLYMPICS;


SELECT * FROM ATHLETE_EVENTS;

SELECT * FROM NOC_REGIONS;

SELECT COUNT(*) FROM ATHLETE_EVENTS;

WITH DUP AS (
SELECT 
      ROW_NUMBER() OVER (PARTITION BY ID,NAME,SEX,AGE,HEIGHT,WEIGHT,TEAM,NOC,GAMES,YEAR,SEASON,CITY,SPORT,EVENT,MEDAL
ORDER BY ID) AS NO ,*
FROM ATHLETE_EVENTS
)

SELECT *  FROM DUP
WHERE NO > 1;

-- 1. How many total Olympic Games held (including Summer and Winter).

SELECT COUNT(DISTINCT(GAMES)) AS TOTAL_GAMES FROM ATHLETE_EVENTS;


-- 2. Total No. of Countries Participated in each Summer/Winter Olympics.

SELECT 
      GAMES,
	  COUNT(DISTINCT TEAM) AS TOTAL_COUNTRIES 
FROM ATHLETE_EVENTS
GROUP BY GAMES
ORDER BY GAMES ASC;

--3 Which year saw the highest and lowest no of countries participating in Olympics?

SELECT 
      TOP 1 GAMES,
	  COUNT(DISTINCT TEAM) AS HIGHEST_TEAM 
FROM ATHLETE_EVENTS 
GROUP BY GAMES
ORDER BY HIGHEST_TEAM DESC ;

SELECT 
       TOP 1 GAMES,
	   COUNT(DISTINCT TEAM) AS LOWEST_TEAM 
FROM ATHLETE_EVENTS 
GROUP BY GAMES
ORDER BY LOWEST_TEAM ASC ;

-- 4.Which nation has participated in all of the Olympic games?

SELECT 
       TEAM,
	   COUNT(DISTINCT GAMES) AS TOTAL_GAMES  
FROM ATHLETE_EVENTS
GROUP BY TEAM
HAVING COUNT( DISTINCT GAMES) = (SELECT COUNT(DISTINCT GAMES) FROM ATHLETE_EVENTS);

-- 5  Identify the sport which was played in all summer Olympics

SELECT  
     SPORT,
	 COUNT(DISTINCT GAMES) 
FROM ATHLETE_EVENTS
WHERE SEASON = 'SUMMER'
GROUP BY SPORT
HAVING COUNT(DISTINCT GAMES) = (SELECT COUNT(DISTINCT GAMES) FROM ATHLETE_EVENTS
                               WHERE SEASON = 'SUMMER');

--6 Which Sports were just played only once and which year in the olympics?

WITH A AS 
( SELECT C.SPORT FROM (
SELECT SPORT,COUNT(DISTINCT GAMES) AS TOTAL_PLAYED FROM ATHLETE_EVENTS
GROUP BY SPORT
HAVING COUNT(DISTINCT GAMES) = 1) AS C
),

B AS (
SELECT SPORT,GAMES FROM ATHLETE_EVENTS
)

SELECT DISTINCT A.SPORT,B.GAMES FROM A
LEFT JOIN B
ON A.SPORT = B.SPORT;
;

--7 Fetch details of the oldest athletes to win a gold medal.

SELECT 
       TOP 5 NAME,
	   SEX,
	   AGE,TEAM,
	   GAMES,SEASON,
	   SPORT,EVENT,
	   MEDAL
FROM ATHLETE_EVENTS
WHERE MEDAL = 'Gold'
ORDER BY AGE DESC;

-- 8. Fetch the top 5 athletes who have won the most gold medals.
SELECT  
     TOP 5 NAME,
	 COUNT(MEDAL) AS TOTAL_GOLD 
FROM ATHLETE_EVENTS
WHERE MEDAL = 'GOLD'
GROUP BY NAME
ORDER BY COUNT(MEDAL) DESC ;

-- 9. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

SELECT TOP 5 NAME,SUM( CASE WHEN MEDAL = 'SILVER' THEN 1 ELSE 0 END) AS SILVER,
            SUM( CASE WHEN MEDAL = 'GOLD' THEN 1 ELSE 0 END) AS GOLD,
			SUM( CASE WHEN MEDAL = 'BRONZE' THEN 1 ELSE 0 END) AS BRONZE,
            SUM( CASE WHEN MEDAL IN ('BRONZE','GOLD','SILVER') THEN 1 ELSE 0 END) AS TOTAL_MEDAL
			FROM ATHLETE_EVENTS
GROUP BY NAME
ORDER BY TOTAL_MEDAL DESC ;

-- 10.Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

SELECT TOP 5 TEAM,
        SUM(CASE WHEN MEDAL= 'GOLD' THEN 1 ELSE 0 END) AS GOLD_MEDAL,
        SUM(CASE WHEN MEDAL = 'SILVER' THEN 1 ELSE 0 END) AS SILVER_MEDAL,
        SUM(CASE WHEN MEDAL = 'BRONZE' THEN 1 ELSE 0 END) AS BRONZE_MEDAL,
        SUM(CASE WHEN MEDAL IN ('GOLD','SILVER','BRONZE') THEN 1 ELSE 0 END) AS TOTAL_MEDAL

FROM ATHLETE_EVENTS
GROUP BY TEAM
ORDER BY TOTAL_MEDAL DESC;


--11 List down total gold, silver and broze medals won by each counntry corresponding to each olympic games.

SELECT A.NOC,A.GAMES,N.REGION ,SUM(CASE WHEN MEDAL = 'GOLD' THEN 1 ELSE 0 END) AS GOLD ,
                   SUM(CASE WHEN MEDAL = 'SILVER' THEN 1 ELSE 0 END)AS SILVER,
				   SUM(CASE WHEN MEDAL = 'BRONZE' THEN 1 ELSE 0 END) AS BRONZE,
				   SUM(CASE WHEN MEDAL IN ('GOLD','SILVER','BRONZE') THEN 1 ELSE 0 END) AS TOTAL_MEDAL FROM ATHLETE_EVENTS AS A
INNER JOIN NOC_REGIONS AS N ON A.NOC = N.NOC
GROUP BY A.NOC,A.GAMES,N.REGION
ORDER BY TOTAL_MEDAL DESC ;


-- 12 Which countries have never won gold medal but have won silver/bronze medals?

WITH TOTAL_MEDALS AS 
(
SELECT A.NOC,N.REGION ,SUM(CASE WHEN MEDAL = 'GOLD' THEN 1 ELSE 0 END) AS GOLD ,
                   SUM(CASE WHEN MEDAL = 'SILVER' THEN 1 ELSE 0 END)AS SILVER,
				   SUM(CASE WHEN MEDAL = 'BRONZE' THEN 1 ELSE 0 END) AS BRONZE,
				   SUM(CASE WHEN MEDAL IN ('GOLD','SILVER','BRONZE') THEN 1 ELSE 0 END) AS TOTAL_MEDAL FROM ATHLETE_EVENTS AS A
INNER JOIN NOC_REGIONS AS N ON A.NOC = N.NOC
GROUP BY A.NOC,N.REGION
) 
SELECT REGION, GOLD ,SILVER,BRONZE FROM TOTAL_MEDALS
WHERE GOLD = 0 AND (SILVER > 0 OR BRONZE >0) 
ORDER BY SILVER DESC,BRONZE DESC;

-- 13. In which Sport/event, India has won highest medals.

SELECT 
     TOP 5 A.NOC,
	 B.REGION,
	 A.SPORT,
	 A.EVENT ,
	 COUNT(A.MEDAL) AS TOTAL_MEDAL 
FROM ATHLETE_EVENTS AS A
INNER JOIN NOC_REGIONS AS B ON A.NOC = B.NOC
WHERE A.MEDAL IN ('GOLD','SILVER','BRONZE') AND B.REGION = 'INDIA'
GROUP BY A.NOC,B.REGION,A.SPORT,A.EVENT 
ORDER BY TOTAL_MEDAL DESC ;


-- 14.Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.

SELECT 
      A.NOC,
	  N.REGION,
	  A.GAMES,
	  A.EVENT,
	  SUM(CASE WHEN MEDAL IN ('GOLD','SILVER','BRONZE') THEN 1 ELSE 0 END) AS TOTAL_MEDAL 
FROM ATHLETE_EVENTS AS A
JOIN NOC_REGIONS AS N ON A.NOC = N.NOC
WHERE N.REGION = 'INDIA' AND A.MEDAL IN ('GOLD','SILVER','BRONZE') AND A.SPORT = 'HOCKEY'
GROUP BY A.NOC,N.REGION,A.GAMES,A.EVENT
HAVING SUM(CASE WHEN MEDAL IN ('GOLD','SILVER','BRONZE') THEN 1 ELSE 0 END) > 0
ORDER BY TOTAL_MEDAL DESC ;

 --15 Fetch the total No. of sports played in each olympic games.

 SELECT 
        DISTINCT GAMES,
		COUNT(DISTINCT SPORT) AS TOTAL_SPORTS 
FROM ATHLETE_EVENTS
 GROUP BY GAMES
 ORDER BY COUNT(DISTINCT SPORT) DESC;

 -- 16 List down all Olympics games held so far.

 SELECT DISTINCT GAMES, CITY FROM ATHLETE_EVENTS
 ORDER BY  GAMES ASC;

 -- 17 top countries have sent fewer than 50 athletes but have a high ratio of medals won per athlete?

 SELECT 
      TOP 10 REGION,GAMES,
	  COUNT(DISTINCT NAME) AS TOTAL_PARTICIPANT ,
	  SUM(CASE WHEN MEDAL IN ('GOLD','SILVER','BRONZE') THEN 1 ELSE 0 END) AS TOTAL_MEDAL,
  ROUND(CAST(SUM(CASE WHEN MEDAL IN ('GOLD','SILVER','BRONZE') THEN 1 ELSE 0 END) AS FLOAT)/ COUNT(DISTINCT NAME),1) AS MEDAL_PER_ATHLETE FROM ATHLETE_EVENTS
 INNER JOIN 
          NOC_REGIONS ON ATHLETE_EVENTS.NOC =  NOC_REGIONS.NOC
 GROUP BY
        REGION,GAMES
 HAVING 
        COUNT(DISTINCT NAME) < 50
 ORDER BY 
        MEDAL_PER_ATHLETE DESC ;



-- 18 Country Dominance in Specific Sports:

CREATE PROCEDURE GAME 
         @SPORT_NAME VARCHAR(50) 
AS
BEGIN
     SELECT TOP 3 N.REGION,A.SPORT,COUNT(A.MEDAL) AS TOTAL_MEDAL FROM ATHLETE_EVENTS AS A
      INNER JOIN NOC_REGIONS AS N ON A.NOC = N.NOC
     WHERE MEDAL IS NOT NULL AND  SPORT = @SPORT_NAME
     GROUP BY REGION,SPORT
      ORDER BY TOTAL_MEDAL DESC;
END

SELECT DISTINCT SPORT FROM ATHLETE_EVENTS;
EXEC GAME @SPORT_NAME = 'FOOTBALL';
EXEC GAME @SPORT_NAME = 'HOCKEY';
EXEC GAME @SPORT_NAME = 'WEIGHTLIFTING';

-- 19 Who is the most successful athlete (in terms of total medals won) in each sport, and how many medals did they win?
WITH A AS 
(
SELECT NAME,SPORT, COUNT(MEDAL) AS TOTAL_MEDAL FROM ATHLETE_EVENTS
WHERE MEDAL IS NOT NULL AND MEDAL = 'GOLD'
GROUP BY NAME,SPORT
),
 RANKING AS (
          SELECT NAME,SPORT,TOTAL_MEDAL,RANK() OVER(PARTITION BY SPORT ORDER BY TOTAL_MEDAL DESC ) AS RANK FROM A
		  )
SELECT * FROM RANKING
WHERE RANK = 1 
ORDER BY TOTAL_MEDAL DESC;

--20 How many medals did each country (NOC) win in the most recent Olympic Games?

SELECT 
         N.REGION, 
		 COUNT(A.MEDAL) AS TOTAL_MEDALS
FROM ATHLETE_EVENTS AS A
INNER JOIN NOC_REGIONS AS N ON A.NOC = N.NOC
WHERE YEAR = (SELECT MAX(YEAR) FROM ATHLETE_EVENTS) AND MEDAL IS NOT NULL
GROUP BY REGION
ORDER BY TOTAL_MEDALS DESC;

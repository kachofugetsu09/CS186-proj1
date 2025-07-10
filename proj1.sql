-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era) AS
 SELECT MAX(era)
 FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst,namelast,people.birthYear FROM people WHERE weight>300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT people.nameFirst,people.nameLast,people.birthYear
  FROM people WHERE nameFirst LIKE '% %'ORDER BY nameFirst ASC,nameLast ASC;
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT people.birthYear,AVG(height),COUNT(*) FROM people GROUP BY people.birthYear
                                                  ORDER BY birthYear ASC
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT people.birthYear,AVG(height) AS avg,COUNT(*)
  FROM people
  GROUP BY people.birthYear
  HAVING avg >70
  ORDER BY birthYear ASC
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT DISTINCT
    p.nameFirst,
    p.nameLast,
    p.playerID,
    h.yearid
  FROM
    people AS p
  INNER JOIN
    halloffame AS h ON p.playerID = h.playerID
  WHERE h.inducted LIKE 'y'
  ORDER BY
    h.yearid DESC,
    p.playerID ASC;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, q2i.playerid, s.schoolid, yearid
 FROM q2i, collegeplaying C, schools S
 WHERE q2i.playerid=c.playerid AND s.schoolID=c.schoolID AND schoolstate LIKE 'CA'
 ORDER BY yearid DESC, s.schoolid, q2i.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    cp.schoolID -- Use alias for schoolID from collegeplaying
  FROM
    people AS p
  INNER JOIN
    halloffame AS h ON p.playerID = h.playerID
  LEFT JOIN
    collegeplaying AS cp ON p.playerID = cp.playerID
  WHERE
    h.inducted = 'Y'
  ORDER BY
    p.playerID DESC,
    cp.schoolID ASC;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT 1, 1, 1, 1, 1 -- replace this line
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT 1, 1, 1, 1 -- replace this line
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT 1, 1, 1 -- replace this line
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT 1, 1, 1, 1 -- replace this line
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT 1, 1, 1, 1 -- replace this line
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT 1, 1, 1, 1 -- replace this line
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT 1, 1, 1, 1, 1 -- replace this line
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT 1, 1 -- replace this line
;


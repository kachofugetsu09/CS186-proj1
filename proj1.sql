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
  SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    B.yearID,
    CAST((B.H + B.H2B + (2 * B.H3B) + (3 * B.HR)) AS REAL) / B.AB AS slg
  FROM
    batting AS b
    LEFT JOIN people AS p
      ON b.playerID = p.playerID
  WHERE
    b.AB > 50
  ORDER BY
    slg DESC,
    yearID ASC,
    p.playerID ASC
  LIMIT 10;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT
    p.playerID,
    p.nameFirst,
    p.nameLast,
    CAST(SUM(B.H + B.H2B + (2 * B.H3B) + (3 * B.HR)) AS REAL) / SUM(B.AB) AS lslg
  FROM
    batting AS b
    LEFT JOIN people AS p
      ON b.playerID = p.playerID
    GROUP BY
        p.playerID,
        p.nameFirst,
        p.nameLast
    HAVING
    SUM(b.AB) > 50
  ORDER BY
    lslg DESC,
    p.playerID ASC
  LIMIT 10;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
SELECT
    p.nameFirst,
    p.nameLast,
    CAST(SUM(B.H + B.H2B + (2 * B.H3B) + (3 * B.HR)) AS REAL) / SUM(B.AB) AS lslg
FROM
    batting AS b
JOIN
    people AS p ON b.playerID = p.playerID
GROUP BY
    p.playerID,
    p.nameFirst,
    p.nameLast
HAVING
    SUM(b.AB) > 50
    AND
    CAST(SUM(B.H + B.H2B + (2 * B.H3B) + (3 * B.HR)) AS REAL) / SUM(B.AB) >
    (
        SELECT
            CAST(SUM(B_mays.H + B_mays.H2B + (2 * B_mays.H3B) + (3 * B_mays.HR)) AS REAL) / SUM(B_mays.AB)
        FROM
            batting AS B_mays
        JOIN
            people AS P_mays ON B_mays.playerID = P_mays.playerID
        WHERE
            P_mays.nameFirst = 'Willie' AND P_mays.nameLast = 'Mays'
        GROUP BY
            P_mays.playerID
        HAVING
            SUM(B_mays.AB) > 50 -- 确保 Willie Mays 也满足 50 打击次数的条件
    )
ORDER BY
    lslg DESC,
    p.nameFirst ASC,
    p.nameLast ASC

;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT
      yearID,
      MIN(salary),
      MAX(salary),
      CAST(AVG(salary) AS REAL) AS avg
      FROM salaries
      GROUP BY
          yearID
ORDER BY
    yearID ASC
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH SalaryStats AS (
      SELECT
          MIN(salary) AS min_s,
          MAX(salary) AS max_s,
          (MAX(salary) - MIN(salary)) AS range_s
      FROM salaries
      WHERE yearID = 2016
  ),
  AllBins AS (
      SELECT binid FROM binids
  ),
  SalariesWithBinId AS (
      SELECT
          s.salary,
          CASE
              WHEN ss.range_s = 0 THEN 0
              ELSE MIN(9, CAST((s.salary - ss.min_s) * 10.0 / ss.range_s AS INT))
          END AS calculated_binid
      FROM salaries AS s
      CROSS JOIN SalaryStats AS ss
      WHERE s.yearID = 2016
  )
  SELECT
      ab.binid,
      CASE
          WHEN ss.range_s = 0 THEN ss.min_s
          ELSE ss.min_s + ab.binid * (ss.range_s / 10.0)
      END AS low,
      CASE
          WHEN ss.range_s = 0 THEN ss.min_s
          WHEN ab.binid = 9 THEN ss.max_s
          ELSE ss.min_s + (ab.binid + 1) * (ss.range_s / 10.0)
      END AS high,
      COUNT(swb.salary) AS count
  FROM AllBins AS ab
  CROSS JOIN SalaryStats AS ss
  LEFT JOIN SalariesWithBinId AS swb ON ab.binid = swb.calculated_binid
  GROUP BY
      ab.binid, low, high
  ORDER BY
      ab.binid ASC;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  WITH AnnualStats AS (
      SELECT
          yearID,
          MIN(salary) AS min_s,
          MAX(salary) AS max_s,
          CAST(AVG(salary) AS REAL) AS avg_s
      FROM salaries
      GROUP BY yearID
  ),
  LaggedStats AS (
      SELECT
          yearID,
          min_s,
          max_s,
          avg_s,
          LAG(min_s, 1) OVER (ORDER BY yearID) AS prev_min_s,
          LAG(max_s, 1) OVER (ORDER BY yearID) AS prev_max_s,
          LAG(avg_s, 1) OVER (ORDER BY yearID) AS prev_avg_s
      FROM AnnualStats
  )
  SELECT
      yearID,
      min_s - prev_min_s AS mindiff,
      max_s - prev_max_s AS maxdiff,
      avg_s - prev_avg_s AS avgdiff
  FROM LaggedStats
  WHERE prev_min_s IS NOT NULL
  ORDER BY
      yearID ASC;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  WITH MaxSalariesPerYear AS (
      SELECT
          yearID,
          MAX(salary) AS max_s
      FROM salaries
      WHERE yearID IN (2000, 2001)
      GROUP BY yearID
  )
  SELECT
      s.playerID,
      p.nameFirst,
      p.nameLast,
      s.salary,
      s.yearID
  FROM salaries AS s
  JOIN people AS p ON s.playerID = p.playerID
  JOIN MaxSalariesPerYear AS ms ON s.yearID = ms.yearID AND s.salary = ms.max_s
  WHERE s.yearID IN (2000, 2001)
  ORDER BY
      s.yearID ASC,
      s.salary DESC,
      s.playerID ASC;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  WITH AllStarSalaries2016 AS (
      SELECT
          a.teamID,
          s.salary
      FROM allstarfull AS a
      JOIN salaries AS s ON a.playerID = s.playerID AND a.yearID = s.yearID
      WHERE a.yearID = 2016
  )
  SELECT
      teamID AS team,
      MAX(salary) - MIN(salary) AS diffAvg
  FROM AllStarSalaries2016
  GROUP BY
      teamID
  ORDER BY
      teamID ASC;


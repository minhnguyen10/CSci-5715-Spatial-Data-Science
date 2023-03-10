-- Part A

EXEC SDO_NET.CREATE_SDO_NETWORK('airport',1,TRUE,FALSE);

@airport_node.sql
@airport_link.sql
@airport_list.sql

SELECT SDO_NET.GET_NO_OF_LINKS('airport') FROM DUAL;

-- SDO_NET.GET_NO_OF_LINKS('AIRPORT')                                              
-- ----------------------------------                                              
--                               4093

SELECT SDO_NET.GET_NO_OF_NODES('airport') FROM DUAL;

-- SDO_NET.GET_NO_OF_NODES('AIRPORT')                                              
-- ----------------------------------                                              
--                                293  

SELECT SDO_NET.GET_NODE_DEGREE('airport', AIRPORT_ID)
FROM airport_list
WHERE AIRPORT_NAME = 'Philadelphia, PA';

-- SDO_NET.GET_NODE_DEGREE('AIRPORT',AIRPORT_ID)                                   
-- ---------------------------------------------                                   
--                                            91 

SELECT AVG(SDO_NET.GET_NODE_OUT_DEGREE('airport', airport_ID))
FROM airport_list;

-- AVG(SDO_NET.GET_NODE_OUT_DEGREE('AIRPORT',AIRPORT_ID))                          
-- ------------------------------------------------------                          
--                                             13.9692833

-- Part B

WITH
At_Most_One_Stop_From_Gustavus_AK (START_NODE_ID, END_NODE_ID, LINK_LEVEL) AS
(
 SELECT START_NODE_ID, END_NODE_ID, 0 LINK_LEVEL
 FROM airport_link$
 WHERE START_NODE_ID = 11997
UNION ALL
 SELECT links.START_NODE_ID, links.END_NODE_ID, a.LINK_LEVEL+1
 FROM At_Most_One_Stop_From_Gustavus_AK a, airport_link$ links
 WHERE a.END_NODE_ID = links.START_NODE_ID AND a.LINK_LEVEL = 0
)
SELECT list.AIRPORT_ID, list.AIRPORT_NAME
FROM At_Most_One_Stop_From_Gustavus_AK a, airport_list list
WHERE LINK_LEVEL <= 1
AND a.END_NODE_ID = list.AIRPORT_ID;

-- AIRPORT_ID AIRPORT_NAME
-- ---------- --------------------------------------------------
--      14747 Seattle, WA
--      14828 Sitka, AK
--      10299 Anchorage, AK
--      15991 Yakutat, AK
--      12819 Ketchikan, AK
--      14256 Petersburg, AK
--      12523 Juneau, AK
--      11997 Gustavus, AK
--      14747 Seattle, WA
--      14828 Sitka, AK
--      10299 Anchorage, AK

-- AIRPORT_ID AIRPORT_NAME
-- ---------- --------------------------------------------------
--      15991 Yakutat, AK
--      12819 Ketchikan, AK
--      14256 Petersburg, AK
--      12523 Juneau, AK
--      11997 Gustavus, AK
--      14747 Seattle, WA
--      14828 Sitka, AK
--      10299 Anchorage, AK
--      15991 Yakutat, AK
--      12819 Ketchikan, AK
--      14256 Petersburg, AK

-- AIRPORT_ID AIRPORT_NAME
-- ---------- --------------------------------------------------
--      12523 Juneau, AK
--      11997 Gustavus, AK

-- 24 rows selected.

WITH
 Portland_To_Paducah(AIRPORT_ID, END_ID, LINK_LEVEL) AS
 (
 SELECT START_NODE_ID, END_NODE_ID, 0 LINK_LEVEL
 FROM airport_link$
 WHERE START_NODE_ID = 14057
UNION ALL
 SELECT a.START_NODE_ID, a.END_NODE_ID, p.LINK_LEVEL+1
 FROM Portland_To_Paducah p, airport_link$ a
 WHERE p.END_ID = a.START_NODE_ID AND p.LINK_LEVEL < 3 AND
p.AIRPORT_ID <> a.START_NODE_ID
 )
SELECT MIN(LINK_LEVEL)
FROM Portland_To_Paducah
WHERE END_ID = 14006;

-- MIN(LINK_LEVEL)
-- ---------------
--               1

-- Part C

SELECT c1.NAME FROM COUNTRY2022 c1, COUNTRY2022 c2 
WHERE c2.NAME='Norway' 
AND c1.NAME<>'Norway' 
AND SDO_NN(c1.GEOM, c2.GEOM, 'sdo_num_res=6')='TRUE';

-- NAME
-- --------------------------------------------------
-- Denmark
-- Finland
-- Russia
-- Sweden
-- United Kingdom

SELECT DISTINCT c.NAME
FROM RIVER2022 r, COUNTRY2022 c
WHERE r.NAME = 'Amazonas'
AND SDO_GEOM.SDO_INTERSECTION(r.GEOM, c.GEOM) is not null;

-- NAME
-- --------------------------------------------------
-- Brazil
-- Peru
-- Colombia

SELECT c2.NAME 
FROM COUNTRY2022 c1, COUNTRY2022 c2 
WHERE c1.NAME='Norway' 
AND SDO_TOUCH(c1.GEOM, c2.GEOM)='TRUE';

-- NAME
-- --------------------------------------------------
-- Finland
-- Russia
-- Sweden

-- Part C2

SELECT c1.Name, c2.Name
FROM COUNTRY2022 c1, COUNTRY2022 c2, USER_SDO_GEOM_METADATA m
WHERE m.TABLE_NAME='COUNTRY2022' 
AND c1.Name <> c2.Name 
AND SDO_GEOM.WITHIN_DISTANCE(c1.GEOM, M.DIMINFO, 1, c2.GEOM, m.DIMINFO) = 'TRUE';

-- Multiple hours. Could never get it to finish but left if running for hours on end.

SELECT c1.Name, c2.Name
FROM COUNTRY2022 c1, COUNTRY2022 c2
WHERE c1.Name <> c2.Name
AND SDO_WITHIN_DISTANCE(c1.GEOM, c2.GEOM, 'DISTANCE = 1') = 'TRUE';

-- Elapsed: 00:00:32.03

-- Q2 is much faster than Q1. It is more effcient and faster becuase it is taking advantage of spatial indexing.
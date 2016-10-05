
-- Подразумевается, что процедура создания смет описывается на клиенте




CREATE TABLE `smeta` (
  `id` int(11) NOT NULL,
  `name` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
  );
CREATE TABLE `smeta_positions` (
 `id` int(11) NOT NULL AUTO_INCREMENT,
 `c_1` varchar(20) DEFAULT NULL,
 `c_2` varchar(20) DEFAULT NULL,
 `total_price` int(11) DEFAULT NULL,
 `smeta_id` int(11) DEFAULT NULL,
 `version` int(11) DEFAULT NULL,
 `pos_id` int(11) DEFAULT NULL,
 PRIMARY KEY (`id`),
 KEY `smeta_id` (`smeta_id`),
 CONSTRAINT `smeta_positions_ibfk_1` FOREIGN KEY (`smeta_id`) REFERENCES `smeta` (`id`),
 );


--Процедура для изменения полей сметы (пока по условию только одно поле было изменяемым)

DELIMITER $$

DROP PROCEDURE IF EXISTS change_position_value;

CREATE PROCEDURE change_position_value(IN summa INTEGER , IN pos INTEGER, IN smeta_name VARCHAR(20)) 
BEGIN

DECLARE p_OLD_SUM INTEGER;
DECLARE p_VERSION INTEGER;
DECLARE p_NEW_SUM_DELTA INTEGER;
DECLARE p_C1 VARCHAR(20);
DECLARE p_C2 VARCHAR(20);
DECLARE p_SMETA_ID INTEGER;


SELECT id INTO p_SMETA_ID
FROM smeta
WHERE name = smeta_name;

SELECT max(version) INTO p_VERSION 
FROM smeta_positions
WHERE smeta_id = p_SMETA_ID;

SELECT c_1 INTO p_C1 
FROM smeta_positions
WHERE pos_id = pos AND smeta_id = p_SMETA_ID
LIMIT 1;

SELECT c_2 INTO p_C2 
FROM smeta_positions
WHERE pos_id = pos AND smeta_id = p_SMETA_ID
LIMIT 1;

SELECT sum(total_price) INTO p_OLD_SUM
FROM
smeta_positions
WHERE version<=p_VERSION AND pos_id = pos AND smeta_id = p_SMETA_ID;

SET p_NEW_SUM_DELTA = summa - p_OLD_SUM;

INSERT INTO smeta_positions(c_1,c_2,total_price,smeta_id,version,pos_id)
VALUE (p_C1,p_C2,p_NEW_SUM_DELTA,p_SMETA_ID,p_VERSION + 1,pos);


END $$

DELIMITER ;


--Процедура для получения любой версии сметы

DELIMITER $$

DROP PROCEDURE IF EXISTS get_smeta_by_version_and_name;

CREATE PROCEDURE get_smeta_by_version_and_name(IN in_Version INTEGER, IN smeta_name VARCHAR(20)) 
BEGIN

DECLARE p_SMETA_ID INTEGER;

SELECT id INTO p_SMETA_ID
FROM smeta
WHERE name = smeta_name;

SELECT c_1 ,c_2, sum(total_price)
FROM smeta_positions
WHERE version<=in_Version and smeta_id = p_SMETA_ID
GROUP BY pos_id;

END $$

DELIMITER ;
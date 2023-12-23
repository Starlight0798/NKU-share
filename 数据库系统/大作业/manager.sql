SET NAMES utf8;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';
 
DROP TABLE IF EXISTS `student_course`; 
DROP TABLE IF EXISTS `student_log`;
DROP TABLE IF EXISTS `user_admin`;
DROP TABLE IF EXISTS `user_student`;
DROP TABLE IF EXISTS `course`;
DROP TABLE IF EXISTS `student`;
DROP TABLE IF EXISTS `major`;
DROP TABLE IF EXISTS `department`;

DROP PROCEDURE IF EXISTS `delete_student_with_related_records`;
DROP TRIGGER IF EXISTS `prevent_much_enrollment`;
DROP PROCEDURE IF EXISTS `change_student_major`;
DROP VIEW IF EXISTS `student_details_view`;

DROP TRIGGER IF EXISTS `check_password_strength_student`;
DROP TRIGGER IF EXISTS `check_password_strength_admin`;
DROP TRIGGER IF EXISTS `trg_insert_student`;


CREATE TABLE `department` (
  `did` INT(11) NOT NULL AUTO_INCREMENT,
  `dname` varchar(15) NOT NULL,
  `dadd` varchar(30),
  `dmng` varchar(10),
  `dtel` varchar(15),
  PRIMARY KEY (`did`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `course` (
  `cid` INT(11) NOT NULL AUTO_INCREMENT,
  `cname` varchar(15) NOT NULL,
  `credit` decimal(2,1),
  `cadd` varchar(20),
  `did` INT(11),
  `tname` varchar(15),
  PRIMARY KEY (`cid`),
  FOREIGN KEY (`did`) REFERENCES `department`(`did`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
 


CREATE TABLE `major` (
  `mid` INT(11) NOT NULL AUTO_INCREMENT,
  `did` INT(11),
  `mname` varchar(20) NOT NULL,
  PRIMARY KEY (`mid`),
  UNIQUE KEY `did_2` (`did`,`mname`),
  KEY `did` (`did`),
  FOREIGN KEY (`did`) REFERENCES `department`(`did`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `student` (
  `sid` INT(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(10) NOT NULL,
  `sex` char(1),
  `age` varchar(3),
  `class` varchar(10),
  `idnum` char(18),
  `mid` INT(11),
  `email` char(30),
  `tel` char(11),
  PRIMARY KEY (`sid`),
  FOREIGN KEY (`mid`) REFERENCES `major`(`mid`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
 


CREATE TABLE `student_course` (
  `sid` INT(11) NOT NULL,
  `cid` INT(11) NOT NULL,
  `score` int(3),
  `status` char(1) DEFAULT '0',
  PRIMARY KEY (`sid`,`cid`),
  FOREIGN KEY (`sid`) REFERENCES `student`(`sid`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`cid`) REFERENCES `course`(`cid`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `student_log` (
  `log_id` INT(11) NOT NULL AUTO_INCREMENT,
  `sid` INT(11) NOT NULL,
  `type` char(2),
  `reason` varchar(30),
  `detail` varchar(100),
  `logdate` date,
  `addtime` datetime,
  PRIMARY KEY (`log_id`),
  KEY `sid` (`sid`),
  FOREIGN KEY (`sid`) REFERENCES `student`(`sid`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

 


CREATE TABLE `user_admin` (
  `adminID` INT(11) NOT NULL AUTO_INCREMENT,
  `adminName` varchar(15),
  `pwd` varchar(32),
  PRIMARY KEY (`adminID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
 


CREATE TABLE `user_student` (
  `sid` INT(11) NOT NULL,
  `pwd` varchar(32),
  PRIMARY KEY (`sid`),
  FOREIGN KEY (`sid`) REFERENCES `student`(`sid`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



DELIMITER //
CREATE PROCEDURE delete_student_with_related_records(IN student_id INT)
BEGIN
    DECLARE total_records INT;
    START TRANSACTION;
    DELETE FROM student_course WHERE sid = student_id;
    DELETE FROM student_log WHERE sid = student_id;
    DELETE FROM user_student WHERE sid = student_id;
    DELETE FROM student WHERE sid = student_id;
    SET total_records = (SELECT COUNT(*) FROM student WHERE sid = student_id)
                      + (SELECT COUNT(*) FROM student_course WHERE sid = student_id)
                      + (SELECT COUNT(*) FROM student_log WHERE sid = student_id)
                      + (SELECT COUNT(*) FROM user_student WHERE sid = student_id);
                  
    IF total_records = 0 THEN
        COMMIT;
    ELSE
        ROLLBACK;
    END IF;
END;
//
DELIMITER ;



DELIMITER //
CREATE TRIGGER prevent_much_enrollment
BEFORE INSERT ON student_course
FOR EACH ROW
BEGIN
  DECLARE credit_count INT;

  SELECT SUM(credit) INTO credit_count
  FROM student_course NATURAL JOIN course
  WHERE sid = NEW.sid;

  IF credit_count >= 30 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'ERROR';
  END IF;
END;
//
DELIMITER ;



DELIMITER //
CREATE PROCEDURE change_student_major(IN p_sid INT, IN p_mname VARCHAR(20))
BEGIN
  DECLARE avg_score DECIMAL(3,1);
  DECLARE major_id INT;

  SELECT mid INTO major_id
  FROM major
  WHERE mname = p_mname;

  IF major_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'ERROR';
  END IF;

  SELECT SUM(score * credit) / SUM(credit) INTO avg_score
  FROM student_course NATURAL JOIN course
  WHERE sid = p_sid;

  IF avg_score IS NULL OR avg_score < 70 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'FAIL';
  END IF;
  
  UPDATE student
  SET mid = major_id
  WHERE sid = p_sid;
END;
//
DELIMITER ;



CREATE VIEW student_details_view AS
SELECT s.sid, s.name, s.sex, s.age, s.class, s.idnum, 
       d.dname AS department_name, 
       m.mname AS major_name, s.email, s.tel,
       (SELECT COUNT(*) FROM student_course AS sc WHERE sc.sid = s.sid) AS course_count,
       (SELECT COUNT(*) FROM student_log AS sl WHERE sl.sid = s.sid) AS reward_punishment_count
FROM student AS s
JOIN major AS m ON s.mid = m.mid
JOIN department AS d ON m.did = d.did
ORDER BY s.sid;



CREATE TRIGGER check_password_strength_student
BEFORE UPDATE ON user_student
FOR EACH ROW
BEGIN
  IF NOT (
    CHAR_LENGTH(NEW.pwd) >= 8
    AND NEW.pwd REGEXP '[A-Z]'
    AND NEW.pwd REGEXP '[a-z]'
    AND NEW.pwd REGEXP '[0-9]'
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'ERROR';
  END IF;
END;
//
DELIMITER ;



CREATE TRIGGER check_password_strength_admin
BEFORE UPDATE ON user_admin
FOR EACH ROW
BEGIN
  IF NOT (
    CHAR_LENGTH(NEW.pwd) >= 8
    AND NEW.pwd REGEXP '[A-Z]'
    AND NEW.pwd REGEXP '[a-z]'
    AND NEW.pwd REGEXP '[0-9]'
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'ERROR';
  END IF;
END;
//
DELIMITER ;



CREATE TRIGGER trg_insert_student
AFTER INSERT ON student
FOR EACH ROW 
BEGIN
  INSERT INTO user_student(sid, pwd) VALUES (NEW.sid, '123456');
END;

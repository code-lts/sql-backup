CREATE DATABASE testbench CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE testbench;

CREATE TABLE `table hérétique ! @*:` (
    `ma première colonne` varchar(64) CHARACTER SET utf8mb4 NOT NULL,
    `qui utilise encore du latin sérieux` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_ci DEFAULT NULL
  ) ENGINE=InnoDB DEFAULT CHARSET=big5 COMMENT="Une table horrible";

ALTER TABLE `table hérétique ! @*:` ADD PRIMARY KEY (`ma première colonne`);
ALTER TABLE `table hérétique ! @*:` ADD INDEX(`qui utilise encore du latin sérieux`);
ALTER TABLE `table hérétique ! @*:` ADD UNIQUE(`ma première colonne`);
ALTER TABLE `table hérétique ! @*:` ADD KEY `les cons` (`qui utilise encore du latin sérieux`) USING BTREE;

CREATE ALGORITHM=UNDEFINED DEFINER=`testbench`@`%` SQL SECURITY DEFINER VIEW `je te vois` AS select `table hérétique ! @*:`.`ma première colonne` AS `ma première colonne`,`table hérétique ! @*:`.`qui utilise encore du latin sérieux` AS `qui utilise encore du latin sérieux` from `table hérétique ! @*:`;

CREATE DEFINER=`testbench`@`%` TRIGGER `test1` BEFORE INSERT ON `table hérétique ! @*:` FOR EACH ROW SET new.`ma première colonne`="a";

CREATE DEFINER=`testbench`@`%` EVENT `event1` ON SCHEDULE AT '2000-01-01 00:00:00' ON COMPLETION PRESERVE ENABLE DO SELECT 1;

CREATE DEFINER=`testbench`@`%` FUNCTION `procédure de test`(`entrée 1` VARCHAR(35) CHARSET cp1250) RETURNS INT(1) UNSIGNED COMMENT 'procédure de test n°1' NOT DETERMINISTIC NO SQL SQL SECURITY DEFINER RETURN 1;

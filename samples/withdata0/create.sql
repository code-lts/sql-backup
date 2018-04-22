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
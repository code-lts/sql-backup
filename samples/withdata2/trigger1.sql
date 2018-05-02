USE testbench;
CREATE  DEFINER=`root`@`%` TRIGGER `dummyTrigger` BEFORE INSERT ON `table hérétique ! @*:` FOR EACH ROW SET new.`ma première colonne` = "";
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('dispatch_card', 'Policejní MDT karta', 0, 0, 1),
('mdt_access', 'Přístup k dispečerskému systému', 0, 0, 1);

INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES
('police', 'Policejní složka', 0),
('sheriff', 'Sheriff', 0),
('ambulance', 'Záchranná služba', 0),
('fib', 'FBI', 0);

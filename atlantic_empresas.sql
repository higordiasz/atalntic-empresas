CREATE TABLE IF NOT EXISTS `atlantic_empresas` (
    `id` int(10) NOT NULL AUTO_INCREMENT,
    `user_id` int(10) NOT NULL DEFAULT '0',
    `cordx` varchar(50) NOT NULL DEFAULT '1.111',
    `cordy` varchar(50) NOT NULL DEFAULT '1.111',
    `cordz` varchar(50) NOT NULL DEFAULT '1.111',
    `value` int(30) NOT NULL DEFAULT '200000',
    `rendimento` int(30) NOT NULL DEFAULT '500',
    `last` varchar(90) NOT NULL DEFAULT '0',
    `max` int(30) NOT NULL DEFAULT '999999',
    PRIMARY KEY(`id`)
)
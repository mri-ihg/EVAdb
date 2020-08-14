DROP TABLE IF EXISTS `omim`;
CREATE TABLE `omim` (
  `omimdisease` int(11) unsigned NULL default NULL,
  `disease` varchar(255) NOT NULL,
  `omimgene` int(11) unsigned NOT NULL,
  `inheritance` set('unknown','ad','ar','x','somatic','mocaicism','sporadic','polygenic') NOT NULL,
  `comment` varchar(255) NOT NULL,
  KEY `omimdisease` (`omimdisease`),
  KEY `omimgene` (`omimgene`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1;

-- MySQL dump 10.11
--
-- Host: localhost    Database: openmrs_lh
-- ------------------------------------------------------
-- Server version	5.0.45-Debian_1ubuntu3.1-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `complex_obs`
--

DROP TABLE IF EXISTS `complex_obs`;
CREATE TABLE `complex_obs` (
  `obs_id` int(11) NOT NULL default '0',
  `mime_type_id` int(11) NOT NULL default '0',
  `urn` text,
  `complex_value` longtext,
  PRIMARY KEY  (`obs_id`),
  KEY `mime_type_of_content` (`mime_type_id`),
  CONSTRAINT `complex_obs_ibfk_1` FOREIGN KEY (`mime_type_id`) REFERENCES `mime_type` (`mime_type_id`),
  CONSTRAINT `obs_pointing_to_complex_content` FOREIGN KEY (`obs_id`) REFERENCES `obs` (`obs_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `concept`
--

DROP TABLE IF EXISTS `concept`;
CREATE TABLE `concept` (
  `concept_id` int(11) NOT NULL auto_increment,
  `retired` tinyint(1) NOT NULL default '0',
  `name` varchar(255) NOT NULL default '',
  `short_name` varchar(255) default NULL,
  `description` text,
  `form_text` text,
  `datatype_id` int(11) NOT NULL default '0',
  `class_id` int(11) NOT NULL default '0',
  `is_set` tinyint(1) NOT NULL default '0',
  `icd10` varchar(255) default NULL,
  `loinc` varchar(255) default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `default_charge` int(11) default NULL,
  `version` varchar(50) default NULL,
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  `form_location` varchar(50) default NULL,
  `units` varchar(50) default NULL,
  `view_count` int(11) default NULL,
  PRIMARY KEY  (`concept_id`),
  KEY `concept_classes` (`class_id`),
  KEY `concept_creator` (`creator`),
  KEY `concept_datatypes` (`datatype_id`),
  KEY `user_who_changed_concept` (`changed_by`),
  CONSTRAINT `concept_classes` FOREIGN KEY (`class_id`) REFERENCES `concept_class` (`concept_class_id`),
  CONSTRAINT `concept_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `concept_datatypes` FOREIGN KEY (`datatype_id`) REFERENCES `concept_datatype` (`concept_datatype_id`),
  CONSTRAINT `user_who_changed_concept` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=461 DEFAULT CHARSET=utf8;

--
-- Table structure for table `concept_answer`
--

DROP TABLE IF EXISTS `concept_answer`;
CREATE TABLE `concept_answer` (
  `concept_answer_id` int(11) NOT NULL auto_increment,
  `concept_id` int(11) NOT NULL default '0',
  `answer_concept` int(11) default NULL,
  `answer_drug` int(11) default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`concept_answer_id`),
  KEY `answer_creator` (`creator`),
  KEY `answer` (`answer_concept`),
  KEY `answers_for_concept` (`concept_id`),
  CONSTRAINT `answer` FOREIGN KEY (`answer_concept`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `answers_for_concept` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `answer_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1006 DEFAULT CHARSET=utf8;

--
-- Table structure for table `concept_class`
--

DROP TABLE IF EXISTS `concept_class`;
CREATE TABLE `concept_class` (
  `concept_class_id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `description` varchar(255) NOT NULL default '',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`concept_class_id`),
  KEY `concept_class_creator` (`creator`),
  CONSTRAINT `concept_class_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;

--
-- Table structure for table `concept_datatype`
--

DROP TABLE IF EXISTS `concept_datatype`;
CREATE TABLE `concept_datatype` (
  `concept_datatype_id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `hl7_abbreviation` varchar(3) default NULL,
  `description` varchar(255) NOT NULL default '',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`concept_datatype_id`),
  KEY `concept_datatype_creator` (`creator`),
  CONSTRAINT `concept_datatype_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

--
-- Table structure for table `concept_map`
--

DROP TABLE IF EXISTS `concept_map`;
CREATE TABLE `concept_map` (
  `concept_map_id` int(11) NOT NULL auto_increment,
  `source` int(11) default NULL,
  `source_id` int(11) default NULL,
  `comment` varchar(255) default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`concept_map_id`),
  KEY `map_source` (`source`),
  KEY `map_creator` (`creator`),
  CONSTRAINT `map_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `map_source` FOREIGN KEY (`source`) REFERENCES `concept_source` (`concept_source_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `concept_name`
--

DROP TABLE IF EXISTS `concept_name`;
CREATE TABLE `concept_name` (
  `concept_id` int(11) NOT NULL default '0',
  `name` varchar(255) NOT NULL default '',
  `short_name` varchar(255) default NULL,
  `description` text NOT NULL,
  `locale` varchar(50) NOT NULL default '',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`concept_id`,`locale`),
  KEY `user_who_created_name` (`creator`),
  CONSTRAINT `name_for_concept` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `user_who_created_name` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `concept_numeric`
--

DROP TABLE IF EXISTS `concept_numeric`;
CREATE TABLE `concept_numeric` (
  `concept_id` int(11) NOT NULL default '0',
  `hi_absolute` double default NULL,
  `hi_critical` double default NULL,
  `hi_normal` double default NULL,
  `low_absolute` double default NULL,
  `low_critical` double default NULL,
  `low_normal` double default NULL,
  `units` varchar(50) default NULL,
  `precise` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`concept_id`),
  CONSTRAINT `numeric_attributes` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `concept_proposal`
--

DROP TABLE IF EXISTS `concept_proposal`;
CREATE TABLE `concept_proposal` (
  `concept_proposal_id` int(11) NOT NULL auto_increment,
  `concept_id` int(11) default NULL,
  `encounter_id` int(11) default NULL,
  `original_text` varchar(255) NOT NULL default '',
  `final_text` varchar(255) default NULL,
  `obs_id` int(11) default NULL,
  `obs_concept_id` int(11) default NULL,
  `state` varchar(32) NOT NULL default 'UNMAPPED' COMMENT 'Valid values are: UNMAPPED, SYNONYM, CONCEPT, REJECT',
  `comments` varchar(255) default NULL COMMENT 'Comment from concept admin/mapper',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  PRIMARY KEY  (`concept_proposal_id`),
  KEY `encounter_for_proposal` (`encounter_id`),
  KEY `concept_for_proposal` (`concept_id`),
  KEY `user_who_created_proposal` (`creator`),
  KEY `user_who_changed_proposal` (`changed_by`),
  KEY `proposal_obs_id` (`obs_id`),
  KEY `proposal_obs_concept_id` (`obs_concept_id`),
  CONSTRAINT `concept_for_proposal` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `encounter_for_proposal` FOREIGN KEY (`encounter_id`) REFERENCES `encounter` (`encounter_id`),
  CONSTRAINT `proposal_obs_concept_id` FOREIGN KEY (`obs_concept_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `proposal_obs_id` FOREIGN KEY (`obs_id`) REFERENCES `obs` (`obs_id`),
  CONSTRAINT `user_who_changed_proposal` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_created_proposal` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `concept_set`
--

DROP TABLE IF EXISTS `concept_set`;
CREATE TABLE `concept_set` (
  `concept_id` int(11) NOT NULL default '0',
  `concept_set` int(11) NOT NULL default '0',
  `sort_weight` double default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`concept_id`,`concept_set`),
  KEY `has_a` (`concept_set`),
  KEY `user_who_created` (`creator`),
  CONSTRAINT `has_a` FOREIGN KEY (`concept_set`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `is_a` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `user_who_created` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `concept_set_derived`
--

DROP TABLE IF EXISTS `concept_set_derived`;
CREATE TABLE `concept_set_derived` (
  `concept_id` int(11) NOT NULL default '0',
  `concept_set` int(11) NOT NULL default '0',
  `sort_weight` double default NULL,
  PRIMARY KEY  (`concept_id`,`concept_set`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `concept_source`
--

DROP TABLE IF EXISTS `concept_source`;
CREATE TABLE `concept_source` (
  `concept_source_id` int(11) NOT NULL auto_increment,
  `name` varchar(50) NOT NULL default '',
  `description` text NOT NULL,
  `hl7_code` varchar(50) NOT NULL default '',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `voided` tinyint(4) default NULL,
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`concept_source_id`),
  KEY `concept_source_creator` (`creator`),
  KEY `user_who_voided_concept_source` (`voided_by`),
  CONSTRAINT `concept_source_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_voided_concept_source` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

--
-- Table structure for table `concept_state_conversion`
--

DROP TABLE IF EXISTS `concept_state_conversion`;
CREATE TABLE `concept_state_conversion` (
  `concept_state_conversion_id` int(11) NOT NULL auto_increment,
  `concept_id` int(11) default '0',
  `program_workflow_id` int(11) default '0',
  `program_workflow_state_id` int(11) default '0',
  PRIMARY KEY  (`concept_state_conversion_id`),
  UNIQUE KEY `unique_workflow_concept_in_conversion` (`program_workflow_id`,`concept_id`),
  KEY `triggering_concept` (`concept_id`),
  KEY `affected_workflow` (`program_workflow_id`),
  KEY `resulting_state` (`program_workflow_state_id`),
  CONSTRAINT `concept_triggers_conversion` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `conversion_involves_workflow` FOREIGN KEY (`program_workflow_id`) REFERENCES `program_workflow` (`program_workflow_id`),
  CONSTRAINT `conversion_to_state` FOREIGN KEY (`program_workflow_state_id`) REFERENCES `program_workflow_state` (`program_workflow_state_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `concept_synonym`
--

DROP TABLE IF EXISTS `concept_synonym`;
CREATE TABLE `concept_synonym` (
  `concept_id` int(11) NOT NULL default '0',
  `synonym` varchar(255) NOT NULL default '',
  `locale` varchar(255) default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`synonym`,`concept_id`),
  KEY `synonym_for` (`concept_id`),
  KEY `synonym_creator` (`creator`),
  CONSTRAINT `synonym_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `synonym_for` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `concept_word`
--

DROP TABLE IF EXISTS `concept_word`;
CREATE TABLE `concept_word` (
  `concept_id` int(11) NOT NULL default '0',
  `word` varchar(50) NOT NULL default '',
  `synonym` varchar(255) NOT NULL default '',
  `locale` varchar(20) NOT NULL default '',
  PRIMARY KEY  (`concept_id`,`word`,`synonym`,`locale`),
  CONSTRAINT `word_for` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `drug`
--

DROP TABLE IF EXISTS `drug`;
CREATE TABLE `drug` (
  `drug_id` int(11) NOT NULL auto_increment,
  `concept_id` int(11) NOT NULL default '0',
  `name` varchar(50) default NULL,
  `combination` tinyint(1) NOT NULL default '0',
  `daily_mg_per_kg` double default NULL,
  `dosage_form` varchar(255) default NULL,
  `dose_strength` double default NULL,
  `inn` longtext,
  `maximum_dose` double default NULL,
  `minimum_dose` double default NULL,
  `route` varchar(255) default NULL,
  `shelf_life` int(11) default NULL,
  `therapy_class` int(11) default NULL,
  `units` varchar(50) default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`drug_id`),
  KEY `drug_creator` (`creator`),
  KEY `primary_drug_concept` (`concept_id`),
  CONSTRAINT `drug_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `primary_drug_concept` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8;

--
-- Table structure for table `drug_barcodes`
--

DROP TABLE IF EXISTS `drug_barcodes`;
CREATE TABLE `drug_barcodes` (
  `id` int(11) NOT NULL auto_increment,
  `drug_id` int(11) NOT NULL default '0',
  `barcode` varchar(16) NOT NULL default '',
  `quantity` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8;

--
-- Table structure for table `drug_ingredient`
--

DROP TABLE IF EXISTS `drug_ingredient`;
CREATE TABLE `drug_ingredient` (
  `concept_id` int(11) NOT NULL default '0',
  `ingredient_id` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ingredient_id`,`concept_id`),
  KEY `combination_drug` (`concept_id`),
  CONSTRAINT `combination_drug` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `ingredient` FOREIGN KEY (`ingredient_id`) REFERENCES `concept` (`concept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `drug_order`
--

DROP TABLE IF EXISTS `drug_order`;
CREATE TABLE `drug_order` (
  `drug_order_id` int(11) NOT NULL auto_increment,
  `order_id` int(11) NOT NULL default '0',
  `drug_inventory_id` int(11) default '0',
  `dose` int(11) default NULL,
  `units` varchar(255) default NULL,
  `frequency` varchar(255) default NULL,
  `prn` tinyint(1) NOT NULL default '0',
  `complex` tinyint(1) NOT NULL default '0',
  `quantity` int(11) default NULL,
  PRIMARY KEY  (`drug_order_id`),
  KEY `inventory_item` (`drug_inventory_id`),
  KEY `extends_order` (`order_id`),
  CONSTRAINT `extends_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `inventory_item` FOREIGN KEY (`drug_inventory_id`) REFERENCES `drug` (`drug_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8404536 DEFAULT CHARSET=utf8;

--
-- Table structure for table `drug_order_delete`
--

DROP TABLE IF EXISTS `drug_order_delete`;
CREATE TABLE `drug_order_delete` (
  `drug_order_id` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `encounter`
--

DROP TABLE IF EXISTS `encounter`;
CREATE TABLE `encounter` (
  `encounter_id` int(11) NOT NULL auto_increment,
  `encounter_type` int(11) default NULL,
  `patient_id` int(11) NOT NULL default '0',
  `provider_id` int(11) NOT NULL default '0',
  `location_id` int(11) NOT NULL default '0',
  `form_id` int(11) default NULL,
  `encounter_datetime` datetime NOT NULL default '0000-00-00 00:00:00',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`encounter_id`),
  KEY `encounter_location` (`location_id`),
  KEY `encounter_patient` (`patient_id`),
  KEY `encounter_provider` (`provider_id`),
  KEY `encounter_type_id` (`encounter_type`),
  KEY `encounter_creator` (`creator`),
  KEY `encounter_form` (`form_id`),
  KEY `ordered_encounters` (`encounter_id`),
  CONSTRAINT `encounter_form` FOREIGN KEY (`form_id`) REFERENCES `form` (`form_id`),
  CONSTRAINT `encounter_ibfk_1` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `encounter_location` FOREIGN KEY (`location_id`) REFERENCES `location` (`location_id`),
  CONSTRAINT `encounter_patient` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`),
  CONSTRAINT `encounter_provider` FOREIGN KEY (`provider_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `encounter_type_id` FOREIGN KEY (`encounter_type`) REFERENCES `encounter_type` (`encounter_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1302957 DEFAULT CHARSET=utf8;

--
-- Table structure for table `encounter_type`
--

DROP TABLE IF EXISTS `encounter_type`;
CREATE TABLE `encounter_type` (
  `encounter_type_id` int(11) NOT NULL auto_increment,
  `name` varchar(50) NOT NULL default '',
  `description` varchar(50) NOT NULL default '',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`encounter_type_id`),
  KEY `user_who_created_type` (`creator`),
  CONSTRAINT `user_who_created_type` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;

--
-- Table structure for table `field`
--

DROP TABLE IF EXISTS `field`;
CREATE TABLE `field` (
  `field_id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `description` text,
  `field_type` int(11) default NULL,
  `concept_id` int(11) default NULL,
  `table_name` varchar(50) default NULL,
  `attribute_name` varchar(50) default NULL,
  `default_value` text,
  `select_multiple` tinyint(1) NOT NULL default '0',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  PRIMARY KEY  (`field_id`),
  KEY `concept_for_field` (`concept_id`),
  KEY `user_who_changed_field` (`changed_by`),
  KEY `user_who_created_field` (`creator`),
  KEY `type_of_field` (`field_type`),
  CONSTRAINT `concept_for_field` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `type_of_field` FOREIGN KEY (`field_type`) REFERENCES `field_type` (`field_type_id`),
  CONSTRAINT `user_who_changed_field` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_created_field` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=350 DEFAULT CHARSET=utf8;

--
-- Table structure for table `field_answer`
--

DROP TABLE IF EXISTS `field_answer`;
CREATE TABLE `field_answer` (
  `field_id` int(11) NOT NULL default '0',
  `answer_id` int(11) NOT NULL default '0',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`field_id`,`answer_id`),
  KEY `answers_for_field` (`field_id`),
  KEY `field_answer_concept` (`answer_id`),
  KEY `user_who_created_field_answer` (`creator`),
  CONSTRAINT `answers_for_field` FOREIGN KEY (`field_id`) REFERENCES `field` (`field_id`),
  CONSTRAINT `field_answer_concept` FOREIGN KEY (`answer_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `user_who_created_field_answer` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `field_type`
--

DROP TABLE IF EXISTS `field_type`;
CREATE TABLE `field_type` (
  `field_type_id` int(11) NOT NULL auto_increment,
  `name` varchar(50) default NULL,
  `description` longtext,
  `is_set` tinyint(1) NOT NULL default '0',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`field_type_id`),
  KEY `user_who_created_field_type` (`creator`),
  CONSTRAINT `user_who_created_field_type` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

--
-- Table structure for table `field_types`
--

DROP TABLE IF EXISTS `field_types`;
CREATE TABLE `field_types` (
  `id` int(11) default NULL,
  `name` varchar(50) default NULL,
  `description` longtext,
  `is_set` tinyint(1) default NULL,
  `creator` int(11) default NULL,
  `date_created` datetime default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `fieldids`
--

DROP TABLE IF EXISTS `fieldids`;
CREATE TABLE `fieldids` (
  `fieldid` varchar(100) default NULL,
  `fieldnum` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `fields`
--

DROP TABLE IF EXISTS `fields`;
CREATE TABLE `fields` (
  `id` int(11) default NULL,
  `name` varchar(255) default NULL,
  `description` text,
  `field_type` int(11) default NULL,
  `concept_id` int(11) default NULL,
  `table_name` varchar(50) default NULL,
  `attribute_name` varchar(50) default NULL,
  `default_value` text,
  `select_multiple` tinyint(1) default NULL,
  `creator` int(11) default NULL,
  `date_created` datetime default NULL,
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `form`
--

DROP TABLE IF EXISTS `form`;
CREATE TABLE `form` (
  `form_id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `version` varchar(50) NOT NULL default '',
  `build` int(11) default NULL,
  `published` tinyint(4) NOT NULL default '0',
  `description` text,
  `encounter_type` int(11) default NULL,
  `schema_namespace` varchar(255) default NULL,
  `template` mediumtext,
  `infopath_solution_version` varchar(50) default NULL,
  `uri` varchar(255) default NULL,
  `xslt` mediumtext,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  `retired` tinyint(1) NOT NULL default '0',
  `retired_by` int(11) default NULL,
  `date_retired` datetime default NULL,
  `retired_reason` varchar(255) default NULL,
  PRIMARY KEY  (`form_id`),
  KEY `user_who_created_form` (`creator`),
  KEY `user_who_last_changed_form` (`changed_by`),
  KEY `user_who_retired_form` (`retired_by`),
  KEY `encounter_type` (`encounter_type`),
  CONSTRAINT `form_encounter_type` FOREIGN KEY (`encounter_type`) REFERENCES `encounter_type` (`encounter_type_id`),
  CONSTRAINT `user_who_created_form` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_last_changed_form` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_retired_form` FOREIGN KEY (`retired_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8;

--
-- Table structure for table `form_field`
--

DROP TABLE IF EXISTS `form_field`;
CREATE TABLE `form_field` (
  `form_field_id` int(11) NOT NULL auto_increment,
  `form_id` int(11) NOT NULL default '0',
  `field_id` int(11) NOT NULL default '0',
  `field_number` int(11) default NULL,
  `field_part` varchar(5) default NULL,
  `page_number` int(11) default NULL,
  `parent_form_field` int(11) default NULL,
  `min_occurs` int(11) default NULL,
  `max_occurs` int(11) default NULL,
  `required` tinyint(1) default NULL,
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`form_field_id`),
  KEY `user_who_last_changed_form_field` (`changed_by`),
  KEY `field_within_form` (`field_id`),
  KEY `form_containing_field` (`form_id`),
  KEY `form_field_hierarchy` (`parent_form_field`),
  KEY `user_who_created_form_field` (`creator`),
  CONSTRAINT `field_within_form` FOREIGN KEY (`field_id`) REFERENCES `field` (`field_id`),
  CONSTRAINT `form_containing_field` FOREIGN KEY (`form_id`) REFERENCES `form` (`form_id`),
  CONSTRAINT `form_field_hierarchy` FOREIGN KEY (`parent_form_field`) REFERENCES `form_field` (`form_field_id`),
  CONSTRAINT `user_who_created_form_field` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_last_changed_form_field` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=725 DEFAULT CHARSET=utf8;

--
-- Table structure for table `form_fields`
--

DROP TABLE IF EXISTS `form_fields`;
CREATE TABLE `form_fields` (
  `id` int(11) default NULL,
  `form_id` int(11) default NULL,
  `field_id` int(11) default NULL,
  `field_number` int(11) default NULL,
  `field_part` varchar(5) default NULL,
  `page_number` int(11) default NULL,
  `parent_form_field` int(11) default NULL,
  `min_occurs` int(11) default NULL,
  `max_occurs` int(11) default NULL,
  `required` tinyint(1) default NULL,
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  `creator` int(11) default NULL,
  `date_created` datetime default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `formentry_archive`
--

DROP TABLE IF EXISTS `formentry_archive`;
CREATE TABLE `formentry_archive` (
  `formentry_archive_id` int(11) NOT NULL auto_increment,
  `form_data` mediumtext NOT NULL,
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `creator` int(11) NOT NULL default '0',
  PRIMARY KEY  (`formentry_archive_id`),
  KEY `User who created formentry_archive` (`creator`),
  CONSTRAINT `User who created formentry_archive` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `formentry_error`
--

DROP TABLE IF EXISTS `formentry_error`;
CREATE TABLE `formentry_error` (
  `formentry_error_id` int(11) NOT NULL auto_increment,
  `form_data` mediumtext NOT NULL,
  `error` varchar(255) NOT NULL default '',
  `error_details` text,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`formentry_error_id`),
  KEY `User who created formentry_error` (`creator`),
  CONSTRAINT `User who created formentry_error` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `formentry_queue`
--

DROP TABLE IF EXISTS `formentry_queue`;
CREATE TABLE `formentry_queue` (
  `formentry_queue_id` int(11) NOT NULL auto_increment,
  `form_data` mediumtext NOT NULL,
  `status` int(11) NOT NULL default '0' COMMENT '0=pending, 1=processing, 2=processed, 3=error',
  `date_processed` datetime default NULL,
  `error_msg` varchar(255) default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`formentry_queue_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `forms`
--

DROP TABLE IF EXISTS `forms`;
CREATE TABLE `forms` (
  `id` int(11) default NULL,
  `name` varchar(255) default NULL,
  `version` varchar(50) default NULL,
  `build` int(11) default NULL,
  `published` tinyint(4) default NULL,
  `description` text,
  `encounter_type` int(11) default NULL,
  `schema_namespace` varchar(255) default NULL,
  `template` mediumtext,
  `infopath_solution_version` varchar(50) default NULL,
  `uri` varchar(255) default NULL,
  `xslt` mediumtext,
  `creator` int(11) default NULL,
  `date_created` datetime default NULL,
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  `retired` tinyint(1) default NULL,
  `retired_by` int(11) default NULL,
  `date_retired` datetime default NULL,
  `retired_reason` varchar(255) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `global_property`
--

DROP TABLE IF EXISTS `global_property`;
CREATE TABLE `global_property` (
  `id` int(11) NOT NULL auto_increment,
  `property` varchar(255) default NULL,
  `property_value` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8;

--
-- Table structure for table `heart_beat`
--

DROP TABLE IF EXISTS `heart_beat`;
CREATE TABLE `heart_beat` (
  `id` int(20) NOT NULL auto_increment,
  `ip` varchar(20) default NULL,
  `property` varchar(200) default NULL,
  `value` varchar(200) default NULL,
  `time_stamp` datetime default NULL,
  `username` varchar(10) default NULL,
  `url` varchar(100) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `hl7_in_archive`
--

DROP TABLE IF EXISTS `hl7_in_archive`;
CREATE TABLE `hl7_in_archive` (
  `hl7_in_archive_id` int(11) NOT NULL auto_increment,
  `hl7_source` int(11) NOT NULL default '0',
  `hl7_source_key` varchar(255) default NULL,
  `hl7_data` mediumtext NOT NULL,
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`hl7_in_archive_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `hl7_in_error`
--

DROP TABLE IF EXISTS `hl7_in_error`;
CREATE TABLE `hl7_in_error` (
  `hl7_in_error_id` int(11) NOT NULL auto_increment,
  `hl7_source` int(11) NOT NULL default '0',
  `hl7_source_key` text,
  `hl7_data` mediumtext NOT NULL,
  `error` varchar(255) NOT NULL default '',
  `error_details` text,
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`hl7_in_error_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `hl7_in_queue`
--

DROP TABLE IF EXISTS `hl7_in_queue`;
CREATE TABLE `hl7_in_queue` (
  `hl7_in_queue_id` int(11) NOT NULL auto_increment,
  `hl7_source` int(11) NOT NULL default '0',
  `hl7_source_key` text,
  `hl7_data` mediumtext NOT NULL,
  `state` int(11) NOT NULL default '0' COMMENT '0=pending, 1=processing, 2=processed, 3=error',
  `date_processed` datetime default NULL,
  `error_msg` text,
  `date_created` datetime default NULL,
  PRIMARY KEY  (`hl7_in_queue_id`),
  KEY `hl7_source` (`hl7_source`),
  CONSTRAINT `hl7_source` FOREIGN KEY (`hl7_source`) REFERENCES `hl7_source` (`hl7_source_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `hl7_source`
--

DROP TABLE IF EXISTS `hl7_source`;
CREATE TABLE `hl7_source` (
  `hl7_source_id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `description` tinytext,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`hl7_source_id`),
  KEY `creator` (`creator`),
  CONSTRAINT `creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
CREATE TABLE `location` (
  `location_id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `description` varchar(255) default NULL,
  `address1` varchar(50) default NULL,
  `address2` varchar(50) default NULL,
  `city_village` varchar(50) default NULL,
  `state_province` varchar(50) default NULL,
  `postal_code` varchar(50) default NULL,
  `country` varchar(50) default NULL,
  `latitude` varchar(50) default NULL,
  `longitude` varchar(50) default NULL,
  `parent_location_id` int(11) default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`location_id`),
  KEY `user_who_created_location` (`creator`),
  CONSTRAINT `user_who_created_location` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1202 DEFAULT CHARSET=utf8;

--
-- Table structure for table `mastercards`
--

DROP TABLE IF EXISTS `mastercards`;
CREATE TABLE `mastercards` (
  `id` int(11) NOT NULL auto_increment,
  `arvnumber` varchar(50) NOT NULL,
  `fieldid` varchar(100) NOT NULL,
  `fieldvalue` varchar(100) NOT NULL,
  `entry` char(1) NOT NULL,
  `mastercard_number` int(2) default NULL,
  `username` varchar(20) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=94694 DEFAULT CHARSET=latin1;

--
-- Table structure for table `mime_type`
--

DROP TABLE IF EXISTS `mime_type`;
CREATE TABLE `mime_type` (
  `mime_type_id` int(11) NOT NULL auto_increment,
  `mime_type` varchar(75) NOT NULL default '',
  `description` text,
  PRIMARY KEY  (`mime_type_id`),
  KEY `mime_type_id` (`mime_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `note`
--

DROP TABLE IF EXISTS `note`;
CREATE TABLE `note` (
  `note_id` int(11) NOT NULL default '0',
  `note_type` varchar(50) default NULL,
  `patient_id` int(11) default NULL,
  `obs_id` int(11) default NULL,
  `encounter_id` int(11) default NULL,
  `text` text NOT NULL,
  `priority` int(11) default NULL,
  `parent` int(11) default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  PRIMARY KEY  (`note_id`),
  KEY `patient_note` (`patient_id`),
  KEY `obs_note` (`obs_id`),
  KEY `encounter_note` (`encounter_id`),
  KEY `user_who_created_note` (`creator`),
  KEY `user_who_changed_note` (`changed_by`),
  KEY `note_hierarchy` (`parent`),
  CONSTRAINT `encounter_note` FOREIGN KEY (`encounter_id`) REFERENCES `encounter` (`encounter_id`),
  CONSTRAINT `note_hierarchy` FOREIGN KEY (`parent`) REFERENCES `note` (`note_id`),
  CONSTRAINT `obs_note` FOREIGN KEY (`obs_id`) REFERENCES `obs` (`obs_id`),
  CONSTRAINT `patient_note` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`),
  CONSTRAINT `user_who_changed_note` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_created_note` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `notification_alert`
--

DROP TABLE IF EXISTS `notification_alert`;
CREATE TABLE `notification_alert` (
  `alert_id` int(11) NOT NULL auto_increment,
  `text` varchar(512) NOT NULL,
  `satisfied_by_any` int(1) NOT NULL default '0',
  `alert_read` int(1) NOT NULL default '0',
  `date_to_expire` datetime default NULL,
  `creator` int(11) NOT NULL,
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  PRIMARY KEY  (`alert_id`),
  KEY `alert_creator` (`creator`),
  KEY `user_who_changed_alert` (`changed_by`),
  CONSTRAINT `alert_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_changed_alert` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `notification_alert_recipient`
--

DROP TABLE IF EXISTS `notification_alert_recipient`;
CREATE TABLE `notification_alert_recipient` (
  `alert_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `alert_read` int(1) NOT NULL default '0',
  `date_changed` timestamp NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`alert_id`,`user_id`),
  KEY `alert_read_by_user` (`user_id`),
  KEY `id_of_alert` (`alert_id`),
  CONSTRAINT `alert_read_by_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `id_of_alert` FOREIGN KEY (`alert_id`) REFERENCES `notification_alert` (`alert_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `notification_template`
--

DROP TABLE IF EXISTS `notification_template`;
CREATE TABLE `notification_template` (
  `template_id` int(11) NOT NULL auto_increment,
  `name` varchar(50) default NULL,
  `template` text,
  `subject` varchar(100) default NULL,
  `sender` varchar(255) default NULL,
  `recipients` varchar(512) default NULL,
  `ordinal` int(11) default '0',
  PRIMARY KEY  (`template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `obs`
--

DROP TABLE IF EXISTS `obs`;
CREATE TABLE `obs` (
  `obs_id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL default '0',
  `concept_id` int(11) NOT NULL default '0',
  `encounter_id` int(11) default NULL,
  `order_id` int(11) default NULL,
  `obs_datetime` datetime NOT NULL default '0000-00-00 00:00:00',
  `location_id` int(11) NOT NULL default '0',
  `obs_group_id` int(11) default NULL,
  `accession_number` varchar(255) default NULL,
  `value_group_id` int(11) default NULL,
  `value_boolean` tinyint(1) default NULL,
  `value_coded` int(11) default NULL,
  `value_drug` int(11) default NULL,
  `value_datetime` datetime default NULL,
  `value_numeric` double default NULL,
  `value_modifier` varchar(2) default NULL,
  `value_text` text,
  `date_started` datetime default NULL,
  `date_stopped` datetime default NULL,
  `comments` varchar(255) default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `voided` tinyint(1) NOT NULL default '0',
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`obs_id`),
  KEY `answer_concept` (`value_coded`),
  KEY `answer_concept_drug` (`value_drug`),
  KEY `encounter_observations` (`encounter_id`),
  KEY `obs_concept` (`concept_id`),
  KEY `obs_enterer` (`creator`),
  KEY `obs_location` (`location_id`),
  KEY `obs_order` (`order_id`),
  KEY `patient_obs` (`patient_id`),
  KEY `user_who_voided_obs` (`voided_by`),
  CONSTRAINT `answer_concept` FOREIGN KEY (`value_coded`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `answer_concept_drug` FOREIGN KEY (`value_drug`) REFERENCES `drug` (`drug_id`),
  CONSTRAINT `encounter_observations` FOREIGN KEY (`encounter_id`) REFERENCES `encounter` (`encounter_id`),
  CONSTRAINT `obs_concept` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `obs_enterer` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `obs_location` FOREIGN KEY (`location_id`) REFERENCES `location` (`location_id`),
  CONSTRAINT `obs_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `patient_obs` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`),
  CONSTRAINT `user_who_voided_obs` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3722506 DEFAULT CHARSET=utf8;

--
-- Table structure for table `order_type`
--

DROP TABLE IF EXISTS `order_type`;
CREATE TABLE `order_type` (
  `order_type_id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `description` varchar(255) NOT NULL default '',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`order_type_id`),
  KEY `type_created_by` (`creator`),
  CONSTRAINT `type_created_by` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL auto_increment,
  `order_type_id` int(11) NOT NULL default '0',
  `concept_id` int(11) NOT NULL default '0',
  `orderer` int(11) default '0',
  `encounter_id` int(11) default NULL,
  `instructions` text,
  `start_date` datetime default NULL,
  `auto_expire_date` datetime default NULL,
  `discontinued` tinyint(1) NOT NULL default '0',
  `discontinued_date` datetime default NULL,
  `discontinued_by` int(11) default NULL,
  `discontinued_reason` varchar(255) default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `voided` tinyint(1) NOT NULL default '0',
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`order_id`),
  KEY `order_creator` (`creator`),
  KEY `orderer_not_drug` (`orderer`),
  KEY `orders_in_encounter` (`encounter_id`),
  KEY `type_of_order` (`order_type_id`),
  KEY `user_who_discontinued_order` (`discontinued_by`),
  KEY `user_who_voided_order` (`voided_by`),
  CONSTRAINT `orderer_not_drug` FOREIGN KEY (`orderer`) REFERENCES `users` (`user_id`),
  CONSTRAINT `orders_in_encounter` FOREIGN KEY (`encounter_id`) REFERENCES `encounter` (`encounter_id`),
  CONSTRAINT `order_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `type_of_order` FOREIGN KEY (`order_type_id`) REFERENCES `order_type` (`order_type_id`),
  CONSTRAINT `user_who_discontinued_order` FOREIGN KEY (`discontinued_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_voided_order` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=832794 DEFAULT CHARSET=utf8;

--
-- Table structure for table `orders_drug_order`
--

DROP TABLE IF EXISTS `orders_drug_order`;
CREATE TABLE `orders_drug_order` (
  `encounter_id` int(11) default NULL,
  `encounter_type` int(11) default NULL,
  `encounter_datetime` datetime default NULL,
  `drug_inventory_id` int(11) default NULL,
  `quantity` int(11) default NULL,
  `orderer` int(11) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `paper_mastercards`
--

DROP TABLE IF EXISTS `paper_mastercards`;
CREATE TABLE `paper_mastercards` (
  `id` int(11) NOT NULL auto_increment,
  `arvnumber` varchar(50) NOT NULL,
  `fieldid` varchar(100) NOT NULL,
  `fieldvalue` varchar(100) NOT NULL,
  `entry` char(1) NOT NULL,
  `mastercard_number` int(2) default NULL,
  `username` varchar(20) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=415311 DEFAULT CHARSET=latin1;

--
-- Table structure for table `patient`
--

DROP TABLE IF EXISTS `patient`;
CREATE TABLE `patient` (
  `patient_id` int(11) NOT NULL auto_increment,
  `gender` varchar(50) NOT NULL default '',
  `race` varchar(50) default NULL,
  `birthdate` date default NULL,
  `birthdate_estimated` tinyint(1) default NULL,
  `birthplace` varchar(50) default NULL,
  `tribe` int(11) default NULL,
  `citizenship` varchar(50) default NULL,
  `mothers_name` varchar(50) default NULL,
  `civil_status` int(11) default NULL,
  `dead` int(1) NOT NULL default '0',
  `death_date` datetime default NULL,
  `cause_of_death` varchar(255) default NULL,
  `health_district` varchar(255) default NULL,
  `health_center` int(11) default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  `voided` tinyint(1) NOT NULL default '0',
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`patient_id`),
  KEY `belongs_to_tribe` (`tribe`),
  KEY `user_who_created_patient` (`creator`),
  KEY `user_who_voided_patient` (`voided_by`),
  KEY `user_who_changed_pat` (`changed_by`),
  KEY `birthdate` (`birthdate`),
  CONSTRAINT `belongs_to_tribe` FOREIGN KEY (`tribe`) REFERENCES `tribe` (`tribe_id`),
  CONSTRAINT `user_who_changed_pat` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_created_patient` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_voided_patient` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18496 DEFAULT CHARSET=utf8;

--
-- Table structure for table `patient_address`
--

DROP TABLE IF EXISTS `patient_address`;
CREATE TABLE `patient_address` (
  `patient_address_id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL default '0',
  `preferred` tinyint(1) NOT NULL default '0',
  `address1` varchar(50) default NULL,
  `address2` varchar(50) default NULL,
  `city_village` varchar(50) default NULL,
  `state_province` varchar(50) default NULL,
  `postal_code` varchar(50) default NULL,
  `country` varchar(50) default NULL,
  `latitude` varchar(50) default NULL,
  `longitude` varchar(50) default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `voided` tinyint(1) NOT NULL default '0',
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`patient_address_id`),
  KEY `patient_address_creator` (`creator`),
  KEY `patient_addresses` (`patient_id`),
  KEY `patient_address_void` (`voided_by`),
  CONSTRAINT `patient_addresses` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`),
  CONSTRAINT `patient_address_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `patient_address_void` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18465 DEFAULT CHARSET=utf8;

--
-- Table structure for table `patient_adherence_dates`
--

DROP TABLE IF EXISTS `patient_adherence_dates`;
CREATE TABLE `patient_adherence_dates` (
  `id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL,
  `drug_id` int(11) NOT NULL,
  `visit_date` date NOT NULL,
  `drugs_run_out_date` date NOT NULL,
  `default_date` date NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `patient_id_visit_date_default_date` (`patient_id`,`visit_date`,`default_date`)
) ENGINE=InnoDB AUTO_INCREMENT=146678 DEFAULT CHARSET=utf8;

--
-- Temporary table structure for view `patient_default_dates`
--

DROP TABLE IF EXISTS `patient_default_dates`;
/*!50001 DROP VIEW IF EXISTS `patient_default_dates`*/;
/*!50001 CREATE TABLE `patient_default_dates` (
  `patient_id` int(11),
  `default_date` date
) */;

--
-- Temporary table structure for view `patient_dispensations_and_initiation_dates`
--

DROP TABLE IF EXISTS `patient_dispensations_and_initiation_dates`;
/*!50001 DROP VIEW IF EXISTS `patient_dispensations_and_initiation_dates`*/;
/*!50001 CREATE TABLE `patient_dispensations_and_initiation_dates` (
  `patient_id` int(11),
  `start_date` datetime
) */;

--
-- Temporary table structure for view `patient_dispensations_and_prescriptions`
--

DROP TABLE IF EXISTS `patient_dispensations_and_prescriptions`;
/*!50001 DROP VIEW IF EXISTS `patient_dispensations_and_prescriptions`*/;
/*!50001 CREATE TABLE `patient_dispensations_and_prescriptions` (
  `patient_id` int(11),
  `encounter_id` int(11),
  `visit_date` date,
  `drug_id` int(11),
  `total_dispensed` int(11),
  `total_remaining` int(11),
  `daily_consumption` int(11)
) */;

--
-- Temporary table structure for view `patient_first_line_regimen_dispensations`
--

DROP TABLE IF EXISTS `patient_first_line_regimen_dispensations`;
/*!50001 DROP VIEW IF EXISTS `patient_first_line_regimen_dispensations`*/;
/*!50001 CREATE TABLE `patient_first_line_regimen_dispensations` (
  `patient_id` int(11),
  `encounter_id` int(11),
  `dispensed_date` datetime
) */;

--
-- Table structure for table `patient_identifier`
--

DROP TABLE IF EXISTS `patient_identifier`;
CREATE TABLE `patient_identifier` (
  `patient_id` int(11) NOT NULL default '0',
  `identifier` varchar(50) NOT NULL default '',
  `identifier_type` int(11) NOT NULL default '0',
  `preferred` tinyint(4) NOT NULL default '0',
  `location_id` int(11) NOT NULL default '0',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `voided` tinyint(1) NOT NULL default '0',
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`patient_id`,`identifier`,`identifier_type`),
  KEY `defines_identifier_type` (`identifier_type`),
  KEY `identifier_creator` (`creator`),
  KEY `identifier_voider` (`voided_by`),
  KEY `identifier_location` (`location_id`),
  KEY `identifier_name` (`identifier`),
  CONSTRAINT `defines_identifier_type` FOREIGN KEY (`identifier_type`) REFERENCES `patient_identifier_type` (`patient_identifier_type_id`),
  CONSTRAINT `identifier_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `identifier_voider` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `identifies_patient` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`),
  CONSTRAINT `patient_identifier_ibfk_2` FOREIGN KEY (`location_id`) REFERENCES `location` (`location_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `patient_identifier_type`
--

DROP TABLE IF EXISTS `patient_identifier_type`;
CREATE TABLE `patient_identifier_type` (
  `patient_identifier_type_id` int(11) NOT NULL auto_increment,
  `name` varchar(50) NOT NULL default '',
  `description` text NOT NULL,
  `format` varchar(50) default NULL,
  `check_digit` tinyint(1) NOT NULL default '0',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`patient_identifier_type_id`),
  KEY `type_creator` (`creator`),
  CONSTRAINT `type_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;

--
-- Table structure for table `patient_name`
--

DROP TABLE IF EXISTS `patient_name`;
CREATE TABLE `patient_name` (
  `patient_name_id` int(11) NOT NULL auto_increment,
  `preferred` tinyint(1) NOT NULL default '0',
  `patient_id` int(11) NOT NULL default '0',
  `prefix` varchar(50) default NULL,
  `given_name` varchar(50) default NULL,
  `middle_name` varchar(50) default NULL,
  `family_name_prefix` varchar(50) default NULL,
  `family_name` varchar(50) default NULL,
  `family_name2` varchar(50) default NULL,
  `family_name_suffix` varchar(50) default NULL,
  `degree` varchar(50) default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `voided` tinyint(1) NOT NULL default '0',
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  PRIMARY KEY  (`patient_name_id`),
  KEY `name_for_patient` (`patient_id`),
  KEY `user_who_made_name` (`creator`),
  KEY `user_who_voided_name` (`voided_by`),
  KEY `first_name` (`given_name`),
  KEY `middle_name` (`middle_name`),
  KEY `last_name` (`family_name`),
  CONSTRAINT `name_for_patient` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`),
  CONSTRAINT `user_who_made_name` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_voided_name` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18530 DEFAULT CHARSET=utf8;

--
-- Temporary table structure for view `patient_outcomes`
--

DROP TABLE IF EXISTS `patient_outcomes`;
/*!50001 DROP VIEW IF EXISTS `patient_outcomes`*/;
/*!50001 CREATE TABLE `patient_outcomes` (
  `patient_id` int(11),
  `outcome_date` datetime,
  `outcome_concept_id` bigint(20)
) */;

--
-- Table structure for table `patient_prescription_totals`
--

DROP TABLE IF EXISTS `patient_prescription_totals`;
CREATE TABLE `patient_prescription_totals` (
  `id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL,
  `drug_id` int(11) NOT NULL,
  `prescription_date` date NOT NULL,
  `daily_consumption` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `patient_id_drug_id_presciption_date` (`patient_id`,`drug_id`,`prescription_date`)
) ENGINE=InnoDB AUTO_INCREMENT=18540 DEFAULT CHARSET=utf8;

--
-- Temporary table structure for view `patient_prescriptions`
--

DROP TABLE IF EXISTS `patient_prescriptions`;
/*!50001 DROP VIEW IF EXISTS `patient_prescriptions`*/;
/*!50001 CREATE TABLE `patient_prescriptions` (
  `patient_id` int(11),
  `encounter_id` int(11),
  `prescription_datetime` datetime,
  `drug_id` int(11),
  `frequency` text,
  `dose_amount` double,
  `time_period` text,
  `quantity` double,
  `daily_consumption` double
) */;

--
-- Table structure for table `patient_program`
--

DROP TABLE IF EXISTS `patient_program`;
CREATE TABLE `patient_program` (
  `patient_program_id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL default '0',
  `program_id` int(11) NOT NULL default '0',
  `date_enrolled` datetime default NULL,
  `date_completed` datetime default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  `voided` tinyint(1) NOT NULL default '0',
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`patient_program_id`),
  KEY `patient_in_program` (`patient_id`),
  KEY `program_for_patient` (`program_id`),
  KEY `patient_program_creator` (`creator`),
  KEY `user_who_changed` (`changed_by`),
  KEY `user_who_voided_patient_program` (`voided_by`),
  CONSTRAINT `patient_in_program` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`) ON UPDATE CASCADE,
  CONSTRAINT `patient_program_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `program_for_patient` FOREIGN KEY (`program_id`) REFERENCES `program` (`program_id`),
  CONSTRAINT `user_who_changed` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_voided_patient_program` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18443 DEFAULT CHARSET=utf8;

--
-- Temporary table structure for view `patient_regimen_ingredients`
--

DROP TABLE IF EXISTS `patient_regimen_ingredients`;
/*!50001 DROP VIEW IF EXISTS `patient_regimen_ingredients`*/;
/*!50001 CREATE TABLE `patient_regimen_ingredients` (
  `ingredient_concept_id` int(11),
  `regimen_concept_id` int(11),
  `patient_id` int(11),
  `encounter_id` int(11),
  `dispensed_date` datetime
) */;

--
-- Temporary table structure for view `patient_regimens`
--

DROP TABLE IF EXISTS `patient_regimens`;
/*!50001 DROP VIEW IF EXISTS `patient_regimens`*/;
/*!50001 CREATE TABLE `patient_regimens` (
  `regimen_concept_id` int(11),
  `patient_id` int(11),
  `encounter_id` int(11),
  `dispensed_date` datetime
) */;

--
-- Temporary table structure for view `patient_registration_dates`
--

DROP TABLE IF EXISTS `patient_registration_dates`;
/*!50001 DROP VIEW IF EXISTS `patient_registration_dates`*/;
/*!50001 CREATE TABLE `patient_registration_dates` (
  `patient_id` int(11),
  `location_id` int(11),
  `registration_date` datetime
) */;

--
-- Temporary table structure for view `patient_start_dates`
--

DROP TABLE IF EXISTS `patient_start_dates`;
/*!50001 DROP VIEW IF EXISTS `patient_start_dates`*/;
/*!50001 CREATE TABLE `patient_start_dates` (
  `patient_id` int(11),
  `start_date` datetime,
  `age_at_initiation` int(7)
) */;

--
-- Table structure for table `patient_state`
--

DROP TABLE IF EXISTS `patient_state`;
CREATE TABLE `patient_state` (
  `patient_state_id` int(11) NOT NULL auto_increment,
  `patient_program_id` int(11) NOT NULL default '0',
  `state` int(11) NOT NULL default '0',
  `start_date` date default NULL,
  `end_date` date default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  `voided` tinyint(1) NOT NULL default '0',
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`patient_state_id`),
  KEY `state_for_patient` (`state`),
  KEY `patient_program_for_state` (`patient_program_id`),
  KEY `patient_state_creator` (`creator`),
  KEY `patient_state_changer` (`changed_by`),
  KEY `patient_state_voider` (`voided_by`),
  CONSTRAINT `patient_program_for_state` FOREIGN KEY (`patient_program_id`) REFERENCES `patient_program` (`patient_program_id`),
  CONSTRAINT `patient_state_changer` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `patient_state_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `patient_state_voider` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `state_for_patient` FOREIGN KEY (`state`) REFERENCES `program_workflow_state` (`program_workflow_state_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `patient_whole_tablets_remaining_and_brought`
--

DROP TABLE IF EXISTS `patient_whole_tablets_remaining_and_brought`;
CREATE TABLE `patient_whole_tablets_remaining_and_brought` (
  `id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) NOT NULL,
  `drug_id` int(11) NOT NULL,
  `visit_date` date NOT NULL,
  `total_remaining` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `patient_id_drug_id_presciption_date` (`patient_id`,`drug_id`,`visit_date`)
) ENGINE=InnoDB AUTO_INCREMENT=117831 DEFAULT CHARSET=utf8;

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
CREATE TABLE `person` (
  `person_id` int(11) NOT NULL auto_increment,
  `patient_id` int(11) default NULL,
  `user_id` int(11) default NULL,
  PRIMARY KEY  (`person_id`),
  KEY `patients` (`patient_id`),
  KEY `users` (`user_id`),
  CONSTRAINT `patients` FOREIGN KEY (`patient_id`) REFERENCES `patient` (`patient_id`),
  CONSTRAINT `users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17734 DEFAULT CHARSET=utf8;

--
-- Table structure for table `pih_datas`
--

DROP TABLE IF EXISTS `pih_datas`;
CREATE TABLE `pih_datas` (
  `id` int(11) NOT NULL default '0',
  `name` varchar(70) default NULL,
  `year_registered` varchar(8) default NULL,
  `stage` varchar(10) default NULL,
  `date_registered` varchar(40) default NULL,
  `date_started` varchar(40) default NULL,
  `unique_id` varchar(10) default NULL,
  `who_stage` varchar(10) default NULL,
  `reason_for_starting` varchar(150) default NULL,
  `age` int(11) default NULL,
  `sex` varchar(10) default NULL,
  `bmi` varchar(6) default NULL,
  `cd_4` varchar(20) default NULL,
  `transfer_in` varchar(4) default NULL,
  `transfer_out` varchar(4) default NULL,
  `death` varchar(4) default NULL,
  `stop` varchar(4) default NULL,
  `defaulter` varchar(4) default NULL,
  `side_effects` varchar(10) default NULL,
  `regimen` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `prescription_frequencies`
--

DROP TABLE IF EXISTS `prescription_frequencies`;
CREATE TABLE `prescription_frequencies` (
  `id` int(11) NOT NULL auto_increment,
  `frequency` varchar(255) NOT NULL,
  `frequency_days` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `frequency_index` (`frequency`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

--
-- Table structure for table `prescription_time_periods`
--

DROP TABLE IF EXISTS `prescription_time_periods`;
CREATE TABLE `prescription_time_periods` (
  `id` int(11) NOT NULL auto_increment,
  `time_period` varchar(255) NOT NULL,
  `time_period_days` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `time_period_index` (`time_period`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

--
-- Table structure for table `privilege`
--

DROP TABLE IF EXISTS `privilege`;
CREATE TABLE `privilege` (
  `privilege_id` int(11) NOT NULL auto_increment,
  `privilege` varchar(50) NOT NULL default '',
  `description` varchar(250) NOT NULL default '',
  PRIMARY KEY  (`privilege_id`)
) ENGINE=InnoDB AUTO_INCREMENT=87 DEFAULT CHARSET=utf8;

--
-- Table structure for table `program`
--

DROP TABLE IF EXISTS `program`;
CREATE TABLE `program` (
  `program_id` int(11) NOT NULL auto_increment,
  `concept_id` int(11) NOT NULL default '0',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  `voided` tinyint(1) NOT NULL default '0',
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`program_id`),
  KEY `program_concept` (`concept_id`),
  KEY `program_creator` (`creator`),
  KEY `user_who_changed_program` (`changed_by`),
  KEY `user_who_voided_program` (`voided_by`),
  CONSTRAINT `program_concept` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `program_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_changed_program` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_voided_program` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

--
-- Table structure for table `program_workflow`
--

DROP TABLE IF EXISTS `program_workflow`;
CREATE TABLE `program_workflow` (
  `program_workflow_id` int(11) NOT NULL auto_increment,
  `program_id` int(11) NOT NULL default '0',
  `concept_id` int(11) NOT NULL default '0',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `voided` tinyint(1) default NULL,
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`program_workflow_id`),
  KEY `program_for_workflow` (`program_id`),
  KEY `workflow_concept` (`concept_id`),
  KEY `workflow_creator` (`creator`),
  KEY `workflow_voided_by` (`voided_by`),
  CONSTRAINT `program_for_workflow` FOREIGN KEY (`program_id`) REFERENCES `program` (`program_id`),
  CONSTRAINT `workflow_concept` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `workflow_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `workflow_voided_by` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `program_workflow_state`
--

DROP TABLE IF EXISTS `program_workflow_state`;
CREATE TABLE `program_workflow_state` (
  `program_workflow_state_id` int(11) NOT NULL auto_increment,
  `program_workflow_id` int(11) NOT NULL default '0',
  `concept_id` int(11) NOT NULL default '0',
  `initial` tinyint(1) NOT NULL default '0',
  `terminal` tinyint(1) NOT NULL default '0',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `voided` tinyint(1) default NULL,
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`program_workflow_state_id`),
  KEY `workflow_for_state` (`program_workflow_id`),
  KEY `state_concept` (`concept_id`),
  KEY `state_creator` (`creator`),
  KEY `state_voided_by` (`voided_by`),
  CONSTRAINT `state_concept` FOREIGN KEY (`concept_id`) REFERENCES `concept` (`concept_id`),
  CONSTRAINT `state_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `state_voided_by` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `workflow_for_state` FOREIGN KEY (`program_workflow_id`) REFERENCES `program_workflow` (`program_workflow_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `relationship`
--

DROP TABLE IF EXISTS `relationship`;
CREATE TABLE `relationship` (
  `relationship_id` int(11) NOT NULL auto_increment,
  `person_id` int(11) NOT NULL default '0',
  `relationship` int(11) NOT NULL default '0',
  `relative_id` int(11) NOT NULL default '0',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `voided` tinyint(1) NOT NULL default '0',
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`relationship_id`),
  KEY `related_person` (`person_id`),
  KEY `related_relative` (`relative_id`),
  KEY `relationship_type` (`relationship`),
  KEY `relation_creator` (`creator`),
  KEY `relation_voider` (`voided_by`),
  CONSTRAINT `related_person` FOREIGN KEY (`person_id`) REFERENCES `person` (`person_id`),
  CONSTRAINT `related_relative` FOREIGN KEY (`relative_id`) REFERENCES `person` (`person_id`),
  CONSTRAINT `relationship_type_id` FOREIGN KEY (`relationship`) REFERENCES `relationship_type` (`relationship_type_id`),
  CONSTRAINT `relation_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `relation_voider` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8;

--
-- Table structure for table `relationship_type`
--

DROP TABLE IF EXISTS `relationship_type`;
CREATE TABLE `relationship_type` (
  `relationship_type_id` int(11) NOT NULL auto_increment,
  `name` varchar(50) NOT NULL default '',
  `description` varchar(255) NOT NULL default '',
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`relationship_type_id`),
  KEY `user_who_created_rel` (`creator`),
  CONSTRAINT `user_who_created_rel` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

--
-- Table structure for table `report`
--

DROP TABLE IF EXISTS `report`;
CREATE TABLE `report` (
  `report_id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `description` text,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  `voided` tinyint(1) default NULL,
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`report_id`),
  KEY `report_creator` (`creator`),
  KEY `user_who_changed_report` (`changed_by`),
  KEY `user_who_voided_report` (`voided_by`),
  CONSTRAINT `report_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_changed_report` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_voided_report` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `report_object`
--

DROP TABLE IF EXISTS `report_object`;
CREATE TABLE `report_object` (
  `report_object_id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `description` varchar(1000) default NULL,
  `report_object_type` varchar(255) NOT NULL,
  `report_object_sub_type` varchar(255) NOT NULL,
  `xml_data` text,
  `creator` int(11) NOT NULL,
  `date_created` datetime NOT NULL,
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  `voided` tinyint(1) NOT NULL,
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`report_object_id`),
  KEY `report_object_creator` (`creator`),
  KEY `user_who_changed_report_object` (`changed_by`),
  KEY `user_who_voided_report_object` (`voided_by`),
  CONSTRAINT `report_object_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_changed_report_object` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_voided_report_object` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
CREATE TABLE `role` (
  `role_id` int(11) NOT NULL auto_increment,
  `role` varchar(50) NOT NULL default '',
  `description` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

--
-- Table structure for table `role_privilege`
--

DROP TABLE IF EXISTS `role_privilege`;
CREATE TABLE `role_privilege` (
  `role_id` int(11) NOT NULL,
  `privilege_id` int(11) NOT NULL,
  PRIMARY KEY  (`privilege_id`,`role_id`),
  KEY `role_privilege` (`role_id`),
  CONSTRAINT `privilege_definitons` FOREIGN KEY (`privilege_id`) REFERENCES `privilege` (`privilege_id`),
  CONSTRAINT `role_privilege` FOREIGN KEY (`role_id`) REFERENCES `role` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `role_role`
--

DROP TABLE IF EXISTS `role_role`;
CREATE TABLE `role_role` (
  `parent_role_id` int(11) NOT NULL,
  `child_role_id` int(11) NOT NULL,
  PRIMARY KEY  (`parent_role_id`,`child_role_id`),
  KEY `inherited_role` (`child_role_id`),
  CONSTRAINT `inherited_role` FOREIGN KEY (`child_role_id`) REFERENCES `role` (`role_id`),
  CONSTRAINT `parent_role` FOREIGN KEY (`parent_role_id`) REFERENCES `role` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `scheduler_task_config`
--

DROP TABLE IF EXISTS `scheduler_task_config`;
CREATE TABLE `scheduler_task_config` (
  `task_config_id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `description` varchar(1024) default NULL,
  `schedulable_class` text,
  `start_time` datetime NOT NULL,
  `start_time_pattern` varchar(50) default NULL,
  `repeat_interval` int(11) NOT NULL default '0',
  `start_on_startup` int(1) NOT NULL default '0',
  `started` int(1) NOT NULL default '0',
  `created_by` int(11) default '0',
  `date_created` datetime default '0000-00-00 00:00:00',
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  PRIMARY KEY  (`task_config_id`),
  KEY `schedule_creator` (`created_by`),
  KEY `schedule_changer` (`changed_by`),
  CONSTRAINT `scheduler_changer` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `scheduler_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `scheduler_task_config_property`
--

DROP TABLE IF EXISTS `scheduler_task_config_property`;
CREATE TABLE `scheduler_task_config_property` (
  `task_config_id` int(11) NOT NULL default '0',
  `property` varchar(100) NOT NULL default '',
  `property_value` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`task_config_id`,`property`),
  CONSTRAINT `task_config_property` FOREIGN KEY (`task_config_id`) REFERENCES `scheduler_task_config` (`task_config_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `tribe`
--

DROP TABLE IF EXISTS `tribe`;
CREATE TABLE `tribe` (
  `tribe_id` int(11) NOT NULL auto_increment,
  `retired` tinyint(1) NOT NULL default '0',
  `name` varchar(50) NOT NULL default '',
  PRIMARY KEY  (`tribe_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `user_property`
--

DROP TABLE IF EXISTS `user_property`;
CREATE TABLE `user_property` (
  `user_id` int(11) NOT NULL default '0',
  `property` varchar(100) NOT NULL default '',
  `property_value` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`user_id`,`property`),
  CONSTRAINT `user_property` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `user_role`
--

DROP TABLE IF EXISTS `user_role`;
CREATE TABLE `user_role` (
  `user_id` int(11) NOT NULL default '0',
  `role_id` int(11) NOT NULL,
  PRIMARY KEY  (`role_id`,`user_id`),
  KEY `user_role` (`user_id`),
  CONSTRAINT `role_definitions` FOREIGN KEY (`role_id`) REFERENCES `role` (`role_id`),
  CONSTRAINT `user_role` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `user_trackings`
--

DROP TABLE IF EXISTS `user_trackings`;
CREATE TABLE `user_trackings` (
  `id` int(11) NOT NULL auto_increment,
  `date_created` datetime NOT NULL,
  `message` varchar(64) default NULL,
  `observation` varchar(32) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=1247 DEFAULT CHARSET=latin1;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `user_id` int(11) NOT NULL auto_increment,
  `system_id` varchar(50) NOT NULL default '',
  `username` varchar(50) default NULL,
  `first_name` varchar(50) default NULL,
  `middle_name` varchar(50) default NULL,
  `last_name` varchar(50) default NULL,
  `password` varchar(50) default NULL,
  `salt` varchar(50) default NULL,
  `secret_question` varchar(255) default NULL,
  `secret_answer` varchar(255) default NULL,
  `creator` int(11) NOT NULL default '0',
  `date_created` datetime NOT NULL default '0000-00-00 00:00:00',
  `changed_by` int(11) default NULL,
  `date_changed` datetime default NULL,
  `voided` tinyint(1) NOT NULL default '0',
  `voided_by` int(11) default NULL,
  `date_voided` datetime default NULL,
  `void_reason` varchar(255) default NULL,
  PRIMARY KEY  (`user_id`),
  KEY `user_creator` (`creator`),
  KEY `user_who_changed_user` (`changed_by`),
  KEY `user_who_voided_user` (`voided_by`),
  CONSTRAINT `user_creator` FOREIGN KEY (`creator`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_changed_user` FOREIGN KEY (`changed_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_who_voided_user` FOREIGN KEY (`voided_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=426 DEFAULT CHARSET=utf8;

--
-- Table structure for table `weight_for_heights`
--

DROP TABLE IF EXISTS `weight_for_heights`;
CREATE TABLE `weight_for_heights` (
  `id` int(11) NOT NULL auto_increment,
  `supinecm` float default NULL,
  `median_weight_height` float default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Table structure for table `weight_height_for_age`
--

DROP TABLE IF EXISTS `weight_height_for_age`;
CREATE TABLE `weight_height_for_age` (
  `agemths` smallint(6) default NULL,
  `sex` smallint(6) default NULL,
  `medianht` double default NULL,
  `sdlowht` double default NULL,
  `sdhighht` double default NULL,
  `medianwt` double default NULL,
  `sdlowwt` double default NULL,
  `sdhighwt` double default NULL,
  `agesex` char(4) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `weight_height_for_ages`
--

DROP TABLE IF EXISTS `weight_height_for_ages`;
CREATE TABLE `weight_height_for_ages` (
  `age_in_months` smallint(6) default NULL,
  `sex` char(12) default NULL,
  `median_height` double default NULL,
  `standard_low_height` double default NULL,
  `standard_high_height` double default NULL,
  `median_weight` double default NULL,
  `standard_low_weight` double default NULL,
  `standard_high_weight` double default NULL,
  `age_sex` char(4) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Final view structure for view `patient_default_dates`
--

/*!50001 DROP TABLE IF EXISTS `patient_default_dates`*/;
/*!50001 DROP VIEW IF EXISTS `patient_default_dates`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `patient_default_dates` AS select `patient_adherence_dates`.`patient_id` AS `patient_id`,`patient_adherence_dates`.`default_date` AS `default_date` from `patient_adherence_dates` where ((not(exists(select 1 AS `Not_used` from `obs` where ((`obs`.`voided` = 0) and (`obs`.`concept_id` = 28) and (`obs`.`patient_id` = `patient_adherence_dates`.`patient_id`) and (`obs`.`obs_datetime` >= `patient_adherence_dates`.`visit_date`) and (`obs`.`obs_datetime` <= `patient_adherence_dates`.`default_date`))))) and (not(exists(select 1 AS `Not_used` from `obs` where ((`obs`.`voided` = 0) and (`obs`.`value_coded` <> 3) and ((`obs`.`concept_id` = 372) or (`obs`.`concept_id` = 367)) and (`obs`.`patient_id` = `patient_adherence_dates`.`patient_id`) and (`obs`.`obs_datetime` >= `patient_adherence_dates`.`visit_date`) and (`obs`.`obs_datetime` <= `patient_adherence_dates`.`default_date`))))) and (not(exists(select 1 AS `Not_used` from ((((`encounter` join `orders` on(((`orders`.`encounter_id` = `encounter`.`encounter_id`) and (`orders`.`voided` = 0)))) join `drug_order` on((`drug_order`.`order_id` = `orders`.`order_id`))) join `drug` on((`drug_order`.`drug_inventory_id` = `drug`.`drug_id`))) join `concept_set` `arv_drug_concepts` on(((`arv_drug_concepts`.`concept_set` = 460) and (`arv_drug_concepts`.`concept_id` = `drug`.`concept_id`)))) where ((`encounter`.`encounter_type` = 3) and (`encounter`.`patient_id` = `patient_adherence_dates`.`patient_id`) and (`encounter`.`encounter_datetime` > `patient_adherence_dates`.`visit_date`) and (`encounter`.`encounter_datetime` <= `patient_adherence_dates`.`default_date`)))))) */;

--
-- Final view structure for view `patient_dispensations_and_initiation_dates`
--

/*!50001 DROP TABLE IF EXISTS `patient_dispensations_and_initiation_dates`*/;
/*!50001 DROP VIEW IF EXISTS `patient_dispensations_and_initiation_dates`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `patient_dispensations_and_initiation_dates` AS select `patient_first_line_regimen_dispensations`.`patient_id` AS `patient_id`,`patient_first_line_regimen_dispensations`.`dispensed_date` AS `start_date` from `patient_first_line_regimen_dispensations` union select `obs`.`patient_id` AS `patient_id`,`obs`.`value_datetime` AS `start_date` from `obs` where ((`obs`.`concept_id` = 143) and (`obs`.`voided` = 0)) */;

--
-- Final view structure for view `patient_dispensations_and_prescriptions`
--

/*!50001 DROP TABLE IF EXISTS `patient_dispensations_and_prescriptions`*/;
/*!50001 DROP VIEW IF EXISTS `patient_dispensations_and_prescriptions`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `patient_dispensations_and_prescriptions` AS select `encounter`.`patient_id` AS `patient_id`,`encounter`.`encounter_id` AS `encounter_id`,cast(`encounter`.`encounter_datetime` as date) AS `visit_date`,`drug`.`drug_id` AS `drug_id`,`drug_order`.`quantity` AS `total_dispensed`,`whole_tablets_remaining_and_brought`.`total_remaining` AS `total_remaining`,`patient_prescription_totals`.`daily_consumption` AS `daily_consumption` from ((((((`encounter` join `orders` on(((`orders`.`encounter_id` = `encounter`.`encounter_id`) and (`orders`.`voided` = 0)))) join `drug_order` on((`drug_order`.`order_id` = `orders`.`order_id`))) join `drug` on((`drug_order`.`drug_inventory_id` = `drug`.`drug_id`))) join `concept_set` `arv_drug_concepts` on(((`arv_drug_concepts`.`concept_set` = 460) and (`arv_drug_concepts`.`concept_id` = `drug`.`concept_id`)))) left join `patient_whole_tablets_remaining_and_brought` `whole_tablets_remaining_and_brought` on(((`whole_tablets_remaining_and_brought`.`patient_id` = `encounter`.`patient_id`) and (`whole_tablets_remaining_and_brought`.`visit_date` = cast(`encounter`.`encounter_datetime` as date)) and (`whole_tablets_remaining_and_brought`.`drug_id` = `drug`.`drug_id`)))) left join `patient_prescription_totals` on(((`patient_prescription_totals`.`drug_id` = `drug`.`drug_id`) and (`patient_prescription_totals`.`patient_id` = `encounter`.`patient_id`) and (`patient_prescription_totals`.`prescription_date` = cast(`encounter`.`encounter_datetime` as date))))) */;

--
-- Final view structure for view `patient_first_line_regimen_dispensations`
--

/*!50001 DROP TABLE IF EXISTS `patient_first_line_regimen_dispensations`*/;
/*!50001 DROP VIEW IF EXISTS `patient_first_line_regimen_dispensations`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `patient_first_line_regimen_dispensations` AS select `encounter`.`patient_id` AS `patient_id`,`encounter`.`encounter_id` AS `encounter_id`,`encounter`.`encounter_datetime` AS `dispensed_date` from `encounter` where ((`encounter`.`encounter_type` = 3) and (not(exists(select 1 AS `Not_used` from ((((`orders` join `drug_order` on((`drug_order`.`order_id` = `orders`.`order_id`))) join `drug` on((`drug_order`.`drug_inventory_id` = `drug`.`drug_id`))) join `drug_ingredient` `dispensed_ingredient` on((`drug`.`concept_id` = `dispensed_ingredient`.`concept_id`))) left join `drug_ingredient` `regimen_ingredient` on(((`regimen_ingredient`.`ingredient_id` = `dispensed_ingredient`.`ingredient_id`) and (`regimen_ingredient`.`concept_id` = 450)))) where ((`orders`.`encounter_id` = `encounter`.`encounter_id`) and (`orders`.`voided` = 0) and isnull(`dispensed_ingredient`.`concept_id`)) group by `encounter`.`encounter_id`,`regimen_ingredient`.`ingredient_id`)))) */;

--
-- Final view structure for view `patient_outcomes`
--

/*!50001 DROP TABLE IF EXISTS `patient_outcomes`*/;
/*!50001 DROP VIEW IF EXISTS `patient_outcomes`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `patient_outcomes` AS select `encounter`.`patient_id` AS `patient_id`,`encounter`.`encounter_datetime` AS `outcome_date`,324 AS `outcome_concept_id` from ((((`encounter` join `orders` on(((`orders`.`encounter_id` = `encounter`.`encounter_id`) and (`orders`.`voided` = 0)))) join `drug_order` on((`drug_order`.`order_id` = `orders`.`order_id`))) join `drug` on((`drug_order`.`drug_inventory_id` = `drug`.`drug_id`))) join `concept_set` `arv_drug_concepts` on(((`arv_drug_concepts`.`concept_set` = 460) and (`arv_drug_concepts`.`concept_id` = `drug`.`concept_id`)))) union select `obs`.`patient_id` AS `patient_id`,`obs`.`value_datetime` AS `value_datetime`,`obs`.`value_coded` AS `value_coded` from `obs` where ((`obs`.`concept_id` = 28) and (`obs`.`voided` = 0)) union select `obs`.`patient_id` AS `patient_id`,`obs`.`obs_datetime` AS `obs_datetime`,325 AS `325` from `obs` where ((`obs`.`concept_id` = 372) and (`obs`.`value_coded` <> 3) and (`obs`.`voided` = 0)) union select `obs`.`patient_id` AS `patient_id`,`obs`.`obs_datetime` AS `obs_datetime`,386 AS `386` from `obs` where ((`obs`.`concept_id` = 367) and (`obs`.`value_coded` <> 3) and (`obs`.`voided` = 0)) union select `patient_default_dates`.`patient_id` AS `patient_id`,`patient_default_dates`.`default_date` AS `default_date`,373 AS `373` from `patient_default_dates` union select `patient`.`patient_id` AS `patient_id`,`patient`.`death_date` AS `death_date`,322 AS `322` from `patient` where (`patient`.`death_date` is not null) */;

--
-- Final view structure for view `patient_prescriptions`
--

/*!50001 DROP TABLE IF EXISTS `patient_prescriptions`*/;
/*!50001 DROP VIEW IF EXISTS `patient_prescriptions`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `patient_prescriptions` AS select `encounter`.`patient_id` AS `patient_id`,`encounter`.`encounter_id` AS `encounter_id`,`prescribed_dose`.`obs_datetime` AS `prescription_datetime`,`prescribed_dose`.`value_drug` AS `drug_id`,`prescribed_dose`.`value_text` AS `frequency`,`prescribed_dose`.`value_numeric` AS `dose_amount`,`prescribed_time_period`.`value_text` AS `time_period`,(`prescribed_dose`.`value_numeric` * (`prescription_time_periods`.`time_period_days` / `prescription_frequencies`.`frequency_days`)) AS `quantity`,(`prescribed_dose`.`value_numeric` / `prescription_frequencies`.`frequency_days`) AS `daily_consumption` from ((((`encounter` join `obs` `prescribed_dose` on(((`prescribed_dose`.`concept_id` = 375) and (`prescribed_dose`.`encounter_id` = `encounter`.`encounter_id`) and (`prescribed_dose`.`value_drug` is not null) and (`prescribed_dose`.`voided` = 0)))) join `obs` `prescribed_time_period` on(((`prescribed_time_period`.`concept_id` = 345) and (`prescribed_time_period`.`encounter_id` = `encounter`.`encounter_id`) and (`prescribed_time_period`.`voided` = 0)))) join `prescription_frequencies` on((`prescription_frequencies`.`frequency` = `prescribed_dose`.`value_text`))) join `prescription_time_periods` on((`prescription_time_periods`.`time_period` = `prescribed_time_period`.`value_text`))) where (`encounter`.`encounter_type` = 2) */;

--
-- Final view structure for view `patient_regimen_ingredients`
--

/*!50001 DROP TABLE IF EXISTS `patient_regimen_ingredients`*/;
/*!50001 DROP VIEW IF EXISTS `patient_regimen_ingredients`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `patient_regimen_ingredients` AS select `regimen_ingredient`.`ingredient_id` AS `ingredient_concept_id`,`regimen_ingredient`.`concept_id` AS `regimen_concept_id`,`encounter`.`patient_id` AS `patient_id`,`encounter`.`encounter_id` AS `encounter_id`,`encounter`.`encounter_datetime` AS `dispensed_date` from ((((((`encounter` join `orders` on(((`orders`.`encounter_id` = `encounter`.`encounter_id`) and (`orders`.`voided` = 0)))) join `drug_order` on((`drug_order`.`order_id` = `orders`.`order_id`))) join `drug` on((`drug_order`.`drug_inventory_id` = `drug`.`drug_id`))) join `drug_ingredient` `dispensed_ingredient` on((`drug`.`concept_id` = `dispensed_ingredient`.`concept_id`))) join `drug_ingredient` `regimen_ingredient` on((`regimen_ingredient`.`ingredient_id` = `dispensed_ingredient`.`ingredient_id`))) join `concept` `regimen_concept` on((`regimen_ingredient`.`concept_id` = `regimen_concept`.`concept_id`))) where ((`encounter`.`encounter_type` = 3) and (`regimen_concept`.`class_id` = 18) and (`orders`.`voided` = 0)) group by `encounter`.`encounter_id`,`regimen_ingredient`.`concept_id`,`regimen_ingredient`.`ingredient_id` */;

--
-- Final view structure for view `patient_regimens`
--

/*!50001 DROP TABLE IF EXISTS `patient_regimens`*/;
/*!50001 DROP VIEW IF EXISTS `patient_regimens`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `patient_regimens` AS select `patient_regimen_ingredients`.`regimen_concept_id` AS `regimen_concept_id`,`patient_regimen_ingredients`.`patient_id` AS `patient_id`,`patient_regimen_ingredients`.`encounter_id` AS `encounter_id`,`patient_regimen_ingredients`.`dispensed_date` AS `dispensed_date` from `patient_regimen_ingredients` group by `patient_regimen_ingredients`.`encounter_id`,`patient_regimen_ingredients`.`regimen_concept_id` having (count(0) = (select count(0) AS `count(*)` from `drug_ingredient` where (`drug_ingredient`.`concept_id` = `patient_regimen_ingredients`.`regimen_concept_id`))) */;

--
-- Final view structure for view `patient_registration_dates`
--

/*!50001 DROP TABLE IF EXISTS `patient_registration_dates`*/;
/*!50001 DROP VIEW IF EXISTS `patient_registration_dates`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `patient_registration_dates` AS select `encounter`.`patient_id` AS `patient_id`,`encounter`.`location_id` AS `location_id`,min(`encounter`.`encounter_datetime`) AS `registration_date` from ((((`encounter` join `orders` on(((`orders`.`encounter_id` = `encounter`.`encounter_id`) and (`orders`.`voided` = 0)))) join `drug_order` on((`drug_order`.`order_id` = `orders`.`order_id`))) join `drug` on((`drug_order`.`drug_inventory_id` = `drug`.`drug_id`))) join `concept_set` `arv_drug_concepts` on(((`arv_drug_concepts`.`concept_set` = 460) and (`arv_drug_concepts`.`concept_id` = `drug`.`concept_id`)))) where (`encounter`.`encounter_type` = 3) group by `encounter`.`patient_id`,`encounter`.`location_id` */;

--
-- Final view structure for view `patient_start_dates`
--

/*!50001 DROP TABLE IF EXISTS `patient_start_dates`*/;
/*!50001 DROP VIEW IF EXISTS `patient_start_dates`*/;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `patient_start_dates` AS select `patient_dispensations_and_initiation_dates`.`patient_id` AS `patient_id`,min(`patient_dispensations_and_initiation_dates`.`start_date`) AS `start_date`,(((year(`patient_dispensations_and_initiation_dates`.`start_date`) - year(`patient`.`birthdate`)) + if((((month(`patient_dispensations_and_initiation_dates`.`start_date`) - month(`patient`.`birthdate`)) + if(((dayofmonth(`patient_dispensations_and_initiation_dates`.`start_date`) - dayofmonth(`patient`.`birthdate`)) < 0),-(1),0)) < 0),-(1),0)) + if(((`patient`.`birthdate_estimated` = 1) and (month(`patient`.`birthdate`) = 7) and (dayofmonth(`patient`.`birthdate`) = 1) and (month(`patient_dispensations_and_initiation_dates`.`start_date`) < month(`patient`.`birthdate`))),1,0)) AS `age_at_initiation` from (`patient_dispensations_and_initiation_dates` join `patient` on((`patient`.`patient_id` = `patient_dispensations_and_initiation_dates`.`patient_id`))) group by `patient_dispensations_and_initiation_dates`.`patient_id` */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2008-10-05 10:14:37

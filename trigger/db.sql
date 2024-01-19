-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : ven. 19 jan. 2024 à 09:04
-- Version du serveur : 8.2.0
-- Version de PHP : 8.2.13

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `trampo`
--

-- --------------------------------------------------------

--
-- Structure de la table `client`
--

DROP TABLE IF EXISTS `client`;
CREATE TABLE IF NOT EXISTS `client` (
  `CLI_CODE` int NOT NULL,
  `CLI_REGION` varchar(3) NOT NULL,
  `CLI_NOM` varchar(50) DEFAULT NULL,
  `CLI_RUE` varchar(50) DEFAULT NULL,
  `CLI_VILLE` varchar(50) DEFAULT NULL,
  `CLI_COPOS` varchar(15) DEFAULT NULL,
  `CLI_PAYS` varchar(3) DEFAULT NULL,
  PRIMARY KEY (`CLI_CODE`),
  KEY `FK_CLI_REGION` (`CLI_REGION`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `client`
--

INSERT INTO `client` (`CLI_CODE`, `CLI_REGION`, `CLI_NOM`, `CLI_RUE`, `CLI_VILLE`, `CLI_COPOS`, `CLI_PAYS`) VALUES
(1, 'R01', 'Decathlon Mondeville', 'rue de Paris', 'Mondeville', '14123', 'FR'),
(2, 'R02', 'Decathlon Lisieux', 'rue de Tourville', 'Lisieux', '14525', 'FR'),
(3, 'R01', 'Intersport Caen', 'ZAC Mondeville 2', 'Caen', '14000', 'FR'),
(4, 'R02', 'Delmas Roger', 'rue des pivoines', 'Honfleur', '14120', 'FR'),
(13, 'R01', 'Bois Expo', 'rue des martyres', 'Colombelles', '14222', 'FR');

-- --------------------------------------------------------

--
-- Structure de la table `commande`
--

DROP TABLE IF EXISTS `commande`;
CREATE TABLE IF NOT EXISTS `commande` (
  `COM_CODE` int NOT NULL AUTO_INCREMENT,
  `COM_CLIENT` int NOT NULL,
  `COM_DATE` date DEFAULT NULL,
  `COM_USER` varchar(70) DEFAULT NULL,
  `COM_ETAT` enum('0','1') NOT NULL DEFAULT '0',
  PRIMARY KEY (`COM_CODE`),
  KEY `FK_COM_CLIENT` (`COM_CLIENT`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `commande`
--

INSERT INTO `commande` (`COM_CODE`, `COM_CLIENT`, `COM_DATE`, `COM_USER`, `COM_ETAT`) VALUES
(1, 1, '2023-02-17', NULL, '0'),
(2, 1, '2023-02-19', NULL, '0'),
(3, 4, '2023-02-23', NULL, '0'),
(4, 2, '2023-02-28', NULL, '0');

--
-- Déclencheurs `commande`
--
DROP TRIGGER IF EXISTS `SuppCommandeCascade`;
DELIMITER $$
CREATE TRIGGER `SuppCommandeCascade` BEFORE DELETE ON `commande` FOR EACH ROW BEGIN
    DELETE FROM `ligcde` WHERE `LIG_COMMANDE` = OLD.`COM_CODE`;
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `commande_complete_data`;
DELIMITER $$
CREATE TRIGGER `commande_complete_data` BEFORE INSERT ON `commande` FOR EACH ROW BEGIN
	DECLARE util varchar(70);
	SELECT USER() INTO util;
	SET NEW.COM_DATE = SYSDATE() , NEW.COM_USER=util;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `ligcde`
--

DROP TABLE IF EXISTS `ligcde`;
CREATE TABLE IF NOT EXISTS `ligcde` (
  `LIG_COMMANDE` int NOT NULL,
  `LIG_PRODUIT` varchar(8) NOT NULL,
  `LIG_QTE` float(4,0) DEFAULT NULL,
  PRIMARY KEY (`LIG_COMMANDE`,`LIG_PRODUIT`),
  KEY `FK_LIG_PRODUIT` (`LIG_PRODUIT`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `ligcde`
--

INSERT INTO `ligcde` (`LIG_COMMANDE`, `LIG_PRODUIT`, `LIG_QTE`) VALUES
(1, 'TP01', 5),
(1, 'TP02', 1),
(1, 'TP03', 10),
(2, 'TP01', 10),
(2, 'TP02', 10),
(3, 'TP01', 1),
(4, 'TP01', 20),
(4, 'TP02', 12);

-- --------------------------------------------------------

--
-- Structure de la table `produit`
--

DROP TABLE IF EXISTS `produit`;
CREATE TABLE IF NOT EXISTS `produit` (
  `PRO_CODE` varchar(8) NOT NULL,
  `PRO_DESIGN` varchar(50) DEFAULT NULL,
  `PRO_PRIX` float(10,2) DEFAULT NULL,
  PRIMARY KEY (`PRO_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `produit`
--

INSERT INTO `produit` (`PRO_CODE`, `PRO_DESIGN`, `PRO_PRIX`) VALUES
('TP01', 'Trampo Economique', 249.00),
('TP02', 'Trampo Intermédiaire', 365.00),
('TP03', 'Trampo Luxe', 452.00),
('TP04', 'Trampo Occasion', 225.00);

--
-- Déclencheurs `produit`
--
DROP TRIGGER IF EXISTS `aftMajPrix`;
DELIMITER $$
CREATE TRIGGER `aftMajPrix` AFTER UPDATE ON `produit` FOR EACH ROW BEGIN
    IF NEW.PRO_PRIX <= OLD.PRO_PRIX THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Le nouveau prix ne peut pas être inférieur ou égal à l ancien prix.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `region`
--

DROP TABLE IF EXISTS `region`;
CREATE TABLE IF NOT EXISTS `region` (
  `REG_CODE` varchar(3) NOT NULL,
  `REG_RESPONSABLE` int NOT NULL,
  `REG_LIVRAISON` varchar(5) NOT NULL,
  `REG_NOM` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`REG_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Déchargement des données de la table `region`
--

INSERT INTO `region` (`REG_CODE`, `REG_RESPONSABLE`, `REG_LIVRAISON`, `REG_NOM`) VALUES
('R01', 4, 'TP', 'Agglo Caen'),
('R02', 5, 'TP', 'Agglo Lisieux'),
('R03', 5, 'NORMA', 'Agglo Evreux');

-- --------------------------------------------------------

--
-- Structure de la table `stat_util`
--

DROP TABLE IF EXISTS `stat_util`;
CREATE TABLE IF NOT EXISTS `stat_util` (
  `utilisateur` varchar(70) NOT NULL,
  `nbUtil` int DEFAULT NULL,
  PRIMARY KEY (`utilisateur`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `client`
--
ALTER TABLE `client`
  ADD CONSTRAINT `FK_CLI_REGION` FOREIGN KEY (`CLI_REGION`) REFERENCES `region` (`REG_CODE`);

--
-- Contraintes pour la table `commande`
--
ALTER TABLE `commande`
  ADD CONSTRAINT `FK_COM_CLIENT` FOREIGN KEY (`COM_CLIENT`) REFERENCES `client` (`CLI_CODE`);

--
-- Contraintes pour la table `ligcde`
--
ALTER TABLE `ligcde`
  ADD CONSTRAINT `FK_LIG_COMMANDE` FOREIGN KEY (`LIG_COMMANDE`) REFERENCES `commande` (`COM_CODE`),
  ADD CONSTRAINT `FK_LIG_PRODUIT` FOREIGN KEY (`LIG_PRODUIT`) REFERENCES `produit` (`PRO_CODE`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

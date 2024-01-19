
ALTER TABLE commande
ADD (COM_USER varchar(70));

CREATE TRIGGER commande_complete_data
BEFORE INSERT ON commande FOR EACH ROW
BEGIN
	DECLARE util varchar(70);
	SELECT USER() INTO util;
	SET NEW.COM_DATE = SYSDATE() , NEW.COM_USER=util;
END;

DROP TABLE IF EXISTS `stat_util`;
CREATE TABLE IF NOT EXISTS `stat_util` (
  `utilisateur` varchar(70) PRIMARY KEY ,
  `nbUtil` int(11)
) ENGINE=INNODB ;

-- Création de la table stat_util

DROP TABLE IF EXISTS `stat_util`;
CREATE TABLE IF NOT EXISTS `stat_util` (
  `utilisateur` varchar(70) PRIMARY KEY ,
  `nbUtil` int(11)
) ENGINE=INNODB ;

-- Création du trigger af_ins_commandes

DELIMITER //	 
CREATE OR REPLACE TRIGGER 'af_ins_commandes';
AFTER INSERT ON commande FOR EACH ROW
BEGIN


	DECLARE vNombre integer;
	select nbUtil into vNombre  from stat_util where utilisateur = new.com_user;
  
	IF vNombre >=1 THEN
		update stat_util
		set nbUtil=vNombre+1
		where utilisateur = new.com_user;
	ELSE
		insert into stat_util (utilisateur, nbUtil) values (new.com_user, 1 );	  
	END IF;


END
DELIMITER ;

--  Créer un trigger nommé aftMajPrix permettant de mettre à jour le prix du produit. 
-- Si celui ci est inférieur ou égal à l'ancien prix alors un message d'erreur s'affichera.


DELIMITER //	

CREATE TRIGGER `aftMajPrix` AFTER UPDATE ON `produit` FOR EACH ROW
BEGIN
    IF NEW.PRO_PRIX <= OLD.PRO_PRIX THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Le nouveau prix ne peut pas être inférieur ou égal à l ancien prix.';
    END IF;
END //

DELIMITER ;

-- Créer un trigger nommé SuppCommandeCascade qui supprime les enregistrements de la table
-- ligne_commande (LIGCDE) relatif à une commande avant de supprimer cette même commande 
-- (reproduction de la suppression en cascade).

DELIMITER //

CREATE TRIGGER `SuppCommandeCascade` BEFORE DELETE ON `commande` FOR EACH ROW
BEGIN
    DELETE FROM `ligcde` WHERE `LIG_COMMANDE` = OLD.`COM_CODE`;
END //

DELIMITER ;

-- Ajouter le champ COM_ETAT dans la table commande. 
-- Ce champ est destiné à savoir si la commande est payée ou non (0=non payée, 1= payée).
-- Créer un trigger nommé verifImpayes qui envoie un message d'erreur si un client
-- passe une nouvelle commande et qu'il a déjà au moins 2 commandes en cours impayées.


CREATE TRIGGER verifImpayes 
BEFORE INSERT ON commande FOR EACH ROW
BEGIN 
    DECLARE nbImpayes int;
    SELECT COUNT(*) INTO nbImpayes
    FROM commande 
    WHERE COM_CLIENT=NEW.COM_CLIENT AND COM_ETAT=0;

    IF nbImpayes >= 2 THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Le client a deja au moins 2 commandes impayées. Nouvelle commande non autorisée.';
    END IF; 
END 


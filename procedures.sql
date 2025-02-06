CREATE PROCEDURE InsertCategorie(IN p_nom VARCHAR(255), IN p_description TEXT)
BEGIN
    INSERT INTO categorie (nom, description) VALUES (p_nom, p_description);
END;

CREATE PROCEDURE GetCategories()
BEGIN
    SELECT * FROM categorie;
END;

CREATE PROCEDURE UpdateCategorie(IN p_id INT, IN p_nom VARCHAR(255), IN p_description TEXT)
BEGIN
    UPDATE categorie SET nom = p_nom, description = p_description WHERE id = p_id;
END;

CREATE PROCEDURE DeleteCategorie(IN p_id INT)
BEGIN
    DELETE FROM categorie WHERE id = p_id;
END;

CREATE PROCEDURE InsertFournisseur(IN p_nom VARCHAR(255), IN p_adresse TEXT, IN p_telephone VARCHAR(20), IN p_email VARCHAR(255))
BEGIN
    INSERT INTO fournisseur (nom, adresse, telephone, email) VALUES (p_nom, p_adresse, p_telephone, p_email);
END;

CREATE PROCEDURE GetFournisseurs()
BEGIN
    SELECT * FROM fournisseur;
END;

CREATE PROCEDURE InsertProduit(IN p_reference VARCHAR(255), IN p_nom VARCHAR(255), IN p_prix_unitaire DECIMAL(10,2), IN p_quantite_stock INT, IN p_categorie_id INT)
BEGIN
    INSERT INTO produit (reference, nom, prix_unitaire, quantite_stock, categorie_id) VALUES (p_reference, p_nom, p_prix_unitaire, p_quantite_stock, p_categorie_id);
END;

CREATE PROCEDURE GetProduits()
BEGIN
    SELECT p.*, c.nom as categorie_nom FROM produit p LEFT JOIN categorie c ON p.categorie_id = c.id;
END;

CREATE PROCEDURE UpdateProduit(IN p_id INT, IN p_reference VARCHAR(255), IN p_nom VARCHAR(255), IN p_prix_unitaire DECIMAL(10,2), IN p_quantite_stock INT, IN p_categorie_id INT)
BEGIN
    UPDATE produit SET reference = p_reference, nom = p_nom, prix_unitaire = p_prix_unitaire, quantite_stock = p_quantite_stock, categorie_id = p_categorie_id WHERE id = p_id;
END;

CREATE PROCEDURE DeleteProduit(IN p_id INT)
BEGIN
    DELETE FROM produit WHERE id = p_id;
END;

CREATE PROCEDURE InsertClient(IN p_nom VARCHAR(255), IN p_adresse TEXT, IN p_telephone VARCHAR(20), IN p_email VARCHAR(255))
BEGIN
    INSERT INTO client (nom, adresse, telephone, email) VALUES (p_nom, p_adresse, p_telephone, p_email);
END;

CREATE PROCEDURE GetClients()
BEGIN
    SELECT * FROM client;
END;

CREATE PROCEDURE InsertCommande(IN p_client_id INT, OUT p_commande_id INT)
BEGIN
    INSERT INTO commande (client_id) VALUES (p_client_id);
    SET p_commande_id = LAST_INSERT_ID();
END;

CREATE PROCEDURE InsertLigneCommande(IN p_commande_id INT, IN p_produit_id INT, IN p_quantite INT, IN p_prix_unitaire DECIMAL(10,2))
BEGIN
    INSERT INTO ligne_commande (commande_id, produit_id, quantite, prix_unitaire) VALUES (p_commande_id, p_produit_id, p_quantite, p_prix_unitaire);
END;

CREATE PROCEDURE UpdateMontantTotalCommande(IN p_commande_id INT)
BEGIN
    UPDATE commande SET montant_total = (SELECT SUM(quantite * prix_unitaire) FROM ligne_commande WHERE commande_id = p_commande_id) WHERE id = p_commande_id;
END;

CREATE PROCEDURE GetCommandes()
BEGIN
    SELECT c.*, cl.nom as client_nom FROM commande c JOIN client cl ON c.client_id = cl.id;
END;

CREATE PROCEDURE GetLignesCommande(IN p_commande_id INT)
BEGIN
    SELECT lc.*, p.nom as produit_nom FROM ligne_commande lc JOIN produit p ON lc.produit_id = p.id WHERE lc.commande_id = p_commande_id;
END;

CREATE PROCEDURE UpdateCommandeStatut(IN p_id INT, IN p_statut VARCHAR(50))
BEGIN
    UPDATE commande SET statut = p_statut WHERE id = p_id;
END;

CREATE PROCEDURE InsertProduitFournisseur(IN p_produit_id INT, IN p_fournisseur_id INT, IN p_prix_achat DECIMAL(10,2))
BEGIN
    INSERT INTO produit_fournisseur (produit_id, fournisseur_id, prix_achat) VALUES (p_produit_id, p_fournisseur_id, p_prix_achat);
END;

CREATE PROCEDURE GetProduitFournisseur()
BEGIN
    SELECT pf.*, p.nom as produit_nom, f.nom as fournisseur_nom FROM produit_fournisseur pf JOIN produit p ON pf.produit_id = p.id JOIN fournisseur f ON pf.fournisseur_id = f.id;
END;

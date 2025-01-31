-- Insertion des catégories
INSERT INTO categorie (nom, description) VALUES
('Avions civils', 'Maquettes d''avions de ligne et privés'),
('Avions militaires', 'Maquettes d''avions de combat et militaires'),
('Avions vintage', 'Maquettes d''avions historiques');

-- Insertion des fournisseurs
INSERT INTO fournisseur (nom, adresse, telephone, email) VALUES
('PaperCraft Pro', '123 rue des Artisans, Paris', '0123456789', 'contact@papercraft.com'),
('AirModel', '456 avenue de l''Aviation, Lyon', '0987654321', 'info@airmodel.fr'),
('Maquettes Plus', '789 boulevard du Commerce, Marseille', '0567891234', 'ventes@maquettesplus.fr');

-- Insertion des produits
INSERT INTO produit (reference, nom, prix_unitaire, quantite_stock, categorie_id) VALUES
('AC001', 'Airbus A380', 29.99, 50, 1),
('AC002', 'Boeing 747', 24.99, 45, 1),
('AM001', 'F-16 Fighting Falcon', 19.99, 30, 2),
('AM002', 'Rafale', 22.99, 25, 2),
('AV001', 'Spitfire', 18.99, 20, 3),
('AV002', 'P-51 Mustang', 17.99, 15, 3);

-- Liaison produits-fournisseurs
INSERT INTO produit_fournisseur (produit_id, fournisseur_id, prix_achat) VALUES
(1, 1, 15.00),
(1, 2, 14.50),
(2, 1, 12.50),
(3, 2, 10.00),
(4, 3, 11.50),
(5, 3, 9.00),
(6, 2, 8.50);

-- Insertion des clients
INSERT INTO client (nom, adresse, telephone, email) VALUES
('Jean Dupont', '12 rue de la Paix, Paris', '0123456789', 'jean.dupont@email.com'),
('Marie Martin', '34 avenue des Fleurs, Lyon', '0987654321', 'marie.martin@email.com'),
('Pierre Durant', '56 boulevard du Port, Marseille', '0567891234', 'pierre.durant@email.com');

-- Insertion des commandes
INSERT INTO commande (date_commande, statut, client_id) VALUES
('2024-01-15 10:00:00', 'livree', 1),
('2024-01-20 14:30:00', 'en_preparation', 2),
('2024-01-25 16:45:00', 'validee', 3);

-- Insertion des lignes de commandes
INSERT INTO ligne_commande (commande_id, produit_id, quantite, prix_unitaire) VALUES
(1, 1, 2, 29.99),
(1, 3, 1, 19.99),
(2, 2, 1, 24.99),
(2, 4, 2, 22.99),
(3, 5, 1, 18.99),
(3, 6, 3, 17.99);

-- Mise à jour des montants totaux des commandes
UPDATE commande c
SET montant_total = (
    SELECT SUM(quantite * prix_unitaire)
    FROM ligne_commande
    WHERE commande_id = c.id
);
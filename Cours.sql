-- Création de la base de données
DROP DATABASE IF EXISTS Jass_schema;    
CREATE DATABASE Jass_schema;
USE Jass_schema;

-- Table CATEGORIE
CREATE TABLE categorie (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table FOURNISSEUR
CREATE TABLE fournisseur (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    adresse TEXT,
    telephone VARCHAR(20),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table PRODUIT
CREATE TABLE produit (
    id INT PRIMARY KEY AUTO_INCREMENT,
    reference VARCHAR(50) NOT NULL UNIQUE,
    nom VARCHAR(100) NOT NULL,
    prix_unitaire DECIMAL(10,2) NOT NULL,
    quantite_stock INT NOT NULL DEFAULT 0,
    categorie_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (categorie_id) REFERENCES categorie(id),
    CHECK (prix_unitaire >= 0),
    CHECK (quantite_stock >= 0)
);

-- Table de liaison PRODUIT_FOURNISSEUR
CREATE TABLE produit_fournisseur (
    produit_id INT,
    fournisseur_id INT,
    prix_achat DECIMAL(10,2),
    PRIMARY KEY (produit_id, fournisseur_id),
    FOREIGN KEY (produit_id) REFERENCES produit(id),
    FOREIGN KEY (fournisseur_id) REFERENCES fournisseur(id)
);

-- Table CLIENT
CREATE TABLE client (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    adresse TEXT,
    telephone VARCHAR(20),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table COMMANDE
CREATE TABLE commande (
    id INT PRIMARY KEY AUTO_INCREMENT,
    date_commande DATETIME DEFAULT CURRENT_TIMESTAMP,
    statut ENUM('en_attente', 'validee', 'en_preparation', 'expediee', 'livree', 'annulee') DEFAULT 'en_attente',
    montant_total DECIMAL(10,2) DEFAULT 0,
    client_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES client(id)
);

-- Table LIGNE_COMMANDE
CREATE TABLE ligne_commande (
    id INT PRIMARY KEY AUTO_INCREMENT,
    commande_id INT NOT NULL,
    produit_id INT NOT NULL,
    quantite INT NOT NULL,
    prix_unitaire DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (commande_id) REFERENCES commande(id),
    FOREIGN KEY (produit_id) REFERENCES produit(id),
    CHECK (quantite > 0),
    CHECK (prix_unitaire >= 0)
);

-- Index pour optimiser les recherches fréquentes
CREATE INDEX idx_produit_reference ON produit(reference);
CREATE INDEX idx_commande_date ON commande(date_commande);
CREATE INDEX idx_commande_client ON commande(client_id);
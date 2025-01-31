require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');
const fs = require('fs');

const app = express();
app.use(express.json());

const dbConfig = {
    host: 'localhost',
    user: 'root',
    password: 'Jassim93420',
    multipleStatements: true
};

port = process.env.PORT || 3000;

const executeSQLFile = async (connection, filePath) => {
    const sql = fs.readFileSync(filePath, 'utf8');
    await connection.query(sql);
    console.log(`${filePath} exécuté avec succès`);
};

const initDB = async () => {
    try {
        const connection = await mysql.createConnection(dbConfig);
        console.log('Connexion à MySQL réussie');

        await executeSQLFile(connection, 'Cours.sql');

        await connection.changeUser({ database: 'Jass_schema' });

        await executeSQLFile(connection, 'data.sql');

        console.log('Base de données initialisée avec succès');
        return connection;
    } catch (err) {
        console.error('Erreur lors de l\'initialisation de la base de données :', err);
        process.exit(1);
    }
};

initDB().then(connection => {
    app.get('/', (req, res) => {
        res.send('Hello World');
    })
    // Routes CATEGORIE
    app.post('/categories', async (req, res) => {
        const { nom, description } = req.body;
        const sql = 'INSERT INTO categorie (nom, description) VALUES (?, ?)';
        await connection.query(sql, [nom, description]);
        res.status(201).json({ message: 'Catégorie ajoutée avec succès' });
    });

    app.get('/categories', async (req, res) => {
        const [result] = await connection.query('SELECT * FROM categorie');
        res.json(result);
    });

    app.get('/categories/injection', async (req, res) => {
        const [result] = await connection.query(`SELECT * FROM categorie WHERE nom='${req.query.nom}'`);
        res.json(result);
    });

    // Routes FOURNISSEUR
    app.post('/fournisseurs', async (req, res) => {
        const { nom, adresse, telephone, email } = req.body;
        const sql = 'INSERT INTO fournisseur (nom, adresse, telephone, email) VALUES (?, ?, ?, ?)';
        await connection.query(sql, [nom, adresse, telephone, email]);
        res.status(201).json({ message: 'Fournisseur ajouté avec succès' });
    });

    app.get('/fournisseurs', async (req, res) => {
        const [result] = await connection.query('SELECT * FROM fournisseur');
        res.json(result);
    });

    // Routes PRODUIT
    app.post('/produits', async (req, res) => {
        const { reference, nom, prix_unitaire, quantite_stock, categorie_id } = req.body;
        const sql = 'INSERT INTO produit (reference, nom, prix_unitaire, quantite_stock, categorie_id) VALUES (?, ?, ?, ?, ?)';
        await connection.query(sql, [reference, nom, prix_unitaire, quantite_stock, categorie_id]);
        res.status(201).json({ message: 'Produit ajouté avec succès' });
    });

    app.get('/produits', async (req, res) => {
        const [result] = await connection.query(
            'SELECT p.*, c.nom as categorie_nom FROM produit p LEFT JOIN categorie c ON p.categorie_id = c.id'
        );
        res.json(result);
    });

    app.put('/produits/:id', async (req, res) => {
        const { reference, nom, prix_unitaire, quantite_stock, categorie_id } = req.body;
        const sql = 'UPDATE produit SET reference = ?, nom = ?, prix_unitaire = ?, quantite_stock = ?, categorie_id = ? WHERE id = ?';
        await connection.query(sql, [reference, nom, prix_unitaire, quantite_stock, categorie_id, req.params.id]);
        res.json({ message: 'Produit mis à jour avec succès' });
    });

    app.delete('/produits/:id', async (req, res) => {
        await connection.query('DELETE FROM produit WHERE id = ?', [req.params.id]);
        res.json({ message: 'Produit supprimé avec succès' });
    });

    // Routes CLIENT
    app.post('/clients', async (req, res) => {
        const { nom, adresse, telephone, email } = req.body;
        const sql = 'INSERT INTO client (nom, adresse, telephone, email) VALUES (?, ?, ?, ?)';
        await connection.query(sql, [nom, adresse, telephone, email]);
        res.status(201).json({ message: 'Client ajouté avec succès' });
    });

    app.get('/clients', async (req, res) => {
        const [result] = await connection.query('SELECT * FROM client');
        res.json(result);
    });

    // Routes COMMANDE
    app.post('/commandes', async (req, res) => {
        try {
            await connection.beginTransaction();
            
            const { client_id, lignes } = req.body;
            const [commande] = await connection.query(
                'INSERT INTO commande (client_id) VALUES (?)',
                [client_id]
            );
            
            for (const ligne of lignes) {
                await connection.query(
                    'INSERT INTO ligne_commande (commande_id, produit_id, quantite, prix_unitaire) VALUES (?, ?, ?, ?)',
                    [commande.insertId, ligne.produit_id, ligne.quantite, ligne.prix_unitaire]
                );
            }

            await connection.query(
                `UPDATE commande c 
                SET montant_total = (
                    SELECT SUM(quantite * prix_unitaire) 
                    FROM ligne_commande 
                    WHERE commande_id = c.id
                ) 
                WHERE id = ?`,
                [commande.insertId]
            );

            await connection.commit();
            res.status(201).json({ message: 'Commande créée avec succès', id: commande.insertId });
        } catch (error) {
            await connection.rollback();
            res.status(500).json({ error: error.message });
        }
    });

    app.get('/commandes', async (req, res) => {
        const [commandes] = await connection.query(
            `SELECT c.*, cl.nom as client_nom 
            FROM commande c 
            JOIN client cl ON c.client_id = cl.id`
        );
        
        for (let commande of commandes) {
            const [lignes] = await connection.query(
                `SELECT lc.*, p.nom as produit_nom 
                FROM ligne_commande lc 
                JOIN produit p ON lc.produit_id = p.id 
                WHERE lc.commande_id = ?`,
                [commande.id]
            );
            commande.lignes = lignes;
        }
        
        res.json(commandes);
    });

    app.put('/commandes/:id/statut', async (req, res) => {
        const { statut } = req.body;
        const sql = 'UPDATE commande SET statut = ? WHERE id = ?';
        await connection.query(sql, [statut, req.params.id]);
        res.json({ message: 'Statut de la commande mis à jour avec succès' });
    });

    // Route PRODUIT_FOURNISSEUR
    app.post('/produit-fournisseur', async (req, res) => {
        const { produit_id, fournisseur_id, prix_achat } = req.body;
        const sql = 'INSERT INTO produit_fournisseur (produit_id, fournisseur_id, prix_achat) VALUES (?, ?, ?)';
        await connection.query(sql, [produit_id, fournisseur_id, prix_achat]);
        res.status(201).json({ message: 'Relation produit-fournisseur ajoutée avec succès' });
    });

    app.get('/produit-fournisseur', async (req, res) => {
        const [result] = await connection.query(
            `SELECT pf.*, p.nom as produit_nom, f.nom as fournisseur_nom 
            FROM produit_fournisseur pf 
            JOIN produit p ON pf.produit_id = p.id 
            JOIN fournisseur f ON pf.fournisseur_id = f.id`
        );
        res.json(result);
    });

    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
        console.log(`Serveur démarré sur le port http://localhost:${PORT}`);
    });
});
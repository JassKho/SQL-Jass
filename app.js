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

const port = process.env.PORT || 3000;

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
        await executeSQLFile(connection, 'procedures.sql');
        console.log('Base de données et procédures initialisées avec succès');
        return connection;
    } catch (err) {
        console.error('Erreur lors de l\'initialisation de la base de données :', err);
        process.exit(1);
    }
};

initDB().then(connection => {
    app.get('/', (req, res) => {
        res.send('Hello World');
    });

    // Routes CATEGORIE
    app.post('/categories', async (req, res) => {
        const { nom, description } = req.body;
        await connection.query('CALL InsertCategorie(?, ?)', [nom, description]);
        res.status(201).json({ message: 'Catégorie ajoutée avec succès' });
    });

    app.get('/categories', async (req, res) => {
        const [result] = await connection.query('CALL GetCategories()');
        res.json(result[0]);
    });

    // Routes FOURNISSEUR
    app.post('/fournisseurs', async (req, res) => {
        const { nom, adresse, telephone, email } = req.body;
        await connection.query('CALL InsertFournisseur(?, ?, ?, ?)', [nom, adresse, telephone, email]);
        res.status(201).json({ message: 'Fournisseur ajouté avec succès' });
    });

    app.get('/fournisseurs', async (req, res) => {
        const [result] = await connection.query('CALL GetFournisseurs()');
        res.json(result[0]);
    });

    // Routes PRODUIT
    app.post('/produits', async (req, res) => {
        const { reference, nom, prix_unitaire, quantite_stock, categorie_id } = req.body;
        await connection.query('CALL InsertProduit(?, ?, ?, ?, ?)', [reference, nom, prix_unitaire, quantite_stock, categorie_id]);
        res.status(201).json({ message: 'Produit ajouté avec succès' });
    });

    app.get('/produits', async (req, res) => {
        const [result] = await connection.query('CALL GetProduits()');
        res.json(result[0]);
    });

    // Routes CLIENT
    app.post('/clients', async (req, res) => {
        const { nom, adresse, telephone, email } = req.body;
        await connection.query('CALL InsertClient(?, ?, ?, ?)', [nom, adresse, telephone, email]);
        res.status(201).json({ message: 'Client ajouté avec succès' });
    });

    app.get('/clients', async (req, res) => {
        const [result] = await connection.query('CALL GetClients()');
        res.json(result[0]);
    });

    // Routes COMMANDE
    app.post('/commandes', async (req, res) => {
        try {
            await connection.beginTransaction();
            const { client_id, lignes } = req.body;
            const [commandeResult] = await connection.query('CALL InsertCommande(?, @commande_id)', [client_id]);
            const [[{ commande_id }]] = await connection.query('SELECT @commande_id as commande_id');
            
            for (const ligne of lignes) {
                await connection.query('CALL InsertLigneCommande(?, ?, ?, ?)', [commande_id, ligne.produit_id, ligne.quantite, ligne.prix_unitaire]);
            }
            await connection.query('CALL UpdateMontantTotalCommande(?)', [commande_id]);
            await connection.commit();
            res.status(201).json({ message: 'Commande créée avec succès', id: commande_id });
        } catch (error) {
            await connection.rollback();
            res.status(500).json({ error: error.message });
        }
    });

    app.get('/commandes', async (req, res) => {
        const [commandes] = await connection.query('CALL GetCommandes()');
        for (let commande of commandes[0]) {
            const [lignes] = await connection.query('CALL GetLignesCommande(?)', [commande.id]);
            commande.lignes = lignes[0];
        }
        res.json(commandes[0]);
    });

    app.put('/commandes/:id/statut', async (req, res) => {
        const { statut } = req.body;
        await connection.query('CALL UpdateCommandeStatut(?, ?)', [req.params.id, statut]);
        res.json({ message: 'Statut de la commande mis à jour avec succès' });
    });

    // Routes PRODUIT_FOURNISSEUR
    app.post('/produit-fournisseur', async (req, res) => {
        const { produit_id, fournisseur_id, prix_achat } = req.body;
        await connection.query('CALL InsertProduitFournisseur(?, ?, ?)', [produit_id, fournisseur_id, prix_achat]);
        res.status(201).json({ message: 'Relation produit - fournisseur ajoutée avec succès' });
    });

    app.get('/produit-fournisseur', async (req, res) => {
        const [result] = await connection.query('CALL GetProduitFournisseur()');
        res.json(result[0]);
    });

    app.listen(port, () => {
        console.log(`Serveur démarré sur http://localhost:${port}`);
    });
});

const { MongoClient } = require('mongodb');
require('dotenv').config();
const mongodbUri = process.env.MONGODB_URI;
const port = process.env.PORT;

const client = new MongoClient(mongodbUri);

async function connectToMongoDB() {
  try {
    await client.connect();
    console.log(`Conectado ao MongoDB Atlas, na porta ${port}`);

    // escolhe o banco de dados e a coleção
    const db = client.db("CarHunters"); //nome do bd
    const collection = db.collection("usuarios"); // colecao

    // Aqui pode colocar as operações que vai fazer no banco
    

    // Encerre a conexão depois que terminar de mexer no banco
    await client.close();
  } catch (err) {
    console.error("Erro ao conectar ao MongoDB Atlas:", err);
  }
}

connectToMongoDB();

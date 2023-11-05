require('dotenv').config();
const { MongoClient } = require('mongodb');
const express = require('express');
const cors = require('cors');
const app = express();
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const functions = require('firebase-functions');
const admin = require('firebase-admin');



const mongodbUri = process.env.MONGODB_URI;
const jwtSecret = process.env.JWT_SECRET;
const port = process.env.PORT;
const allowedOrigin = process.env.ALLOWED_ORIGIN || '*';
const serviceAccount = require('./chave-privada.json');

app.use(cors({
  origin: allowedOrigin,
  methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
  credentials: true,
}));
app.use(express.json());

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://carhunters.firebaseio.com',
});

if (admin.apps.length > 0) {
  console.log('Conectado ao Firebase');
} else {
  console.log('Não conectado ao Firebase');
}

const client = new MongoClient(mongodbUri);

// Conexão ao MongoDB
async function connectToMongoDB() {
  try {
    await client.connect();
    console.log('Conectado ao MongoDB Atlas');


    // CADASTRO

    //Cadastro de usuarios (no firebase)
    async function createUserInFirebase(email, senha) {
      try {
        // Crie o usuário no Firebase Authentication
        const userRecord = await admin.auth().createUser({
          email: email,
          password: senha,
        });
    
        return userRecord;
      } catch (error) {
        throw error;
      }
    }

    // Cadastro de usuários(no mongo)
    app.post('/users', async (req, res) => {
      const { nome, email, senha } = req.body;
    
      const db = client.db('erapraseropi');
      const collection = db.collection('usuarios');

      const user = { nome, email };
      const resultado = await collection.insertOne(user);
      console.log('Usuário cadastrado com sucesso:', resultado.insertedId);

       try {
    await createUserInFirebase(email, senha);
    console.log('Usuário criado com sucesso no Firebase');
    res.status(201).json({ message: 'Usuário cadastrado com sucesso' });
  } catch (error) {
    console.error('Erro ao criar usuário no Firebase:', error);
    // Lide com o erro, se necessário
    res.status(500).json({ message: 'Erro ao criar usuário no Firebase' });
  }
});

   


// Função para criar token de autenticação
function criarTokenDeAutenticacao(usuario) {
  const payload = {
    id: usuario._id,
    senha: usuario.senha,
  };
  const token = jwt.sign(payload, jwtSecret, { expiresIn: '1h' });
  return token;
}

    // Login
app.post('/login', async (req, res) => {
  const { email, senha } = req.body;

  try {
    // Autenticar o usuário no Firebase Authentication
    const user = await admin.auth().getUserByEmail(email);

    // Verificar a senha (pode ser opcional dependendo do seu caso)
    if (user && user.email === email) {
      // Agora, você pode criar um token de autenticação, se necessário
      const token = criarTokenDeAutenticacao(user);
      res.status(200).json({ token });
    } else {
      res.status(401).json({ message: 'Credenciais inválidas' });
    }
  } catch (error) {
    console.error('Erro ao autenticar o usuário no Firebase:', error);
    res.status(500).json({ message: 'Erro ao autenticar o usuário' });
  }
});

    


    





    // Função para excluir um usuário no Firebase Authentication e no MongoDB
    async function deleteFirebaseUser(email) {
      try {
        // Exclua o usuário do Firebase Authentication com base no email
        const userRecord = await admin.auth().getUserByEmail(email);
        await admin.auth().deleteUser(userRecord.uid);
    
        // Exclua o usuário correspondente no MongoDB usando o email
        await collection.deleteOne({ email });
    
        console.log('Usuário excluído do Firebase Authentication e MongoDB com email:', email);
      } catch (error) {
        console.error('Erro ao excluir usuário do Firebase Authentication e MongoDB:', error);
      }
    }
    

    

    //Função que acompanha o mongo
    async function watchMongoDB() {
      try {
        await connectToMongoDB();
    
        const database = client.db('erapraseropi');
        collection = database.collection('usuarios');
    
        const changeStream = collection.watch();
    
        changeStream.on('change', async (change) => {
          console.log('Alteração no MongoDB:', change);
    
          if (change.operationType === 'insert') {
            const newUser = change.fullDocument;
    
            // Verifique se o documento no MongoDB possui o campo 'email'
            if (newUser.email) {
              // Encontre o usuário correspondente no Firebase Authentication pelo email
              admin.auth().getUserByEmail(newUser.email)
                .then((userRecord) => {
                  // Atualize os detalhes do usuário no MongoDB, se necessário
                  const updateFields = {};
    
                  // Verifique as mudanças no documento do MongoDB e atualize o usuário correspondente no Firebase Authentication
                  if (newUser.email !== userRecord.email) {
                    updateFields.email = newUser.email;
                  }
    
                  // Atualize o usuário, se houver mudanças
                  if (Object.keys(updateFields).length > 0) {
                    return admin.auth().updateUser(userRecord.uid, updateFields);
                  }
                })
                .then(() => {
                  console.log('Usuário atualizado no Firebase Authentication com email:', newUser.email);
                })
                .catch((error) => {
                  console.error('Erro ao atualizar usuário no Firebase Authentication:', error);
                });
            } else {
              // O novo documento não possui um email, criando um novo usuário no Firebase
              createUserInFirebase(newUser.email, newUser.senha)
                .then((userRecord) => {
                  // Atualize o documento no MongoDB com o UID ou email (como preferir)
                  collection.updateOne(
                    { email: newUser.email },
                    { $set: { uid: userRecord.uid } }
                  )
                  .then(() => {
                    console.log('Novo usuário criado no Firebase Authentication e UID registrado no MongoDB:', userRecord);
                  })
                  .catch((error) => {
                    console.error('Erro ao registrar UID no MongoDB:', error);
                  });
                })
                .catch((error) => {
                  console.error('Erro ao criar usuário no Firebase Authentication:', error);
                });
            }
          } else if (change.operationType === 'delete') {
            const deletedUser = change.fullDocument;
    
            if (deletedUser && deletedUser.email) {
              // Exclua o usuário do Firebase Authentication com base no email
              admin.auth().getUserByEmail(deletedUser.email)
                .then((userRecord) => {
                  deleteFirebaseUser(userRecord.uid);
                })
                .catch((error) => {
                  console.error('Erro ao excluir usuário no Firebase Authentication:', error);
                });
            }
          }
        });
      } catch (error) {
        console.error('Erro ao observar o MongoDB:', error);
      }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // Rota de pesquisa no Mercado Livre
    app.get('/pesquisa', async (req, res) => {
      try {
        // Lógica para realizar a pesquisa no Mercado Livre
        // ...
        res.status(200).json({ message: 'Resultados da pesquisa' });
      } catch (err) {
        console.error('Erro ao realizar pesquisa no Mercado Livre:', err);
        res.status(500).json({ message: 'Erro na pesquisa' });
      }
    });

    app.listen(port, () => {
      console.log(`Servidor Node.js rodando na porta ${port}`);
    });
  } catch (err) {
    console.error('Erro ao conectar ao MongoDB Atlas:', err);
  }
}

connectToMongoDB();

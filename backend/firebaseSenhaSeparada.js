// Importe a biblioteca Firebase
const firebase = require('firebase/app');
require('firebase/auth');

// Configure sua aplicação Firebase com as configurações do seu projeto
const firebaseConfig = {
    apiKey: "AIzaSyCWLZYgUkW_50UZnGoKR9lBdxbN8DJT0qs",
    authDomain: "carhunters-2b5e3.firebaseapp.com",
    projectId: "carhunters-2b5e3",
    storageBucket: "carhunters-2b5e3.appspot.com",
    messagingSenderId: "948179322175",
    appId: "1:948179322175:web:c13d2f3b99267b3606bf8a",
    measurementId: "G-R4QZCXPSVT"
  };

// Inicialize a aplicação Firebase
firebase.initializeApp(firebaseConfig);

// Função para fazer login com email e senha
async function signInWithEmailAndPassword(email, password) {
  try {
    const userCredential = await firebase.auth().signInWithEmailAndPassword(email, password);
    const user = userCredential.user;
    return user;
  } catch (error) {
    // Trate erros de autenticação aqui
    console.error('Erro ao fazer login:', error.message);
    throw error;
  }
}

// Função para criar uma nova conta com email e senha
async function createAccountWithEmailAndPassword(email, password) {
  try {
    const userCredential = await firebase.auth().createUserWithEmailAndPassword(email, password);
    const user = userCredential.user;
    return user;
  } catch (error) {
    // Trate erros de criação de conta aqui
    console.error('Erro ao criar conta:', error.message);
    throw error;
  }
}

// Função para fazer logout do usuário atual
function signOut() {
  return firebase.auth().signOut();
}




  
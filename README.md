# CRID - Sistema de Inscrição em Disciplinas

Um sistema descentralizado para gerenciamento de pedidos de inscrição em disciplinas acadêmicas da UFRJ, implementado em Solidity usando blockchain Ethereum.

## Sobre o Projeto

O CRID (Sistema de Inscrição em Disciplinas) é um smart contract que digitaliza e automatiza o processo de inscrição em disciplinas acadêmicas, proporcionando transparência, segurança e eficiência no gerenciamento de pedidos.

## Funcionalidades

### Para Administradores
- Cadastro de estudantes, coordenadores e orientadores
- Cadastro de disciplinas com controle de vagas
- Atualização de dados dos estudantes
- Gerenciamento completo do sistema

### Para Estudantes
- Realização de pedidos de inscrição
- Visualização do próprio CRID
- Solicitação de trancamento de disciplinas
- Controle de pedidos duplicados

### Para Orientadores
- Dar concordância aos pedidos dos orientandos
- Visualização dos pedidos dos estudantes sob orientação

### Para Coordenadores
- Processamento de pedidos (aprovar, rejeitar, trancar)
- Controle de vagas das disciplinas
- Gerenciamento de pedidos por disciplina

## Arquitetura do Sistema

### Estruturas de Dados Principais

```solidity
enum StatusPedido {
    Solicitado,  // Aguardando análise
    Efetivado,   // Pedido aprovado
    Trancado,    // Pedido trancado
    Rejeitado    // Pedido rejeitado
}

struct Disciplina {
    string nome;
    string codigo;
    string turma;
    uint8 cargaHoraria;
    uint8 vagas;
    uint8 vagasOcupadas;
    bool ativa;
    address coordenador;
}

struct PedidoInscricao {
    address estudante;
    string matricula;
    string codigoDisciplina;
    StatusPedido status;
    uint256 timestamp;
    uint16 coa;
    uint16 cra;
    uint8 periodo;
    bool concordanciaOrientador;
}
```

## Tecnologias Utilizadas
- Solidity: Linguagem de programação para smart contracts
- Ethereum: Blockchain para execução do contrato
- Remix IDE: Ambiente de desenvolvimento

## Deploy  via Remix IDE

1. Acesse Remix IDE
2. Crie um novo arquivo .sol e cole o código do contrato
3. Compile o contrato (Solidity 0.8.x)
4. Conecte sua carteira Ethereum
5. Deploy na rede desejada

## Como Usar

1. Configuração Inicial (Admin)
```
// Adicionar coordenadores
contract.adicionarCoordenador("0x...");

// Adicionar orientadores  
contract.adicionarOrientador("0x...");
  
// Cadastrar estudantes
contract.cadastrarEstudante(
    "0x...",      // endereço
    "123456789",  // matrícula
    "João Silva", // nome
    120,          // COA
    85,           // CRA
    6,            // período
    "0x..."       // orientador
);
  
// Cadastrar disciplinas
contract.cadastrarDisciplina(
    "EEL740",           // código
    "COMUNICAÇÕES II",  // nome
    "EL1",              // turma
    60,                 // carga horária
    30,                 // vagas
    "0x..."             // coordenador
);
```

2. Fluxo do Estudante
```
// Realizar pedido
contract.realizarPedido("EEL740");

// Solicitar trancamento
contract.solicitarTrancamento(1);

// Visualizar CRID
contract.getCRIDEstudante("0x...");
```

3. Fluxo do Orientador
```
// Dar concordância
contract.darConcordancia(1);
```

4. Fluxo do Coordenador
```
// Processar pedido
contract.processarPedido(1, StatusPedido.Efetivado);
```

## Eventos do Sistema

- event EstudanteCadastrado(address indexed estudante, string matricula, string nome);
- event DisciplinaCadastrada(string indexed codigo, string nome, address coordenador);
- event PedidoRealizado(uint256 indexed idPedido, address indexed estudante, string codigoDisciplina);
- event PedidoAtualizado(uint256 indexed idPedido, StatusPedido novoStatus);
- event CoordenadorAdicionado(address indexed coordenador);
- event OrientadorAdicionado(address indexed orientador);

## Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature: `git checkout -b feature/AmazingFeature`
3. Commit suas mudanças: `git commit -m 'Add some AmazingFeature'`
4. Push para a branch: `git push origin feature/AmazingFeature`
5. Abra um Pull Request

## Licença

Este projeto está sob a licença GPL-3.0. Veja o arquivo LICENSE para mais detalhes.

## Agradecimentos

Este projeto foi criado como parte dos estudos na Universidade Federal do Rio de Janeiro (UFRJ), no curso de Engenharia Eletrônica e de Computação, na disciplina de Programação Avançada, ministrada pelo professor Cláudio Micelli, com o objetivo de explorar projetos utilizando a tecnologia blockchain.

## Alunos
Alan Gonçalves & Gabriela Sasso

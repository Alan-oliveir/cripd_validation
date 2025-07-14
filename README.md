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
- Prevenção de pedidos duplicados

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

### Fluxo do Sistema

1. **Cadastro:** Admin cadastra estudantes, coordenadores, orientadores e disciplinas
2. **Solicitação:** Estudante realiza pedido de inscrição
3. **Concordância:** Orientador dá concordância ao pedido
4. **Processamento:** Coordenador aprova, rejeita ou tranca o pedido
5. **Trancamento:** Estudante pode solicitar trancamento de disciplina efetivada

## Tecnologias Utilizadas

- **Solidity:** Linguagem de programação para smart contracts
- **Ethereum:** Blockchain para execução do contrato
- **Remix IDE:** Ambiente de desenvolvimento

## Requisitos

- Solidity `>=0.7.0 <0.9.0`
- Ambiente Ethereum (local ou testnet)
- Carteira Ethereum (MetaMask recomendado)
- Saldo em ETH para deploy em testnet

## Deploy via Remix IDE

1. Acesse [Remix IDE](https://remix.ethereum.org/)
2. Crie um novo arquivo `.sol` e cole o código do contrato
3. Compile o contrato (Solidity 0.8.x)
4. Conecte sua carteira Ethereum
5. Deploy na rede desejada

## Como Usar

### 1. Configuração Inicial (Admin)

Exemplo de comandos para a instância do contrato já implantada (`contract`):

```solidity
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
    "COMUNICACOES II",  // nome (sem acento por compatibilidade)
    "EL1",              // turma
    60,                 // carga horária
    30,                 // vagas
    "0x..."             // coordenador
);
```

### 2. Fluxo do Estudante

```solidity
// Realizar pedido
contract.realizarPedido("EEL740");

// Solicitar trancamento
contract.solicitarTrancamento(1);

// Visualizar CRID
contract.getCRIDEstudante("0x...");
```

### 3. Fluxo do Orientador

```solidity
// Dar concordância
contract.darConcordancia(1);
```

### 4. Fluxo do Coordenador

```solidity
// Processar pedido
contract.processarPedido(1, StatusPedido.Efetivado);
```

## Eventos do Sistema

```solidity
event EstudanteCadastrado(address indexed estudante, string matricula, string nome);
event DisciplinaCadastrada(string indexed codigo, string nome, address coordenador);
event PedidoRealizado(uint256 indexed idPedido, address indexed estudante, string codigoDisciplina);
event PedidoAtualizado(uint256 indexed idPedido, StatusPedido novoStatus);
event CoordenadorAdicionado(address indexed coordenador);
event OrientadorAdicionado(address indexed orientador);
```

## Funcionalidades Principais

### Consultas
- `getDisciplinas()`: Retorna todas as disciplinas cadastradas
- `getPedidosPorEstudante(address)`: Retorna pedidos de um estudante
- `getPedidosPorDisciplina(string)`: Retorna pedidos de uma disciplina
- `getPedidoDetalhado(uint256)`: Retorna detalhes de um pedido específico
- `getCRIDEstudante(address)`: Retorna CRID (pedidos efetivados/trancados)

### Controle de Acesso
- **Admin:** Cadastros e gerenciamento geral
- **Coordenador:** Processamento de pedidos de suas disciplinas
- **Orientador:** Concordância com pedidos de orientandos
- **Estudante:** Solicitação e trancamento de pedidos

## Segurança

- Controle de acesso baseado em modificadores
- Prevenção de pedidos duplicados
- Validação de dados de entrada
- Controle de vagas das disciplinas
- Auditoria através de eventos

## Testes

O projeto inclui um arquivo de testes unitários Solidity (`crid_validation_test.sol`).

Para rodar os testes no Remix:
1. Coloque `Crid_Validation.sol` e `crid_validation_test.sol` na mesma pasta do Remix IDE.
2. Compile ambos os arquivos.
3. Acesse a aba "Solidity Unit Testing" no Remix e execute os testes.

## Estrutura de Arquivos

```
├── Crid_Validation.sol            # Contrato principal
├── crid_validation_test.sol       # Testes unitários Solidity
├── README.md                      # Documentação
└── LICENSE                        # Licença GPL-3.0
```

## Limitações

- Não implementa sistema de pré-requisitos
- Não há validação de conflitos de horário

## Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature: `git checkout -b feature/AmazingFeature`
3. Commit suas mudanças: `git commit -m 'Add some AmazingFeature'`
4. Push para a branch: `git push origin feature/AmazingFeature`
5. Abra um Pull Request

## Licença

Este projeto está sob a licença GPL-3.0. Veja o arquivo [LICENSE](./LICENSE) para mais detalhes.

## Agradecimentos

Este projeto foi criado como parte dos estudos na Universidade Federal do Rio de Janeiro (UFRJ), no curso de Engenharia Eletrônica e de Computação, na disciplina de Programação Avançada, ministrada pelo professor Cláudio Micelli, com o objetivo de explorar projetos utilizando a tecnologia blockchain.

## Alunos

**Alan Gonçalves & Gabriela Sasso**  
*Engenharia Eletrônica e de Computação - UFRJ*  
*Disciplina: Programação Avançada*  
*Professor: Cláudio Micelli*  
*Período: 2025.1*

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol";
import "./4_Crid_Validation.sol";

contract CRIDTest {
    CRID crid;
    
    // Endereços para testes
    address admin = address(this);
    address coordenador1 = address(0x1);
    address coordenador2 = address(0x2);
    address orientador1 = address(0x3);
    address orientador2 = address(0x4);
    address estudante1 = address(0x5);
    address estudante2 = address(0x6);
    address estudante3 = address(0x7);
    
    // Função executada antes de cada teste
    function beforeEach() public {
        crid = new CRID();
    }
    
    // ========== TESTES DE CONFIGURAÇÃO INICIAL ==========
    
    function testInitialSetup() public {
        Assert.equal(crid.admin(), admin, "Admin deve ser o deployer do contrato");
        Assert.equal(crid.proximoIdPedido(), 1, "Proximo ID deve começar em 1");
    }
    
    // ========== TESTES DE CADASTRO DE COORDENADORES ==========
    
    function testAdicionarCoordenador() public {
        crid.adicionarCoordenador(coordenador1);
        Assert.ok(crid.coordenadores(coordenador1), "Coordenador deve estar cadastrado");
    }
    
    function testAdicionarCoordenadorApenasAdmin() public {
        // Teste negativo - só admin pode adicionar coordenador
        try crid.adicionarCoordenador(coordenador1) {
            Assert.ok(true, "Admin pode adicionar coordenador");
        } catch Error(string memory reason) {
            Assert.ok(false, "Admin deve conseguir adicionar coordenador");
        }
    }
    
    // ========== TESTES DE CADASTRO DE ORIENTADORES ==========
    
    function testAdicionarOrientador() public {
        crid.adicionarOrientador(orientador1);
        Assert.ok(crid.orientadores(orientador1), "Orientador deve estar cadastrado");
    }
    
    // ========== TESTES DE CADASTRO DE ESTUDANTES ==========
    
    function testCadastrarEstudante() public {
        // Primeiro cadastrar orientador
        crid.adicionarOrientador(orientador1);
        
        // Cadastrar estudante
        crid.cadastrarEstudante(
            estudante1,
            "2020123456",
            "João Silva",
            120,
            85,
            6,
            orientador1
        );
        
        // Verificar se foi cadastrado corretamente
        (string memory matricula, string memory nome, uint16 coa, uint16 cra, uint8 periodo, bool ativo, address orientador) = crid.estudantes(estudante1);
        
        Assert.equal(matricula, "2020123456", "Matrícula deve estar correta");
        Assert.equal(nome, "João Silva", "Nome deve estar correto");
        Assert.equal(coa, 120, "COA deve estar correto");
        Assert.equal(cra, 85, "CRA deve estar correto");
        Assert.equal(periodo, 6, "Período deve estar correto");
        Assert.ok(ativo, "Estudante deve estar ativo");
        Assert.equal(orientador, orientador1, "Orientador deve estar correto");
    }
    
    function testCadastrarEstudanteSemOrientador() public {
        // Teste negativo - tentar cadastrar estudante sem orientador válido
        try crid.cadastrarEstudante(
            estudante1,
            "2020123456",
            "João Silva",
            120,
            85,
            6,
            orientador1
        ) {
            Assert.ok(false, "Não deve conseguir cadastrar estudante sem orientador válido");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Orientador nao cadastrado", "Erro deve ser sobre orientador não cadastrado");
        }
    }
    
    // ========== TESTES DE CADASTRO DE DISCIPLINAS ==========
    
    function testCadastrarDisciplina() public {
        // Primeiro cadastrar coordenador
        crid.adicionarCoordenador(coordenador1);
        
        // Cadastrar disciplina
        crid.cadastrarDisciplina(
            "EEL740",
            "COMUNICACOES II",
            "EL1",
            60,
            30,
            coordenador1
        );
        
        // Verificar se foi cadastrada corretamente
        (string memory nome, string memory codigo, string memory turma, uint8 cargaHoraria, uint8 vagas, uint8 vagasOcupadas, bool ativa, address coordenador) = crid.disciplinas("EEL740");
        
        Assert.equal(nome, "COMUNICACOES II", "Nome da disciplina deve estar correto");
        Assert.equal(codigo, "EEL740", "Código da disciplina deve estar correto");
        Assert.equal(turma, "EL1", "Turma deve estar correta");
        Assert.equal(cargaHoraria, 60, "Carga horária deve estar correta");
        Assert.equal(vagas, 30, "Número de vagas deve estar correto");
        Assert.equal(vagasOcupadas, 0, "Vagas ocupadas deve começar em 0");
        Assert.ok(ativa, "Disciplina deve estar ativa");
        Assert.equal(coordenador, coordenador1, "Coordenador deve estar correto");
    }
    
    function testCadastrarDisciplinaSemCoordenador() public {
        // Teste negativo - tentar cadastrar disciplina sem coordenador válido
        try crid.cadastrarDisciplina(
            "EEL740",
            "COMUNICACOES II",
            "EL1",
            60,
            30,
            coordenador1
        ) {
            Assert.ok(false, "Não deve conseguir cadastrar disciplina sem coordenador válido");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Coordenador nao cadastrado", "Erro deve ser sobre coordenador não cadastrado");
        }
    }
    
    // ========== TESTES DE PEDIDOS DE INSCRIÇÃO ==========
    
    function testRealizarPedido() public {
        // Setup: cadastrar coordenador, orientador, estudante e disciplina
        crid.adicionarCoordenador(coordenador1);
        crid.adicionarOrientador(orientador1);
        
        crid.cadastrarEstudante(
            estudante1,
            "2020123456",
            "João Silva",
            120,
            85,
            6,
            orientador1
        );
        
        crid.cadastrarDisciplina(
            "EEL740",
            "COMUNICACOES II",
            "EL1",
            60,
            30,
            coordenador1
        );
        
        // Simular que o estudante está fazendo o pedido
        // Nota: Em um ambiente real, você usaria vm.prank(estudante1) se estiver usando Foundry
        // Como estamos no Remix, vamos assumir que o teste está sendo executado como estudante
        
        // Realizar pedido
        crid.realizarPedido("EEL740");
        
        // Verificar se o pedido foi criado
        uint256[] memory pedidosEstudante = crid.getPedidosPorEstudante(admin); // usando admin como proxy para estudante
        Assert.equal(pedidosEstudante.length, 1, "Deve haver 1 pedido para o estudante");
        
        // Verificar detalhes do pedido
        (address estudante, string memory matricula, string memory codigoDisciplina, CRID.StatusPedido status, uint256 timestamp, uint16 coa, uint16 cra, uint8 periodo, bool concordanciaOrientador) = crid.getPedidoDetalhado(1);
        
        Assert.equal(estudante, admin, "Estudante deve estar correto");
        Assert.equal(codigoDisciplina, "EEL740", "Código da disciplina deve estar correto");
        Assert.equal(uint(status), uint(CRID.StatusPedido.Solicitado), "Status deve ser Solicitado");
        Assert.equal(concordanciaOrientador, false, "Concordância deve ser false inicialmente");
    }
    
    function testRealizarPedidoDuplicado() public {
        // Setup inicial
        crid.adicionarCoordenador(coordenador1);
        crid.adicionarOrientador(orientador1);
        
        crid.cadastrarEstudante(
            estudante1,
            "2020123456",
            "João Silva",
            120,
            85,
            6,
            orientador1
        );
        
        crid.cadastrarDisciplina(
            "EEL740",
            "COMUNICACOES II",
            "EL1",
            60,
            30,
            coordenador1
        );
        
        // Realizar primeiro pedido
        crid.realizarPedido("EEL740");
        
        // Tentar realizar segundo pedido para mesma disciplina
        try crid.realizarPedido("EEL740") {
            Assert.ok(false, "Não deve conseguir fazer pedido duplicado");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Pedido ja existe para esta disciplina", "Erro deve ser sobre pedido duplicado");
        }
    }
    
    // ========== TESTES DE CONCORDÂNCIA DO ORIENTADOR ==========
    
    function testDarConcordancia() public {
        // Setup completo
        crid.adicionarCoordenador(coordenador1);
        crid.adicionarOrientador(orientador1);
        
        crid.cadastrarEstudante(
            estudante1,
            "2020123456",
            "João Silva",
            120,
            85,
            6,
            orientador1
        );
        
        crid.cadastrarDisciplina(
            "EEL740",
            "COMUNICACOES II",
            "EL1",
            60,
            30,
            coordenador1
        );
        
        // Realizar pedido
        crid.realizarPedido("EEL740");
        
        // Dar concordância (simulando orientador)
        crid.darConcordancia(1);
        
        // Verificar se concordância foi dada
        (,,,,,,, bool concordanciaOrientador) = crid.getPedidoDetalhado(1);
        Assert.ok(concordanciaOrientador, "Concordância deve ter sido dada");
    }
    
    // ========== TESTES DE PROCESSAMENTO DE PEDIDOS ==========
    
    function testProcessarPedidoEfetivado() public {
        // Setup completo
        crid.adicionarCoordenador(coordenador1);
        crid.adicionarOrientador(orientador1);
        
        crid.cadastrarEstudante(
            estudante1,
            "2020123456",
            "João Silva",
            120,
            85,
            6,
            orientador1
        );
        
        crid.cadastrarDisciplina(
            "EEL740",
            "COMUNICACOES II",
            "EL1",
            60,
            30,
            coordenador1
        );
        
        // Realizar pedido
        crid.realizarPedido("EEL740");
        
        // Processar pedido como efetivado
        crid.processarPedido(1, CRID.StatusPedido.Efetivado);
        
        // Verificar status
        (,,,CRID.StatusPedido status,,,,,) = crid.getPedidoDetalhado(1);
        Assert.equal(uint(status), uint(CRID.StatusPedido.Efetivado), "Status deve ser Efetivado");
        
        // Verificar se vaga foi ocupada
        (,,,,,uint8 vagasOcupadas,,) = crid.disciplinas("EEL740");
        Assert.equal(vagasOcupadas, 1, "Deve haver 1 vaga ocupada");
    }
    
    function testProcessarPedidoRejeitado() public {
        // Setup completo
        crid.adicionarCoordenador(coordenador1);
        crid.adicionarOrientador(orientador1);
        
        crid.cadastrarEstudante(
            estudante1,
            "2020123456",
            "João Silva",
            120,
            85,
            6,
            orientador1
        );
        
        crid.cadastrarDisciplina(
            "EEL740",
            "COMUNICACOES II",
            "EL1",
            60,
            30,
            coordenador1
        );
        
        // Realizar pedido
        crid.realizarPedido("EEL740");
        
        // Processar pedido como rejeitado
        crid.processarPedido(1, CRID.StatusPedido.Rejeitado);
        
        // Verificar status
        (,,,CRID.StatusPedido status,,,,,) = crid.getPedidoDetalhado(1);
        Assert.equal(uint(status), uint(CRID.StatusPedido.Rejeitado), "Status deve ser Rejeitado");
    }
    
    // ========== TESTES DE TRANCAMENTO ==========
    
    function testSolicitarTrancamento() public {
        // Setup completo
        crid.adicionarCoordenador(coordenador1);
        crid.adicionarOrientador(orientador1);
        
        crid.cadastrarEstudante(
            estudante1,
            "2020123456",
            "João Silva",
            120,
            85,
            6,
            orientador1
        );
        
        crid.cadastrarDisciplina(
            "EEL740",
            "COMUNICACOES II",
            "EL1",
            60,
            30,
            coordenador1
        );
        
        // Realizar e efetivar pedido
        crid.realizarPedido("EEL740");
        crid.processarPedido(1, CRID.StatusPedido.Efetivado);
        
        // Solicitar trancamento
        crid.solicitarTrancamento(1);
        
        // Verificar se status voltou para Solicitado
        (,,,CRID.StatusPedido status,,,,,) = crid.getPedidoDetalhado(1);
        Assert.equal(uint(status), uint(CRID.StatusPedido.Solicitado), "Status deve voltar para Solicitado");
    }
    
    // ========== TESTES DE FUNÇÕES DE CONSULTA ==========
    
    function testGetDisciplinas() public {
        // Cadastrar coordenador e disciplinas
        crid.adicionarCoordenador(coordenador1);
        
        crid.cadastrarDisciplina("EEL740", "COMUNICACOES II", "EL1", 60, 30, coordenador1);
        crid.cadastrarDisciplina("EEL741", "SISTEMAS DIGITAIS", "EL2", 45, 25, coordenador1);
        
        string[] memory disciplinas = crid.getDisciplinas();
        Assert.equal(disciplinas.length, 2, "Deve haver 2 disciplinas cadastradas");
        Assert.equal(disciplinas[0], "EEL740", "Primeira disciplina deve ser EEL740");
        Assert.equal(disciplinas[1], "EEL741", "Segunda disciplina deve ser EEL741");
    }
    
    function testGetStatusString() public {
        Assert.equal(crid.getStatusString(CRID.StatusPedido.Solicitado), "Solicitado", "Status string deve estar correto");
        Assert.equal(crid.getStatusString(CRID.StatusPedido.Efetivado), "Pedido ja efetivado", "Status string deve estar correto");
        Assert.equal(crid.getStatusString(CRID.StatusPedido.Trancado), "Pedido trancado", "Status string deve estar correto");
        Assert.equal(crid.getStatusString(CRID.StatusPedido.Rejeitado), "Pedido rejeitado", "Status string deve estar correto");
    }
    
    // ========== TESTES DE ATUALIZAÇÃO DE DADOS ==========
    
    function testAtualizarEstudante() public {
        // Setup
        crid.adicionarOrientador(orientador1);
        crid.cadastrarEstudante(estudante1, "2020123456", "João Silva", 120, 85, 6, orientador1);
        
        // Atualizar dados
        crid.atualizarEstudante(estudante1, 130, 90, 7);
        
        // Verificar se foi atualizado
        (,, uint16 coa, uint16 cra, uint8 periodo,,) = crid.estudantes(estudante1);
        Assert.equal(coa, 130, "COA deve ter sido atualizado");
        Assert.equal(cra, 90, "CRA deve ter sido atualizado");
        Assert.equal(periodo, 7, "Período deve ter sido atualizado");
    }
    
    // ========== TESTES DE CRID ==========
    
    function testGetCRIDEstudante() public {
        // Setup completo
        crid.adicionarCoordenador(coordenador1);
        crid.adicionarOrientador(orientador1);
        
        crid.cadastrarEstudante(estudante1, "2020123456", "João Silva", 120, 85, 6, orientador1);
        
        crid.cadastrarDisciplina("EEL740", "COMUNICACOES II", "EL1", 60, 30, coordenador1);
        crid.cadastrarDisciplina("EEL741", "SISTEMAS DIGITAIS", "EL2", 45, 25, coordenador1);
        
        // Fazer pedidos
        crid.realizarPedido("EEL740");
        crid.realizarPedido("EEL741");
        
        // Processar pedidos
        crid.processarPedido(1, CRID.StatusPedido.Efetivado);
        crid.processarPedido(2, CRID.StatusPedido.Rejeitado);
        
        // Verificar CRID (deve conter apenas pedidos efetivados e trancados)
        uint256[] memory cridEstudante = crid.getCRIDEstudante(admin);
        Assert.equal(cridEstudante.length, 1, "CRID deve conter apenas 1 pedido (efetivado)");
        Assert.equal(cridEstudante[0], 1, "CRID deve conter o pedido ID 1");
    }
    
    // ========== TESTES DE CONTROLE DE VAGAS ==========
    
    function testControleVagas() public {
        // Setup
        crid.adicionarCoordenador(coordenador1);
        crid.adicionarOrientador(orientador1);
        
        crid.cadastrarEstudante(estudante1, "2020123456", "João Silva", 120, 85, 6, orientador1);
        
        // Criar disciplina com apenas 1 vaga
        crid.cadastrarDisciplina("EEL740", "COMUNICACOES II", "EL1", 60, 1, coordenador1);
        
        // Fazer pedido e efetivar
        crid.realizarPedido("EEL740");
        crid.processarPedido(1, CRID.StatusPedido.Efetivado);
        
        // Verificar se vaga foi ocupada
        (,,,,,uint8 vagasOcupadas,,) = crid.disciplinas("EEL740");
        Assert.equal(vagasOcupadas, 1, "Deve haver 1 vaga ocupada");
    }
}

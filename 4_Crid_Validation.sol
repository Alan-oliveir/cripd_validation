// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title CRID - Sistema de Inscrição em Disciplinas 
 * @dev Implementa o sistema de pedidos de inscrição em disciplinas acadêmicas na UFRJ
 */
contract CRID {
    
    // Enum para os status possíveis de um pedido
    enum StatusPedido {
        Solicitado,         // Pedido aguardando análise
        Efetivado,          // Pedido já efetivado
        Trancado,            // Pedido trancado
        Rejeitado           // Pedido rejeitado (não aparece no CRID final)
    }
    
    // Struct para representar uma disciplina
    struct Disciplina {
        string nome;         // Ex: COMUNICACÕES II
        string codigo;       // Ex: EEL740        
        string turma;        // Ex: EL1
        uint8 cargaHoraria;  // Carga horária
        uint8 vagas;         // Número de vagas disponíveis
        uint8 vagasOcupadas; // Número de vagas ocupadas
        bool ativa;          // Se a disciplina está ativa
        address coordenador; // Coordenador responsável
    }
    
    // Struct para representar um pedido de inscrição
    struct PedidoInscricao {
        address estudante;
        string matricula;
        string codigoDisciplina;
        StatusPedido status;
        uint256 timestamp;
        uint16 coa;         // Créditos Obtidos Acumulados
        uint16 cra;         // Coeficiente de Rendimento Acumulado
        uint8 periodo;      // Período atual do aluno
        bool concordanciaOrientador; // Se tem concordância do orientador
    }
    
    // Struct para representar um estudante
    struct Estudante {
        string matricula;
        string nome;
        uint16 coa;
        uint16 cra;
        uint8 periodo;
        bool ativo;
        address orientador;
    }
    
    // Variáveis de estado
    address public admin;
    uint256 public proximoIdPedido;
    
    // Mapeamentos
    mapping(address => Estudante) public estudantes;
    mapping(string => Disciplina) public disciplinas;
    mapping(uint256 => PedidoInscricao) public pedidos;
    mapping(address => bool) public coordenadores;
    mapping(address => bool) public orientadores;
    mapping(string => uint256[]) public pedidosPorDisciplina;
    mapping(address => uint256[]) public pedidosPorEstudante;    
    mapping(address => mapping(string => bool)) public pedidoExistente; // Adicionar mapeamento para controlar pedidos duplicados

    // Arrays para controle
    string[] public codigosDisciplinas;
    
    // Eventos
    event EstudanteCadastrado(address indexed estudante, string matricula, string nome);
    event DisciplinaCadastrada(string indexed codigo, string nome, address coordenador);
    event PedidoRealizado(uint256 indexed idPedido, address indexed estudante, string codigoDisciplina);
    event PedidoAtualizado(uint256 indexed idPedido, StatusPedido novoStatus);
    event CoordenadorAdicionado(address indexed coordenador);
    event OrientadorAdicionado(address indexed orientador);
    
    // Modificadores
    modifier apenasAdmin() {
        require(msg.sender == admin, "Apenas o admin pode executar esta funcao");
        _;
    }
    
    modifier apenasCoordenador() {
        require(coordenadores[msg.sender], "Apenas coordenadores podem executar esta funcao");
        _;
    }
    
    modifier apenasOrientador() {
        require(orientadores[msg.sender], "Apenas orientadores podem executar esta funcao");
        _;
    }
    
    modifier apenasEstudanteAtivo() {
        require(estudantes[msg.sender].ativo, "Apenas estudantes ativos podem executar esta funcao");
        _;
    }
    
    /**
     * @dev Construtor do contrato
     */
    constructor() {
        admin = msg.sender;
        proximoIdPedido = 1;
    }
    
    /**
     * @dev Adiciona um novo coordenador
     * @param _coordenador Endereço do coordenador
     */
    function adicionarCoordenador(address _coordenador) external apenasAdmin {
        coordenadores[_coordenador] = true;
        emit CoordenadorAdicionado(_coordenador);
    }
    
    /**
     * @dev Adiciona um novo orientador
     * @param _orientador Endereço do orientador
     */
    function adicionarOrientador(address _orientador) external apenasAdmin {
        orientadores[_orientador] = true;
        emit OrientadorAdicionado(_orientador);
    }
    
    /**
     * @dev Cadastra um novo estudante
     * @param _estudante Endereço do estudante
     * @param _matricula Matrícula do estudante
     * @param _nome Nome do estudante
     * @param _coa Créditos Obtidos Acumulados
     * @param _cra Coeficiente de Rendimento Acumulado
     * @param _periodo Período atual
     * @param _orientador Endereço do orientador
     */
    function cadastrarEstudante(
        address _estudante,
        string memory _matricula,
        string memory _nome,
        uint16 _coa,
        uint16 _cra,
        uint8 _periodo,
        address _orientador
    ) external apenasAdmin {
        require(_estudante != address(0), "Endereco invalido");
        require(orientadores[_orientador], "Orientador nao cadastrado");
        
        estudantes[_estudante] = Estudante({
            matricula: _matricula,
            nome: _nome,
            coa: _coa,
            cra: _cra,
            periodo: _periodo,
            ativo: true,
            orientador: _orientador
        });
        
        emit EstudanteCadastrado(_estudante, _matricula, _nome);
    }
    
    /**
     * @dev Cadastra uma nova disciplina
     * @param _codigo Código da disciplina
     * @param _nome Nome da disciplina
     * @param _turma Turma
     * @param _cargaHoraria Carga horária
     * @param _vagas Número de vagas
     * @param _coordenador Coordenador responsável
     */
    function cadastrarDisciplina(
        string memory _codigo,
        string memory _nome,
        string memory _turma,
        uint8 _cargaHoraria,
        uint8 _vagas,
        address _coordenador
    ) external apenasAdmin {
        require(coordenadores[_coordenador], "Coordenador nao cadastrado");
        require(!disciplinas[_codigo].ativa, "Disciplina ja cadastrada");
        
        disciplinas[_codigo] = Disciplina({
            nome: _nome,
            codigo: _codigo,
            turma: _turma,
            cargaHoraria: _cargaHoraria,
            vagas: _vagas,
            vagasOcupadas: 0,
            ativa: true,
            coordenador: _coordenador
        });
        
        codigosDisciplinas.push(_codigo);
        emit DisciplinaCadastrada(_codigo, _nome, _coordenador);
    }
    
    /**
     * @dev Realiza pedido de inscrição em disciplina
     * @param _codigoDisciplina Código da disciplina
     */
    function realizarPedido(string memory _codigoDisciplina) external apenasEstudanteAtivo {
        require(disciplinas[_codigoDisciplina].ativa, "Disciplina nao encontrada ou inativa");
        require(!pedidoExistente[msg.sender][_codigoDisciplina], "Pedido ja existe para esta disciplina");
        
        Estudante memory estudante = estudantes[msg.sender];
        
        uint256 idPedido = proximoIdPedido++;
        
        pedidos[idPedido] = PedidoInscricao({
            estudante: msg.sender,
            matricula: estudante.matricula,
            codigoDisciplina: _codigoDisciplina,
            status: StatusPedido.Solicitado,
            timestamp: block.timestamp,
            coa: estudante.coa,
            cra: estudante.cra,
            periodo: estudante.periodo,
            concordanciaOrientador: false
        });
        
        pedidosPorDisciplina[_codigoDisciplina].push(idPedido);
        pedidosPorEstudante[msg.sender].push(idPedido);
        
        pedidoExistente[msg.sender][_codigoDisciplina] = true;
        
        emit PedidoRealizado(idPedido, msg.sender, _codigoDisciplina);
    }
    
    /**
     * @dev Orientador dá concordância ao pedido
     * @param _idPedido ID do pedido
     */
    function darConcordancia(uint256 _idPedido) external apenasOrientador {
        PedidoInscricao storage pedido = pedidos[_idPedido];
        require(pedido.estudante != address(0), "Pedido nao encontrado");
        require(estudantes[pedido.estudante].orientador == msg.sender, "Nao e orientador deste estudante");
        
        pedido.concordanciaOrientador = true;
        emit PedidoAtualizado(_idPedido, pedido.status);
    }
    
    /**
     * @dev Coordenador processa pedido (efetiva, tranca ou rejeita)
     * @param _idPedido ID do pedido
     * @param _novoStatus Novo status do pedido
     */
    function processarPedido(uint256 _idPedido, StatusPedido _novoStatus) external apenasCoordenador {
        PedidoInscricao storage pedido = pedidos[_idPedido];
        require(pedido.estudante != address(0), "Pedido nao encontrado");
        require(pedido.status == StatusPedido.Solicitado, "Pedido ja foi processado");
        
        Disciplina storage disciplina = disciplinas[pedido.codigoDisciplina];
        require(disciplina.coordenador == msg.sender, "Nao e coordenador desta disciplina");
        
        if (_novoStatus == StatusPedido.Efetivado) {
            require(disciplina.vagasOcupadas < disciplina.vagas, "Nao ha vagas disponiveis");
            disciplina.vagasOcupadas++;
        } else if (_novoStatus == StatusPedido.Trancado && pedido.status == StatusPedido.Efetivado) {
            // Liberar vaga quando trancar
            disciplina.vagasOcupadas--;
        }
        
        pedido.status = _novoStatus;
        emit PedidoAtualizado(_idPedido, _novoStatus);
    }

    /**
     * @dev Estudante solicita trancamento de disciplina já efetivada
     * @param _idPedido ID do pedido efetivado
     */
    function solicitarTrancamento(uint256 _idPedido) external apenasEstudanteAtivo {
        PedidoInscricao storage pedido = pedidos[_idPedido];
        require(pedido.estudante == msg.sender, "Nao e seu pedido");
        require(pedido.status == StatusPedido.Efetivado, "Pedido deve estar efetivado para ser trancado");
        
        // Muda para solicitado para que o coordenador possa processar o trancamento
        pedido.status = StatusPedido.Solicitado;
        emit PedidoAtualizado(_idPedido, StatusPedido.Solicitado);
    }
    
    /**
     * @dev Retorna os pedidos de uma disciplina
     * @param _codigoDisciplina Código da disciplina
     * @return Array com IDs dos pedidos
     */
    function getPedidosPorDisciplina(string memory _codigoDisciplina) external view returns (uint256[] memory) {
        return pedidosPorDisciplina[_codigoDisciplina];
    }
    
    /**
     * @dev Retorna os pedidos de um estudante
     * @param _estudante Endereço do estudante
     * @return Array com IDs dos pedidos
     */
    function getPedidosPorEstudante(address _estudante) external view returns (uint256[] memory) {
        return pedidosPorEstudante[_estudante];
    }
    
    /**
     * @dev Retorna todas as disciplinas cadastradas
     * @return Array com códigos das disciplinas
     */
    function getDisciplinas() external view returns (string[] memory) {
        return codigosDisciplinas;
    }
    
    /**
     * @dev Retorna informações detalhadas de um pedido
     * @param _idPedido ID do pedido
     * @dev Retorna Informações do pedido
     */
    function getPedidoDetalhado(uint256 _idPedido) external view returns (
        address estudante,
        string memory matricula,
        string memory codigoDisciplina,
        StatusPedido status,
        uint256 timestamp,
        uint16 coa,
        uint16 cra,
        uint8 periodo,
        bool concordanciaOrientador
    ) {
        PedidoInscricao memory pedido = pedidos[_idPedido];
        return (
            pedido.estudante,
            pedido.matricula,
            pedido.codigoDisciplina,
            pedido.status,
            pedido.timestamp,
            pedido.coa,
            pedido.cra,
            pedido.periodo,
            pedido.concordanciaOrientador
        );
    }
    
    /**
     * @dev Retorna o status de um pedido em string
     * @param _status Status enum
     * @return Status em string
     */
    function getStatusString(StatusPedido _status) external pure returns (string memory) {
        if (_status == StatusPedido.Solicitado) return "Solicitado";
        if (_status == StatusPedido.Efetivado) return "Pedido ja efetivado";
        if (_status == StatusPedido.Trancado) return "Pedido trancado";
        if (_status == StatusPedido.Rejeitado) return "Pedido rejeitado";
        return "Status desconhecido";
    }
    
    /**
     * @dev Atualiza dados do estudante
     * @param _estudante Endereço do estudante
     * @param _coa Novo COA
     * @param _cra Novo CRA
     * @param _periodo Novo período
     */
    function atualizarEstudante(
        address _estudante,
        uint16 _coa,
        uint16 _cra,
        uint8 _periodo
    ) external apenasAdmin {
        require(estudantes[_estudante].ativo, "Estudante nao encontrado");
        
        estudantes[_estudante].coa = _coa;
        estudantes[_estudante].cra = _cra;
        estudantes[_estudante].periodo = _periodo;
    }

    /**
     * @dev Retorna apenas os pedidos que aparecem no CRID (efetivados e trancados)
     * @param _estudante Endereço do estudante
     * @return Array com IDs dos pedidos no CRID
     */
    function getCRIDEstudante(address _estudante) external view returns (uint256[] memory) {
        uint256[] storage todosPedidos = pedidosPorEstudante[_estudante];
        uint256 length = todosPedidos.length;
        uint256[] memory pedidosCRID = new uint256[](length);
        uint256 count = 0;
        
        for (uint256 i = 0; i < length; i++) {
            StatusPedido status = pedidos[todosPedidos[i]].status;
            if (status == StatusPedido.Efetivado || status == StatusPedido.Trancado) {
                pedidosCRID[count] = todosPedidos[i];
                count++;
            }
        }
        
        // Redimensionar array para o tamanho correto
        assembly {
            mstore(pedidosCRID, count)
        }
        
        return pedidosCRID;
    }
}

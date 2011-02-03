-- BANCO DE DADOS:

CREATE DATABASE inhunmi;

USE inhunmi;

-- TABELA ACESSO:

CREATE TABLE acesso (
	id				INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	usuario				CHAR(16) NOT NULL,

	atendimento			ENUM("Sim", "Não") DEFAULT "Não" NOT NULL,
	caixa				ENUM("Sim", "Não") DEFAULT "Não" NOT NULL,

	grupo_cadastro			ENUM("Sim", "Não") DEFAULT "Não" NOT NULL,
	cadastro_pessoa			ENUM("Sim", "Não") DEFAULT "Não" NOT NULL,
	cadastro_instituicao		ENUM("Sim", "Não") DEFAULT "Não" NOT NULL,
	cadastro_departamento		ENUM("Sim", "Não") DEFAULT "Não" NOT NULL,
	cadastro_produto		ENUM("Sim", "Não") DEFAULT "Não" NOT NULL,
	cadastro_produto_grupo  	ENUM("Sim", "Não") DEFAULT "Não" NOT NULL,
	cadastro_encomenda		ENUM("Sim", "Não") DEFAULT "Não" NOT NULL,
	cadastro_compromisso		ENUM("Sim", "Não") DEFAULT "Não" NOT NULL,
	cadastro_forma_pagamento	ENUM("Sim", "Não") DEFAULT "Não" NOT NULL,

	grupo_relatorio			ENUM("Sim", "Não") DEFAULT "Não" NOT NULL,
	grupo_gerenciamento		ENUM("Sim", "Não") DEFAULT "Não" NOT NULL,

	acesso				ENUM("Sim", "Não") DEFAULT "Não" NOT NULL,
	configuracao			ENUM("Sim", "Não") DEFAULT "Não" NOT NULL,
	PRIMARY KEY (id)
);

-- TABELA PESSOA_INSTITUICAO:

CREATE TABLE pessoa_instituicao (
	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	nome			CHAR(80) NOT NULL,
	tipo			ENUM("Pessoa", "Instituição") NOT NULL,
	tipo_cliente		ENUM("Sim", "Não") NOT NULL DEFAULT "Não",
	tipo_cliente_vip	ENUM("Sim", "Não") NOT NULL DEFAULT "Não",
	tipo_cliente_pendente   ENUM("Sim", "Não") NOT NULL DEFAULT "Não",
	tipo_funcionario	ENUM("Sim", "Não") NOT NULL DEFAULT "Não",
	tipo_fornecedor		ENUM("Sim", "Não") NOT NULL DEFAULT "Não",
	PRIMARY KEY (id)
);

-- TABELA PESSOA_INSTITUICAO_PESSOA:

CREATE TABLE pessoa_instituicao_pessoa (
	dono			INT(8) UNSIGNED NOT NULL,
	tratamento		ENUM("Sr.", "Sra.", "Srta.") NOT NULL DEFAULT "Sr.",
	nome_favorito		CHAR(20) NULL,
	data_nascimento		DATE NULL,
	rg			CHAR(11) NULL,
	cpf			CHAR(11) NULL,
	PRIMARY KEY (dono)
);

-- TABELA PESSOA_INSTITUICAO_INSTITUICAO

CREATE TABLE pessoa_instituicao_instituicao (
	dono		INT(8) UNSIGNED NOT NULL,
	tipo		ENUM("Empresa Privada", 
                             "Empresa Pública", 
			     "Fundação",
			     "ONG", 
                             "Outro") NULL,
	cgc		CHAR(11) NULL,
	PRIMARY KEY (dono)
);

-- TABELA PESSOA_INSTITUICAO_TELEFONE:

CREATE TABLE pessoa_instituicao_telefone (
	id		INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	dono		INT(8) UNSIGNED NOT NULL,	-- Refere a pessoa_instituicao.id
	tipo		ENUM("Residencial", 
			     "Comercial",
			     "Celular",
			     "Fax", 
 			     "Outro") NOT NULL DEFAULT "Outro",
	ddd		DECIMAL(3) NULL,
	numero		DECIMAL(8) NOT NULL,
	PRIMARY KEY (id),
	INDEX numero	(numero),
	INDEX dono	(dono)
);

-- TABELA PESSOA_INSTITUICAO_ENDERECO

CREATE TABLE pessoa_instituicao_endereco (
	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	dono			INT(8) UNSIGNED NOT NULL,	-- Refere a pessoa_instituicao.id
	endereco_logradouro	CHAR(40) NOT NULL,
	endereco_numero		CHAR(8)  NOT NULL,
	endereco_apartamento	CHAR(6)  NULL,
	endereco_complemento	CHAR(10) NULL,
	endereco_cep		CHAR(10) NULL,
	endereco_bairro		CHAR(20) NULL,
	endereco_referencia	CHAR(20) NULL,
	PRIMARY KEY (id),
	INDEX	dono 	(dono),
	INDEX	endereco_logradouro (endereco_logradouro(10)) 	-- Limitar o tamanho do índice aos 10 primeiros caracteres
);

-- TABELA PESSOA_INSTITUICAO_EMAIL

CREATE TABLE pessoa_instituicao_email (
	id		INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	dono		INT(8) UNSIGNED NOT NULL,	-- Refere a pessoa_instituicao.id
	email		CHAR(40) NOT NULL,
	tipo		ENUM("Pessoal", 
                             "Comercial", 
			     "Outro") DEFAULT "Outro",
	favorito	ENUM("Sim", "Não") DEFAULT "Não",
	PRIMARY KEY (id),
	INDEX	email	(email),
	INDEX	dono 	(dono)
);


-- TABELA PESSOA_INSTITUICAO_CONTATO_PARENTESCO

CREATE TABLE pessoa_instituicao_contato_parentesco (
	id		INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	dono		INT(8) UNSIGNED NOT NULL,	-- Refere a pessoa_instituicao.id
	contato_parente	INT(8) UNSIGNED NOT NULL,
	tipo		ENUM ("Patrão",
			      "Funcionário",
			      "Vendedor",
			      "Cliente",

			      "Pai/Mãe", 
			      "Filho/Filha", 
			      "Irmão/Irmã", 
			      "Avô/Avó", 
			      "Bisavô/Bisavó", 
			      "Tio/Tia",
			      "Sobrinho/Sobrinha",
			      "Namorado/Namorada",
			      "Noivo/Noiva", 
			      "Conjugue",
			      "Outro")NOT NULL DEFAULT "Outro",
	PRIMARY KEY (id),
	INDEX		dono (dono)
);

-- TABELA porta_consumo

CREATE TABLE porta_consumo (
	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	numero			INT(8) UNSIGNED NULL,
	tipo			ENUM("Cartão", 
			     	     "Mesa", 
			     	     "Balcão",
			     	     "Encomenda") NOT NULL DEFAULT "Cartão",
	status			ENUM("Aberto", 
			     	     "Fechado", 
			     	     "Em Fechamento",
			             "Pendente",
			             "Outro") NOT NULL DEFAULT "Aberto",
	dono			INT(8) UNSIGNED NULL,	-- pessoa_instituicao.id
	usuario			INT(8) UNSIGNED DEFAULT 0, -- acesso.id
	datahora		TIMESTAMP,
	datahora_inicial	TIMESTAMP,
	datahora_final		DATETIME NULL,
	status_anterior		ENUM("Aberto", 
			     	     "Fechado", 
			     	     "Em Fechamento",
			             "Pendente",
			             "Outro") NOT NULL DEFAULT "Outro",
	PRIMARY KEY (id),
	INDEX status (status)
);


-- TABELA CONSUMO

-- Quantos registros de consumos precisamos?
-- Vamos supor que, por dia, utilizamos 1000 porta_consumos,
-- cada um com 3 consumos. Até agora temos 3000 consumos/dia.
-- Consequentemente teriamos aproximadamente 109.500 consumos/ano.
-- Com um campo tipo INT(8) podemos armazenar até 900 anos de consumo,
-- o que necessitaria de 98.550.000 campos únicos.

CREATE TABLE consumo (
	id			INT(8) UNSIGNED NOT NULL AUTO_INCREMENT DEFAULT 0,
	dono			INT(8) UNSIGNED NOT NULL, -- porta_consumo.id
	produto			INT(8) UNSIGNED NOT NULL,
	produto_quantidade	INT(8) UNSIGNED NOT NULL,
	valor			FLOAT(8,2) NOT NULL,
	datahora		TIMESTAMP,
	datahora_inicial	TIMESTAMP,
	departamento_venda	INT(8) NULL,
	usuario			INT(8) UNSIGNED NOT NULL, -- acesso.id
	PRIMARY KEY (id),
	INDEX dono (dono)
);

-- TABELA CONSUMO_META_GRUPO

CREATE TABLE consumo_meta_grupo (
 	id			INT(8) UNSIGNED NOT NULL AUTO_INCREMENT DEFAULT 0,
	dono			INT(8) UNSIGNED NOT NULL,
	produto 		INT(8) UNSIGNED NOT NULL,
	produto_quantidade	INT(8) UNSIGNED NOT NULL,
	PRIMARY KEY (id),
	INDEX dono (dono)
);

-- TABELA ENCOMENDA

CREATE TABLE encomenda (
	dono			INT(8) UNSIGNED NOT NULL, -- porta_consumo.id
	tipo_entrega		ENUM("Sim", "Não") NOT NULL DEFAULT "Não",
	local_entrega		VARCHAR(200),
	taxa_entrega		FLOAT(8,2) NOT NULL DEFAULT "0.00",
	datahora_entrega 	DATETIME NOT NULL,
	observacoes		VARCHAR(255),
	usuario			INT(8) UNSIGNED NOT NULL, -- acesso.id
	PRIMARY KEY (dono)
);

-- TABELA PORTA_CONSUMO_PAGAMENTO

-- Esta tabela descreve o fechamento de um porta_consumo, é claro.
-- Para isso, registramos um número seqüencial, o porta_consumo
-- associado a esse fechamento, a data e hora, além de forma de
-- pagamento. Devemos tambem alterar o status do porta_consumo
-- associado para 'Fechado', quando o total do porta_consumo for pago.
-- Desta maneira pode-se utilizar-se o mesmo porta_consumo inúmeras vezes
-- no mesmo dia.

CREATE TABLE porta_consumo_pagamento (
	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	dono			INT(8) UNSIGNED NOT NULL, -- porta_consumo.id
	forma_pagamento	        INT(8) UNSIGNED NOT NULL,
	valor			FLOAT(8,2) NOT NULL,
	datahora		TIMESTAMP,
	datahora_inicial	TIMESTAMP,
	usuario			INT(8) UNSIGNED NOT NULL, -- acesso.id
	PRIMARY KEY (id),
	INDEX dono (dono)
);

-- TABELA FORMA_PAGAMENTO

CREATE TABLE forma_pagamento (
	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	descricao		CHAR(40) NOT NULL,
	tipo_contra_vale	ENUM("Sim", "Não") NOT NULL DEFAULT "Não",
	tipo_troco		ENUM("Normal", "Selecionável") NOT NULL DEFAULT "Normal",
	PRIMARY KEY (id)
);

-- TABELA PRODUTO

-- Apenas o campo "tipo_vendido" possui indice, porque sera o criterio
-- examinado na GRANDE maioria das consultas relacionadas a produtos

CREATE TABLE produto (
	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	tipo_comprado		ENUM("Sim", "Não") NOT NULL DEFAULT "Não",
	tipo_vendido		ENUM("Sim", "Não") NOT NULL DEFAULT "Não",
	tipo_produzido		ENUM("Sim", "Não") NOT NULL DEFAULT "Não",
	tipo_meta_grupo		ENUM("Sim", "Não") NOT NULL DEFAULT "Não",
	tipo_generalizado	ENUM("Sim", "Não") NOT NULL DEFAULT "Não",
	descricao		CHAR(40) NOT NULL UNIQUE,
	unidade			ENUM("Unidade",
				     "Grama", 
				     "Mililitro", 
				     "Outro") NOT NULL DEFAULT "Unidade",
	grupo			INT(8) UNSIGNED NULL,
	departamento_compra 	INT(8) UNSIGNED NULL,
	departamento_venda  	INT(8) UNSIGNED NULL,
	departamento_producao 	INT(8) UNSIGNED NULL,
	departamento_estoque 	INT(8) UNSIGNED NULL,
	preco_venda		FLOAT(8,6),
	estoque_minimo		INT(8) UNSIGNED NULL,
        PRIMARY KEY (id),
	INDEX tipo_vendido 	(tipo_vendido)
);


CREATE TABLE produto_grupo (
	id		INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	descricao	CHAR(40) NOT NULL UNIQUE,
	PRIMARY KEY (id)
);

-- TABELA PRODUTO_COMPOSICAO

CREATE TABLE produto_composicao (
	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	dono			INT(8) UNSIGNED NOT NULL,
	produto			INT(8) UNSIGNED NOT NULL,
	quantidade 		FLOAT(8,6) NOT NULL,
	PRIMARY KEY (id),
	INDEX 	dono	(dono)
);



-- TABELA PRODUTO_EQUIVALENCIA

CREATE TABLE produto_equivalencia (
	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL,
	dono			INT(8) UNSIGNED NOT NULL,
	equivalencia		INT(8) UNSIGNED NOT NULL,
	quantidade		FLOAT(8,6) NOT NULL,
	INDEX 	dono	(dono),
	PRIMARY KEY (id)	
);


-- TABELA departamento

CREATE TABLE departamento (
	id	INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	nome	CHAR(40) NOT NULL,
	PRIMARY KEY (id)
);
	

CREATE TABLE caixa_movimento (
	id		INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	usuario		INT(8) UNSIGNED NOT NULL, -- refere a acesso.id
	descricao	CHAR(40) NOT NULL,
	tipo		ENUM("Crédito", "Débito") NOT NULL DEFAULT "Crédito",
	valor		FLOAT(8,2) UNSIGNED NOT NULL,
	forma_pagamento	INT(8) UNSIGNED NOT NULL,
	datahora	TIMESTAMP NOT NULL,
	PRIMARY KEY (id)
);









CREATE TABLE porta_consumo_fixo (
	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	numero			INT(8) UNSIGNED NULL,
	tipo			ENUM("Cartão", 
			     	     "Mesa") NOT NULL DEFAULT "Cartão",
	tipo_invalido		ENUM("Sim", "Não") NOT NULL DEFAULT "Não",
	tipo_automatico		ENUM("Sim", "Não") NOT NULL DEFAULT "Não",
	dono			INT(8) UNSIGNED NULL,	-- pessoa_instituicao.id
	observacao		CHAR(40) NULL,
	PRIMARY KEY (id)
);

-- PRODUCAO: 
-- Registro de uma determinada produção, ou seja, um conjunto de produtos 
-- que devem ser produzidos. 
-- CREATE TABLE producao (
--	id		INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
--	descricao	CHAR(40) NULL,
--	data		DATE NULL
--);

-- PRODUCAO_PRODUTOS:
-- Os produtos finais de uma produção são listados, ou seja, os produtos
-- a serem produzidos.
-- CREATE TABLE producao_produtos (
--	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
--	dono			INT(8) UNSIGNED NOT NULL, -- registro_producao.id
--	produto			INT(8) UNSIGNED NOT NULL, -- produto.id
--	produto_quantidade	INT(8) UNSIGNED NOT NULL,
--	PRIMARY KEY (id),
--	INDEX dono (dono)
-- );

-- PRODUCAO_PRODUTOS_COMPOSICAO
-- Os produtos (matéria-prima) usados para produzir os produtos em PRODUCAO_PRODUTOS
-- CREATE TABLE producao_produtos_composicao (
--	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
--	dono			INT(8) UNSIGNED NOT NULL, -- registro_producao.id
--	produto			INT(8) UNSIGNED NOT NULL, -- produto.id
--	produto_quantidade	INT(8) UNSIGNED NOT NULL,
--	PRIMARY KEY (id),
--	INDEX dono (dono)
-- );

CREATE TABLE log (
	dominio			ENUM("PortaConsumo",
				     "Consumo",
				     "Pagamento",
				     "Não Especificado",
				     "Outro") DEFAULT "Não Especificado" NOT NULL,
	dominio_id		INT(8) UNSIGNED NULL, -- ex: porta_consumo.id, consumo.id
	operacao		ENUM("Inclusão",
				     "Alteração",
				     "Deleção",
				     "Não Especificada",
				     "Outra") DEFAULT "Não Especificada" NOT NULL,
	mensagem_interna	CHAR(80) NOT NULL,
	mensagem_usuario	CHAR(40) NOT NULL,
	usuario			INT(8) UNSIGNED NOT NULL, -- refere a acesso.id
 	datahora		TIMESTAMP NOT NULL,
	INDEX datahora (datahora)
);

-- CAMPOS PADROES:
--	id		INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
--	dono		INT(8) UNSIGNED NOT NULL,
--	usuario		INT(8) UNSIGNED DEFAULT 0, -- refere a acesso.id

-- CREATE TABLE porta_consumo_observacao (
-- 	dono		INT(8) UNSIGNED NOT NULL,
-- 	usuario		INT(8) UNSIGNED DEFAULT 0, -- refere a acesso.id
-- 	observacao	VARCHAR(200) NOT NULL,
-- 	datahora	TIMESTAMP NOT NULL,
-- 	INDEX	dono (dono)
-- );

-- CREATE TABLE consumo_observacao (
-- 	dono		INT(8) UNSIGNED NOT NULL,
-- 	usuario		INT(8) UNSIGNED DEFAULT 0, -- refere a acesso.id
-- 	observacao	VARCHAR(200) NOT NULL,
-- 	datahora	TIMESTAMP NOT NULL,
-- 	INDEX	dono (dono)
-- );

-- DEMONSTRATIVO DE VENDA DIARIA: 

-- separar por "unidade" de produtos, tipo Grama, Unidade, etc...

-- CREATE TABLE etapa_producao (
-- 	id		INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
-- 	descricao	CHAR(40) NOT NULL,
-- 	departamento	INT(8) UNSIGNED NOT NULL,
-- 	PRIMARY KEY (id)
-- );

-- CREATE TABLE produto_rendimentos_perdas (
-- 	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
-- 	dono			INT(8) UNSIGNED NOT NULL, -- produto.id
-- 	fator 			FLOAT(8,6) NOT NULL,
-- 	frequencia		ENUM("Sempre, Selecionavel") DEFAULT "Sempre",
-- 	etapa_producao		INT(8) UNSIGNED NOT NULL,
-- 	PRIMARY KEY (id),
-- 	INDEX 	dono	(dono)
-- );

-- CREATE TABLE registro_producao (
-- 	id		INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
-- 	descricao	CHAR(40) NULL,
-- 	data		DATE NULL
-- );

-- CREATE TABLE registro_producao_produtos (
-- 	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
-- 	dono			INT(8) UNSIGNED NOT NULL, -- registro_producao.id
-- 	produto			INT(8) UNSIGNED NOT NULL, -- produto.id
-- 	produto_quantidade	INT(8) UNSIGNED NOT NULL,
-- 	PRIMARY KEY (id),
-- 	INDEX dono (dono)
-- );

-- Um compromisso é usado para agrupar operações diversas como: 
--
-- *Compras*, que pode conter:
--		*entrada de produtos no estoque* (compromisso_produto)
--		*parcelas de pagamento* (compromisso_parcela)
--
-- *Contas A Pagar*, que sao compromissos associados ou não a compras.
-- 
-- *Contas A Receber*, que sao compromissos associados ou não a vendas.
-- (Contas a Receber conflitam de certa maneira com porta_consumos em
--  estado pendente. Uma possivel solucao é a importação dos porta_consumos
--  quando for desejável.)

-- Movimentos individuais (nao associados a um compromisso), podem 
-- também existir. Estes tem o campo *dono* igual a 0.


-- CREATE TABLE compromisso (
-- 	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
-- 	dono			INT(8) UNSIGNED NOT NULL,	-- Refere a pessoa_instituicao.id
-- 	tipo			ENUM("Compra",
-- 				     "Compra (com Conta a Pagar)",
-- 				     "Conta a Pagar",
-- 				     "Venda (com Conta a Receber)",
-- 				     "Conta a Receber",
-- 				     "Outro"),
-- 	status_compra		ENUM("Pedido", "Recebido"), 
-- 	status_venda		ENUM("Pedido", "Recebido"),
-- 	status_pagamento	ENUM("Pago", "A Pagar", "Outro"),
-- 	documento		CHAR(20),
-- 	descricao		CHAR(200),
-- 	valor			FLOAT(8,6) NOT NULL,
-- 	data			DATE,
-- 	PRIMARY KEY (id)
-- );

-- CREATE TABLE compromisso_produto (
-- 	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
-- 	dono			INT(8) UNSIGNED NOT NULL, -- refere a compromisso.id
-- 	produto			INT(8) UNSIGNED NOT NULL, -- refere a produto.id
-- 	operacao		ENUM("Entrada", "Saída", "Outra"),
-- 	quantidade		INT(8) NOT NULL,
-- 	valor			FLOAT(8,6) NOT NULL,
-- 	valido_para_estoque	ENUM("Sim", "Não") DEFAULT "Sim" NOT NULL,
-- 	departamento_estoque 	INT(8) NOT NULL,
-- 	datahora		DATETIME NULL,
-- 	INDEX dono (dono),
-- 	INDEX datahora (datahora),
-- 	PRIMARY KEY (id)
-- );

-- CREATE TABLE compromisso_despesa (
-- 	id		INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
-- 	dono		INT(8) UNSIGNED NOT NULL,
-- 	descricao	CHAR(80) NOT NULL,
-- 	valor		FLOAT(8,6) NOT NULL,
-- 	INDEX dono (dono),
-- 	PRIMARY KEY (id)
-- );

-- CREATE TABLE compromisso_parcela (
-- 	id		INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
-- 	dono		INT(8) UNSIGNED NOT NULL,
-- 	situacao	ENUM("Pago", "A Pagar"),
-- 	forma_pagamento INT(8) UNSIGNED NOT NULL,
-- 	valor		FLOAT(8,6) NOT NULL,
-- 	data		DATE,
-- 	INDEX	dono (dono),
-- 	PRIMARY KEY (id)
-- );

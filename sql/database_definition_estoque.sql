-- Sempre ao calcular o estoque de um produto, o ultimo registro desta tabela
-- é levado em conta como o estoque atual em *datahora*. Outros campos que
-- devem (talvez opcionalmente) serem levados em conta incluem produtos vendidos
-- (consumo.produto_quantidade) e produtos de um compromisso (compromisso_produto.*)

CREATE TABLE estoque_ajuste_produto_grupo (
	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	departamento		INT(8) UNSIGNED NOT NULL, -- refere a departamento.id
	datahora_inicial	TIMESTAMP NULL,
	datahora		DATETIME NULL,
	observacao		CHAR(40) NOT NULL,
	usuario			INT(8) UNSIGNED NOT NULL, -- refere a acesso.id
	PRIMARY KEY (id)
);

CREATE TABLE estoque_ajuste_produto (
	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	grupo			INT(8) UNSIGNED NULL, -- refere a estoque_ajuste_produto_grupo.id -- opt
	produto			INT(8) UNSIGNED NOT NULL, -- refere a produto.id
	departamento		INT(8) UNSIGNED NOT NULL, -- refere a departamento.id
	quantidade		INT(8) NOT NULL,
	datahora_inicial	TIMESTAMP NULL,
	datahora		DATETIME NULL,
	observacao		CHAR(40) NULL,
	usuario			INT(8) UNSIGNED NOT NULL, -- refere a acesso.id
	INDEX produto (produto),
	PRIMARY KEY (id)
);

-- Movimentos incluem entradas, saidas e transferências entre departamentos.
-- Entradas podem ou não estar associadas com um compromisso.

-- Registros com departamento de origem E departamento de destino são consideradas
-- transferências. Nesse caso, o estoque do departamento origem *É* afetado pela
-- tranferência, ex:


-- Depto. Estoque Central:                Depto. Estoque Anexo:	  
-- =======================		  =====================	  
-- Coca Cola Lata 350ml -> Qtd = 100	  Coca Cola Lata 350ml -> Qtd = 0


-- Tranferência:
-- =============
--                   id: 2
--          compromisso: NULL
--              produto: 21     -> Coca Cola Lata 350ml
--  departamento_origem: 1      -> Depto. Estoque Central
-- departamento_destino: 8      -> Depto. Estoque Anexo
--           quantidade: 100
--  valido_para_estoque: Sim
--             datahora: 2003-02-08 10:05:34
--           observacao: Tranferência de produtos


-- Depto. Estoque Central:                Depto. Estoque Anexo:	  
-- =======================		  =====================	  
-- Coca Cola Lata 350ml -> Qtd = 0	  Coca Cola Lata 350ml -> Qtd = 100

CREATE TABLE estoque_movimento_produto_grupo (
	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	departamento_origem	INT(8) UNSIGNED NULL, -- refere a departamento.id
	departamento_destino	INT(8) UNSIGNED NULL, -- refere a departamento.id,
	datahora_inicial	TIMESTAMP NULL,
	datahora		DATETIME NULL,
	fornecedor		INT(8) UNSIGNED NULL,
	observacao		CHAR(40) NULL,
	usuario			INT(8) UNSIGNED NOT NULL, -- refere a acesso.id
	PRIMARY KEY (id)
);

CREATE TABLE estoque_movimento_produto (
	id			INT(8) UNSIGNED AUTO_INCREMENT NOT NULL DEFAULT 0,
	grupo			INT(8) UNSIGNED NULL, -- refere a estoque_movimento_produto_grupo.id -- opt
	produto			INT(8) UNSIGNED NOT NULL, -- refere a produto.id
	departamento_origem	INT(8) UNSIGNED NULL, -- refere a departamento.id
	departamento_destino	INT(8) UNSIGNED NULL, -- refere a departamento.id
	quantidade		INT(8) UNSIGNED NOT NULL,
	fornecedor		INT(8) UNSIGNED NULL,
	valor			FLOAT(8,2) NULL,
	datahora_inicial	TIMESTAMP NULL,
	datahora		DATETIME NULL,
	observacao		CHAR(40) NULL,
	usuario			INT(8) UNSIGNED NOT NULL, -- refere a acesso.id
	INDEX produto (produto),
	PRIMARY KEY (id)
);
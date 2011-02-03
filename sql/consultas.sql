-- ** RESUMO DE VENDAS **

-- Exemplo:

-- 00000021 - Bebidas Revenda:
-- ===========================

-- CÃ³digo    DescriÃ§Ã£o                               Qtd.Vend.  Valor
-- --------  --------------------------------------  ---------  --------
-- 00000001  Fanta Laranja 700 ml - Copo             40         48.00
-- 00000002  Coca-Cola Light 500 ml - Copo           20         15.00
-- ---------------------------------------------------------------------
-- SUB-TOTAL:					     60		63.00


SELECT
 	-- Nivel 1
	produto_grupo.id as codigo_grupo, produto_grupo.descricao as grupo,
	-- Nivel 2
	produto.id as codigo_produto, produto.descricao as produto,
	SUM(consumo.produto_quantidade) as quantidade,
	SUM(consumo.valor) as valor
FROM
	produto, produto_grupo, consumo, porta_consumo
WHERE
	produto.grupo = produto_grupo.id 
	AND consumo.produto = produto.id
	AND porta_consumo.datahora_final IS NOT NULL
	-- REQUER PARAMETROS, substituir 20000101 e NOW()
	AND porta_consumo.datahora_final BETWEEN 20000101 AND NOW()
GROUP BY
	consumo.produto
ORDER BY
	produto.grupo, consumo.produto;

-- -------------------------------------------------------------------------

-- ** TELFONES **

SELECT
	-- Nivel 1
	pessoa_instituicao.id as id, pessoa_instituicao.nome as nome,
	-- Nivel 2
	CONCAT('(', pessoa_instituicao_telefone.ddd, ')', ' ', pessoa_instituicao_telefone.numero, ' (', pessoa_instituicao_telefone.tipo, ')') as telefone
FROM
	pessoa_instituicao, pessoa_instituicao_telefone
WHERE
	pessoa_instituicao_telefone.dono = pessoa_instituicao.id
	-- REQUER PARAMETRO
	AND pessoa_instituicao.tipo = 'Pessoa'
ORDER BY
	nome;



-- ** CONSUMOS (PARA PRODUÇÃO) DE UMA ENCOMENDA  **

SELECT
	-- Nivel 1
	departamento.nome as departamento,
	-- Nivel 2
	SUM(consumo.produto_quantidade) as quantidade, 
	produto.unidade, 
	produto.descricao as produto
FROM
	consumo, produto, departamento 
WHERE	
	consumo.produto = produto.id
	AND produto.departamento_producao = departamento.id 
	AND consumo.dono = 21 
GROUP BY 
	produto 
ORDER BY
	departamento, produto;

-- ** DADOS DE UMA ENCOMENDA **

SELECT
	--porta_consumo
	porta_consumo.id,
	porta_consumo.status,
	porta_consumo.datahora,
	porta_consumo.datahora_inicial,
	porta_consumo.datahora_final,
	--encomenda
	encomenda.tipo_entrega,
	encomenda.local_entrega,
	encomenda.taxa_entrega,
	encomenda.observacoes,
	encomenda.datahora_entrega,
	encomenda.usuario,
	--pessoa_instituicao
	pessoa_instituicao.nome AS cliente
FROM
	porta_consumo, encomenda, pessoa_instituicao
WHERE
	porta_consumo.id = encomenda.dono
	AND porta_consumo.dono = pessoa_instituicao.id
	-- PARAMETRO
	AND porta_consumo.id = 21;


-- -------------------------------------------------------------------------

-- Status Caixa:


-- Saldo de Movimentos

SELECT 
	forma_pagamento.descricao as forma_pagamento,
	SUM(IF(STRCMP(tipo, "Crédito"), valor - (2 * valor), valor)) as valor,
FROM 
	forma_pagamento, caixa_movimento 
WHERE 
	forma_pagamento.id = caixa_movimento.forma_pagamento
	-- PARAMETROS: DataInicial, DataFinal
	AND datahora BETWEEN DataInicial AND DataFinal
	-- PARAMETRO: Usuario
        AND usuario = Usuario
GROUP BY 
	forma_pagamento;

-- Saldo de Recebimentos 

SELECT 
	forma_pagamento.descricao as forma_pagamento,
	SUM(porta_consumo_pagamento.valor) as valor
FROM 
	forma_pagamento, porta_consumo_pagamento 
WHERE 
	forma_pagamento.id = porta_consumo_pagamento.forma_pagamento
	-- PARAMETROS: DataInicial, DataFinal
	AND datahora BETWEEN DataInicial AND DataFinal
	-- PARAMETRO: Usuario
        AND usuario = Usuario
GROUP BY 
	forma_pagamento;


-- -------------------------------------------------------------------------

-- Resumo de produtos para producao de encomendas
-- (InhReportEncomendaProducao.pas)

SELECT 
	produto.descricao as produto, 
	SUM(consumo.produto_quantidade) as quantidade
FROM 
	produto, consumo, porta_consumo, encomenda
WHERE 
	-- LINKING
	(produto.id = consumo.produto)
	AND (encomenda.dono = porta_consumo.id)
	AND (consumo.dono = porta_consumo.id)
	-- Apenas Encomendas
	AND (porta_consumo.tipo = "Encomenda")
	-- Apenas Encomendas Abertas
	AND (porta_consumo.status = "Aberto")
	-- PARAMETROS: DataInicial, DataFinal
	AND (encomenda.datahora_entrega BETWEEN DataInicial AND DataFinal)
GROUP BY
	produto.descricao
ORDER BY
	produto.grupo, produto.descricao;

-- -------------------------------------------------------------------------

-- Listagem de encomendas, entre datas, e sucessivamente por horario

-- Primeiramente, a lista de encomendas dentro deste horário.

SELECT
	porta_consumo.id,
	encomenda.datahora_entrega
FROM
	porta_consumo,
	encomenda
WHERE
	-- LINKING
	(porta_consumo.id = encomenda.dono)
	-- PARAMETROS: DataInicial, DataFinal
	AND (encomenda.datahora_entrega BETWEEN DataInicial AND DataFinal)
ORDER BY
	datahora_entrega;

-- -------------------------------------------------------------------------

-- Lista de IDs dos porta-consumos de encomendas de um determinado cliente

-- POR TELEFONE DO CLIENTE

SELECT
	porta_consumo.id
FROM
	porta_consumo,
	encomenda,
	pessoa_instituicao,
	pessoa_instituicao_telefone
WHERE
	-- LINKING
	(porta_consumo.id = encomenda.dono)
	AND (porta_consumo.dono = pessoa_instituicao.id)
	AND (pessoa_instituicao_telefone.dono = pessoa_instituicao.id)
	-- RESTRICT
	AND (porta_consumo.tipo = "Encomenda")
	AND (porta_consumo.status = "Aberto")
	-- PARAMETROS: NumeroTelefone
	AND (pessoa_instituicao_telefone.numero = NumeroTelefone)
ORDER BY
	porta_consumo.id DESC;

-- POR NOME DO CLIENTE

SELECT
	porta_consumo.id
FROM
	porta_consumo,
	encomenda,
	pessoa_instituicao
WHERE
	-- LINKING
	(porta_consumo.id = encomenda.dono)
	AND (porta_consumo.dono = pessoa_instituicao.id)
	-- RESTRICT
	AND (porta_consumo.tipo = "Encomenda")
	AND (porta_consumo.status = "Aberto")
	-- PARAMETROS: Nome
	AND (pessoa_instituicao.nome LIKE Nome%)
ORDER BY
	porta_consumo.id DESC;

-- RESUMO DE PRODUTOS DE COMPROMISSOS VALIDOS PARA ESTOQUE

SELECT
	produto.descricao as Produto,
	SUM(compromisso_produto.quantidade) as Quantidade,
	compromisso_produto.operacao
FROM
	produto,
	compromisso_produto
WHERE
	-- LINKING
	(produto.id = compromisso_produto.produto)
GROUP BY
	compromisso_produto.produto,
	compromisso_produto.operacao
ORDER BY
	produto.descricao;



-- PRODUTOS COM ESTOQUE AJUSTADO 

SELECT
	DISTINCT(produto)
FROM
	produto_estoque_ajuste;


-- ULTIMOS AJUSTES (produto / datahora)

SELECT
	produto,
	MAX(datahora) AS datahora
FROM 
	produto_estoque_ajuste

GROUP BY
	produto
ORDER BY
	produto;



-- ULTIMOS AJUSTES DE ESTOQUE VALIDOS PARA CADA PRODUTO
-- (usado para o cálculo de estoque)


SELECT 
	DISTINCT(produto),
	quantidade,
	datahora
FROM
	produto_estoque_ajuste
ORDER BY
	produto,
	datahora DESC;

-- SOMA DOS CONSUMOS DE UM DETERMINADO GRUPO DE PRODUTOS

SELECT
	produto,
	SUM(produto_quantidade) AS quantidade,
	departamento_venda
FROM
	consumo
WHERE
	-- PARAMETRO: DataHoraInicial
	datahora_inicial > DataHoraInicial
GROUP BY
	produto,
	departamento_venda


-- 

SELECT
	*
FROM
	produto_estoque_ajuste
WHERE
	


--------------------------------------------------------


SELECT
	estoque_movimento_produto.produto AS produto_id,
	estoque_movimento_produto.departamento_origem AS departamento_origem_id,
	estoque_movimento_produto.departamento_destino AS departamento_destino_id,

	produto.descricao AS produto,
	departamento_origem.nome AS departamento_origem,
	departamento_destino.nome AS departamento_destino,

	estoque_movimento_produto.quantidade,
	estoque_movimento_produto.datahora,
	estoque_movimento_produto.usuario AS usuario_id,

	acesso.usuario AS usuario
FROM
	estoque_movimento_produto,
	produto,
	departamento AS departamento_origem,
	departamento AS departamento_destino,
	acesso
WHERE
	(estoque_movimento_produto.produto = produto.id) AND
	(estoque_movimento_produto.departamento_origem = departamento_origem.id) AND
	(estoque_movimento_produto.departamento_destino = departamento_destino.id) AND
	(acesso.id = estoque_movimento_produto.usuario);

--------------------------------------------------------------------------------
-- Movimento de entrada - departamento_origem = NULL
--------------------------------------------------------------------------------

SELECT
	estoque_movimento_produto.id,
	estoque_movimento_produto.produto AS produto_id,
	estoque_movimento_produto.departamento_destino AS departamento_id,

	produto.descricao AS produto,
	departamento.nome AS departamento,

	estoque_movimento_produto.quantidade,
	estoque_movimento_produto.datahora,
	estoque_movimento_produto.usuario AS usuario_id,

	acesso.usuario AS usuario
FROM
	estoque_movimento_produto,
	produto,
	departamento,
	acesso
WHERE
	(estoque_movimento_produto.produto = produto.id) AND
	(estoque_movimento_produto.departamento_origem IS NULL) AND
	(estoque_movimento_produto.departamento_destino = departamento.id) AND
	(acesso.id = estoque_movimento_produto.usuario);


--------------------------------------------------------------------------------
-- Ajuste Simples
--------------------------------------------------------------------------------

SELECT
	estoque_ajuste_produto.id,
	estoque_ajuste_produto.produto AS produto_id,
	estoque_ajuste_produto.departamento AS departamento_id,

	produto.descricao AS produto,
	departamento.nome AS departamento,

	estoque_ajuste_produto.quantidade,
	estoque_ajuste_produto.datahora,
	estoque_ajuste_produto.usuario AS usuario_id,

	acesso.usuario AS usuario
FROM
	estoque_ajuste_produto,
	produto,
	departamento,
	acesso
WHERE
	(estoque_movimento_produto.produto = produto.id) AND
	(estoque_movimento_produto.departamento_origem IS NULL) AND
	(estoque_movimento_produto.departamento_destino = departamento.id) AND
	(acesso.id = estoque_movimento_produto.usuario);


--------------------------------------------------------------------------------
-- Ajuste Simples
--------------------------------------------------------------------------------
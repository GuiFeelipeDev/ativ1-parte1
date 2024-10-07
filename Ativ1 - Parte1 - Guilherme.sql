/*
ALUNO: Guilherme Felipe Pereira

Atividade 1 - Parte 1
*/

-- Criação da tabela clientes
CREATE TABLE clientes (
	id_cliente SERIAL PRIMARY KEY,
	nome VARCHAR(255) NOT NULL
);

-- Criação da tabela pedidos
CREATE TABLE pedidos (
	id_pedido SERIAL PRIMARY KEY,
	id_cliente INT NOT NULL,
	data_pedido DATE NOT NULL,
	valor_total DECIMAL(10,2) DEFAULT 0.0,
	FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Criação da tabela itens_pedido
CREATE TABLE itens_pedido (
	id_item SERIAL PRIMARY KEY,
	id_pedido INT NOT NULL,
	descricao VARCHAR(255) NOT NULL,
	preco DECIMAL(10,2) NOT NULL,
	quantidade INT NOT NULL,
	FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
);

-- 100.000 Inserções na tabela de clientes
INSERT INTO clientes (nome)
SELECT
	'Cliente' || LEFT(md5(random()::text), 10) -- Geração de um nome aleatório usando Hash md5
FROM generate_series(1, 100000);


SELECT * FROM clientes;

-- 100.000 Inserções na tabela de pedidos
INSERT INTO pedidos(id_cliente, data_pedido, valor_total)
SELECT
	FLOOR(RANDOM() * 100000 + 1)::INT, -- Selecionando um ID de um cliente aleatório
	NOW() + (random() * (NOW()+'90 days' - NOW())) + '30 days', -- Selecionando um dia aleatório
	FLOOR(3000 + (random() * 2001)) -- Criando um valor total aleatório
FROM generate_series(1, 100000);

SELECT * FROM pedidos;

-- 100.000 Inserções na tabela de pedidos
INSERT INTO itens_pedido (id_pedido, descricao, preco, quantidade)
SELECT
	FLOOR(RANDOM() * 100000 + 1)::INT, -- Selecionando um ID de um pedido aleatório
	CONCAT('Descrição do pedido ', i), -- Criando uma descrição básica
	FLOOR(3000 + (random() * 1001)), -- Criando um preço aleatório
	FLOOR((random() * 10)::int) + 1 -- Criando uma quantidade aleatória
FROM generate_series(1, 100000) AS s(i);

SELECT * FROM itens_pedido;

-- BATERIA DE TESTES PARA A TABELA CLIENTES
-- SEM INDEXAÇÃO
EXPLAIN ANALYZE SELECT * FROM clientes WHERE nome = 'Clientebf65b59951';
EXPLAIN ANALYZE SELECT * FROM clientes WHERE id_cliente > 50001 AND id_cliente < 90001;
EXPLAIN ANALYZE SELECT * FROM clientes GROUP BY id_cliente;
EXPLAIN ANALYZE SELECT * FROM clientes ORDER BY nome;
-- INDEX B-TREE
CREATE INDEX idx_cliente_nome ON clientes USING BTREE(nome);
CREATE INDEX idx_cliente_id ON clientes USING BTREE(id_cliente);

EXPLAIN ANALYZE SELECT * FROM clientes WHERE nome = 'Clientebf65b59951';
EXPLAIN ANALYZE SELECT * FROM clientes WHERE id_cliente > 50001 AND id_cliente < 90001;
EXPLAIN ANALYZE SELECT * FROM clientes GROUP BY id_cliente;
EXPLAIN ANALYZE SELECT * FROM clientes ORDER BY nome;
-- INDEX B-TREE COM CLUSTER
CLUSTER clientes USING idx_cliente_nome;
CLUSTER clientes USING idx_cliente_id;

EXPLAIN ANALYZE SELECT * FROM clientes WHERE nome = 'Clientebf65b59951';
EXPLAIN ANALYZE SELECT * FROM clientes WHERE id_cliente > 50001 AND id_cliente < 90001;
EXPLAIN ANALYZE SELECT * FROM clientes GROUP BY id_cliente;
EXPLAIN ANALYZE SELECT * FROM clientes ORDER BY nome;
-- INDEX HASH
CREATE INDEX idx_h_cliente_nome ON clientes USING HASH(nome);

EXPLAIN ANALYZE SELECT * FROM clientes WHERE nome = 'Clientebf65b59951';
-- ========================================

-- BATERIA DE TESTES PARA A TABELA PEDIDOS
-- SEM INDEXAÇÃO
EXPLAIN ANALYZE SELECT * FROM pedidos WHERE data_pedido = '2025-01-17';
EXPLAIN ANALYZE SELECT * FROM pedidos WHERE valor_total > 3500 AND valor_total < 4000;
EXPLAIN ANALYZE SELECT * FROM pedidos GROUP BY id_pedido;
EXPLAIN ANALYZE SELECT * FROM pedidos ORDER BY valor_total;
-- INDEX B-TREE
CREATE INDEX idx_pedidos_data ON pedidos USING BTREE(data_pedido);
CREATE INDEX idx_pedidos_id ON pedidos USING BTREE(id_pedido);
CREATE INDEX idx_pedidos_valor_total ON pedidos USING BTREE(valor_total);

EXPLAIN ANALYZE SELECT * FROM pedidos WHERE data_pedido = '2025-01-17';
EXPLAIN ANALYZE SELECT * FROM pedidos WHERE valor_total > 3500 AND valor_total < 4000;
EXPLAIN ANALYZE SELECT * FROM pedidos GROUP BY id_pedido;
EXPLAIN ANALYZE SELECT * FROM pedidos ORDER BY valor_total;
-- INDEX B-TREE COM CLUSTER
CLUSTER pedidos USING idx_pedidos_data;
CLUSTER pedidos USING idx_pedidos_id;
CLUSTER pedidos USING idx_pedidos_valor_total;

EXPLAIN ANALYZE SELECT * FROM pedidos WHERE data_pedido = '2025-01-17';
EXPLAIN ANALYZE SELECT * FROM pedidos WHERE valor_total > 3500 AND valor_total < 4000;
EXPLAIN ANALYZE SELECT * FROM pedidos GROUP BY id_pedido;
EXPLAIN ANALYZE SELECT * FROM pedidos ORDER BY valor_total;
-- INDEX HASH
-- Nenhuma das consultas utilizadas suporta o index HASH
-- ========================================

-- BATERIA DE TESTES PARA A TABELA PEDIDOS
-- SEM INDEXAÇÃO
EXPLAIN ANALYZE SELECT * FROM itens_pedido WHERE preco = 3722.00;
EXPLAIN ANALYZE SELECT * FROM itens_pedido WHERE preco > 3500 AND preco < 4200;
EXPLAIN ANALYZE SELECT * FROM itens_pedido GROUP BY id_item;
EXPLAIN ANALYZE SELECT * FROM itens_pedido ORDER BY quantidade;

-- INDEX B-TREE
CREATE INDEX idx_itens_preco ON itens_pedido USING BTREE(preco);
CREATE INDEX idx_itens_id ON itens_pedido USING BTREE(id_item);
CREATE INDEX idx_itens_quantidade ON itens_pedido USING BTREE(quantidade);

EXPLAIN ANALYZE SELECT * FROM itens_pedido WHERE preco = 3722.00;
EXPLAIN ANALYZE SELECT * FROM itens_pedido WHERE preco > 3500 AND preco < 4200;
EXPLAIN ANALYZE SELECT * FROM itens_pedido GROUP BY id_item;
EXPLAIN ANALYZE SELECT * FROM itens_pedido ORDER BY quantidade;
-- INDEX INDEX B-TREE COM CLUSTER
CLUSTER itens_pedido USING idx_itens_preco;
CLUSTER itens_pedido USING idx_itens_id;
CLUSTER itens_pedido USING idx_itens_quantidade;

EXPLAIN ANALYZE SELECT * FROM itens_pedido WHERE preco = 3722.00;
EXPLAIN ANALYZE SELECT * FROM itens_pedido WHERE preco > 3500 AND preco < 4200;
EXPLAIN ANALYZE SELECT * FROM itens_pedido GROUP BY id_item;
EXPLAIN ANALYZE SELECT * FROM itens_pedido ORDER BY quantidade;
-- INDEX HASH
CREATE INDEX idx_h_itens_preco ON itens_pedido USING HASH(preco);

EXPLAIN ANALYZE SELECT * FROM itens_pedido WHERE preco = 3722.00;
-- ========================================
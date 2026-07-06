-- updates -- select antes e depois de cada um pra mostrar a mudanca

USE falls_car;

-- cidade: atualizar estado
SELECT id_cidade, nome, estado FROM cidade WHERE id_cidade = 1;
UPDATE cidade SET estado = 'RJ' WHERE id_cidade = 1;
SELECT id_cidade, nome, estado FROM cidade WHERE id_cidade = 1;

-- loja: atualizar telefone
SELECT id_loja, nome, telefone FROM loja WHERE id_loja = 1;
UPDATE loja SET telefone = '21-3000-0099' WHERE id_loja = 1;
SELECT id_loja, nome, telefone FROM loja WHERE id_loja = 1;

-- categoria_veiculo: reajuste de diaria
SELECT id_categoria, descricao, valor_diaria FROM categoria_veiculo WHERE id_categoria = 1;
UPDATE categoria_veiculo SET valor_diaria = 130.00 WHERE id_categoria = 1;
SELECT id_categoria, descricao, valor_diaria FROM categoria_veiculo WHERE id_categoria = 1;

-- automovel: carro saiu da manutencao
SELECT placa, modelo, status FROM automovel WHERE id_automovel = 3;
UPDATE automovel SET status = 'LIVRE' WHERE id_automovel = 3;
SELECT placa, modelo, status FROM automovel WHERE id_automovel = 3;

-- cliente: atualizar telefone
SELECT id_cliente, nome, telefone FROM cliente WHERE id_cliente = 1;
UPDATE cliente SET telefone = '21-98888-0001' WHERE id_cliente = 1;
SELECT id_cliente, nome, telefone FROM cliente WHERE id_cliente = 1;

-- cartao_credito: renovar validade
SELECT id_cartao, nome_titular, validade FROM cartao_credito WHERE id_cartao = 1;
UPDATE cartao_credito SET validade = '09/2029' WHERE id_cartao = 1;
SELECT id_cartao, nome_titular, validade FROM cartao_credito WHERE id_cartao = 1;

-- motorista: marcar como indisponivel
SELECT nome, IF(disponivel,'Disponivel','Indisponivel') AS situacao FROM motorista WHERE id_motorista = 1;
UPDATE motorista SET disponivel = FALSE WHERE id_motorista = 1;
SELECT nome, IF(disponivel,'Disponivel','Indisponivel') AS situacao FROM motorista WHERE id_motorista = 1;

-- manutencao: registrar data de fim
SELECT id_manutencao, data_inicio, data_fim, descricao FROM manutencao WHERE id_manutencao = 1;
UPDATE manutencao SET data_fim = '2026-06-16' WHERE id_manutencao = 1;
SELECT id_manutencao, data_inicio, data_fim, descricao FROM manutencao WHERE id_manutencao = 1;

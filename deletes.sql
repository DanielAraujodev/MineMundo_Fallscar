-- deletes de cada tabela
-- uso id 99 (que nao existe) so pra mostrar a sintaxe sem
-- apagar nada de verdade -- as tabelas tem FK entre si, ia dar
-- erro de constraint se eu tentasse apagar algo que ta em uso
-- entao o esperado e "0 linhas afetadas" em todos

USE falls_car;

-- contagem antes dos deletes
SELECT COUNT(*) AS total_cidades    FROM cidade;
SELECT COUNT(*) AS total_lojas      FROM loja;
SELECT COUNT(*) AS total_automoveis FROM automovel;
SELECT COUNT(*) AS total_clientes   FROM cliente;

-- deletes em cada tabela
DELETE FROM manutencao        WHERE id_manutencao  = 99;
DELETE FROM locacao           WHERE id_locacao      = 99;
DELETE FROM pagamento         WHERE id_pagamento    = 99;
DELETE FROM reserva           WHERE id_reserva      = 99;
DELETE FROM motorista         WHERE id_motorista    = 99;
DELETE FROM forma_pagamento   WHERE id_forma_pagamento = 99;
DELETE FROM automovel         WHERE id_automovel    = 99;
DELETE FROM distancia_loja    WHERE id_loja_a = 99 AND id_loja_b = 98;
DELETE FROM categoria_veiculo WHERE id_categoria    = 99;
DELETE FROM loja              WHERE id_loja         = 99;
DELETE FROM cliente           WHERE id_cliente      = 99;
DELETE FROM cidade            WHERE id_cidade       = 99;

-- contagem depois: deve ser igual a de antes
SELECT COUNT(*) AS total_cidades    FROM cidade;
SELECT COUNT(*) AS total_lojas      FROM loja;
SELECT COUNT(*) AS total_automoveis FROM automovel;
SELECT COUNT(*) AS total_clientes   FROM cliente;

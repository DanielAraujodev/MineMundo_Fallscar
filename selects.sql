-- selects com join, mostrando os dados relacionados

USE falls_car;

-- frota completa com categoria, loja e cidade
SELECT a.placa, a.modelo, a.ano_fabricacao,
       cv.descricao AS categoria, cv.valor_diaria,
       l.nome AS loja_atual, c.nome AS cidade, a.status
FROM automovel a
JOIN categoria_veiculo cv ON cv.id_categoria = a.id_categoria
JOIN loja l               ON l.id_loja       = a.id_loja_atual
JOIN cidade c             ON c.id_cidade      = l.id_cidade
ORDER BY a.status, cv.descricao;

-- clientes com sua forma de pagamento
SELECT c.nome AS cliente, c.email, fp.tipo, fp.referencia
FROM cliente c
JOIN forma_pagamento fp ON fp.id_cliente = c.id_cliente
ORDER BY c.nome;

-- reservas ativas com todos os dados legíveis
SELECT r.id_reserva, c.nome AS cliente, cv.descricao AS categoria,
       l.nome AS loja_retirada, r.data_retirada_prevista,
       r.data_devolucao_prevista, r.canal, r.status
FROM reserva r
JOIN cliente c            ON c.id_cliente   = r.id_cliente
JOIN categoria_veiculo cv ON cv.id_categoria = r.id_categoria
JOIN loja l               ON l.id_loja       = r.id_loja_retirada
ORDER BY r.data_retirada_prevista;

-- pagamentos com forma de pagamento usada
SELECT p.id_pagamento, c.nome AS cliente, fp.tipo AS forma,
       fp.referencia, p.tipo, p.valor, p.status, p.data_pagamento
FROM pagamento p
JOIN reserva r          ON r.id_reserva         = p.id_reserva
JOIN cliente c          ON c.id_cliente          = r.id_cliente
JOIN forma_pagamento fp ON fp.id_forma_pagamento = p.id_forma_pagamento
ORDER BY p.data_pagamento;

-- distancias entre lojas
SELECT ci.nome AS cidade, la.nome AS loja_origem,
       lb.nome AS loja_destino, d.distancia_km
FROM distancia_loja d
JOIN loja la   ON la.id_loja   = d.id_loja_a
JOIN loja lb   ON lb.id_loja   = d.id_loja_b
JOIN cidade ci ON ci.id_cidade = la.id_cidade
ORDER BY ci.nome, d.distancia_km;

-- locacoes em andamento
SELECT l.id_locacao, c.nome AS cliente, a.placa, a.modelo,
       lo.nome AS loja_retirada, l.data_retirada_real,
       l.km_retirada, l.status
FROM locacao l
JOIN reserva r   ON r.id_reserva   = l.id_reserva
JOIN cliente c   ON c.id_cliente   = r.id_cliente
JOIN automovel a ON a.id_automovel = l.id_automovel
JOIN loja lo     ON lo.id_loja     = l.id_loja_retirada_real
WHERE l.status = 'EM_ANDAMENTO';

-- manutencoes abertas
SELECT a.placa, a.modelo, lo.nome AS loja,
       m.data_inicio, m.descricao
FROM manutencao m
JOIN automovel a ON a.id_automovel = m.id_automovel
JOIN loja lo     ON lo.id_loja     = m.id_loja
WHERE m.data_fim IS NULL;

-- funcionalidade principal: achar e alocar o carro livre mais
-- proximo da loja de retirada (pode ser carro de outra loja,
-- desde que seja da mesma cidade)
-- exemplo usado: joao reservou um economico pra retirar em
-- copacabana (reserva 1), vamos achar e alocar o carro pra ele

USE falls_car;

-- 1) reserva do joao
SELECT
    r.id_reserva,
    c.nome        AS cliente,
    cv.descricao  AS categoria_desejada,
    l.nome        AS loja_retirada,
    r.data_retirada_prevista,
    r.data_devolucao_prevista
FROM reserva r
JOIN cliente c            ON c.id_cliente   = r.id_cliente
JOIN categoria_veiculo cv ON cv.id_categoria = r.id_categoria
JOIN loja l               ON l.id_loja       = r.id_loja_retirada
WHERE r.id_reserva = 1;

-- 2) carros economicos livres no rio (so pra visualizar as opcoes)
SELECT
    a.placa,
    a.modelo,
    l.nome   AS loja_atual,
    a.status
FROM automovel a
JOIN categoria_veiculo cv ON cv.id_categoria = a.id_categoria
JOIN loja l               ON l.id_loja       = a.id_loja_atual
JOIN cidade ci            ON ci.id_cidade     = l.id_cidade
WHERE cv.descricao = 'Economico'
  AND a.status     = 'LIVRE'
  AND ci.nome      = 'Rio de Janeiro';

-- 3) agora o sistema acha o mais proximo de verdade
-- carro que ja esta na propria loja entra com distancia 0
-- (por isso o COALESCE no LEFT JOIN com distancia_loja)
SELECT
    a.id_automovel,
    a.placa,
    a.modelo,
    l.nome   AS loja_onde_esta,
    COALESCE(d.distancia_km, 0) AS distancia_km
FROM reserva r
JOIN loja lr               ON lr.id_loja      = r.id_loja_retirada
JOIN automovel a           ON a.id_categoria  = r.id_categoria
                           AND a.status        = 'LIVRE'
JOIN loja l                ON l.id_loja       = a.id_loja_atual
                           AND l.id_cidade     = lr.id_cidade
LEFT JOIN distancia_loja d ON d.id_loja_a     = lr.id_loja
                           AND d.id_loja_b     = a.id_loja_atual
WHERE r.id_reserva = 1
ORDER BY distancia_km ASC
LIMIT 1;
-- da o carro ABC1A12, que ja ta em copacabana mesmo (distancia 0)

-- 4) aloca o carro de verdade, numa transacao
-- o "AND status = LIVRE" no update evita duas pessoas
-- pegarem o mesmo carro ao mesmo tempo
START TRANSACTION;

UPDATE automovel
   SET status = 'ALUGADO'
 WHERE id_automovel = 2
   AND status = 'LIVRE';

INSERT INTO locacao (id_reserva, id_automovel, id_motorista,
                     id_loja_retirada_real, data_retirada_real,
                     km_retirada, status)
VALUES (1, 2, NULL, 2, '2026-06-25 10:05:00', 15320, 'EM_ANDAMENTO');

UPDATE reserva SET status = 'CONCLUIDA' WHERE id_reserva = 1;

COMMIT;

-- 5) confere se deu certo
SELECT placa, modelo, status FROM automovel WHERE id_automovel = 2; -- virou ALUGADO

SELECT
    l.id_locacao,
    c.nome        AS cliente,
    a.placa,
    a.modelo,
    lo.nome       AS loja_retirada,
    l.data_retirada_real,
    l.km_retirada,
    l.status
FROM locacao l
JOIN reserva r   ON r.id_reserva   = l.id_reserva
JOIN cliente c   ON c.id_cliente   = r.id_cliente
JOIN automovel a ON a.id_automovel = l.id_automovel
JOIN loja lo     ON lo.id_loja     = l.id_loja_retirada_real
WHERE l.id_locacao = 2;

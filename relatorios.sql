-- relatorios estatisticos sobre as locacoes
USE falls_car;

-- faturamento liquido por loja (antecipado + multa - reembolso)
SELECT
    lo.nome AS loja,
    COUNT(DISTINCT l.id_locacao) AS qtd_locacoes,
    SUM(CASE WHEN p.tipo IN ('ANTECIPADO','MULTA') THEN p.valor ELSE 0 END) -
    SUM(CASE WHEN p.tipo = 'REEMBOLSO'             THEN p.valor ELSE 0 END) AS faturamento_liquido
FROM locacao l
JOIN loja lo     ON lo.id_loja    = l.id_loja_retirada_real
JOIN pagamento p ON p.id_reserva  = l.id_reserva
GROUP BY lo.id_loja, lo.nome
ORDER BY faturamento_liquido DESC;

-- faturamento por categoria de veiculo
SELECT
    cv.descricao AS categoria,
    COUNT(DISTINCT l.id_locacao) AS qtd_locacoes,
    SUM(CASE WHEN p.tipo IN ('ANTECIPADO','MULTA') THEN p.valor ELSE 0 END) -
    SUM(CASE WHEN p.tipo = 'REEMBOLSO'             THEN p.valor ELSE 0 END) AS faturamento_liquido
FROM locacao l
JOIN automovel a          ON a.id_automovel  = l.id_automovel
JOIN categoria_veiculo cv ON cv.id_categoria = a.id_categoria
JOIN pagamento p          ON p.id_reserva    = l.id_reserva
GROUP BY cv.id_categoria, cv.descricao
ORDER BY faturamento_liquido DESC;

-- top 5 carros mais alugados
SELECT
    a.placa,
    a.modelo,
    cv.descricao        AS categoria,
    COUNT(l.id_locacao) AS qtd_locacoes
FROM locacao l
JOIN automovel a          ON a.id_automovel  = l.id_automovel
JOIN categoria_veiculo cv ON cv.id_categoria = a.id_categoria
GROUP BY a.id_automovel, a.placa, a.modelo, cv.descricao
ORDER BY qtd_locacoes DESC
LIMIT 5;

-- ocupacao da frota por loja
SELECT
    lo.nome AS loja,
    COUNT(*)                                                AS total_carros,
    SUM(a.status = 'ALUGADO')                              AS alugados,
    SUM(a.status = 'LIVRE')                                AS livres,
    SUM(a.status = 'MANUTENCAO')                           AS em_manutencao,
    ROUND(100 * SUM(a.status = 'ALUGADO') / COUNT(*), 1)  AS pct_ocupacao
FROM automovel a
JOIN loja lo ON lo.id_loja = a.id_loja_atual
GROUP BY lo.id_loja, lo.nome
ORDER BY pct_ocupacao DESC;

-- tempo medio das locacoes ja finalizadas (em dias)
SELECT
    AVG(DATEDIFF(data_devolucao_real, data_retirada_real)) AS media_dias_locacao
FROM locacao
WHERE status = 'FINALIZADA';

-- resumo de multas e reembolsos gerados
SELECT
    p.tipo,
    COUNT(*)     AS quantidade,
    SUM(p.valor) AS valor_total
FROM pagamento p
WHERE p.tipo IN ('MULTA','REEMBOLSO')
GROUP BY p.tipo;

-- faturamento mensal
SELECT
    DATE_FORMAT(l.data_retirada_real, '%Y-%m') AS mes,
    COUNT(DISTINCT l.id_locacao)               AS qtd_locacoes,
    SUM(CASE WHEN p.tipo IN ('ANTECIPADO','MULTA') THEN p.valor ELSE 0 END) -
    SUM(CASE WHEN p.tipo = 'REEMBOLSO'             THEN p.valor ELSE 0 END) AS faturamento_liquido
FROM locacao l
JOIN pagamento p ON p.id_reserva = l.id_reserva
WHERE l.status = 'FINALIZADA'
GROUP BY DATE_FORMAT(l.data_retirada_real, '%Y-%m')
ORDER BY mes;

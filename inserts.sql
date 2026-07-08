-- inserts de teste, com select depois de cada um pra ver o que entrou

USE falls_car;

-- cidade
INSERT INTO cidade (nome, estado) VALUES
('Rio de Janeiro', 'RJ'),
('Sao Paulo', 'SP');

SELECT * FROM cidade;

-- loja
INSERT INTO loja (nome, endereco, telefone, id_cidade) VALUES
('Falls Car - Aeroporto Galeao',    'Av. Vinte de Janeiro, s/n', '21-3000-0001', 1),
('Falls Car - Copacabana',          'Av. Atlantica, 500',        '21-3000-0002', 1),
('Falls Car - Aeroporto Guarulhos', 'Rod. Helio Smidt, s/n',     '11-3000-0003', 2);

SELECT * FROM loja;

-- distancia entre lojas (so entre lojas da mesma cidade)
INSERT INTO distancia_loja (id_loja_a, id_loja_b, distancia_km) VALUES
(1, 2, 18.5),
(2, 1, 18.5);

SELECT la.nome AS de, lb.nome AS para, d.distancia_km
FROM distancia_loja d
JOIN loja la ON la.id_loja = d.id_loja_a
JOIN loja lb ON lb.id_loja = d.id_loja_b;

-- categoria de veiculo
INSERT INTO categoria_veiculo (descricao, valor_diaria) VALUES
('Economico',      120.00),
('Intermediario',  180.00),
('SUV',            250.00);

SELECT * FROM categoria_veiculo;

-- automovel
INSERT INTO automovel (placa, modelo, ano_fabricacao, id_categoria, id_loja_atual, status) VALUES
('ABC1A11', 'Chevrolet Onix', 2024, 1, 1, 'LIVRE'),
('ABC1A12', 'Chevrolet Onix', 2024, 1, 2, 'LIVRE'),
('XYZ2B22', 'Jeep Compass',   2023, 3, 1, 'MANUTENCAO'),
('ABC3C33', 'Honda Civic',    2024, 2, 3, 'LIVRE');

SELECT a.placa, a.modelo, a.ano_fabricacao,
       cv.descricao AS categoria, l.nome AS loja, a.status
FROM automovel a
JOIN categoria_veiculo cv ON cv.id_categoria = a.id_categoria
JOIN loja l               ON l.id_loja       = a.id_loja_atual;

-- cliente
INSERT INTO cliente (nome, cpf, numero_cnh, validade_cnh, telefone, email) VALUES
('Joao Pedro Silva',   '12345678901', 'CNH001122', '2028-05-10', '21-99999-0001', 'joao.pedro@email.com'),
('Mariana Costa Lima', '98765432100', 'CNH003344', '2027-11-20', '11-98888-0002', 'mariana.lima@email.com');

SELECT * FROM cliente;

-- cartao de credito
INSERT INTO cartao_credito (id_cliente, ultimos_digitos, bandeira, nome_titular, validade) VALUES
(1, '1111', 'Visa',       'JOAO PEDRO SILVA',   '08/2029'),
(2, '0004', 'Mastercard', 'MARIANA COSTA LIMA', '03/2028');

SELECT cc.id_cartao, c.nome AS cliente, cc.ultimos_digitos,
       cc.bandeira, cc.nome_titular, cc.validade
FROM cartao_credito cc
JOIN cliente c ON c.id_cliente = cc.id_cliente;

-- motorista
INSERT INTO motorista (nome, cnh, validade_cnh, id_loja, disponivel) VALUES
('Carlos Souza', 'CNH998877', '2027-02-01', 1, TRUE);

SELECT m.nome, m.cnh, m.validade_cnh, l.nome AS loja,
       IF(m.disponivel, 'Sim', 'Nao') AS disponivel
FROM motorista m
JOIN loja l ON l.id_loja = m.id_loja;

-- reserva
INSERT INTO reserva (id_cliente, id_categoria, id_loja_retirada,
                     data_retirada_prevista, data_devolucao_prevista,
                     canal, com_motorista, status) VALUES
(1, 1, 2, '2026-06-25 10:00:00', '2026-06-28 10:00:00', 'INTERNET', FALSE, 'CONFIRMADA'),
(2, 2, 3, '2026-06-20 09:00:00', '2026-06-23 09:00:00', 'LOJA',     FALSE, 'CONFIRMADA');

SELECT r.id_reserva, c.nome AS cliente, cv.descricao AS categoria,
       l.nome AS loja_retirada, r.data_retirada_prevista,
       r.data_devolucao_prevista, r.canal, r.status
FROM reserva r
JOIN cliente c            ON c.id_cliente   = r.id_cliente
JOIN categoria_veiculo cv ON cv.id_categoria = r.id_categoria
JOIN loja l               ON l.id_loja       = r.id_loja_retirada;

-- pagamento antecipado das duas reservas
INSERT INTO pagamento (id_reserva, id_cartao, tipo, valor, status) VALUES
(1, 1, 'ANTECIPADO', 360.00, 'APROVADO'),
(2, 2, 'ANTECIPADO', 540.00, 'APROVADO');

SELECT p.id_pagamento, c.nome AS cliente, cc.bandeira,
       cc.ultimos_digitos, p.tipo, p.valor, p.status, p.data_pagamento
FROM pagamento p
JOIN reserva r        ON r.id_reserva = p.id_reserva
JOIN cliente c        ON c.id_cliente = r.id_cliente
JOIN cartao_credito cc ON cc.id_cartao = p.id_cartao;

-- locacao da Mariana (reserva 2, efetivada direto na loja)
INSERT INTO locacao (id_reserva, id_automovel, id_motorista,
                     id_loja_retirada_real, data_retirada_real,
                     km_retirada, status)
VALUES (2, 4, NULL, 3, '2026-06-20 09:10:00', 8500, 'EM_ANDAMENTO');

UPDATE automovel SET status = 'ALUGADO' WHERE id_automovel = 4;

SELECT l.id_locacao, c.nome AS cliente, a.placa, a.modelo,
       lo.nome AS loja_retirada, l.data_retirada_real, l.km_retirada, l.status
FROM locacao l
JOIN reserva r   ON r.id_reserva   = l.id_reserva
JOIN cliente c   ON c.id_cliente   = r.id_cliente
JOIN automovel a ON a.id_automovel = l.id_automovel
JOIN loja lo     ON lo.id_loja     = l.id_loja_retirada_real;

-- manutencao
INSERT INTO manutencao (id_automovel, id_loja, data_inicio, descricao, custo) VALUES
(3, 1, '2026-06-15', 'Troca de pastilhas e discos de freio', 480.00);

SELECT m.id_manutencao, a.placa, a.modelo, lo.nome AS loja,
       m.data_inicio, m.data_fim, m.descricao, m.custo
FROM manutencao m
JOIN automovel a ON a.id_automovel = m.id_automovel
JOIN loja lo     ON lo.id_loja     = m.id_loja;

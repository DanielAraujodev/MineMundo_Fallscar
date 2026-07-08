-- criacao do banco (mysql / mariadb)

CREATE DATABASE IF NOT EXISTS falls_car
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_general_ci;

USE falls_car;

-- cidade
CREATE TABLE cidade (
    id_cidade   INT AUTO_INCREMENT PRIMARY KEY,
    nome        VARCHAR(80)  NOT NULL,
    estado      CHAR(2)      NOT NULL,
    UNIQUE KEY uk_cidade (nome, estado)
);

-- loja
CREATE TABLE loja (
    id_loja     INT AUTO_INCREMENT PRIMARY KEY,
    nome        VARCHAR(80)  NOT NULL,
    endereco    VARCHAR(150) NOT NULL,
    telefone    VARCHAR(20),
    id_cidade   INT NOT NULL,
    CONSTRAINT fk_loja_cidade FOREIGN KEY (id_cidade)
        REFERENCES cidade(id_cidade)
);

-- distancia entre lojas da mesma cidade
-- usada para encontrar o carro mais proximo na funcionalidade principal
CREATE TABLE distancia_loja (
    id_loja_a     INT NOT NULL,
    id_loja_b     INT NOT NULL,
    distancia_km  DECIMAL(6,2) NOT NULL,
    PRIMARY KEY (id_loja_a, id_loja_b),
    CONSTRAINT fk_dist_loja_a FOREIGN KEY (id_loja_a) REFERENCES loja(id_loja),
    CONSTRAINT fk_dist_loja_b FOREIGN KEY (id_loja_b) REFERENCES loja(id_loja),
    CONSTRAINT ck_dist_diferentes CHECK (id_loja_a <> id_loja_b)
);

-- categoria do veiculo
CREATE TABLE categoria_veiculo (
    id_categoria   INT AUTO_INCREMENT PRIMARY KEY,
    descricao      VARCHAR(40) NOT NULL,
    valor_diaria   DECIMAL(8,2) NOT NULL
);

-- automovel
CREATE TABLE automovel (
    id_automovel    INT AUTO_INCREMENT PRIMARY KEY,
    placa           VARCHAR(8)  NOT NULL UNIQUE,
    modelo          VARCHAR(60) NOT NULL,
    ano_fabricacao  YEAR        NOT NULL,
    id_categoria    INT NOT NULL,
    id_loja_atual   INT NOT NULL,
    status          ENUM('LIVRE','ALUGADO','RESERVADO','MANUTENCAO')
                    NOT NULL DEFAULT 'LIVRE',
    CONSTRAINT fk_auto_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria_veiculo(id_categoria),
    CONSTRAINT fk_auto_loja FOREIGN KEY (id_loja_atual)
        REFERENCES loja(id_loja)
);

-- cliente
CREATE TABLE cliente (
    id_cliente       INT AUTO_INCREMENT PRIMARY KEY,
    nome             VARCHAR(100) NOT NULL,
    cpf              CHAR(11)     NOT NULL UNIQUE,
    numero_cnh       VARCHAR(20)  NOT NULL,
    validade_cnh     DATE         NOT NULL,
    telefone         VARCHAR(20),
    email            VARCHAR(100) NOT NULL UNIQUE
);

-- cartao de credito do cliente
CREATE TABLE cartao_credito (
    id_cartao      INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente     INT NOT NULL,
    ultimos_digitos CHAR(4)      NOT NULL,
    bandeira       VARCHAR(20)  NOT NULL,
    nome_titular   VARCHAR(100) NOT NULL,
    validade       CHAR(7)      NOT NULL,
    CONSTRAINT fk_cartao_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente)
);

-- motorista (funcionario que pode conduzir o veiculo)
CREATE TABLE motorista (
    id_motorista    INT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(100) NOT NULL,
    cnh             VARCHAR(20)  NOT NULL,
    validade_cnh    DATE         NOT NULL,
    id_loja         INT NOT NULL,
    disponivel      BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_motorista_loja FOREIGN KEY (id_loja)
        REFERENCES loja(id_loja)
);

-- reserva feita pelo cliente
CREATE TABLE reserva (
    id_reserva              INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente              INT NOT NULL,
    id_categoria            INT NOT NULL,
    id_loja_retirada        INT NOT NULL,
    data_reserva            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_retirada_prevista  DATETIME NOT NULL,
    data_devolucao_prevista DATETIME NOT NULL,
    canal                   ENUM('INTERNET','TELEFONE','LOJA') NOT NULL,
    com_motorista           BOOLEAN NOT NULL DEFAULT FALSE,
    status                  ENUM('CONFIRMADA','CANCELADA','CONCLUIDA')
                            NOT NULL DEFAULT 'CONFIRMADA',
    CONSTRAINT fk_reserva_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente),
    CONSTRAINT fk_reserva_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria_veiculo(id_categoria),
    CONSTRAINT fk_reserva_loja FOREIGN KEY (id_loja_retirada)
        REFERENCES loja(id_loja)
);

-- pagamento
-- tipo ANTECIPADO: cobrado na hora da reserva
-- tipo MULTA: gerado se o cliente devolver atrasado
-- tipo REEMBOLSO: gerado se o cliente devolver antes do prazo
-- o unique em (id_reserva, tipo) garante no maximo um registro de cada tipo por reserva
CREATE TABLE pagamento (
    id_pagamento   INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva     INT NOT NULL,
    id_cartao      INT NOT NULL,
    tipo           ENUM('ANTECIPADO','MULTA','REEMBOLSO') NOT NULL,
    valor          DECIMAL(8,2) NOT NULL,
    data_pagamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status         ENUM('APROVADO','NEGADO','REEMBOLSADO') NOT NULL,
    UNIQUE KEY uk_reserva_tipo (id_reserva, tipo),
    CONSTRAINT fk_pag_reserva FOREIGN KEY (id_reserva)
        REFERENCES reserva(id_reserva),
    CONSTRAINT fk_pag_cartao FOREIGN KEY (id_cartao)
        REFERENCES cartao_credito(id_cartao)
);

-- locacao
-- valor_ajuste e tipo_ajuste so sao preenchidos na devolucao
-- valor_ajuste: diferenca entre o que foi pago e o valor real
-- tipo_ajuste: MULTA, REEMBOLSO ou NENHUM
CREATE TABLE locacao (
    id_locacao            INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva            INT NOT NULL UNIQUE,
    id_automovel          INT NOT NULL,
    id_motorista          INT NULL,
    id_loja_retirada_real INT NOT NULL,
    id_loja_devolucao     INT NULL,
    data_retirada_real    DATETIME NOT NULL,
    data_devolucao_real   DATETIME NULL,
    km_retirada           INT NOT NULL,
    km_devolucao          INT NULL,
    valor_ajuste          DECIMAL(8,2) NULL,
    tipo_ajuste           ENUM('MULTA','REEMBOLSO','NENHUM') NULL,
    status                ENUM('EM_ANDAMENTO','FINALIZADA')
                          NOT NULL DEFAULT 'EM_ANDAMENTO',
    CONSTRAINT fk_loc_reserva FOREIGN KEY (id_reserva)
        REFERENCES reserva(id_reserva),
    CONSTRAINT fk_loc_automovel FOREIGN KEY (id_automovel)
        REFERENCES automovel(id_automovel),
    CONSTRAINT fk_loc_motorista FOREIGN KEY (id_motorista)
        REFERENCES motorista(id_motorista),
    CONSTRAINT fk_loc_loja_retirada FOREIGN KEY (id_loja_retirada_real)
        REFERENCES loja(id_loja),
    CONSTRAINT fk_loc_loja_devolucao FOREIGN KEY (id_loja_devolucao)
        REFERENCES loja(id_loja)
);

-- manutencao
CREATE TABLE manutencao (
    id_manutencao  INT AUTO_INCREMENT PRIMARY KEY,
    id_automovel   INT NOT NULL,
    id_loja        INT NOT NULL,
    data_inicio    DATE NOT NULL,
    data_fim       DATE NULL,
    descricao      VARCHAR(200) NOT NULL,
    custo          DECIMAL(8,2) NULL,
    CONSTRAINT fk_manut_automovel FOREIGN KEY (id_automovel)
        REFERENCES automovel(id_automovel),
    CONSTRAINT fk_manut_loja FOREIGN KEY (id_loja)
        REFERENCES loja(id_loja)
);

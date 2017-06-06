/**
Implementação da estrutura física do banco de dados do SIG 1º CGEO
- FAZER
 - EMPRESA RESPONSAVEL PELO BUEIRO,
 - REDE DE TELEFONIA
 - PARA-RAIO COM TIPO DE INSTALACAO E MANUTENCAO, COLOCAR TABELA DE MANUTENCAO DO PARA-RAIO
 - RELACIONAR O ABASTECIMENTO DE ÁGUA (HIDROMETROS) E ENERGIA NOS PREDIOS - Desligando um hidrometro quais predios seriam atingidos
*/


BEGIN;
--ESQUEMAS
/**
 Esquemas que irão segmentar as categorias e classes definidas no projeto.
*/
CREATE EXTENSION postgis;

CREATE SCHEMA rede_logica; --alterar para rede fisica e colocar telefonia
CREATE SCHEMA rede_eletrica;
CREATE SCHEMA rede_hidraulica;
CREATE SCHEMA area_verde;
CREATE SCHEMA limites;
CREATE SCHEMA dominios;
CREATE SCHEMA planta_baixa;
CREATE SCHEMA adm;
SET search_path = pg_catalog, public,rede_logica,rede_hidraulica,rede_eletrica,area_verde,limites;

--TABLELAS DE DOMINIO
CREATE TABLE dominios.tipo_abetura(
	codigo SMALLINT NOT NULL UNIQUE,
	nome VARCHAR(255) NOT NULL
);
GRANT ALL ON TABLE dominios.tipo_abetura TO public;

 CREATE TABLE dominios.mat_construcao(
	codigo SMALLINT NOT NULL UNIQUE,
	nome VARCHAR(255) NOT NULL
);
 GRANT ALL ON TABLE dominios.mat_construcao TO public;

CREATE TABLE dominios.situacao_fisica(
	codigo SMALLINT NOT NULL UNIQUE,
	nome VARCHAR(255) NOT NULL
);
GRANT ALL ON TABLE dominios.situacao_fisica TO public;

CREATE TABLE dominios.tipo_equipamento(
	codigo SMALLINT NOT NULL UNIQUE,
	nome VARCHAR(255) NOT NULL
);
GRANT ALL ON TABLE dominios.tipo_equipamento TO public;

CREATE TABLE dominios.tipo_instalacao(
	codigo SMALLINT NOT NULL UNIQUE,
	nome VARCHAR(255) NOT NULL
);
GRANT ALL ON TABLE dominios.tipo_instalacao TO public;

CREATE TABLE dominios.tipo_reforma(
	codigo SMALLINT NOT NULL UNIQUE,
	nome VARCHAR(255) NOT NULL
);
GRANT ALL ON TABLE dominios.tipo_reforma TO public;

CREATE TABLE dominios.tipo_area_grama(
	codigo SMALLINT NOT NULL UNIQUE,
	nome VARCHAR(255)
);
INSERT INTO dominios.tipo_area_grama VALUES
(1,'pátio'),
(2,'campo de campo_futebol');


CREATE TABLE dominios.estado_mnt(
	codigo SMALLINT NOT NULL UNIQUE,
	nome VARCHAR(255) NOT NULL
);
GRANT ALL ON TABLE dominios.estado_mnt TO public;
INSERT INTO dominios.estado_mnt VALUES
(1,'Bom'),
(2,'Ruim'),
(3,'Ótimo');

CREATE TABLE dominios.tipo_cabeamento(
	codigo SMALLINT NOT NULL UNIQUE,
	nome VARCHAR(255) NOT NULL
);
GRANT ALL ON TABLE dominios.tipo_cabeamento TO public;
INSERT INTO dominios.tipo_cabeamento VALUES
(1,'Coaxial'),
(2,'Par trançado'),
(3,'Fibra Optica');

/**######################## CATEGORIA REDE LOGICA ################################# */

/** Aparelho responsavel pelo reforco de sinal e/ou
redistribuição de dados da rede lógica */

CREATE TABLE rede_logica.terminal(
 gid SERIAL NOT NULL PRIMARY KEY UNIQUE,
 portas VARCHAR(50),
 modelo VARCHAR(20),
 tipo VARCHAR(20)
)
WITH (OIDS=FALSE)
;
SELECT AddGeometryColumn('rede_logica','terminal', 'geom', 32722, 'MULTIPOINT', 2 );
CREATE INDEX idx_rede_logica_terminal_geom ON rede_logica.terminal USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE rede_logica.terminal ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE rede_logica.terminal TO public;

--########################################################################################
/** Estrutura pode receber cabeamento (ethernet, fibra óptica)
com fins de extensão de rede lógica */
CREATE TABLE rede_logica.ponto_rede(
 gid SERIAL NOT NULL PRIMARY KEY UNIQUE,
 codigo VARCHAR(50),
 fk_terminal INTEGER NOT NULL REFERENCES rede_logica.terminal (gid)
  )
WITH (OIDS=FALSE)
;
SELECT AddGeometryColumn('rede_logica','ponto_rede', 'geom', 32722, 'MULTIPOINT', 2 );
CREATE INDEX idx_rede_logica_ponto_rede_geom ON rede_logica.ponto_rede USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE rede_logica.ponto_rede ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE rede_logica.ponto_rede TO public;

--###########################################################################################
/** Tipo de fiação responsável pela ligação e 
tráfego de dados na rede lógica
*/
CREATE TABLE rede_logica.cabeamento(
 gid SERIAL NOT NULL PRIMARY KEY UNIQUE,
 id_tipo_cabeamento INTEGER NOT NULL REFERENCES dominios.tipo_cabeamento (codigo),
 velocidade VARCHAR(50),
 descricao VARCHAR(50),
 fk_terminal INTEGER NOT NULL REFERENCES rede_logica.terminal (gid)
 )
WITH (OIDS=FALSE)
;
SELECT AddGeometryColumn('rede_logica','cabeamento' ,'geom', 32722, 'MULTILINESTRING', 2 );
CREATE INDEX idx_rede_logica_cabeamento_geom ON rede_logica.cabeamento USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE rede_logica.cabeamento ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE rede_logica.cabeamento TO public;


--###########################################################################################
/**Máquina responsável por armazenar/enviar/receber 
dados da rede lógica*/

CREATE TABLE rede_logica.servidor(
 gid SERIAL NOT NULL PRIMARY KEY UNIQUE,
 marca VARCHAR(50),
 modelo VARCHAR(20),
 fk_terminal INTEGER NOT NULL REFERENCES rede_logica.terminal (gid)
 )
WITH (OIDS=FALSE)
;
SELECT AddGeometryColumn('rede_logica', 'servidor','geom', 32722, 'MULTIPOINT', 2 );
CREATE INDEX idx_rede_logica_servidor_geom ON rede_logica.servidor USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE rede_logica.servidor ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE rede_logica.servidor TO public;





--############################################################################################################
/** Implementações do Cap Pedro Reis
*/

/** 

*/
CREATE TABLE planta_baixa.instalacao(
	gid SERIAL NOT NULL PRIMARY KEY,
	nome VARCHAR(255),
	nome_abrev VARCHAR(80),
	perimetro REAL ,
	area REAL,
	status VARCHAR(255),
	tipo_instalacao INTEGER REFERENCES dominios.tipo_instalacao(codigo),
	capacidade SMALLINT
);
SELECT AddGeometryColumn('planta_baixa', 'instalacao','geom', 31982, 'MULTIPOLYGON', 2 );
CREATE INDEX idx_planta_baixa_instalacao_geom ON planta_baixa.instalacao USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE planta_baixa.instalacao ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE planta_baixa.instalacao TO public;

--###################################################################################################################
/**
*/
CREATE TABLE planta_baixa.parede(
	gid SERIAL NOT NULL PRIMARY KEY,
	pe_direito REAL NOT NULL,
	comprimento REAL NOT NULL,
	mat_construcao_id INTEGER REFERENCES dominios.mat_construcao (codigo),
	situacao_fisica_id INTEGER REFERENCES dominios.situacao_fisica (codigo)
);
SELECT AddGeometryColumn('planta_baixa', 'parede','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_planta_baixa_parede_geom ON planta_baixa.parede USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE planta_baixa.parede ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE planta_baixa.parede TO public;


--#################################################################################################################
/**
*/
CREATE TABLE planta_baixa.abertura(
	gid SERIAL NOT NULL PRIMARY KEY,
	tipo_abetura_id INTEGER REFERENCES dominios.tipo_abetura(codigo),
	mat_construcao_id INTEGER REFERENCES dominios.mat_construcao (codigo),
	parede_id INTEGER REFERENCES planta_baixa.parede(gid)

);
SELECT AddGeometryColumn('planta_baixa', 'abertura','geom', 31982, 'MULTILINESTRING', 2 );
CREATE INDEX idx_planta_baixa_abertura_geom ON planta_baixa.abertura USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE planta_baixa.abertura ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE planta_baixa.abertura TO public;


--#################################################################################################################
/**
*/
CREATE TABLE planta_baixa.equipamento(
	gid SERIAL NOT NULL PRIMARY KEY,
	carga VARCHAR(255),
	modelo VARCHAR(255),
	capacidade VARCHAR(80),
	situacao_fisica_id INTEGER REFERENCES dominios.situacao_fisica(codigo),
	tipo_equipamento_id INTEGER NOT NULL REFERENCES dominios.tipo_equipamento(codigo),
	mat_construcao_id INTEGER  NOT NULL REFERENCES dominios.mat_construcao (codigo),
	parede_id INTEGER REFERENCES planta_baixa.parede(gid)

);
SELECT AddGeometryColumn('planta_baixa', 'equipamento','geom', 31982, 'MULTIPOINT', 2 );
CREATE INDEX idx_planta_baixa_equipamento_geom ON planta_baixa.equipamento USING gist (geom) WITH (FILLFACTOR=90);
ALTER TABLE planta_baixa.equipamento ALTER COLUMN geom SET NOT NULL;
GRANT ALL ON TABLE planta_baixa.equipamento TO public;

--LIGACOES ENTRE TABELAS
CREATE TABLE adm.instalacao_reforma(
	gid SERIAL NOT NULL PRIMARY KEY,
	data_reforma DATE,
	empresa_responsavel VARCHAR(255),
	fiscal_obra VARCHAR(255),
	instalacao_id INTEGER NOT NULL REFERENCES planta_baixa.instalacao(gid),
	tipo_reforma_id INTEGER NULL REFERENCES dominios.tipo_reforma(codigo),
	garantia INTEGER, --NUMERO DE MESES DE GARANTIA
	edital VARCHAR(255),--EDITAL DE LICITAÇÃO
	valor REAL, --CUSTO DA OBRA
	--tipo_instalacao_id INTEGER NOT NULL REFERENCES dominios.tipo_instalacao(codigo)

);



--############################################################################################################


/* Estabelecendo permissões nas sequences para o grupo public */

GRANT ALL ON ALL SEQUENCES IN SCHEMA rede_logica TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA rede_eletrica TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA rede_hidraulica TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA area_verde TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA limites TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA dominios TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA planta_baixa TO public;
GRANT ALL ON ALL SEQUENCES IN SCHEMA adm TO public;

ROLLBACK;

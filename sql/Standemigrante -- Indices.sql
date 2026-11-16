--	I n d i c e s
-- 

USE standemigrante;

-- Index
--
CREATE INDEX idxVeiculosPrazoSeguro ON veiculos(prazoSeguro);
CREATE INDEX idxVeiculosPrazoInspecao ON veiculos(prazoInspecao);

SHOW INDEX FROM veiculos;

CREATE INDEX idxClientesNIF ON Clientes(NIF);

SHOW INDEX FROM clientes;

CREATE INDEX idxVeiculosMatricula ON veiculos(matricula);

SHOW INDEX FROM veiculos;

SELECT DISTINCT TABLE_NAME, INDEX_NAME
	FROM INFORMATION_SCHEMA.STATISTICS
	WHERE TABLE_SCHEMA = 'standemigrante';

DROP INDEX idxVeiculosPrazoSeguro ON veiculos;
DROP INDEX idxVeiculosPrazoInspecao ON veiculos;
DROP INDEX idxVeiculosMatricula ON veiculos;
DROP INDEX idxClientesNIF ON clientes;
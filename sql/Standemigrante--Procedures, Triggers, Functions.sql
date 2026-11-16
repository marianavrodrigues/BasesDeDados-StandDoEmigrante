-- P R O C E D I M E N T O S
-- F U N C O E S
-- G A T I L H O S
--
USE standemigrante;

-- TRIGGERS !!
-- 
DELIMITER $$
CREATE TRIGGER atulizaNrFuncionarios
AFTER INSERT ON Funcionarios
FOR EACH ROW
BEGIN
    UPDATE Stands
    SET nrFuncionarios = nrFuncionarios + 1
    WHERE idStand = NEW.idStand;
END$$
DELIMITER ;

INSERT INTO Funcionarios
	(idFuncionario, nome, rua, numero, localidade, codigoPostal, dataNascimento, cargo, idStand)
	Values 
    ('4', 'Joao Miranda Costa', 'Rua Fonte dos Santos', '15', 'Remelhe', '4755-446', '1999-12-01', 'Funcionário', '1');

SELECT nrFuncionarios
	FROM stands
	WHERE idstand = '1';
    
DROP TRIGGER atulizaNrFuncionarios;


DELIMITER $$
CREATE TRIGGER atulizaNrVeiculos
AFTER INSERT ON Veiculos
FOR EACH ROW
BEGIN
    UPDATE Stands
    SET nrVeiculos = nrVeiculos + 1
    WHERE idStand = NEW.idStand;
END$$
DELIMITER ;

INSERT INTO Veiculos
	(idVeiculo, matricula, marca, modelo, cor, anoFabrico, tipoCombustivel, quilometragem, prazoSeguro, prazoInspecao, precoDia, idStand)
    VALUES
    ('7', '22-ZE-82', 'Peugeot', '307', 'Azul', '2002', 'Diesel', '225000', '2026-01-12', '2027-02-16', '40.00', '1');

SELECT nrVeiculos
	FROM stands
	WHERE idstand = '1';

DROP TRIGGER atulizaNrVeiculos;
--
--
DELIMITER $$
CREATE TRIGGER atualizaVeiculosAlugados
AFTER INSERT ON standemigrante.Alugueres
FOR EACH ROW
BEGIN
    DECLARE standID INT;

    SELECT idStand INTO standID
    FROM standemigrante.Veiculos
    WHERE idVeiculo = NEW.idVeiculo;

    CALL standemigrante.atualizaNrdeVeiculosAlugados(standID);
END$$
DELIMITER ;

INSERT INTO Alugueres
	(idAluguer, idVeiculo, idFuncionario, idCliente, dataInicio, dataFinalPrevista, dataFinalEfetiva, valorTotal, tipoPagamento, estado)
	VALUES
	(4, 7, 4, 3, '2024-06-01 10:00:00', '2024-06-10 10:00:00', NULL, 500.00, 'A Pronto', 'Ativo');

SELECT idStand,nrVeiculosAlugados from stands;

DROP TRIGGER atualizaVeiculosAlugados;

-- Procedure!!
--
-- M01 -> O sistema deverá ser capaz de contabilizar o total de alugueres realizados por mês. 
DELIMITER $$
CREATE PROCEDURE totalAlugueresPorMes (IN p_ano INT, IN p_mes INT)
BEGIN
    SELECT COUNT(idAluguer) AS totalAlugueres
		FROM standEmigrante.Alugueres
	WHERE YEAR(dataInicio) = p_ano AND MONTH(dataInicio) = p_mes;
END $$
DELIMITER ;

CALL totalAlugueresPorMes(2024, 5);
CALL totalAlugueresPorMes(2024, 6);

DROP PROCEDURE receitaMensal;

-- M02 -> O sistema deverá ser capaz de calcular as receitas obtidas com os alugueres. 
DELIMITER $$
CREATE PROCEDURE receitaMensal (IN p_ano INT,IN p_mes INT)
BEGIN
    SELECT SUM(valor) AS ReceitaMensal
		FROM standEmigrante.Pagamentos
	WHERE YEAR(dataHora) = p_ano AND MONTH(dataHora) = p_mes;
END $$
DELIMITER ;

CALL receitaMensal(2024, 5);
CALL receitaMensal(2024, 6);

DROP PROCEDURE receitaMensal;

ALTER TABLE standemigrante.Stands
ADD COLUMN nrVeiculosAlugados INT DEFAULT 0;

DELIMITER $$
CREATE PROCEDURE atualizaNrdeVeiculosAlugados(IN idStandInput INT)
BEGIN
    DECLARE totalAlugados INT;
    
    SELECT COUNT(*) INTO totalAlugados
		FROM standemigrante.Alugueres A
			JOIN standemigrante.Veiculos V ON A.idVeiculo = V.idVeiculo
		WHERE A.estado = 'Ativo' AND V.idStand = idStandInput;
        
    UPDATE standemigrante.Stands
    SET nrVeiculosAlugados = totalAlugados
    WHERE idStand = idStandInput;
END$$
DELIMITER ;

CALL atualizaNrdeVeiculosAlugados(1);
CALL atualizaNrdeVeiculosAlugados(2);
CALL atualizaNrdeVeiculosAlugados(3);

SELECT * from stands;

DROP PROCEDURE atualizaNrdeVeiculosAlugados;

-- Functions!!
--
DELIMITER $$
CREATE FUNCTION standemigrante.verificaCarro(matriculaInput VARCHAR(8))
RETURNS VARCHAR(10) DETERMINISTIC
BEGIN
    DECLARE resultado VARCHAR(10);
   IF EXISTS (
    SELECT 1
		FROM standemigrante.Alugueres
		JOIN Veiculos ON Veiculos.idVeiculo = Alugueres.idVeiculo
    WHERE matricula = matriculaInput
      AND estado = 'Ativo'
	) THEN
		SET resultado = 'Alugado';
	ELSE 
		SET resultado = 'Livre';
    end IF;
	
    RETURN resultado;
END$$
DELIMITER ;

SELECT standemigrante.verificaCarro('07-CR-07');

DROP FUNCTION verificaCarro;
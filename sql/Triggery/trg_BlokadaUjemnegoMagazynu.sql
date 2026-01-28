CREATE OR ALTER TRIGGER trg_BlokadaUjemnegoMagazynu
ON Magazyn
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE IloscDostepna < 0)
    BEGIN
        RAISERROR('B£¥D: Stan magazynowy nie mo¿e byæ ujemny! SprawdŸ dostêpnoœæ towaru.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
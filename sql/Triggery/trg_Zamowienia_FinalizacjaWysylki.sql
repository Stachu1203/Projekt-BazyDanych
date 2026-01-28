CREATE OR ALTER TRIGGER trg_Zamowienia_FinalizacjaWysylki
ON PozycjeZamowienia
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(StatusProdukcjiID)
    BEGIN
        UPDATE z
        SET z.StatusZamowieniaID = 4 
        FROM Zamowienia z
        WHERE z.ZamowienieID IN (SELECT DISTINCT ZamowienieID FROM inserted)
          AND z.StatusZamowieniaID = 3 
          AND NOT EXISTS (
              SELECT 1 FROM PozycjeZamowienia pz 
              WHERE pz.ZamowienieID = z.ZamowienieID 
              AND pz.StatusProdukcjiID != 7
          );
    END
END;
GO
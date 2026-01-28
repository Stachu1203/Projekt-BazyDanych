CREATE OR ALTER PROCEDURE dbo.usp_AktualizujEtapProdukcji
    @ProduktZamowienieID INT,
    @PracownikID INT,
    @Godziny DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE PozycjeZamowienia
        SET StatusProdukcjiID = StatusProdukcjiID + 1,
            DataZakonczenia = CASE WHEN StatusProdukcjiID + 1 = 7 THEN GETDATE() ELSE NULL END
        WHERE ProduktZamowienieID = @ProduktZamowienieID;

        INSERT INTO EwidencjaCzasuPracy (ProduktZamowienieID, PracownikID, GodzinyPracy, DataPracy)
        VALUES (@ProduktZamowienieID, @PracownikID, @Godziny, GETDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
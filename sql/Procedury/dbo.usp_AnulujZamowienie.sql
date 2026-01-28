USE [u_staszel];
GO

CREATE OR ALTER PROCEDURE dbo.usp_AnulujZamowienie
    @ZamowienieId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

     IF NOT EXISTS (SELECT 1 FROM Zamowienia WHERE ZamowienieID = @ZamowienieId)
        BEGIN
            ;THROW 50001, 'B³¹d: Nie mo¿na anulowaæ nieistniej¹cego zamówienia.', 1;
        END

    
        UPDATE m
        SET m.IloscDostepna = m.IloscDostepna + pz.Ilosc,
            m.DataPrzyjecia = GETDATE()
        FROM Magazyn m
        JOIN PozycjeZamowienia pz ON m.ProduktID = pz.ProduktID
        WHERE pz.ZamowienieID = @ZamowienieId 
          AND pz.StatusProdukcjiID = 7; 

        IF EXISTS (SELECT 1 FROM Platnosc WHERE ZamowienieID = @ZamowienieId)
        BEGIN
            UPDATE Platnosc
            SET StatusPlatnosciID = (SELECT StatusPlatnosciID FROM StatusyPlatnosci WHERE NazwaStatusu LIKE '%Anulowana%'),
                KwotaNetto = 0,
                KwotaBrutto = 0,
                DataPlatnosci = NULL 
            WHERE ZamowienieID = @ZamowienieId;
        END

        
        UPDATE Zamowienia 
        SET StatusZamowieniaID = 7 
        WHERE ZamowienieID = @ZamowienieId;

        COMMIT TRANSACTION;
        PRINT 'Zamówienie nr ' + CAST(@ZamowienieId AS VARCHAR) + ' zosta³o pomyœlnie anulowane. Stany magazynowe i finanse zosta³y zaktualizowane.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
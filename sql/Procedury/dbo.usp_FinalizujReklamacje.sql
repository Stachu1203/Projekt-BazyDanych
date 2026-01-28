USE [u_staszel];
GO

CREATE OR ALTER PROCEDURE dbo.usp_FinalizujReklamacje
    @ReklamacjaID INT,
    @Decyzja NVARCHAR(50), -- Opcje: 'ZWROT', 'NAPRAWA', 'ODRZUCONA'
    @Komentarz NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ZamowienieID INT;
    DECLARE @ProduktID INT;
    DECLARE @Ilosc INT;

    SELECT 
        @ZamowienieID = z.ZamowienieID
    FROM Reklamacje r
    JOIN Zamowienia z ON r.ZamowienieID = z.ZamowienieID
    WHERE r.ReklamacjeID = @ReklamacjaID;

    IF @ZamowienieID IS NULL
    BEGIN
        RAISERROR('B£¥D: Reklamacja o podanym ID nie istnieje.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Reklamacje
        SET OpisReklamacji = OpisReklamacji + ' | DECYZJA: ' + @Decyzja + ' | NOTATKA: ' + ISNULL(@Komentarz, 'Brak')
        WHERE ReklamacjeID = @ReklamacjaID;

        
        IF @Decyzja = 'ZWROT'
        BEGIN
            
            UPDATE Platnosc
            SET StatusPlatnosciID = 5,
                KwotaBrutto = 0,
                DataPlatnosci = GETDATE()
            WHERE ZamowienieID = @ZamowienieID;

            UPDATE Zamowienia
            SET StatusZamowieniaID = 6
            WHERE ZamowienieID = @ZamowienieID;

            UPDATE m
            SET m.IloscDostepna = m.IloscDostepna + pz.Ilosc
            FROM Magazyn m
            JOIN PozycjeZamowienia pz ON m.ProduktID = pz.ProduktID
            WHERE pz.ZamowienieID = @ZamowienieID;

            PRINT 'Reklamacja sfinalizowana: Dokonano zwrotu œrodków.';
        END

        ELSE IF @Decyzja = 'NAPRAWA'
        BEGIN

            UPDATE PozycjeZamowienia
            SET StatusProdukcjiID = 1,
                DataRozpoczecia = GETDATE(),
                DataZakonczenia = NULL
            WHERE ZamowienieID = @ZamowienieID;

            UPDATE Zamowienia
            SET StatusZamowieniaID = 3
            WHERE ZamowienieID = @ZamowienieID;

            PRINT 'Reklamacja sfinalizowana: Zlecono ponown¹ produkcjê/naprawê.';
        END

        ELSE IF @Decyzja = 'ODRZUCONA'
        BEGIN

            UPDATE Zamowienia
            SET StatusZamowieniaID = 5
            WHERE ZamowienieID = @ZamowienieID;

            PRINT 'Reklamacja sfinalizowana: Reklamacja odrzucona.';
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
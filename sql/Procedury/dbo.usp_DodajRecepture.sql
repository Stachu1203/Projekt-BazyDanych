USE [u_staszel];
GO

CREATE OR ALTER PROCEDURE dbo.usp_DodajRecepture
    @ProduktID INT,
    @CzasProdukcji INT,        -- Czas w minutach
    @OpisReceptury NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Sprawdzenie, czy produkt w ogóle istnieje
    IF NOT EXISTS (SELECT 1 FROM Produkt WHERE ProduktID = @ProduktID)
    BEGIN
        RAISERROR('B£¥D: Produkt o podanym ID nie istnieje w katalogu.', 16, 1);
        RETURN;
    END

    -- 2. Sprawdzenie, czy produkt nie ma ju¿ przypisanej receptury 
    -- (Tabela Receptury ma UNIQUE na ProduktID)
    IF EXISTS (SELECT 1 FROM Receptury WHERE ProduktID = @ProduktID)
    BEGIN
        RAISERROR('B£¥D: Ten produkt ma ju¿ zdefiniowan¹ recepturê. U¿yj procedury aktualizacji.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 3. Wstawienie nowej receptury
        INSERT INTO Receptury (ProduktID, OpisReceptury, CzasProdukcji)
        VALUES (@ProduktID, @OpisReceptury, @CzasProdukcji);

        COMMIT TRANSACTION;
        PRINT 'Sukces: Receptura zosta³a pomyœlnie przypisana do produktu.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
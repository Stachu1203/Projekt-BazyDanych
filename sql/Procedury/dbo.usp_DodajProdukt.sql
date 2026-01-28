CREATE OR ALTER PROCEDURE dbo.usp_DodajProdukt
    @Nazwa NVARCHAR(255),
    @KategoriaID INT,
    @Cena DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM Kategoria WHERE KategoriaID = @KategoriaID)
    BEGIN
        RAISERROR('B£¥D: Podana kategoria nie istnieje w systemie.', 16, 1);
        RETURN;
    END

    INSERT INTO Produkt (NazwaProduktu, KategoriaID, CenaSprzedazy)
    VALUES (@Nazwa, @KategoriaID, @Cena);
END;
GO
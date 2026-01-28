CREATE OR ALTER PROCEDURE dbo.usp_ZlozZamowienie
    @KlientId INT,
    @ProduktId INT,
    @Ilosc INT,
    @AdresDostawy NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ZamowienieId INT;
        DECLARE @Dostepne INT;
        DECLARE @Cena DECIMAL(18,2);

        
        SELECT @Dostepne = ISNULL(IloscDostepna, 0) FROM Magazyn WHERE ProduktID = @ProduktId;
        SELECT @Cena = CenaSprzedazy FROM Produkt WHERE ProduktID = @ProduktId;

        
        INSERT INTO Zamowienia (KlientID, DataZamowienia, StatusZamowieniaID, AdresZamowienia)
        VALUES (@KlientId, GETDATE(), 1, @AdresDostawy);
        
        SET @ZamowienieId = SCOPE_IDENTITY();

        IF @Dostepne >= @Ilosc
        BEGIN
            UPDATE Magazyn SET IloscDostepna = IloscDostepna - @Ilosc WHERE ProduktID = @ProduktId;
            
            INSERT INTO PozycjeZamowienia (ZamowienieID, ProduktID, Ilosc, StatusProdukcjiID, Cena, DataZakonczenia)
            VALUES (@ZamowienieId, @ProduktId, @Ilosc, 7, @Cena, GETDATE());
        END
        ELSE
        BEGIN
            INSERT INTO PozycjeZamowienia (ZamowienieID, ProduktID, Ilosc, StatusProdukcjiID, Cena, DataRozpoczecia)
            VALUES (@ZamowienieId, @ProduktId, @Ilosc, 1, @Cena, GETDATE());
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
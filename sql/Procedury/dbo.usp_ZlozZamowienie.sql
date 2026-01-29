USE [u_staszel];
GO

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
        
        DECLARE @WylosowanyPrzewoznik INT;
        DECLARE @WylosowanyDeadline DATETIME;

        SELECT TOP 1 @WylosowanyPrzewoznik = PrzewoznikID 
        FROM Przewoznicy_Kurierzy 
        ORDER BY NEWID();

        SET @WylosowanyDeadline = DATEADD(day, (ABS(CHECKSUM(NEWID())) % 15) + 7, GETDATE());

  
        SELECT @Dostepne = ISNULL(IloscDostepna, 0) FROM Magazyn WHERE ProduktID = @ProduktId;
        SELECT @Cena = CenaSprzedazy FROM Produkt WHERE ProduktID = @ProduktId;

    
        INSERT INTO Zamowienia (KlientID, DataZamowienia, Deadline, StatusZamowieniaID, AdresZamowienia, PrzewoznikID)
        VALUES (@KlientId, GETDATE(), @WylosowanyDeadline, 1, @AdresDostawy, @WylosowanyPrzewoznik);
        
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
        PRINT 'Sukces: Zamówienie złożone. Przewoźnik i termin zostały przydzielone automatycznie.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
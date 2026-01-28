USE [u_staszel];
GO

CREATE OR ALTER PROCEDURE dbo.usp_ZarejestrujPlatnosc
    @ZamowienieId INT,
    @TypPlatnosciID INT,
    @KwotaBruttoInput DECIMAL(18, 2) = NULL 
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Zamowienia WHERE ZamowienieID = @ZamowienieId)
            THROW 50001, 'B³¹d: Zamówienie o podanym ID nie istnieje.', 1;

        DECLARE @SumaPozycji DECIMAL(18, 2);
        DECLARE @RabatProcent DECIMAL(18, 2);
        DECLARE @KwotaNetto DECIMAL(18, 2);
        DECLARE @KwotaBrutto DECIMAL(18, 2);

        SELECT @RabatProcent = ISNULL(Przecena, 0) FROM Zamowienia WHERE ZamowienieID = @ZamowienieId;
        
        SELECT @SumaPozycji = SUM(Ilosc * Cena) 
        FROM PozycjeZamowienia 
        WHERE ZamowienieID = @ZamowienieId;


        SET @KwotaNetto = @SumaPozycji * (1 - (@RabatProcent / 100));
        
        IF @KwotaBruttoInput IS NOT NULL 
            SET @KwotaBrutto = @KwotaBruttoInput;
        ELSE 
            SET @KwotaBrutto = ROUND(@KwotaNetto * 1.23, 2);

        IF EXISTS (SELECT 1 FROM Platnosc WHERE ZamowienieID = @ZamowienieId)
        BEGIN
            UPDATE Platnosc SET 
                StatusPlatnosciID = 2, 
                DataPlatnosci = GETDATE(),
                KwotaNetto = @KwotaNetto,
                KwotaBrutto = @KwotaBrutto,
                TypPlatnosciID = @TypPlatnosciID
            WHERE ZamowienieID = @ZamowienieId;
        END
        ELSE
        BEGIN
            INSERT INTO Platnosc (ZamowienieID, NumerFaktury, TypPlatnosciID, StatusPlatnosciID, KwotaNetto, KwotaBrutto, DataPlatnosci)
            VALUES (
                @ZamowienieId, 
                'FV/' + CAST(YEAR(GETDATE()) AS NVARCHAR) + '/' + CAST(@ZamowienieId AS NVARCHAR),
                @TypPlatnosciID, 2, @KwotaNetto, @KwotaBrutto, GETDATE()
            );
        END

        UPDATE Zamowienia SET StatusZamowieniaID = 2 WHERE ZamowienieID = @ZamowienieId;

        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
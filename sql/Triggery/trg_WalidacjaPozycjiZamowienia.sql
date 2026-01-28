USE [u_staszel];
GO

CREATE OR ALTER TRIGGER trg_WalidacjaPozycjiZamowienia
ON PozycjeZamowienia
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Zamowienia z JOIN inserted i ON z.ZamowienieID = i.ZamowienieID 
               WHERE z.Przecena < 0 OR z.Przecena > 100)
    BEGIN
        RAISERROR('B£¥D: Rabat musi mieœciæ siê w przedziale 0-100%%.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM inserted WHERE Ilosc <= 0)
    BEGIN
        RAISERROR('B£¥D: Iloœæ zamówionego produktu musi byæ wiêksza od zera.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO
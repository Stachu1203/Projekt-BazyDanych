CREATE OR ALTER TRIGGER trg_Zamowienia_StartProdukcjiPoPlatnosci
ON Zamowienia
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(StatusZamowieniaID)
    BEGIN
        UPDATE z
        SET z.StatusZamowieniaID = 3 
        FROM Zamowienia z
        INNER JOIN inserted i ON z.ZamowienieID = i.ZamowienieID
        WHERE i.StatusZamowieniaID = 2; 
    END
END;
GO
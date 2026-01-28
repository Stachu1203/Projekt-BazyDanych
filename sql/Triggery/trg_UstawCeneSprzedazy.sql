CREATE OR ALTER TRIGGER trg_UstawCeneSprzedazy
ON PozycjeZamowienia
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE pz
    SET pz.Cena = p.CenaSprzedazy
    FROM PozycjeZamowienia pz
    INNER JOIN inserted i ON pz.ProduktZamowienieID = i.ProduktZamowienieID
    INNER JOIN Produkt p ON i.ProduktID = p.ProduktID
    WHERE pz.Cena IS NULL OR pz.Cena = 0;
END;
GO
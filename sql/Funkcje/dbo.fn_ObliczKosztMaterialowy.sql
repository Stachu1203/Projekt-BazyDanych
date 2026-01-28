USE [u_staszel];
GO

-- Tworzymy funkcjê obliczaj¹c¹ koszt materia³ów dla jednego produktu
CREATE OR ALTER FUNCTION dbo.fn_ObliczKosztMaterialowy (@ProduktID INT)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @SumaKosztow DECIMAL(18, 2);

    -- Logika obliczeñ: sumujemy (iloœæ z receptury * koszt jednostkowy czêœci)
    SELECT @SumaKosztow = SUM(er.Ilosc * c.KosztJednostkowy)
    FROM Receptury r
    JOIN ElementyReceptury er ON r.RecepturaID = er.RecepturaID
    JOIN Czesci c ON er.CzescID = c.CzesciID
    WHERE r.ProduktID = @ProduktID;

    -- Jeœli produkt nie ma receptury, zwróæ 0 zamiast NULL
    RETURN ISNULL(@SumaKosztow, 0);
END;
GO
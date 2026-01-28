USE [u_staszel];
GO

CREATE OR ALTER FUNCTION dbo.fn_PobierzIloscWProdukcji (@ProduktID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Suma INT;

    SELECT @Suma = SUM(pz.Ilosc)
    FROM PozycjeZamowienia pz
    JOIN StatusyProdukcji sp ON pz.StatusProdukcjiID = sp.StatusProdukcjiID
    WHERE pz.ProduktID = @ProduktID 
      AND sp.NazwaStatusu != 'Gotowe';

    RETURN ISNULL(@Suma, 0);
END;
GO
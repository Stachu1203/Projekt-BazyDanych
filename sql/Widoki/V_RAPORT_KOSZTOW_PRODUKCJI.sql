USE [u_staszel];
GO

CREATE OR ALTER VIEW V_RAPORT_KOSZTOW_PRODUKCJI AS
SELECT 
    p.NazwaProduktu,
    k.NazwaKategorii,
    YEAR(pz.DataZakonczenia) AS Rok,
    MONTH(pz.DataZakonczenia) AS Miesiac,
    DATEPART(QUARTER, pz.DataZakonczenia) AS Kwartal,
    
    -- Wykorzystanie Twojej funkcji dla kosztu jednostkowego
    dbo.fn_ObliczKosztMaterialowy(p.ProduktID) AS KosztJednostkowy,
    
    -- Agregacja iloœci i kosztów ca³kowitych
    SUM(pz.Ilosc) AS LaczaIloscWyprodukowana,
    SUM(pz.Ilosc * dbo.fn_ObliczKosztMaterialowy(p.ProduktID)) AS CalkowityKosztProdukcjiGrupy
    
FROM Produkt p
JOIN Kategoria k ON p.KategoriaID = k.KategoriaID
JOIN PozycjeZamowienia pz ON p.ProduktID = pz.ProduktID
-- Raport uwzglêdnia tylko produkty, które fizycznie zosta³y ukoñczone (status 7)
WHERE pz.StatusProdukcjiID = 7 AND pz.DataZakonczenia IS NOT NULL
GROUP BY 
    p.NazwaProduktu, 
    k.NazwaKategorii, 
    YEAR(pz.DataZakonczenia), 
    MONTH(pz.DataZakonczenia), 
    DATEPART(QUARTER, pz.DataZakonczenia),
    p.ProduktID; -- ProduktID musi byæ w GROUP BY, aby funkcja dzia³a³a poprawnie
GO
USE [u_staszel];
GO

CREATE OR ALTER VIEW V_ZARZADCZY_RAPORT_WYNIKOW AS
SELECT 
    k.NazwaKategorii,
    p.NazwaProduktu,
    YEAR(z.DataZamowienia) AS Rok,
    MONTH(z.DataZamowienia) AS Miesiac,
    DATEPART(WEEK, z.DataZamowienia) AS Tydzien,
    
    -- Agregacja iloœci
    SUM(pz.Ilosc) AS RazemSztuk,
    
    -- PRZYCHODY (u¿ywamy funkcji rabatu)
    SUM(dbo.fn_ObliczWartoscPoRabacie(pz.Cena, pz.Ilosc, z.Przecena)) AS PrzychodNetto,
    
    -- KOSZTY (u¿ywamy funkcji kosztu materia³owego)
    SUM(pz.Ilosc * dbo.fn_ObliczKosztMaterialowy(p.ProduktID)) AS KosztProdukcjiRazem,
    
    -- ZYSK I MAR¯A
    SUM(dbo.fn_ObliczWartoscPoRabacie(pz.Cena, pz.Ilosc, z.Przecena)) - 
    SUM(pz.Ilosc * dbo.fn_ObliczKosztMaterialowy(p.ProduktID)) AS ZyskOperacyjny

FROM Zamowienia z
JOIN PozycjeZamowienia pz ON z.ZamowienieID = pz.ZamowienieID
JOIN Produkt p ON pz.ProduktID = p.ProduktID
JOIN Kategoria k ON p.KategoriaID = k.KategoriaID
GROUP BY 
    k.NazwaKategorii, 
    p.NazwaProduktu, 
    YEAR(z.DataZamowienia), 
    MONTH(z.DataZamowienia), 
    DATEPART(WEEK, z.DataZamowienia),
    p.ProduktID; -- ProduktID potrzebny dla funkcji wewn¹trz SUM
GO
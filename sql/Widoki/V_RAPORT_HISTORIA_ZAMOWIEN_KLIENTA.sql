USE [u_staszel];
GO

CREATE OR ALTER VIEW V_RAPORT_HISTORIA_ZAMOWIEN_KLIENTA AS
SELECT 
    k.KlientID,
    k.Imie_Nazwisko AS Klient,
    k.NIP,
    z.ZamowienieID,
    z.DataZamowienia,
    
    YEAR(z.DataZamowienia) AS Rok,
    MONTH(z.DataZamowienia) AS Miesiac,
    DATEPART(QUARTER, z.DataZamowienia) AS Kwartal,
    
    p.NazwaProduktu,
    pz.Ilosc,
    pz.Cena AS CenaKatalogowa,
    z.Przecena AS ProcentRabatu,
    
    -- Obliczenia za pomoc¹ Twojej nowej funkcji
    dbo.fn_ObliczWartoscPoRabacie(pz.Cena, pz.Ilosc, z.Przecena) AS WartoscPoRabacie,
    
    -- Dodatkowo obliczamy sam¹ kwotê oszczêdnoœci dla klienta
    (pz.Cena * pz.Ilosc) - dbo.fn_ObliczWartoscPoRabacie(pz.Cena, pz.Ilosc, z.Przecena) AS KwotaOszczednosci

FROM Klienci k
JOIN Zamowienia z ON k.KlientID = z.KlientID
JOIN PozycjeZamowienia pz ON z.ZamowienieID = pz.ZamowienieID
JOIN Produkt p ON pz.ProduktID = p.ProduktID;
GO
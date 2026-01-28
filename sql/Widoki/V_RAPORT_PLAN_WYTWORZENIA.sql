USE [u_staszel];
GO

CREATE OR ALTER VIEW V_RAPORT_PLAN_WYTWORZENIA AS
SELECT 
    p.NazwaProduktu,
    k.NazwaKategorii,
    -- Przedzia³y czasowe na podstawie Deadline'u zamówienia
    YEAR(z.Deadline) AS RokPlanowany,
    MONTH(z.Deadline) AS MiesiacPlanowany,
    DATEPART(WEEK, z.Deadline) AS TydzienPlanowany,
    
    -- Iloœæ do wytworzenia (wykorzystujemy Twoj¹ funkcjê)
    dbo.fn_PobierzIloscWProdukcji(p.ProduktID) AS IloscDoWytworzenia,
    
    -- Wyliczamy szacowany czas pracy (zak³adaj¹c, ¿e masz kolumnê CzasProdukcji w Receptury)
    ISNULL(r.CzasProdukcji * dbo.fn_PobierzIloscWProdukcji(p.ProduktID), 0) AS SzacowanyCzasPracy_Min,
    
    -- Status najwy¿szy w hierarchii dla danego produktu w tym zamówieniu
    sp.NazwaStatusu AS AktualnyEtap

FROM Produkt p
JOIN Kategoria k ON p.KategoriaID = k.KategoriaID
JOIN PozycjeZamowienia pz ON p.ProduktID = pz.ProduktID
JOIN Zamowienia z ON pz.ZamowienieID = z.ZamowienieID
JOIN StatusyProdukcji sp ON pz.StatusProdukcjiID = sp.StatusProdukcjiID
LEFT JOIN Receptury r ON p.ProduktID = r.ProduktID

-- Filtrujemy tylko to, co nie jest jeszcze gotowe
WHERE sp.NazwaStatusu != 'Gotowe'
GO
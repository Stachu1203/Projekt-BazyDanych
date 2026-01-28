USE [u_staszel];
GO

CREATE OR ALTER VIEW V_PLANOWANIE_PRODUKCJI_CR AS
SELECT 
    z.ZamowienieID,
    p.NazwaProduktu,
    pz.Ilosc,
    z.Deadline,
    ISNULL(r.CzasProdukcji * pz.Ilosc, 0) AS CzasPotrzebny_Min,

    DATEDIFF(MINUTE, GETDATE(), z.Deadline) AS CzasDoDeadline_Min,

    CAST(DATEDIFF(MINUTE, GETDATE(), z.Deadline) AS FLOAT) / 
    NULLIF(ISNULL(r.CzasProdukcji * pz.Ilosc, 0), 0) AS CriticalRatio,
    sp.NazwaStatusu AS AktualnyEtap
FROM PozycjeZamowienia pz
JOIN Zamowienia z ON pz.ZamowienieID = z.ZamowienieID
JOIN Produkt p ON pz.ProduktID = p.ProduktID
JOIN StatusyProdukcji sp ON pz.StatusProdukcjiID = sp.StatusProdukcjiID
LEFT JOIN Receptury r ON p.ProduktID = r.ProduktID
WHERE sp.NazwaStatusu != 'Gotowe' AND z.StatusZamowieniaID = 3; 
GO
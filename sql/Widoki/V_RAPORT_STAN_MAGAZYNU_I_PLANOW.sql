CREATE OR ALTER VIEW V_RAPORT_STAN_MAGAZYNU_I_PLANOW AS
SELECT 
    p.NazwaProduktu,
    ISNULL(m.IloscDostepna, 0) AS StanMagazynowyAktualny,
    
 
    dbo.fn_PobierzIloscWProdukcji(p.ProduktID) AS IloscZaplanowanaDoProdukcji,
    
    m.DataPrzyjecia AS OstatniePrzyjecie,
    m.DataWydania AS OstatnieWydanie
FROM Produkt p
LEFT JOIN Magazyn m ON p.ProduktID = m.ProduktID;
GO
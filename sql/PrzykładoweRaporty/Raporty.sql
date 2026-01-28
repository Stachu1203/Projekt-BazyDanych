
--1. Ranking zyskownoœci kategorii
SELECT 
    NazwaKategorii, 
    SUM(PrzychodNetto) AS Przychody_Suma, 
    SUM(ZyskOperacyjny) AS Zysk_Suma
FROM V_ZARZADCZY_RAPORT_WYNIKOW
GROUP BY NazwaKategorii
ORDER BY Zysk_Suma DESC;

--2. Analiza lojalnoœci i rabatów klienta
SELECT 
    Klient, 
    COUNT(DISTINCT ZamowienieID) AS Liczba_Zamowien,
    SUM(KwotaOszczednosci) AS Suma_Przyznanych_Rabatow,
    SUM(WartoscPoRabacie) AS Laczny_Przychod_od_Klienta
FROM V_RAPORT_HISTORIA_ZAMOWIEN_KLIENTA
WHERE Rok = 2025
GROUP BY Klient
ORDER BY Laczny_Przychod_od_Klienta DESC;

--3. Produkty wymagaj¹ce natychmiastowej produkcji
SELECT 
    NazwaProduktu, 
    StanMagazynowyAktualny AS W_Magazynie, 
    IloscZaplanowanaDoProdukcji AS W_Produkcji
FROM V_RAPORT_STAN_MAGAZYNU_I_PLANOW
WHERE StanMagazynowyAktualny < IloscZaplanowanaDoProdukcji;

--4. Miesiêczny trend zysku
SELECT 
    Miesiac, 
    SUM(PrzychodNetto) AS Sprzedaz, 
    SUM(KosztProdukcjiRazem) AS Koszty, 
    SUM(ZyskOperacyjny) AS Zysk
FROM V_ZARZADCZY_RAPORT_WYNIKOW
WHERE Rok = 2025
GROUP BY Miesiac
ORDER BY Miesiac;

--5. Obci¹¿enie produkcji na najbli¿szy tydzieñ
SELECT 
    NazwaProduktu, 
    SUM(IloscDoWytworzenia) AS Sztuk_Do_Zrobienia,
    TydzienPlanowany
FROM V_RAPORT_PLAN_WYTWORZENIA
WHERE RokPlanowany = YEAR(GETDATE()) 
  AND TydzienPlanowany = DATEPART(WEEK, GETDATE())
GROUP BY NazwaProduktu, TydzienPlanowany;

--6. Porównanie kosztu jednostkowego z cen¹ rynkow¹
SELECT 
    NazwaProduktu, 
    KosztJednostkowy, 
    (SELECT TOP 1 CenaSprzedazy FROM Produkt p WHERE p.NazwaProduktu = v.NazwaProduktu) AS Cena_Katalogowa,
    (SELECT TOP 1 CenaSprzedazy FROM Produkt p WHERE p.NazwaProduktu = v.NazwaProduktu) - KosztJednostkowy AS Mar¿a_na_1szt
FROM V_RAPORT_KOSZTOW_PRODUKCJI v
GROUP BY NazwaProduktu, KosztJednostkowy;
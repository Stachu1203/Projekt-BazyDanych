USE [u_staszel];
GO

CREATE ROLE Kierownik;      
CREATE ROLE Sprzedawca;   
CREATE ROLE Produkcja;     
GO

GRANT SELECT ON SCHEMA::dbo TO Kierownik;
DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO Kierownik;

GRANT EXECUTE ON dbo.usp_AnalizaObciazeniaMocy TO Kierownik;
GO

GRANT SELECT, INSERT, UPDATE ON Klienci TO Sprzedawca;
GRANT SELECT, INSERT, UPDATE ON Firmy TO Sprzedawca;

GRANT SELECT ON Produkt TO Sprzedawca;
GRANT SELECT ON Kategoria TO Sprzedawca;

GRANT EXECUTE ON dbo.usp_ZlozZamowienie TO Sprzedawca;
GRANT EXECUTE ON dbo.usp_ZarejestrujPlatnosc TO Sprzedawca;
GRANT EXECUTE ON dbo.usp_AnulujZamowienie TO Sprzedawca;
GRANT EXECUTE ON dbo.usp_FinalizujReklamacje TO Sprzedawca;

DENY SELECT ON Receptury TO Sprzedawca;
DENY SELECT ON Czesci TO Sprzedawca;
GO

GRANT SELECT ON V_PLANOWANIE_PRODUKCJI_CR TO Produkcja;

GRANT SELECT ON Receptury TO Produkcja;
GRANT SELECT ON ElementyReceptury TO Produkcja;
GRANT SELECT ON Czesci TO Produkcja;

GRANT EXECUTE ON dbo.usp_AktualizujEtapProdukcji TO Produkcja;

GRANT SELECT, UPDATE ON Magazyn TO Produkcja;


DENY SELECT ON Platnosc TO Produkcja;
DENY SELECT ON Klienci TO Produkcja;
GO
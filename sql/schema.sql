-- Opcjonalne: Czyszczenie bazy przed nowym importem
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
EXEC sp_MSforeachtable 'DELETE FROM ?';
-- Jeśli chcesz zresetować liczniki IDENTITY:
-- EXEC sp_MSforeachtable 'DBCC CHECKIDENT ("?", RESEED, 0)'; 
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';
GO

-- 1. TABELE SŁOWNIKOWE
CREATE TABLE StatusyZamowien
(
    StatusZamowieniaID INT PRIMARY KEY IDENTITY(1,1),
    NazwaStatusu NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE StatusyProdukcji
(
    StatusProdukcjiID INT PRIMARY KEY IDENTITY(1,1),
    NazwaStatusu NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE TypyUmow
(
    TypUmowyID INT PRIMARY KEY IDENTITY(1,1),
    NazwaUmowy NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Stanowiska
(
    StanowiskoID INT PRIMARY KEY IDENTITY(1,1),
    NazwaStanowiska NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE TypyPlatnosci
(
    TypPlatnosciID INT PRIMARY KEY IDENTITY(1,1),
    Metoda NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE StatusyPlatnosci
(
    StatusPlatnosciID INT PRIMARY KEY IDENTITY(1,1),
    NazwaStatusu NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE TypyReklamacji
(
    TypReklamacjiID INT PRIMARY KEY IDENTITY(1,1),
    NazwaTypu NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Kategoria
(
    KategoriaID INT PRIMARY KEY IDENTITY(1,1),
    NazwaKategorii NVARCHAR(100) NOT NULL UNIQUE,
    Opis NVARCHAR(MAX),
    Obrazek VARBINARY(MAX)
);

CREATE TABLE Przewoznicy_Kurierzy
(
    PrzewoznikID INT PRIMARY KEY IDENTITY(1,1),
    NazwaFirmyPrzewoznika NVARCHAR(255) NOT NULL,
    Telefon NVARCHAR(50) NOT NULL
);

-- 2. GŁÓWNE TABELE
CREATE TABLE Firmy
(
    NIP NVARCHAR(20) PRIMARY KEY,
    NazwaFirmy NVARCHAR(255) NOT NULL,
    Miasto NVARCHAR(100) NOT NULL,
    Ulica NVARCHAR(255) NOT NULL,
    NumerBudynku NVARCHAR(20) NOT NULL,
    KodPocztowy NVARCHAR(20) NOT NULL,
    Telefon NVARCHAR(50)
);

CREATE TABLE Klienci
(
    KlientID INT PRIMARY KEY IDENTITY(1,1),
    NIP NVARCHAR(20),
    Imie_Nazwisko NVARCHAR(255) NOT NULL,
    Miasto_Dostawy NVARCHAR(100) NOT NULL,
    Ulica_Dostawy NVARCHAR(255) NOT NULL,
    Numer_Dostawy NVARCHAR(20) NOT NULL,
    KodPocztowy NVARCHAR(20) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    Telefon NVARCHAR(50) NOT NULL,
    CONSTRAINT FK_Klienci_Firmy FOREIGN KEY (NIP) REFERENCES Firmy(NIP)
);

CREATE TABLE Zamowienia
(
    ZamowienieID INT PRIMARY KEY IDENTITY(1,1),
    KlientID INT NOT NULL,
    DataZamowienia DATETIME DEFAULT GETDATE() NOT NULL,
    Deadline DATETIME,
    StatusZamowieniaID INT NOT NULL,
    Przecena DECIMAL(18, 2) DEFAULT 0,
    AdresZamowienia NVARCHAR(MAX) NOT NULL,
    PrzewoznikID INT,
    CONSTRAINT FK_Zamowienia_Klienci FOREIGN KEY (KlientID) REFERENCES Klienci(KlientID),
    CONSTRAINT FK_Zamowienia_Status FOREIGN KEY (StatusZamowieniaID) REFERENCES StatusyZamowien(StatusZamowieniaID),
    CONSTRAINT FK_Zamowienia_Przewoznik FOREIGN KEY (PrzewoznikID) REFERENCES Przewoznicy_Kurierzy(PrzewoznikID)
);

CREATE TABLE Produkt
(
    ProduktID INT PRIMARY KEY IDENTITY(1,1),
    NazwaProduktu NVARCHAR(255) NOT NULL,
    KategoriaID INT NOT NULL,
    CenaSprzedazy DECIMAL(18, 2) NOT NULL,
    Obrazek VARBINARY(MAX),
    CONSTRAINT FK_Produkt_Kategoria FOREIGN KEY (KategoriaID) REFERENCES Kategoria(KategoriaID)
);

CREATE TABLE PozycjeZamowienia
(
    ProduktZamowienieID INT PRIMARY KEY IDENTITY(1,1),
    ZamowienieID INT NOT NULL,
    ProduktID INT NOT NULL,
    Ilosc INT NOT NULL DEFAULT 1,
    StatusProdukcjiID INT NOT NULL,
    Cena DECIMAL(18, 2) NOT NULL,
    DataRozpoczecia DATETIME,
    DataZakonczenia DATETIME,
    Marza DECIMAL(18, 2),
    CONSTRAINT FK_Pozycje_Zamowienia FOREIGN KEY (ZamowienieID) REFERENCES Zamowienia(ZamowienieID),
    CONSTRAINT FK_Pozycje_Produkt FOREIGN KEY (ProduktID) REFERENCES Produkt(ProduktID),
    CONSTRAINT FK_Pozycje_StatusProd FOREIGN KEY (StatusProdukcjiID) REFERENCES StatusyProdukcji(StatusProdukcjiID)
);

CREATE TABLE Magazyn
(
    SlotMagazynowyID INT PRIMARY KEY IDENTITY(1,1),
    ProduktID INT NOT NULL,
    IloscDostepna INT NOT NULL DEFAULT 0,
    DataPrzyjecia DATETIME,
    DataWydania DATETIME,
    CONSTRAINT FK_Magazyn_Produkt FOREIGN KEY (ProduktID) REFERENCES Produkt(ProduktID)
);

CREATE TABLE Receptury
(
    RecepturaID INT PRIMARY KEY IDENTITY(1,1),
    ProduktID INT NOT NULL UNIQUE,
    OpisReceptury NVARCHAR(MAX),
    CzasProdukcji INT NOT NULL,
    CONSTRAINT FK_Receptury_Produkt FOREIGN KEY (ProduktID) REFERENCES Produkt(ProduktID)
);

CREATE TABLE Czesci
(
    CzesciID INT PRIMARY KEY IDENTITY(1,1),
    NazwaCzesci NVARCHAR(255) NOT NULL,
    Material NVARCHAR(100),
    KosztJednostkowy DECIMAL(18, 2) NOT NULL
);

CREATE TABLE ElementyReceptury
(
    RecepturaID INT NOT NULL,
    CzescID INT NOT NULL,
    Ilosc INT NOT NULL,
    PRIMARY KEY (RecepturaID, CzescID),
    CONSTRAINT FK_ER_Receptura FOREIGN KEY (RecepturaID) REFERENCES Receptury(RecepturaID),
    CONSTRAINT FK_ER_Czesc FOREIGN KEY (CzescID) REFERENCES Czesci(CzesciID)
);

CREATE TABLE Pracownicy
(
    PracownikID INT PRIMARY KEY IDENTITY(1,1),
    Imie_Nazwisko NVARCHAR(255) NOT NULL,
    StawkaGodzinowa DECIMAL(18, 2) NOT NULL,
    TypUmowyID INT NOT NULL,
    StanowiskoID INT NOT NULL,
    CzyNaUrlopie BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Pracownicy_Umowa FOREIGN KEY (TypUmowyID) REFERENCES TypyUmow(TypUmowyID),
    CONSTRAINT FK_Pracownicy_Stanowisko FOREIGN KEY (StanowiskoID) REFERENCES Stanowiska(StanowiskoID)
);

CREATE TABLE Urlopy
(
    UrlopID INT PRIMARY KEY IDENTITY(1,1),
    PracownikID INT NOT NULL,
    DataStart DATETIME NOT NULL,
    DataKoniec DATETIME NOT NULL,
    Powod NVARCHAR(MAX),
    CONSTRAINT FK_Urlopy_Pracownik FOREIGN KEY (PracownikID) REFERENCES Pracownicy(PracownikID)
);

CREATE TABLE EwidencjaCzasuPracy
(
    EwidencjaID INT PRIMARY KEY IDENTITY(1,1),
    ProduktZamowienieID INT NOT NULL,
    PracownikID INT NOT NULL,
    GodzinyPracy DECIMAL(18, 2) NOT NULL,
    DataPracy DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Ewidencja_Pozycja FOREIGN KEY (ProduktZamowienieID) REFERENCES PozycjeZamowienia(ProduktZamowienieID),
    CONSTRAINT FK_Ewidencja_Pracownik FOREIGN KEY (PracownikID) REFERENCES Pracownicy(PracownikID)
);

CREATE TABLE Platnosc
(
    PlatnoscID INT PRIMARY KEY IDENTITY(1,1),
    ZamowienieID INT NOT NULL UNIQUE,
    NumerFaktury NVARCHAR(100) UNIQUE,
    TypPlatnosciID INT NOT NULL,
    StatusPlatnosciID INT NOT NULL,
    KwotaNetto DECIMAL(18, 2) NOT NULL,
    KwotaBrutto DECIMAL(18, 2) NOT NULL,
    DataPlatnosci DATETIME,
    CONSTRAINT FK_Platnosc_Zamowienie FOREIGN KEY (ZamowienieID) REFERENCES Zamowienia(ZamowienieID),
    CONSTRAINT FK_Platnosc_Typ FOREIGN KEY (TypPlatnosciID) REFERENCES TypyPlatnosci(TypPlatnosciID),
    CONSTRAINT FK_Platnosc_Status FOREIGN KEY (StatusPlatnosciID) REFERENCES StatusyPlatnosci(StatusPlatnosciID)
);

CREATE TABLE Reklamacje
(
    ReklamacjeID INT PRIMARY KEY IDENTITY(1,1),
    ZamowienieID INT NOT NULL,
    TypReklamacjiID INT NOT NULL,
    OpisReklamacji NVARCHAR(MAX) NOT NULL,
    DataZgloszenia DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Reklamacje_Zamowienie FOREIGN KEY (ZamowienieID) REFERENCES Zamowienia(ZamowienieID),
    CONSTRAINT FK_Reklamacje_Typ FOREIGN KEY (TypReklamacjiID) REFERENCES TypyReklamacji(TypReklamacjiID)
);
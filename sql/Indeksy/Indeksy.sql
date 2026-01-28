USE [u_staszel];
GO

-- 1. Indeksy na kluczach obcych. Przyspieszaj¹ ³¹czenie tabel (JOIN) w raportach.
CREATE INDEX IX_Klienci_NIP ON Klienci(NIP);
CREATE INDEX IX_Zamowienia_KlientId ON Zamowienia(KlientID);
CREATE INDEX IX_PozycjeZamowienia_ZamowienieId ON PozycjeZamowienia(ZamowienieID);
CREATE INDEX IX_PozycjeZamowienia_ProduktId ON PozycjeZamowienia(ProduktID);
CREATE INDEX IX_ElementyReceptury_CzescId ON ElementyReceptury(CzescID);

-- 2. Indeksy na datach i terminach. Przyspieszaj¹ raportowanie i planowanie produkcji.
CREATE INDEX IX_Zamowienia_DataZamowienia ON Zamowienia(DataZamowienia);
CREATE INDEX IX_Zamowienia_Deadline ON Zamowienia(Deadline);
CREATE INDEX IX_Ewidencja_DataPracy ON EwidencjaCzasuPracy(DataPracy);

-- 3. Indeksy pomocnicze do filtrowania (kategorie i statusy).
CREATE INDEX IX_Produkt_KategoriaId ON Produkt(KategoriaID);
CREATE INDEX IX_PozycjeZamowienia_StatusProdukcjiId ON PozycjeZamowienia(StatusProdukcjiID);
CREATE INDEX IX_Platnosc_ZamowienieId ON Platnosc(ZamowienieID);

GO
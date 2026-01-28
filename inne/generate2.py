import random
from faker import Faker
from datetime import datetime, timedelta

fake = Faker('pl_PL')

def generate_sql():
    sql = []
    
    sql.append("USE [u_staszel];")
    sql.append("GO\n")
    sql.append("EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';")
    sql.append("GO\n")
    
    # --- 1. SŁOWNIKI ---
    lookups = {
        'StatusyZamowien': ('StatusZamowieniaID', 'NazwaStatusu', ['Nowe', 'Opłacone', 'W realizacji', 'Wysłane', 'Dostarczone', 'Reklamacja', 'Anulowane']),
        'StatusyProdukcji': ('StatusProdukcjiID', 'NazwaStatusu', ['Oczekiwanie', 'Cięcie', 'Oklejanie', 'Montaż', 'Lakierowanie', 'Kontrola Jakości', 'Gotowe']),
        'TypyUmow': ('TypUmowyID', 'NazwaUmowy', ['UOP', 'B2B', 'Zlecenie', 'O Dzieło', 'Staż']),
        'Stanowiska': ('StanowiskoID', 'NazwaStanowiska', ['Stolarz', 'Lakiernik', 'Magazynier', 'Kierownik Produkcji', 'Logistyk', 'Księgowy', 'Projektant']),
        'TypyPlatnosci': ('TypPlatnosciID', 'Metoda', ['Przelew', 'Karta', 'BLIK', 'Gotówka', 'Za pobraniem']),
        'StatusyPlatnosci': ('StatusPlatnosciID', 'NazwaStatusu', ['Oczekuje', 'Zapłacone', 'Częściowo opłacone', 'Przeterminowane', 'Zwrot']),
        'TypyReklamacji': ('TypReklamacjiID', 'NazwaTypu', ['Uszkodzenie mechaniczne', 'Błędny wymiar', 'Wada materiału', 'Brakujący element', 'Inne'])
    }

    for table, (id_col, val_col, values) in lookups.items():
        sql.append(f"SET IDENTITY_INSERT {table} ON;")
        for i, val in enumerate(values, 1):
            sql.append(f"INSERT INTO {table} ({id_col}, {val_col}) VALUES ({i}, '{val}');")
        sql.append(f"SET IDENTITY_INSERT {table} OFF;\nGO\n")

    # --- 2. FIRMY---
    nips = []
    for _ in range(30):
        nip = fake.nip()
        nips.append(nip)
        comp_name = fake.company().replace("'", "''")
        sql.append(f"INSERT INTO Firmy (NIP, NazwaFirmy, Miasto, Ulica, NumerBudynku, KodPocztowy, Telefon) "
                   f"VALUES ('{nip}', '{comp_name}', '{fake.city()}', '{fake.street_name().replace("'", "''")}', '{fake.building_number()}', '{fake.postcode()}', '{fake.phone_number()}');")
    sql.append("GO\n")

    # --- 3. KLIENCI ---
    sql.append("SET IDENTITY_INSERT Klienci ON;")
    for i in range(1, 61):
        nip_val = f"'{random.choice(nips)}'" if random.random() > 0.5 else "'BRAK'"
        sql.append(f"INSERT INTO Klienci (KlientID, NIP, Imie_Nazwisko, Miasto_Dostawy, Ulica_Dostawy, Numer_Dostawy, KodPocztowy, Email, Telefon) "
                   f"VALUES ({i}, {nip_val}, '{fake.name().replace("'", "''")}', '{fake.city()}', '{fake.street_name().replace("'", "''")}', '{fake.building_number()}', '{fake.postcode()}', '{fake.email()}', '{fake.phone_number()}');")
    sql.append("SET IDENTITY_INSERT Klienci OFF;\nGO\n")

    # --- 4. PRZEWOŹNICY I KATEGORIE ---
    sql.append("SET IDENTITY_INSERT Przewoznicy_Kurierzy ON;")
    for i in range(1, 11):
        sql.append(f"INSERT INTO Przewoznicy_Kurierzy (PrzewoznikID, NazwaFirmyPrzewoznika, Telefon) VALUES ({i}, 'Kurier {fake.last_name()}', '{fake.phone_number()}');")
    sql.append("SET IDENTITY_INSERT Przewoznicy_Kurierzy OFF;\nGO\n")

    sql.append("SET IDENTITY_INSERT Kategoria ON;")
    kat_names = ['Meble Kuchenne', 'Szafy', 'Stoły', 'Krzesła', 'Akcesoria']
    for i, name in enumerate(kat_names, 1):
        sql.append(f"INSERT INTO Kategoria (KategoriaID, NazwaKategorii, Opis) VALUES ({i}, '{name}', 'Opis kategorii {name}');")
    sql.append("SET IDENTITY_INSERT Kategoria OFF;\nGO\n")

    # --- 5. PRODUKTY I CZĘŚCI ---
    sql.append("SET IDENTITY_INSERT Produkt ON;")
    for i in range(1, 41):
        sql.append(f"INSERT INTO Produkt (ProduktID, NazwaProduktu, KategoriaID, CenaSprzedazy) VALUES ({i}, 'Produkt {fake.word().upper()}', {random.randint(1,5)}, {random.randint(500, 5000)});")
    sql.append("SET IDENTITY_INSERT Produkt OFF;\nGO\n")

    sql.append("SET IDENTITY_INSERT Czesci ON;")
    materialy = ['Drewno', 'MDF', 'Stal', 'Szkło']
    for i in range(1, 51):
        sql.append(f"INSERT INTO Czesci (CzesciID, NazwaCzesci, Material, KosztJednostkowy) VALUES ({i}, 'Część-{fake.word()}', '{random.choice(materialy)}', {random.randint(10, 200)});")
    sql.append("SET IDENTITY_INSERT Czesci OFF;\nGO\n")

    # --- 6. MAGAZYN ---
    sql.append("SET IDENTITY_INSERT Magazyn ON;")
    for i in range(1, 41): 
        ilosc = random.randint(10, 100)
        data_prz = datetime.now() - timedelta(days=random.randint(60, 100))
        data_wyd = data_prz + timedelta(days=random.randint(5, 30))
        sql.append(f"INSERT INTO Magazyn (SlotMagazynowyID, ProduktID, IloscDostepna, DataPrzyjecia, DataWydania) "
                   f"VALUES ({i}, {i}, {ilosc}, '{data_prz.strftime('%Y-%m-%d')}', '{data_wyd.strftime('%Y-%m-%d')}');")
    sql.append("SET IDENTITY_INSERT Magazyn OFF;\nGO\n")

    # --- 7. RECEPTURY I ELEMENTY ---
    sql.append("SET IDENTITY_INSERT Receptury ON;")
    for i in range(1, 41):
        sql.append(f"INSERT INTO Receptury (RecepturaID, ProduktID, OpisReceptury, CzasProdukcji) VALUES ({i}, {i}, 'Instrukcja dla produktu {i}', {random.randint(30, 600)});")
    sql.append("SET IDENTITY_INSERT Receptury OFF;\nGO\n")

    used_elements = set()
    for _ in range(150):
        r_id, c_id = random.randint(1, 40), random.randint(1, 50)
        if (r_id, c_id) not in used_elements:
            sql.append(f"INSERT INTO ElementyReceptury (RecepturaID, CzescID, Ilosc) VALUES ({r_id}, {c_id}, {random.randint(1,10)});")
            used_elements.add((r_id, c_id))
    sql.append("GO\n")

    # --- 8. PRACOWNICY I URLOPY ---
    sql.append("SET IDENTITY_INSERT Pracownicy ON;")
    for i in range(1, 21):
        sql.append(f"INSERT INTO Pracownicy (PracownikID, Imie_Nazwisko, StawkaGodzinowa, TypUmowyID, StanowiskoID, CzyNaUrlopie) "
                   f"VALUES ({i}, '{fake.name().replace("'", "''")}', {random.randint(35, 120)}, {random.randint(1,5)}, {random.randint(1,7)}, 0);")
    sql.append("SET IDENTITY_INSERT Pracownicy OFF;\nGO\n")

    sql.append("SET IDENTITY_INSERT Urlopy ON;")
    for i in range(1, 16):
        start = datetime.now() - timedelta(days=random.randint(1, 300))
        sql.append(f"INSERT INTO Urlopy (UrlopID, PracownikID, DataStart, DataKoniec, Powod) VALUES ({i}, {random.randint(1,20)}, '{start.strftime('%Y-%m-%d')}', '{(start+timedelta(days=14)).strftime('%Y-%m-%d')}', 'Urlop wypoczynkowy');")
    sql.append("SET IDENTITY_INSERT Urlopy OFF;\nGO\n")

    # --- 9. HISTORYCZNE ZAMÓWIENIA ---
    sql.append("SET IDENTITY_INSERT Zamowienia ON;")
    for i in range(1, 101):
        data_z = datetime.now() - timedelta(days=random.randint(1, 730)) 
        deadline = data_z + timedelta(days=21)
        sql.append(f"INSERT INTO Zamowienia (ZamowienieID, KlientID, DataZamowienia, Deadline, StatusZamowieniaID, Przecena, AdresZamowienia, PrzewoznikID) "
                   f"VALUES ({i}, {random.randint(1,60)}, '{data_z.strftime('%Y-%m-%d')}', '{deadline.strftime('%Y-%m-%d')}', {random.randint(1,7)}, {random.choice([0, 0, 5, 10])}, '{fake.address().replace(chr(10), ', ').replace(chr(39), chr(39)+chr(39))}', {random.randint(1,10)});")
    sql.append("SET IDENTITY_INSERT Zamowienia OFF;\nGO\n")

    # --- 10. PŁATNOŚCI ---
    sql.append("SET IDENTITY_INSERT Platnosc ON;")
    for i in range(1, 101):
        netto = random.randint(1000, 10000)
        brutto = round(netto * 1.23, 2)
        data_p = datetime.now() - timedelta(days=random.randint(1, 30))
        sql.append(f"INSERT INTO Platnosc (PlatnoscID, ZamowienieID, NumerFaktury, TypPlatnosciID, StatusPlatnosciID, KwotaNetto, KwotaBrutto, DataPlatnosci) "
                   f"VALUES ({i}, {i}, 'FV/{random.randint(2024, 2025)}/{i:03d}', {random.randint(1,5)}, {random.randint(1,2)}, {netto}, {brutto}, '{data_p.strftime('%Y-%m-%d')}');")
    sql.append("SET IDENTITY_INSERT Platnosc OFF;\nGO\n")

    # --- 11. POZYCJE ZAMÓWIENIA ---
    sql.append("SET IDENTITY_INSERT PozycjeZamowienia ON;")
    for i in range(1, 251):
        status_prod = random.randint(1, 7)
        data_start = datetime.now() - timedelta(days=random.randint(30, 60))
        data_koniec = f"'{ (data_start + timedelta(days=5)).strftime('%Y-%m-%d') }'" if status_prod == 7 else "NULL"
        marza = round(random.uniform(150.0, 800.0), 2)
        
        sql.append(f"INSERT INTO PozycjeZamowienia (ProduktZamowienieID, ZamowienieID, ProduktID, Ilosc, StatusProdukcjiID, Cena, DataRozpoczecia, DataZakonczenia, Marza) "
                   f"VALUES ({i}, {random.randint(1,100)}, {random.randint(1,40)}, {random.randint(1,4)}, {status_prod}, {random.randint(600, 3000)}, '{data_start.strftime('%Y-%m-%d')}', {data_koniec}, {marza});")
    sql.append("SET IDENTITY_INSERT PozycjeZamowienia OFF;\nGO\n")

    # --- 12. REKLAMACJE I EWIDENCJA ---
    sql.append("SET IDENTITY_INSERT Reklamacje ON;")
    for i in range(1, 11):
        sql.append(f"INSERT INTO Reklamacje (ReklamacjeID, ZamowienieID, TypReklamacjiID, OpisReklamacji) VALUES ({i}, {random.randint(1,100)}, {random.randint(1,5)}, 'Problem z jakością wykonania nr {i}');")
    sql.append("SET IDENTITY_INSERT Reklamacje OFF;\nGO\n")

    sql.append("SET IDENTITY_INSERT EwidencjaCzasuPracy ON;")
    for i in range(1, 151):
        sql.append(f"INSERT INTO EwidencjaCzasuPracy (EwidencjaID, ProduktZamowienieID, PracownikID, GodzinyPracy, DataPracy) "
                   f"VALUES ({i}, {random.randint(1,250)}, {random.randint(1,20)}, {random.randint(2,8)}, GETDATE());")
    sql.append("SET IDENTITY_INSERT EwidencjaCzasuPracy OFF;\nGO\n")

    sql.append("EXEC sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';")
    sql.append("GO")

    with open("import_danych.sql", "w", encoding="utf-8") as f:
        f.write("\n".join(sql))

if __name__ == "__main__":
    generate_sql()
    print("OK")
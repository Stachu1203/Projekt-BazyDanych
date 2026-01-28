CREATE OR ALTER PROCEDURE dbo.usp_AnalizaObciazeniaMocy
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DostepneMoce_H DECIMAL(18,2);
    DECLARE @PotrzebneMoce_H DECIMAL(18,2);

    -- 1. Obliczamy dostêpnoœæ (ludzie niebêd¹cy na urlopie * 8h)
    SELECT @DostepneMoce_H = COUNT(*) * 8 FROM Pracownicy WHERE CzyNaUrlopie = 0;

    -- 2. Obliczamy potrzeby (na podstawie Twojego planu wytworzenia)
    SELECT @PotrzebneMoce_H = SUM(r.CzasProdukcji * pz.Ilosc) / 60.0
    FROM PozycjeZamowienia pz
    JOIN Receptury r ON pz.ProduktID = r.ProduktID
    JOIN StatusyProdukcji sp ON pz.StatusProdukcjiID = sp.StatusProdukcjiID
    WHERE sp.NazwaStatusu != 'Gotowe';

    -- 3. Wynik dla Managera
    SELECT 
        ISNULL(@DostepneMoce_H, 0) AS MoceDzienne_H,
        ISNULL(@PotrzebneMoce_H, 0) AS SumaPracyWKolejce_H,
        CASE 
            WHEN @PotrzebneMoce_H > (@DostepneMoce_H * 5) THEN 'KRYTYCZNE: Pracy na ponad tydzieñ!'
            WHEN @PotrzebneMoce_H > @DostepneMoce_H THEN 'WYSOKIE: Wymagane nadgodziny'
            ELSE 'OPTYMALNE'
        END AS StatusFabryki;
END;
GO
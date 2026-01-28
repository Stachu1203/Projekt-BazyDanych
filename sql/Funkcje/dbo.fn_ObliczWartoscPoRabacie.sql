USE [u_staszel];
GO

CREATE OR ALTER FUNCTION dbo.fn_ObliczWartoscPoRabacie (
    @Cena DECIMAL(18, 2),
    @Ilosc INT,
    @ProcentRabatu DECIMAL(5, 2)
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @WartoscBrutto DECIMAL(18, 2);
    DECLARE @WartoscPoRabacie DECIMAL(18, 2);

    -- Obliczamy wartoœæ bazow¹
    SET @WartoscBrutto = @Cena * @Ilosc;

    -- Obliczamy wartoœæ po odjêciu procentu (u¿ywamy ISNULL, by obs³u¿yæ ewentualne NULLe)
    SET @WartoscPoRabacie = @WartoscBrutto * (1 - (ISNULL(@ProcentRabatu, 0) / 100));

    RETURN ROUND(@WartoscPoRabacie, 2);
END;
GO
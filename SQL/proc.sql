CREATE OR ALTER PROCEDURE dbo.sp_AddIncoming
    @GoodsId INT,
    @PlaceId INT,     
    @Qty DECIMAL(18,3),
    @Price DECIMAL(18,2),
    @BatchNum NVARCHAR(50),
    @DocNum NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @DocId INT, @BatchId INT, @DocDate DATETIME = GETDATE();

        -- 1. Создаем новую партию (BatchId сгенерируется сам)
        INSERT INTO Batches (GoodsId, BatchNum, PurchasePrice, PurchaseDate, InitialQty)
        VALUES (@GoodsId, @BatchNum, @Price, @DocDate, @Qty);
        SET @BatchId = SCOPE_IDENTITY();

        -- 2. Создаем заголовок документа (Приход)
        INSERT INTO Documents (DocNum, DocDate, DocType)
        VALUES (@DocNum, @DocDate, 1);
        SET @DocId = SCOPE_IDENTITY();

        -- 3. Привязываем строку документа к новой партии и месту
        INSERT INTO DocLines (DocId, BatchId, Qty, Price, ToPlaceId)
        VALUES (@DocId, @BatchId, @Qty, @Price, @PlaceId);

        -- 4. Создаем запись о текущем остатке для этой НОВОЙ партии
        -- Здесь всегда INSERT, так как BatchId только что создан
        INSERT INTO BatchLoc (BatchId, PlaceId, CurrentQty)
        VALUES (@BatchId, @PlaceId, @Qty);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
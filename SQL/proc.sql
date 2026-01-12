--CREATE OR ALTER PROCEDURE dbo.sp_AddIncoming
--    @GoodsId INT,
--    @PlaceId INT,     
--    @Qty DECIMAL(18,3),
--    @Price DECIMAL(18,2),
--    @BatchNum NVARCHAR(50),
--    @DocNum NVARCHAR(50)
--AS
--BEGIN
--    SET NOCOUNT ON;
--    BEGIN TRANSACTION;
--    BEGIN TRY
--        DECLARE @DocId INT, @BatchId INT, @DocDate DATETIME = GETDATE();

--        -- 1. Создаем новую партию (BatchId сгенерируется сам)
--        INSERT INTO Batches (GoodsId, BatchNum, PurchasePrice, PurchaseDate, InitialQty)
--        VALUES (@GoodsId, @BatchNum, @Price, @DocDate, @Qty);
--        SET @BatchId = SCOPE_IDENTITY();

--        -- 2. Создаем заголовок документа (Приход)
--        INSERT INTO Documents (DocNum, DocDate, DocType)
--        VALUES (@DocNum, @DocDate, 1);
--        SET @DocId = SCOPE_IDENTITY();

--        -- 3. Привязываем строку документа к новой партии и месту
--        INSERT INTO DocLines (DocId, BatchId, Qty, Price, ToPlaceId)
--        VALUES (@DocId, @BatchId, @Qty, @Price, @PlaceId);

--        -- 4. Создаем запись о текущем остатке для этой НОВОЙ партии
--        -- Здесь всегда INSERT, так как BatchId только что создан
--        INSERT INTO BatchLoc (BatchId, PlaceId, CurrentQty)
--        VALUES (@BatchId, @PlaceId, @Qty);

--        COMMIT TRANSACTION;
--    END TRY
--    BEGIN CATCH
--        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
--        THROW;
--    END CATCH
--END;

--GO

CREATE OR ALTER PROCEDURE dbo.sp_AddOutgoingManual
    @BatchId INT,          -- ID партии (из грида)
    @PlaceId INT,          -- ID места хранения (из грида)
    @Qty DECIMAL(18, 3),   -- Сколько списываем
    @DocNum NVARCHAR(50)   -- Номер документа (акта/ордера)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DocId INT;
    DECLARE @DocDate DATETIME = GETDATE();

    -- Начинаем транзакцию, чтобы данные не "развалились"
    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. Проверяем, не списали ли эту партию прямо сейчас другие пользователи
        DECLARE @CurrentQty DECIMAL(18, 3);
        SELECT @CurrentQty = CurrentQty 
        FROM BatchLoc 
        WHERE BatchId = @BatchId AND PlaceId = @PlaceId;

        IF @CurrentQty IS NULL OR @CurrentQty < @Qty
        BEGIN
            RAISERROR('Недостаточно товара на остатке!', 16, 1);
        END

        -- 2. Создаем запись в таблице Documents (Тип 2 = Расход)
        INSERT INTO Documents (DocNum, DocDate, DocType)
        VALUES (@DocNum, @DocDate, 2);
        
        SET @DocId = SCOPE_IDENTITY();

        -- 3. Создаем запись в DocLines (движение товара)
        -- Поле FromPlaceId указывает, откуда ушел товар
        INSERT INTO DocLines (DocId, BatchId, Qty, Price, FromPlaceId)
        VALUES (@DocId, @BatchId, @Qty, 0, @PlaceId);

        -- 4. Обновляем остаток в таблице BatchLoc
        UPDATE BatchLoc
        SET CurrentQty = CurrentQty - @Qty
        WHERE BatchId = @BatchId AND PlaceId = @PlaceId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;

GO
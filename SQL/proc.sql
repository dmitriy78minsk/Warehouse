-- добавление товара
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
        DECLARE 
           @DocId INT, 
           @BatchId INT, 
           @DocDate DATETIME = GETDATE();

        -- Создаем новую партию
        INSERT INTO Batches (GoodsId, BatchNum, PurchasePrice, PurchaseDate, InitialQty)
        VALUES (@GoodsId, @BatchNum, @Price, @DocDate, @Qty);
        SET @BatchId = SCOPE_IDENTITY();

        -- Создаем заголовок документа (Приход)
        INSERT INTO Documents (DocNum, DocDate, DocType)
        VALUES (@DocNum, @DocDate, 1);
        SET @DocId = SCOPE_IDENTITY();

        -- Привязываем строку документа к новой партии и месту
        INSERT INTO DocLines (DocId, BatchId, Qty, Price, ToPlaceId)
        VALUES (@DocId, @BatchId, @Qty, @Price, @PlaceId);

        -- Создаем запись о текущем остатке для этой НОВОЙ партии
        INSERT INTO BatchLoc (BatchId, PlaceId, CurrentQty)
        VALUES (@BatchId, @PlaceId, @Qty);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
-- списание вручную
CREATE OR ALTER PROCEDURE dbo.sp_AddOutgoingManual
    @BatchId INT,          
    @PlaceId INT,         
    @Qty DECIMAL(18, 3),   
    @DocNum NVARCHAR(50)   
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DocId INT;
    DECLARE @DocDate DATETIME = GETDATE();

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Проверяем, не списали ли уже эту партию 
        DECLARE @CurrentQty DECIMAL(18, 3);
        SELECT @CurrentQty = CurrentQty 
        FROM BatchLoc 
        WHERE BatchId = @BatchId AND PlaceId = @PlaceId;

        IF @CurrentQty IS NULL OR @CurrentQty < @Qty
        BEGIN
            RAISERROR('Недостаточно товара на остатке!', 16, 1);
        END

        -- Создаем запись в таблице Documents (Тип 2 = Расход)
        INSERT INTO Documents (DocNum, DocDate, DocType)
        VALUES (@DocNum, @DocDate, 2);
        
        SET @DocId = SCOPE_IDENTITY();

        -- Создаем запись в DocLines (движение товара)
        INSERT INTO DocLines (DocId, BatchId, Qty, Price, FromPlaceId)
        VALUES (@DocId, @BatchId, @Qty, 0, @PlaceId);

        -- Обновляем остаток в таблице BatchLoc
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
-- Списание по FIFO
CREATE OR ALTER PROCEDURE dbo.sp_AddOutgoingFIFO
    @GoodsId INT,         
    @WarehouseId INT,     
    @QtyToIssue DECIMAL(18,3), 
    @DocNum NVARCHAR(50)   
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DocId INT;
    DECLARE @DocDate DATETIME = GETDATE();

    -- Проверка общего остатка
    DECLARE @TotalAvailable DECIMAL(18,3);

    SELECT @TotalAvailable = SUM(BL.CurrentQty)
    FROM BatchLoc BL
    JOIN Batches B ON BL.BatchId = B.BatchId
    JOIN Place P ON BL.PlaceId = P.PlaceId
    WHERE B.GoodsId = @GoodsId 
      AND P.WarehouseId = @WarehouseId;

    -- Если товара нет или его меньше чем нужно
    IF ISNULL(@TotalAvailable, 0) < @QtyToIssue
    BEGIN
        RAISERROR('Недостаточно товара на складе!', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Создаем заголовок документа (Тип 2 - Расход)
        INSERT INTO Documents (DocNum, DocDate, DocType) 
        VALUES (@DocNum, @DocDate, 2);
        
        SET @DocId = SCOPE_IDENTITY();

        -- Объявляем переменные для курсора
        DECLARE @BatchId INT, @PlaceId INT, @CurrentQty DECIMAL(18,3);
        
        -- Выбираем партии по дате закупки (FIFO)
        DECLARE cur CURSOR LOCAL FOR 
            SELECT BL.BatchId, BL.PlaceId, BL.CurrentQty 
            FROM BatchLoc BL
            JOIN Batches B ON BL.BatchId = B.BatchId
            JOIN Place P ON BL.PlaceId = P.PlaceId
            WHERE B.GoodsId = @GoodsId 
              AND P.WarehouseId = @WarehouseId 
              AND BL.CurrentQty > 0
            ORDER BY B.PurchaseDate ASC; 

        OPEN cur;
        FETCH NEXT FROM cur INTO @BatchId, @PlaceId, @CurrentQty;

        WHILE @@FETCH_STATUS = 0 AND @QtyToIssue > 0
        BEGIN
            DECLARE @Take DECIMAL(18,3);
            
            -- Определяем сколько взять из этой конкретной ячейки/партии
            IF @CurrentQty >= @QtyToIssue 
                SET @Take = @QtyToIssue;
            ELSE 
                SET @Take = @CurrentQty;

            -- Уменьшаем остаток
            UPDATE BatchLoc 
            SET CurrentQty = CurrentQty - @Take 
            WHERE BatchId = @BatchId AND PlaceId = @PlaceId;

            -- Пишем строку в документ
            INSERT INTO DocLines (DocId, BatchId, Qty, Price, FromPlaceId)
            VALUES (@DocId, @BatchId, @Take, 0, @PlaceId);

            -- Уменьшаем счетчик того, что осталось списать
            SET @QtyToIssue = @QtyToIssue - @Take;

            FETCH NEXT FROM cur INTO @BatchId, @PlaceId, @CurrentQty;
        END;

        CLOSE cur;
        DEALLOCATE cur;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        IF (SELECT CURSOR_STATUS('local','cur')) >= 0 
        BEGIN 
            CLOSE cur; 
            DEALLOCATE cur; 
        END;

        DECLARE @Msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@Msg, 16, 1);
    END CATCH
END;
GO
-- перемещение товара
CREATE OR ALTER PROCEDURE dbo.sp_MoveStock
    @BatchId INT,
    @FromPlaceId INT,
    @ToPlaceId INT,
    @Qty DECIMAL(18, 3),
    @DocNum NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DocId INT;
    DECLARE @DocDate DATETIME = GETDATE();

    BEGIN TRANSACTION;
    BEGIN TRY
        -- есть ли товар на исходном месте?
        DECLARE @CurrentQty DECIMAL(18, 3);
        SELECT @CurrentQty = CurrentQty 
        FROM BatchLoc 
        WHERE BatchId = @BatchId AND PlaceId = @FromPlaceId;

        IF @CurrentQty IS NULL OR @CurrentQty < @Qty
        BEGIN
            RAISERROR('Недостаточно товара для перемещения!', 16, 1);
        END

        -- Создаем документ (Тип 3 = Перемещение)
        INSERT INTO Documents (DocNum, DocDate, DocType)
        VALUES (@DocNum, @DocDate, 3);
        SET @DocId = SCOPE_IDENTITY();

        INSERT INTO DocLines (DocId, BatchId, Qty, Price, FromPlaceId, ToPlaceId)
        VALUES (@DocId, @BatchId, @Qty, 0, @FromPlaceId, @ToPlaceId);

        UPDATE BatchLoc
        SET CurrentQty = CurrentQty - @Qty
        WHERE BatchId = @BatchId AND PlaceId = @FromPlaceId;

        -- Добавляем получателю (UPSERT логика)
        IF EXISTS (SELECT 1 FROM BatchLoc WHERE BatchId = @BatchId AND PlaceId = @ToPlaceId)
        BEGIN
            UPDATE BatchLoc
            SET CurrentQty = CurrentQty + @Qty
            WHERE BatchId = @BatchId AND PlaceId = @ToPlaceId;
        END
        ELSE
        BEGIN
            INSERT INTO BatchLoc (BatchId, PlaceId, CurrentQty)
            VALUES (@BatchId, @ToPlaceId, @Qty);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO
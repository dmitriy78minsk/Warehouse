CREATE OR ALTER VIEW v_InventoryBalance AS
SELECT 
    W.WarehouseName,
    W.Address AS WarehouseAddress,
    P.PlaceName,
    G.GoodsName,
    B.BatchNum, -- “еперь мы видим номер партии в таблице
    BL.CurrentQty,
    B.PurchasePrice,
    (BL.CurrentQty * B.PurchasePrice) AS TotalSum,
    B.BatchId,
    BL.LocId,
    G.GoodsId,
    B.PurchaseDate,
    P.PlaceId,
    W.WarehouseId
FROM BatchLoc BL
JOIN Batches B ON BL.BatchId = B.BatchId
JOIN Goods G ON B.GoodsId = G.GoodsId
JOIN Place P ON BL.PlaceId = P.PlaceId
JOIN Warehouse W ON P.WarehouseId = W.WarehouseId
WHERE BL.CurrentQty > 0;
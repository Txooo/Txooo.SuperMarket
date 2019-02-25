--同步库存采购数量
UPDATE dbo.vmall_bill_warehouse_inventory
SET inventory_in = ISNULL(ss2.goods_count,0)
--SELECT wi.inventory_id,wi.inventory_in,ss2.* 
FROM dbo.vmall_bill_warehouse_inventory AS wi
    LEFT JOIN
    (
        SELECT s.into_warehouse_id,
               SUM(sid2.goods_count) goods_count,
               sid2.batch_id
        FROM dbo.vmall_bill_supply_into_detail sid2
            INNER JOIN dbo.vmall_bill_supply_into AS si
                ON si.into_id = sid2.into_id
            INNER JOIN dbo.vmall_bill_supply AS s
                ON s.bill_id = si.bill_id
        WHERE si.check_status = 4
              AND s.check_status = 6
        GROUP BY s.into_warehouse_id,
                 sid2.batch_id
    ) AS ss2
        ON ss2.batch_id = wi.batch_id
           AND wi.warehouse_id = ss2.into_warehouse_id
WHERE wi.inventory_in <> ISNULL(ss2.goods_count,0);

--同步库存销售数量
UPDATE dbo.vmall_bill_warehouse_inventory
SET inventory_out = wil.goods_count
--SELECT wil.*,wi.inventory_out 
FROM dbo.vmall_bill_warehouse_inventory AS wi
    INNER JOIN
    (
        SELECT SUM(   CASE inventory_type
                          WHEN 12 THEN
                              -goods_count
                          ELSE
                              goods_count
                      END
                  ) goods_count,
               inventory_from
        FROM dbo.vmall_bill_warehouse_inventory_log
        WHERE inventory_type IN ( 11, 12 )
        GROUP BY inventory_from
    ) wil
        ON wi.inventory_id = wil.inventory_from
WHERE wi.inventory_out <> wil.goods_count;

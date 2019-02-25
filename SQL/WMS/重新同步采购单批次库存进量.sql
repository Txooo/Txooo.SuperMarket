UPDATE dbo.vmall_bill_warehouse_inventory
SET inventory_in = ss2.goods_count
--SELECT wi.inventory_id,ss2.* 
FROM dbo.vmall_bill_warehouse_inventory AS wi
    INNER JOIN
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
WHERE wi.inventory_in <> ss2.goods_count;

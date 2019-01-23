--库存日志中，仓库管理加盟商id 与 订单加盟商id 不一致
SELECT c.manage_brand_id,
       d.brand_id,
       a.inventory_from,
       d.order_id,
       d.add_time
FROM
(
    SELECT inventory_from,
           bill_id
    FROM dbo.vmall_bill_warehouse_inventory_log
    WHERE inventory_type = 11
) a
    LEFT JOIN dbo.vmall_bill_warehouse_inventory AS b
        ON a.inventory_from = b.inventory_id
    LEFT JOIN dbo.vmall_bill_warehouse AS c
        ON c.warehouse_id = b.warehouse_id
    LEFT JOIN
    (
        SELECT order_id,
               brand_id,
               MAX(add_time) add_time
        FROM dbo.vmall_order_goods_map
        GROUP BY order_id,
                 brand_id
    ) AS d
        ON d.order_id = a.bill_id
WHERE c.manage_brand_id <> d.brand_id
ORDER BY d.add_time DESC;

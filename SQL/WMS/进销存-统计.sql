
--清理数据
TRUNCATE TABLE dbo.vmall_bill_summary_gs1_num;
DECLARE @brand_id BIGINT = 497863;
--插入数据
INSERT INTO dbo.vmall_bill_summary_gs1_num
(
    gs1_num,
    supply_count,
    inventory_in,
    inventory_out,
    inventory_keep,
    rectify_count,
    order_count
)
--查询数据
SELECT aa.gs1_num,
       bb.bill_count,
       aa.inventory_in,
       aa.inventory_out,
       aa.inventory_keep,
       cc.rectify_count,
       dd.goods_count
FROM
( --库存数据
    SELECT SUM(a.inventory_in) inventory_in,
           SUM(a.inventory_out) inventory_out,
           SUM(a.inventory_keep) inventory_keep,
           g.gs1_num
    FROM
    (
        SELECT *
        FROM dbo.vmall_bill_warehouse_inventory
        WHERE warehouse_id IN (
                                  SELECT warehouse_id
                                  FROM dbo.vmall_bill_warehouse
                                  WHERE manage_brand_id = @brand_id
                              )
    ) AS a
        LEFT JOIN dbo.vmall_bill_batch AS b
            ON b.batch_id = a.batch_id
        LEFT JOIN dbo.vmall_goods AS g
            ON g.gs1_num = b.gs1_num
    WHERE g.brand_id = @brand_id
    GROUP BY g.gs1_num
) AS aa
    --采购数据
    LEFT JOIN
    (
        SELECT gs1_num,
               SUM(goods_count) bill_count
        FROM dbo.vmall_bill_supply_detail
        WHERE bill_id IN (
                             SELECT bill_id
                             FROM dbo.vmall_bill_supply
                             WHERE check_status = 6
                                   AND into_warehouse_id IN (
                                                                SELECT warehouse_id
                                                                FROM dbo.vmall_bill_warehouse
                                                                WHERE manage_brand_id = @brand_id
                                                            )
                         )
        GROUP BY gs1_num
    ) AS bb
        ON bb.gs1_num = aa.gs1_num
    --盘点
    LEFT JOIN
    (
        SELECT SUM(a.goods_count) rectify_count,
               c.gs1_num
        FROM
        (
            SELECT inventory_id,
                   SUM(goods_count) goods_count
            FROM dbo.vmall_bill_rectify_detail
            WHERE bill_id IN (
                                 SELECT bill_id
                                 FROM dbo.vmall_bill_rectify
                                 WHERE check_status = 2
                                       AND brand_id = @brand_id
                             )
            GROUP BY inventory_id
        ) AS a
            INNER JOIN dbo.vmall_bill_warehouse_inventory AS b
                ON b.inventory_id = a.inventory_id
            INNER JOIN dbo.vmall_bill_batch AS c
                ON c.batch_id = b.batch_id
        GROUP BY c.gs1_num
    ) AS cc
        ON cc.gs1_num = aa.gs1_num
    --订单销售
    LEFT JOIN
    (
        SELECT c.gs1_num,
               SUM(a.goods_count) goods_count
        FROM
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
        ) AS a
            LEFT JOIN dbo.vmall_bill_warehouse_inventory AS b
                ON a.inventory_from = b.inventory_id
            LEFT JOIN dbo.vmall_bill_batch AS c
                ON b.batch_id = c.batch_id AND c.brand_id=@brand_id
        GROUP BY c.gs1_num
    ) AS dd
        ON dd.gs1_num = aa.gs1_num;
--查询有问题的商品
SELECT *
FROM dbo.vmall_bill_summary_gs1_num
WHERE inventory_in <> (inventory_out + inventory_keep - rectify_count)
      OR inventory_out <> order_count;

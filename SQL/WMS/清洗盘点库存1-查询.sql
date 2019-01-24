
DECLARE @brand_id BIGINT = 497863;
SELECT a.inventory_id,
       a.inventory_in,
       a.inventory_out,
       a.inventory_keep,
       b.rectify_count 
	   FROM
    (
        SELECT inventory_id,
               inventory_in,
               inventory_out,
               inventory_keep
        FROM dbo.vmall_bill_warehouse_inventory
        WHERE warehouse_id IN (
                                  SELECT warehouse_id
                                  FROM dbo.vmall_bill_warehouse
                                  WHERE manage_brand_id = @brand_id
                              )
    ) AS a LEFT JOIN (
	SELECT inventory_id,SUM(goods_count) rectify_count FROM dbo.vmall_bill_rectify_detail 
	WHERE bill_id IN (SELECT bill_id FROM dbo.vmall_bill_rectify 
	WHERE brand_id=@brand_id AND check_status=2)
	GROUP BY inventory_id 
	) AS b ON b.inventory_id = a.inventory_id
	WHERE a.inventory_in<>a.inventory_keep+a.inventory_out-b.rectify_count
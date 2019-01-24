DECLARE @brand_id BIGINT = 497863;
DECLARE @inventory_id BIGINT,
        @inventory_keep INT,
        @inventory_count INT,
        @rectify_id BIGINT;
DECLARE aa_list CURSOR FOR
SELECT a.inventory_id,
       a.inventory_keep,
       a.inventory_in - (a.inventory_keep + a.inventory_out - b.rectify_count) inventory_count
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
) AS a
    LEFT JOIN
    (
        SELECT inventory_id,
               SUM(goods_count) rectify_count
        FROM dbo.vmall_bill_rectify_detail
        WHERE bill_id IN (
                             SELECT bill_id
                             FROM dbo.vmall_bill_rectify
                             WHERE brand_id = @brand_id
                                   AND check_status = 2
                         )
        GROUP BY inventory_id
    ) AS b
        ON b.inventory_id = a.inventory_id
WHERE a.inventory_in <> a.inventory_keep + a.inventory_out - b.rectify_count;
OPEN aa_list;
FETCH NEXT FROM aa_list
INTO @inventory_id,
     @inventory_keep,
     @inventory_count;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT CAST(@inventory_id AS VARCHAR(50)) + 'ÊýÁ¿' + CAST(@inventory_count AS VARCHAR(50));

    FETCH NEXT FROM aa_list
    INTO @inventory_id,
         @inventory_keep,
         @inventory_count;
END;
CLOSE aa_list;
DEALLOCATE aa_list;
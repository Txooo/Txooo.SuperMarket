DECLARE @brand_id BIGINT = 497863;
DECLARE @inventory_id BIGINT,
        @inventory_keep INT,
        @inventory_count INT,
        @rectify_id BIGINT;
DECLARE aa_list CURSOR FOR
SELECT a.inventory_id,
       a.inventory_keep,
	   --当前库存+已消费-盘点-总采购 = 应盘点数
       a.inventory_keep + a.inventory_out - b.rectify_count - a.inventory_in AS inventory_count
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
    PRINT CAST(@inventory_id AS VARCHAR(50)) + '数量' + CAST(@inventory_count AS VARCHAR(50));
    INSERT INTO dbo.vmall_bill_rectify
    (
        brand_id,
        warehouse_id,
        warehouse_name,
        sponsor_user_id,
        sponsor_user_name,
        add_time,
        check_user_id,
        check_user_name,
        check_status,
        check_time,
        bill_remark,
        bill_number
    )
    SELECT manage_brand_id,
           warehouse_id,
           warehouse_name,
           0,
           '系统结算',
           GETDATE(),
           0,
           '系统结算',
           2,
           GETDATE(),
           '系统结算库存盘点',
           ''
    FROM dbo.vmall_bill_warehouse
    WHERE warehouse_id IN (
                              SELECT warehouse_id
                              FROM dbo.vmall_bill_warehouse_inventory
                              WHERE inventory_id = @inventory_id
                          );
    SET @rectify_id = @@IDENTITY;
    UPDATE dbo.vmall_bill_rectify
    SET bill_number = 'JS' + CAST(@rectify_id AS VARCHAR(50))
    WHERE bill_id = @rectify_id;

    INSERT INTO dbo.vmall_bill_rectify_detail
    (
        bill_id,
        inventory_id,
        goods_count,
        add_time,
        goods_remark
    )
    VALUES
    (@rectify_id, @inventory_id, @inventory_count, GETDATE(), '系统结算');

    INSERT INTO dbo.vmall_bill_rectify_log
    (
        bill_id,
        bill_status,
        user_id,
        log_msg,
        add_time
    )
    VALUES
    (   @rectify_id, -- bill_id - bigint
        2,           -- bill_status - int
        0,           -- user_id - bigint
        N'系统结算',     -- log_msg - nvarchar(500)
        GETDATE()    -- add_time - datetime
    );
    INSERT INTO dbo.vmall_bill_warehouse_inventory_log
    (
        inventory_from,
        inventory_to,
        goods_count,
        inventory_type,
        bill_id,
        from_keep,
        to_keep,
        remark,
        add_time
    )
    VALUES
    (   @inventory_id,
        @inventory_id,
        @inventory_count,
        5,
        @rectify_id,
        @inventory_keep,
        @inventory_keep,
        N'系统结算',  -- remark - nvarchar(500)
        GETDATE() -- add_time - datetime
    );

    FETCH NEXT FROM aa_list
    INTO @inventory_id,
         @inventory_keep,
         @inventory_count;
END;
CLOSE aa_list;
DEALLOCATE aa_list;
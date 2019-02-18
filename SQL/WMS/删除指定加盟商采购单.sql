--加盟商id
DECLARE @brand_id INT =499352
--采购单
DECLARE @bill_ids TABLE ( bill_id BIGINT )
--采购入库单
DECLARE @into_ids TABLE ( into_id BIGINT )
--获得采购单id
INSERT INTO @bill_ids ( bill_id )
SELECT bill_id FROM dbo.vmall_bill_supply WHERE 
into_warehouse_id IN (SELECT warehouse_id FROM dbo.vmall_bill_warehouse 
WHERE brand_id=@brand_id)

--SELECT * FROM @bill_ids
--采购详情，采购日志
DELETE FROM dbo.vmall_bill_supply_detail WHERE bill_id IN (SELECT bill_id FROM @bill_ids)
DELETE FROM dbo.vmall_bill_supply_log WHERE bill_id IN (SELECT bill_id FROM @bill_ids)
--获得采购入库单id
INSERT INTO @into_ids ( into_id )
SELECT into_id FROM dbo.vmall_bill_supply_into WHERE bill_id IN (SELECT bill_id FROM @bill_ids)
--采购入库详情，采购入库日志，采购入库单，
DELETE FROM dbo.vmall_bill_supply_into_detail WHERE into_id IN (SELECT into_id FROM @into_ids)
DELETE FROM dbo.vmall_bill_supply_into_log WHERE into_id IN (SELECT into_id FROM @into_ids)
DELETE FROM dbo.vmall_bill_supply_into WHERE bill_id IN (SELECT bill_id FROM @bill_ids)
--入库日志,采购单
DELETE FROM dbo.vmall_bill_warehouse_inventory_log WHERE bill_id IN (SELECT into_id FROM @into_ids) AND inventory_type IN (1,2)
DELETE FROM dbo.vmall_bill_supply WHERE bill_id IN (SELECT bill_id FROM @bill_ids)

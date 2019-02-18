--������id
DECLARE @brand_id INT =499352
--�ɹ���
DECLARE @bill_ids TABLE ( bill_id BIGINT )
--�ɹ���ⵥ
DECLARE @into_ids TABLE ( into_id BIGINT )
--��òɹ���id
INSERT INTO @bill_ids ( bill_id )
SELECT bill_id FROM dbo.vmall_bill_supply WHERE 
into_warehouse_id IN (SELECT warehouse_id FROM dbo.vmall_bill_warehouse 
WHERE brand_id=@brand_id)

--SELECT * FROM @bill_ids
--�ɹ����飬�ɹ���־
DELETE FROM dbo.vmall_bill_supply_detail WHERE bill_id IN (SELECT bill_id FROM @bill_ids)
DELETE FROM dbo.vmall_bill_supply_log WHERE bill_id IN (SELECT bill_id FROM @bill_ids)
--��òɹ���ⵥid
INSERT INTO @into_ids ( into_id )
SELECT into_id FROM dbo.vmall_bill_supply_into WHERE bill_id IN (SELECT bill_id FROM @bill_ids)
--�ɹ�������飬�ɹ������־���ɹ���ⵥ��
DELETE FROM dbo.vmall_bill_supply_into_detail WHERE into_id IN (SELECT into_id FROM @into_ids)
DELETE FROM dbo.vmall_bill_supply_into_log WHERE into_id IN (SELECT into_id FROM @into_ids)
DELETE FROM dbo.vmall_bill_supply_into WHERE bill_id IN (SELECT bill_id FROM @bill_ids)
--�����־,�ɹ���
DELETE FROM dbo.vmall_bill_warehouse_inventory_log WHERE bill_id IN (SELECT into_id FROM @into_ids) AND inventory_type IN (1,2)
DELETE FROM dbo.vmall_bill_supply WHERE bill_id IN (SELECT bill_id FROM @bill_ids)

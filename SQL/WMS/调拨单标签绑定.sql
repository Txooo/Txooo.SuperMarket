--获得标签 在进行中的调拨单记录
DECLARE @tag_id BIGINT=154
SELECT b.out_id,b.check_status,b.bill_id,c.into_id,c.check_status AS into_status FROM 
vmall_bill_allocation_out_tag AS a
INNER JOIN dbo.vmall_bill_allocation_out AS b
ON a.out_id=b.out_id
LEFT JOIN dbo.vmall_bill_allocation_into AS c
ON b.out_id=c.out_id
WHERE tag_id IN (@tag_id) AND b.check_status NOT IN (4,5) AND ISNULL(c.check_status,0) NOT IN (4,5) 

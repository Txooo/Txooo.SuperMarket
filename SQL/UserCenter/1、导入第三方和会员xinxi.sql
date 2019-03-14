--导入第三方基本信息
SET IDENTITY_INSERT dbo.gzy_user_third ON;
INSERT INTO dbo.gzy_user_third
(
    third_user_id,
    third_type,
    third_id,
    nickname,
    brand_id,
    com_id,
    mobile,
    status,
    add_time,
    user_id,
    member_id,
    old_user_id
)
SELECT b.user_id,
       CASE third_type
           WHEN 0 THEN
               1
           WHEN 1 THEN
               5
           WHEN 2 THEN
               6
       END,
       open_id,
       nickname,
       brand_id,
       0,
       mobile,
       CASE user_level
           WHEN 0 THEN
               0
           ELSE
               1
       END,
       add_time,
       0,
       0,
       user_id
FROM [TxoooBrandShop].dbo.vmall_user AS b
WHERE NOT EXISTS
(
    SELECT 1 FROM dbo.gzy_user_third AS a WHERE a.old_user_id = b.user_id
)
      AND b.brand_id IN (
                            SELECT brand_id FROM [TxoooBrandShop].dbo.vmall_index WHERE is_open = 3
                        );
SET IDENTITY_INSERT dbo.gzy_user_third OFF;

--SET IDENTITY_INSERT dbo.gzy_user_member ON;
----导入会员基本信息
--INSERT INTO dbo.gzy_user_member
--(
--    member_id,
--    brand_id,
--    com_id,
--    user_id,
--    mobile,
--    balance,
--    credits_total,
--    income_total,
--    expense_total,
--    income_credits,
--    expense_credits,
--    create_time,
--    last_change,
--    level,
--    old_member_id
--)
--SELECT b.member_id,
--       brand_id,
--       com_id,
--       0,
--       member_mobile,
--       0,
--       0,
--       0,
--       0,
--       0,
--       0,
--       create_time,
--       last_change,
--       1,
--       member_id
--FROM [TxoooBrandShop].dbo.vmall_user_assets AS b
--WHERE NOT EXISTS
--(
--    SELECT 1 FROM dbo.gzy_user_member AS a WHERE a.old_member_id = b.member_id
--)
--      AND b.brand_id IN (
--                            SELECT brand_id FROM [TxoooBrandShop].dbo.vmall_index WHERE is_open = 3
--                        );
--SET IDENTITY_INSERT dbo.gzy_user_member OFF;

----会员余额积分数据同步
--UPDATE dbo.gzy_user_member
--SET balance = b.balance,
--    credits_total = b.credits_total,
--    income_total = b.income_total,
--    expense_total = b.expense_total,
--    income_credits = b.income_credits,
--    expense_credits = b.expense_credits,
--    last_change = b.last_change,
--    pay_pwd = b.pay_pwd,
--    pay_methods = b.pay_methods,
--    free_secret = b.free_secret,
--    level = b.level
--FROM dbo.gzy_user_member AS a
--    INNER JOIN TxoooBrandShop.dbo.vmall_user_assets AS b
--        ON a.member_id = b.member_id;

--更新第三方人脸
UPDATE [dbo].[gzy_user_third]
SET user_id = b.new_face_id
FROM dbo.gzy_user_third AS a
    LEFT JOIN dbo.face_user_map AS b
        ON b.old_user_id = a.old_user_id;

--更新第三方企业
UPDATE dbo.gzy_user_third
SET com_id = b.com_id
FROM dbo.gzy_user_third AS a
    LEFT JOIN TxoooBrands.dbo.brand_index AS b
        ON a.brand_id = b.brand_id;

--更新会员人脸和企业
UPDATE dbo.gzy_user_member
SET user_id = b.user_id,
    com_id = b.com_id
FROM dbo.gzy_user_member AS a
    LEFT JOIN dbo.gzy_user_third AS b
        ON a.mobile = b.mobile
           AND a.brand_id = b.brand_id
WHERE b.user_id IS NOT NULL;

--更新第三方会员
UPDATE dbo.gzy_user_third
SET member_id = b.member_id
FROM dbo.gzy_user_third AS a
    LEFT JOIN dbo.gzy_user_member AS b
        ON b.brand_id = a.brand_id
           AND b.user_id = a.user_id;

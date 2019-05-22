--从公共库同步商品图片
UPDATE dbo.vmall_goods
SET goods_img = b.goods_img
FROM dbo.vmall_goods AS g
    INNER JOIN dbo.vmall_goods_libary AS b
        ON g.goods_num = b.goods_num
WHERE g.brand_id = 499875
      AND g.goods_img = '';

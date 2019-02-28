SELECT *
FROM
(
    SELECT CONVERT(VARCHAR(10), add_time, 120) tdate,
           SUM(total_amount) total_amount
    FROM dbo.vmall_order
    WHERE pay_state = 1
          AND order_state > 0
          AND add_time > GETDATE() - 60
          AND brand_id IN (
                              SELECT brand_id FROM dbo.vmall_index WHERE is_open = 3
                          )
    GROUP BY CONVERT(VARCHAR(10), add_time, 120)
) a
ORDER BY a.tdate DESC;

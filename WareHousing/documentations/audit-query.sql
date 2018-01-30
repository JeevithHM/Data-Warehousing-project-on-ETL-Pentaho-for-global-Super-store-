SELECT group_seq
     , MAX(IF(table_type = 'source', table_name,  NULL)) AS source
     , MAX(IF(table_type = 'target', table_name,  NULL)) AS target
     , SUM(IF(table_type = 'source', audit_value, NULL)) AS source_value
     , SUM(IF(table_type = 'target', audit_value, NULL)) AS target_value
     , IF (SUM(IF(table_type = 'source', audit_value, NULL)) = SUM(IF(table_type = 'target', audit_value, NULL)), 'PASS', 'FAIL') audit_result
  FROM
       (
        /* Fact Granuality */
        SELECT 1 AS group_seq, 'source' AS table_type, 'gs_orders count' AS table_name, COUNT(*) AS audit_value
          FROM source_db.gs_orders
         UNION ALL  
        SELECT 1 AS group_seq, 'target' AS table_type, 'fact_orders count' AS table_name, COUNT(*) AS audit_value
          FROM datamart_db.fact_orders

         UNION ALL        

         /* Order Date and Ship Date */      
        SELECT 2 AS group_seq, 'source' AS table_type, 'gs_orders data_diff' AS table_name, 
               SUM(CONVERT(DATE_FORMAT(`Ship Date`, '%Y%m%d'), signed integer) - CONVERT(DATE_FORMAT(`Order Date`, '%Y%m%d'), signed integer)) AS audit_value
          FROM source_db.gs_orders
         UNION ALL
        SELECT 2 AS group_seq, 'target' AS table_type, 'fact_orders date_diff' AS table_name, SUM(ship_date_skey - order_date_skey) AS audit_value
          FROM datamart_db.fact_orders 

         UNION ALL

          /* State Information */
        SELECT 3 AS group_seq, 'source' AS table_type, 'stg_state city' AS table_name, COUNT(*) AS audit_value
          FROM stage_db.stg_city
         UNION ALL  
        SELECT 3 AS group_seq, 'target' AS table_type, 'dim_geography count' AS table_name, COUNT(*) AS audit_value
          FROM datamart_db.dim_geography
       ) a 
 GROUP BY group_seq
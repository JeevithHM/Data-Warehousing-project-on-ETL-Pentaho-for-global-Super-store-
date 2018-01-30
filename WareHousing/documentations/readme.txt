1. Connect to your local MySQL server via a client and execute the ddl script below:
    documentations/ddl-scripts.sql

2. Launch Pentaho Kettle, go to “Edit” —-> “Edit the kettle.properties file”, and make necessary changes to the variables below:
    - ETL_USER_NAME
    - ETL_USER_PASS
    - ETL_HOME_DIR
    - DIM_DATE_END  : Set the value to 2020-12-31
    - DIM_DATE_START: Set the value to 2010-01-01

3. Open the job below in the main folder and execute it:
    main-job.kjb

4. Upon successful execution of the previous step, run the audit query below and verify that the row counts between the source and target match:

   /* Fact Granuality */
   SELECT 'source_db.gs_orders' AS table_name
         , COUNT(*) AS cnt_num 
      FROM source_db.gs_orders
     UNION ALL  
    SELECT 'datamart_db.fact_orders' AS table_name
         , COUNT(*) AS cnt_num 
      FROM datamart_db.fact_orders;

  /* State Information */
  SELECT 'source' AS table_name, COUNT(*)
    FROM stage_db.stg_state
   UNION ALL  
  SELECT 'target' AS table_name, COUNT(*)
    FROM datamart_db.dim_geography;        
    
  /* Order Date and Ship Date */      
  SELECT 'source_db.gs_orders', SUM(CONVERT(DATE_FORMAT(`Ship Date`, '%Y%m%d'), signed integer) - CONVERT(DATE_FORMAT(`Order Date`, '%Y%m%d'), signed integer)) AS total_date_diff
    FROM source_db.gs_orders
   UNION ALL
  SELECT 'target_db.gs_orders', SUM(ship_date_skey - order_date_skey) AS total_date_diff
    FROM datamart_db.fact_orders ;   
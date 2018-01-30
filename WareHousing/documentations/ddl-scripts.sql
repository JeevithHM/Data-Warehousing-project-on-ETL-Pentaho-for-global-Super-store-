/* Disable foreign key constraints */
SET FOREIGN_KEY_CHECKS=0;

/* extract_db */
CREATE DATABASE IF NOT EXISTS source_db   DEFAULT CHARACTER SET = utf8;

DROP TABLE IF EXISTS source_db.gs_orders;
CREATE TABLE source_db.gs_orders (
  `Row ID` tinytext,
  `Order ID` tinytext,
  `Order Date` datetime DEFAULT NULL,
  `Ship Date` datetime DEFAULT NULL,
  `Ship Mode` tinytext,
  `Customer ID` tinytext,
  `Customer Name` tinytext,
  `Segment` tinytext,
  `Postal Code` tinytext,
  `City` tinytext,
  `State` tinytext,
  `Country` tinytext,
  `Region` tinytext,
  `Market` tinytext,
  `Product ID` tinytext,
  `Category` tinytext,
  `Sub-Category` tinytext,
  `Product Name` tinytext,
  `Sales` double DEFAULT NULL,
  `Quantity` int(11) DEFAULT NULL,
  `Discount` double DEFAULT NULL,
  `Profit` double DEFAULT NULL,
  `Shipping Cost` double DEFAULT NULL,
  `Order Priority` tinytext
) ENGINE=InnoDB DEFAULT CHARSET=utf8
;

/* stage_db */
CREATE DATABASE IF NOT EXISTS stage_db    DEFAULT CHARACTER SET = utf8;

DROP TABLE IF EXISTS stage_db.stg_market;
CREATE TABLE stage_db.stg_market (
  market_id int(11) NOT NULL AUTO_INCREMENT,
  market_name varchar(255) DEFAULT NULL,
  PRIMARY KEY (market_id)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8
;

DROP TABLE IF EXISTS stage_db.stg_region;
CREATE TABLE stage_db.stg_region (
  region_id int(11) NOT NULL AUTO_INCREMENT,
  region_name varchar(255) DEFAULT NULL,
  market_id int(11) NOT NULL,
  PRIMARY KEY (region_id),
  KEY ndx_region_market_id (market_id),
  FOREIGN KEY (market_id) REFERENCES stg_market (market_id)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8
;

DROP TABLE IF EXISTS stage_db.stg_country;
CREATE TABLE stage_db.stg_country (
  country_id int(11) NOT NULL AUTO_INCREMENT,
  country_name varchar(255) DEFAULT NULL,
  market_id int(11) NOT NULL,
  PRIMARY KEY (country_id),
  KEY ndx_country_market_id (market_id),
  FOREIGN KEY (market_id) REFERENCES stg_market (market_id)    
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8
;

DROP TABLE IF EXISTS stage_db.stg_state;
CREATE TABLE stage_db.stg_state (
  state_id int(11) NOT NULL AUTO_INCREMENT,
  state_name varchar(255) DEFAULT NULL,
  country_id int(11) NOT NULL,
    PRIMARY KEY (state_id),
  KEY ndx_state_country_id (country_id)
  
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8
;


DROP TABLE IF EXISTS stage_db.stg_city;
CREATE TABLE stage_db.stg_city (

  city_id int(11) NOT NULL AUTO_INCREMENT,
  city_name varchar(255) DEFAULT NULL,
  country_id int(11) NOT NULL,
  region_id int(11) NOT NULL,
   state_id int(11) NOT NULL,
   market_id int(11) NOT NULL,
   postal_code varchar(255) DEFAULT NULL,
   PRIMARY KEY (city_id),
   KEY ndx_city_state_id (state_id),
   FOREIGN KEY (state_id) REFERENCES stg_state (state_id),
   KEY ndx_city_country_id (country_id),
   FOREIGN KEY (country_id) REFERENCES stg_country (country_id), 
   KEY ndx_city_region_id (region_id),
   FOREIGN KEY (region_id) REFERENCES stg_region (region_id),
   KEY ndx_city_market_id (market_id),
   FOREIGN KEY (market_id) REFERENCES stg_market (market_id) 
   )ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8
   ;

   
   
DROP TABLE IF EXISTS stage_db.stg_category;
CREATE TABLE stage_db.stg_category (
  category_id int(11) NOT NULL AUTO_INCREMENT,
  category_name varchar(255) DEFAULT NULL,
  PRIMARY KEY (category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS stage_db.stg_sub_category;
CREATE TABLE stage_db.stg_sub_category (
  sub_category_id int(11) NOT NULL AUTO_INCREMENT,
  sub_category_name varchar(255) DEFAULT NULL,
  category_id int(11) NOT NULL,
  PRIMARY KEY (sub_category_id),
  KEY ndx_subcat_category_id (category_id),
  CONSTRAINT stg_sub_category_ibfk_1 FOREIGN KEY (category_id) REFERENCES stg_category (category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS stage_db.stg_product;
CREATE TABLE stage_db.stg_product (
  product_id char(11) NOT NULL,
  product_name varchar(255) DEFAULT NULL,
  sub_category_id int(11) NOT NULL,
  PRIMARY KEY (product_id),
  KEY ndx_prod_subcat_id (sub_category_id),
  CONSTRAINT stg_product_ibfk_1 FOREIGN KEY (sub_category_id) REFERENCES stg_sub_category (sub_category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/* datamart_db */
CREATE DATABASE IF NOT EXISTS datamart_db DEFAULT CHARACTER SET = utf8;

DROP TABLE IF EXISTS datamart_db.dim_date;
CREATE TABLE datamart_db.dim_date (
  date_skey int(11) NOT NULL,
  the_date date DEFAULT NULL,
  the_year smallint(6) DEFAULT NULL,
  the_quarter tinyint(4) DEFAULT NULL,
  the_month tinyint(4) DEFAULT NULL,
  the_week tinyint(4) DEFAULT NULL,
  day_of_year smallint(6) DEFAULT NULL,
  day_of_month tinyint(4) DEFAULT NULL,
  day_of_week tinyint(4) DEFAULT NULL,
  PRIMARY KEY (date_skey),
  UNIQUE KEY the_date (the_date)
);

DROP TABLE IF EXISTS datamart_db.dim_product;
CREATE TABLE datamart_db.dim_product (
  product_skey int(11) NOT NULL AUTO_INCREMENT,
  product_id varchar(11) DEFAULT NULL,
  product_name varchar(255) DEFAULT NULL,
  product_sub_category_name varchar(255) DEFAULT NULL,
  product_category_name varchar(255) DEFAULT NULL,
  PRIMARY KEY (product_skey),
  UNIQUE KEY product_id (product_id)
);

DROP TABLE IF EXISTS datamart_db.dim_geography;
CREATE TABLE datamart_db.dim_geography (
  geography_skey int(11) NOT NULL AUTO_INCREMENT,
  city_id int(11) NOT NULL DEFAULT '0',
  state_name varchar(255) DEFAULT NULL,
  country_name varchar(255) DEFAULT NULL,
  region_name varchar(255) DEFAULT NULL,
  market_name varchar(255) DEFAULT NULL,
  city_name varchar(255) DEFAULT NULL,
  PRIMARY KEY (geography_skey)
) ENGINE=InnoDB AUTO_INCREMENT=1129 DEFAULT CHARSET=utf8;



DROP TABLE IF EXISTS datamart_db.dim_segment;
CREATE TABLE datamart_db.dim_segment (
segment_skey int(11) NOT NULL AUTO_INCREMENT,
segment varchar(255) DEFAULT NULL,		
PRIMARY KEY (segment_skey),
UNIQUE KEY segment (segment)
);


DROP TABLE IF EXISTS datamart_db.dim_customer;
CREATE TABLE datamart_db.dim_customer (
customer_skey int(11) NOT NULL AUTO_INCREMENT,
customer_name varchar(256) DEFAULT NULL,
customer_id varchar(256) DEFAULT NULL,
shipmode varchar(256) DEFAULT NULL,
order_priority varchar(256) DEFAULT NULL,

PRIMARY KEY (customer_skey)
);









DROP TABLE IF EXISTS datamart_db.fact_orders;
CREATE TABLE datamart_db.fact_orders (
  product_skey int(11) DEFAULT NULL,
  geography_skey int(11) DEFAULT NULL,
  customer_skey int(11) DEFAULT NULL,
  shipmode_skey int(11) DEFAULT NULL,
  segment_skey int(11) DEFAULT NULL,
    order_date_skey int(11) DEFAULT NULL,  
  ship_date_skey int(11) DEFAULT NULL,
  order_row_id varchar(85) DEFAULT NULL,
  order_id varchar(85) DEFAULT NULL,
  sales_amt double DEFAULT NULL,
  sales_qty int(11) DEFAULT NULL,
  discount_amt double DEFAULT NULL,
  profit_amt double DEFAULT NULL,
  shipping_amt double DEFAULT NULL,
  KEY ndx_forder_od_skey (order_date_skey),
  KEY fk_product_skey (product_skey),
  KEY fk_geography_skey (geography_skey),
  CONSTRAINT fk_order_date FOREIGN KEY (order_date_skey) REFERENCES dim_date (date_skey),
  CONSTRAINT fk_ship_date FOREIGN KEY (ship_date_skey) REFERENCES dim_date (date_skey),
  CONSTRAINT fk_product_skey FOREIGN KEY (product_skey) REFERENCES dim_product (product_skey),
  CONSTRAINT fk_geography_skey FOREIGN KEY (geography_skey) REFERENCES dim_geography (geography_skey),
  CONSTRAINT fk_customer_skey FOREIGN KEY (customer_skey) REFERENCES dim_customer (customer_skey),
  
  CONSTRAINT fk_segment_skey FOREIGN KEY (segment_skey) REFERENCES dim_segment (segment_skey)
  
  );
 
/* Enable foreign key constraints */
SET FOREIGN_KEY_CHECKS=1;














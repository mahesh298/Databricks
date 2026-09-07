-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Set-up the project environment for Formula1 Project
-- MAGIC 1. Create External Location databricks-course-ext-dl1-formula1
-- MAGIC 1. Create Catalog formula1
-- MAGIC 1. Create Schemas landing, bronze, silver and gold
-- MAGIC 1. Create Volume Files in the landing schema

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Access Cloud Storage

-- COMMAND ----------

-- MAGIC %fs ls 'abfss://formula1@databrickscourseextdl1.dfs.core.windows.net/landing'

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Create External Location

-- COMMAND ----------

CREATE EXTERNAL LOCATION IF NOT EXISTS databricks_course_ext_dl1_formula1
URL 'abfss://formula1@databrickscourseextdl1.dfs.core.windows.net/'
WITH (STORAGE CREDENTIAL `databricks-course-sc`)
COMMENT 'External location for the formula1 container';

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Create Catalog formula1

-- COMMAND ----------

SHOW CATALOGS;

-- COMMAND ----------

CREATE CATALOG IF NOT EXISTS formula1
   MANAGED LOCATION 'abfss://formula1@databrickscourseextdl1.dfs.core.windows.net/' 
   COMMENT 'This is the main catalog for the formula1 project' ;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Create Schemas landing, bronze, silver, gold

-- COMMAND ----------

CREATE SCHEMA IF NOT EXISTS formula1.landing;
CREATE SCHEMA IF NOT EXISTS formula1.bronze
    MANAGED LOCATION 'abfss://formula1@databrickscourseextdl1.dfs.core.windows.net/bronze';
CREATE SCHEMA IF NOT EXISTS formula1.silver
    MANAGED LOCATION 'abfss://formula1@databrickscourseextdl1.dfs.core.windows.net/silver';
CREATE SCHEMA IF NOT EXISTS formula1.gold
    MANAGED LOCATION 'abfss://formula1@databrickscourseextdl1.dfs.core.windows.net/gold';         

-- COMMAND ----------

-- 1. Landing layer
CREATE SCHEMA IF NOT EXISTS formula1.landing
COMMENT 'Internal managed schema for landing/staging raw data';

-- 2. Bronze layer (Raw / Ingested)
CREATE SCHEMA IF NOT EXISTS formula1.bronze
COMMENT 'Internal managed schema for bronze Delta tables';

-- 3. Silver layer (Cleaned / Enriched)
CREATE SCHEMA IF NOT EXISTS formula1.silver
COMMENT 'Internal managed schema for silver Delta tables';

-- 4. Gold layer (Aggregated / Business-level)
CREATE SCHEMA IF NOT EXISTS formula1.gold
COMMENT 'Internal managed schema for gold analytical tables';

-- COMMAND ----------

SELECT current_catalog();

-- COMMAND ----------

USE CATALOG formula1;

-- COMMAND ----------

SHOW SCHEMAS;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Create Volume Files

-- COMMAND ----------

CREATE EXTERNAL VOLUME formula1.landing.files
LOCATION 'abfss://formula1@databrickscourseextdl1.dfs.core.windows.net/landing';

-- COMMAND ----------

-- MAGIC %fs ls /Volumes/formula1/landing/files

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # Creating Catolog internally

-- COMMAND ----------

CREATE CATALOG IF NOT EXISTS formula1
COMMENT 'Internal managed catalog using default metastore storage for Formula 1 data';

-- COMMAND ----------

USE CATALOG formula1;

-- COMMAND ----------

SELECT current_metastore();

-- COMMAND ----------

CREATE SCHEMA IF NOT EXISTS formula1.raw
COMMENT 'Schema for staging files and intermediate datasets';

-- COMMAND ----------

CREATE VOLUME IF NOT EXISTS formula1.raw.landing
COMMENT 'Internal staging volume for raw CSV files and folder directories';
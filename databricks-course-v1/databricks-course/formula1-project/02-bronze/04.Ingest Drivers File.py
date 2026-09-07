# Databricks notebook source
# MAGIC %md
# MAGIC # Ingest drivers.json file
# MAGIC 1. Read the file using spark dataframe reader API
# MAGIC 1. Define and enforce schema (preserve the nested structure)
# MAGIC 1. Add Metadata Columns 
# MAGIC     - Source File
# MAGIC     - Ingestion Timestamp
# MAGIC 1. Write to bronze delta table    

# COMMAND ----------

# MAGIC %run ../00-common/01.environment-config

# COMMAND ----------

# MAGIC %run ../00-common/02.bronze-helpers

# COMMAND ----------

# Define source_file and table_name
source_file = f"{landing_folder_path}/drivers.json"
table_name = f"{catalog_name}.{bronze_schema}.drivers"

# COMMAND ----------

# MAGIC %md
# MAGIC #### Step 1 - Read the JSON file using the dataframe reader API

# COMMAND ----------

# Define the schema
from pyspark.sql.types import StructType, StructField, StringType, DateType

name_schema = StructType([
    StructField('givenName', StringType()),
    StructField('familyName', StringType())
])

drivers_schema = StructType([
    StructField('driverId', StringType()),
    StructField('name', name_schema),
    StructField('dateOfBirth', DateType()),
    StructField('nationality', StringType()),
    StructField('url', StringType())
])

# COMMAND ----------

# Read data from the drivers file
drivers_df = (
    spark.read
       .format('json')
       .schema(drivers_schema)
       .option('mode', 'FAILFAST')
       .load(source_file)
)

# COMMAND ----------

# MAGIC %md
# MAGIC #### Step 2 - Add Metadata Columns
# MAGIC - Source File
# MAGIC - Ingestion Timestamp

# COMMAND ----------

drivers_final_df = add_ingestion_metadata(drivers_df)

# COMMAND ----------

# MAGIC %md
# MAGIC #### Step 3 - Write to bronze delta table

# COMMAND ----------

(
    drivers_final_df
        .write
        .format('delta')
        .mode('overwrite')
        .saveAsTable(table_name)
)

# COMMAND ----------

display(spark.table(table_name))

# COMMAND ----------

# Set session timezone to Eastern Time
spark.conf.set("spark.sql.session.timeZone", "America/New_York")

# Verify current timezone
spark.sql("SELECT current_timezone(), current_timestamp()").show(truncate=False)

# COMMAND ----------

from pyspark.sql.types import (
    BinaryType,
    BooleanType,
    StringType,
    StructField,
    StructType,
)

text_schema = StructType([
    StructField("name", StringType()),
    StructField("code", StringType()),
    StructField("descr", StringType()),
    StructField("is_active", BooleanType()),
    StructField("payload", BinaryType()),
])

data = [
    ("Lewis", "HAM", "Lead Driver", True, bytearray(b"raw_bytes_stream"))
]

spark.createDataFrame(data, schema=text_schema).show(truncate=False)

# COMMAND ----------

from datetime import date, datetime, timedelta
from pyspark.sql.types import (
    DateType,
    DayTimeIntervalType,
    StructField,
    StructType,
    TimestampNTZType,
    TimestampType,
    YearMonthIntervalType,
)

temporal_schema = StructType(
    [
        StructField("race_date", DateType()),
        StructField("event_tz", TimestampType()),  # TIMESTAMP_LTZ
        StructField("wall_clock", TimestampNTZType()),  # No timezone
        StructField("elapsed", DayTimeIntervalType()),  # days, hours, mins, secs
    ]
)

data = [
    (
        date(2026, 3, 15),
        datetime(2026, 3, 15, 14, 0, 0),
        datetime(2026, 3, 15, 14, 0, 0),
        timedelta(days=2, hours=3, minutes=15),
    )
]
spark.createDataFrame(data, schema=temporal_schema).show(truncate=False)

# COMMAND ----------

from pyspark.sql.functions import to_date

df = spark.createDataFrame(
    [("1500-01-01",)],
    ["date"]
)

df = df.withColumn("date", to_date("date"))

df.show()
# Batch-Processing-ELT_Pipeline
# Snowflake ELT Batch Processing Pipeline

## 📌 Project Overview

This project implements an end-to-end **ELT data pipeline** using AWS S3 and Snowflake to ingest, transform, validate, audit, and analyze sales data.

The pipeline follows a layered architecture:

**S3 → Cloud_Integration → Bronze → Silver → Gold → Power BI**

The project demonstrates practical implementation of Snowflake data engineering concepts including **Snowpipe, Streams, Tasks, Stored Procedures, SQL transformations, audit logging, dimensional modeling, and automated notifications**.

---

## 🏗️ Architecture

```text
                    ┌──────────────────┐
                    │   Source CSV     │
                    │   Sales Data     │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │     AWS S3       │
                    │    Raw Data      │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │    Snowpipe      │
                    │ Auto Ingestion   │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ Bronze Layer     │
                    │ Raw Data         │
                    └────────┬─────────┘
                             │
                       Streams/Tasks
                             │
                             ▼
                    ┌──────────────────┐
                    │ Silver Layer     │
                    │ Cleaned Data     │
                    └────────┬─────────┘
                             │
                    SQL Transformations
                             │
                             ▼
                    ┌──────────────────┐
                    │ Gold Layer       │
                    │ Business Views   │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │    Power BI      │
                    │    Dashboard     │
                    └──────────────────┘
```

---

## 🎯 Project Objectives

* Build an end-to-end cloud-based ELT pipeline.
* Automatically ingest CSV files from Amazon S3 into Snowflake.
* Store raw data in a Bronze layer.
* Transform and clean data in the Silver layer.
* Create dimensional models for analytical reporting.
* Build Gold-layer business views.
* Implement audit and logging mechanisms.
* Automate pipeline execution using Snowflake Tasks.
* Track newly inserted records using Streams.
* Generate success/failure notifications.
* Connect transformed data to Power BI for visualization.

---

## 🛠️ Technologies Used

| Technology        | Purpose                           |
| ----------------- | --------------------------------- |
| Python            | Data generation and file creation |
| Amazon S3         | Cloud object storage              |
| Snowflake         | Data warehouse and ELT processing |
| Snowpipe          | Automated data ingestion          |
| Snowflake Streams | Change data capture               |
| Snowflake Tasks   | Pipeline automation               |
| Stored Procedures | Transformation framework          |
| SQL               | Data transformation and analysis  |
| Power BI          | Data visualization                |
| Email Integration | Pipeline notifications            |

---

## 📊 Source Dataset

The project uses sales transaction data containing **21 columns**.

Important fields include:

* `ORDER_ID`
* `ORDER_DATE`
* `CUSTOMER_ID`
* `CUSTOMER_NAME`
* `AGE`
* `GENDER`
* `REGION`
* `CITY`
* `PRODUCT_CATEGORY`
* `PRODUCT_NAME`
* `QUANTITY`
* `UNIT_PRICE`
* `DISCOUNT_PCT`
* `TOTAL_AMOUNT`
* `PROFIT`
* `SHIPPING_COST`
* `PAYMENT_METHOD`
* `CUSTOMER_SATISFACTION`
* `RETURN_FLAG`
* `ORDER_STATUS`
* `DAYS_TO_SHIP`

---

## 🔄 Pipeline Workflow

### 1. Data Generation

Python is used to generate sales transaction data in CSV format.

The generated files are uploaded to the raw data location in Amazon S3.

### 2. Amazon S3

S3 acts as the cloud-based landing zone for raw CSV files.

```text
S3
└── raw_data/
    ├── sales_001.csv
    ├── sales_002.csv
    └── sales_003.csv
```

### 3. Snowpipe

Snowpipe automatically loads newly arrived CSV files from S3 into the Snowflake Bronze table.

```text
S3 → Snowpipe → Bronze Table
```

### 4. Bronze Layer

The Bronze layer stores the ingested raw data with minimal transformation.

This layer preserves the source-level data for traceability and downstream processing.

### 5. Streams

A Snowflake Stream tracks newly inserted or changed records in the Bronze layer.

This allows downstream processing to identify new data without repeatedly processing the entire Bronze table.

### 6. Tasks

Snowflake Tasks automate the execution of the transformation workflow.

The task processes newly available records and loads them into the Silver layer.

### 7. Stored Procedures

Stored procedures are used to organize transformation logic and automate repetitive ELT operations.

Examples include:

* Data validation
* Data cleaning
* Type conversion
* NULL handling
* Dimension loading
* Fact loading
* Audit logging

### 8. Silver Layer

The Silver layer contains cleaned and transformed data.

Example tables include:

```text
customer_details
price_details
product_details
product_overview
fact_sales_data
```

### 9. Dimensional Model

The analytical model follows a **star schema** consisting of:

```text
                 ┌─────────────────┐
                 │ Customer Dim    │
                 └────────┬────────┘
                          │
                          │
┌─────────────────┐  ┌───▼─────────────┐  ┌─────────────────┐
│ Product Dim     │──│ Fact Sales Data │──│ Other Dimensions│
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

The fact table contains transactional measures such as:

* Quantity
* Unit Price
* Total Amount
* Profit
* Shipping Cost
* Customer Satisfaction
* Days to Ship

### 10. Gold Layer

The Gold layer contains business-ready views for analytics.

Examples include:

* Sales KPI
* Daily Sales Trend
* Monthly Sales
* Sales Growth
* Product Performance
* Category Performance
* Top Products
* Customer Performance
* Customer Revenue Contribution
* Product Revenue Contribution

### 11. Power BI

The Gold-layer views are connected to Power BI to create interactive dashboards for business analysis.

---

## 🔍 Key Data Engineering Concepts Demonstrated

* ETL vs ELT
* Cloud storage
* Data ingestion
* Snowpipe
* External stages
* Storage integrations
* Streams
* Tasks
* Stored Procedures
* Change Data Capture
* Incremental processing
* Audit logging
* Error handling
* Dimensional modeling
* Star schema
* Fact and dimension tables
* Analytical views
* Business intelligence

---

## 📁 Project Structure

```text
snowflake-elt-batch-processing-pipeline/
│
├── README.md
│
├── data/
│   └── sample_data.csv
│
├── sql/
│   ├── database_schema.sql
│   ├── bronze_tables.sql
│   ├── silver_tables.sql
│   ├── gold_views.sql
│   ├── stored_procedures.sql
│   ├── snowpipe.sql
│   ├── streams_tasks.sql
│   └── audit_tables.sql
│
├── python/
│   └── data_generation.py
│
├── powerbi/
│   └── dashboard_screenshot.png
│
└── screenshots/
    └── architecture.png
```

---

## 🚀 How to Reproduce the Project

### Step 1 — Generate the Data

Run the Python script:

```bash
python python/data_generation.py
```

### Step 2 — Upload Data to S3

Upload the generated CSV file to the configured S3 raw-data location.

### Step 3 — Configure Snowflake

Create:

* Database
* Schemas
* File Format
* Storage Integration
* External Stage
* Bronze Table
* Snowpipe

### Step 4 — Configure Incremental Processing

Create:

* Stream
* Silver tables
* Stored Procedures
* Tasks
* Audit tables

### Step 5 — Create Gold Views

Execute the SQL scripts inside the `sql/` directory.

### Step 6 — Connect Power BI

Connect Power BI to the Gold-layer views and build the analytical dashboard.

---

## 📈 Business Use Cases

The pipeline enables analysis of:

* Total sales
* Total profit
* Sales growth
* Product performance
* Category contribution
* Customer revenue
* Regional performance
* Returns
* Shipping performance
* Customer satisfaction

---

## 👨‍💻 Skills Demonstrated

**Data Engineering:**
Python, SQL, ELT, ETL, Data Warehousing, Data Modeling

**Snowflake:**
Snowpipe, Streams, Tasks, Stored Procedures, Stages, Storage Integration, Views

**AWS:**
Amazon S3

**Analytics:**
Power BI, KPI Development, Business Reporting

---

## 📌 Future Enhancements

* Implement Snowflake Dynamic Tables.
* Add more robust data-quality checks.
* Implement retry mechanisms for failed pipeline executions.
* Add additional business dimensions.
* Introduce CI/CD for SQL deployment.
* Add automated testing for transformation logic.

---

## 📄 License

This project is created for educational and portfolio purposes.

# OmniStream: Relational Database Architecture for Video Streaming Platforms

OmniStream is a high-performance, scalable relational database system designed for video streaming platforms, engineered using PostgreSQL 17. The project encompasses the entire database development lifecycle, including conceptual modeling, Third Normal Form (3NF) logical schema design, data definition language (DDL) implementation, data manipulation language (DML) seeding, complex data query language (DQL) analytics, and transaction control language (TCL) safety protocols.

## Technical Stack
* Database Management System: PostgreSQL 17
* Administration Tool: pgAdmin 4
* Modeling Tools: Draw.io, Mermaid.js
* Core Features: JSONB Document Storage, GIN Inverted Indexing, Recursive Querying, ACID Transaction Blocks

## Project Directory Structure
The repository is organized into a production-ready directory layout:
```text
OmniStream-Database-System/
├── README.md
├── docs/
│   ├── OmniStream_Database_Design_Report.pdf
│   ├── Conceptual_ERD.drawio
│   └── Logical_Schema.drawio
├── sql/
│   ├── 01_ddl_schema.sql
│   ├── 02_dml_seed_data.sql
│   └── 03_analytics_and_tcl.sql
└── backup/
    └── MoviePlatform_backup.sql

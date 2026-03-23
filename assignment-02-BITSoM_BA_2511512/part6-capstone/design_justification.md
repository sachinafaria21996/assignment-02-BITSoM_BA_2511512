## Design Justification

### Storage Systems

1. For this hospital network, I chose a strategy that matches each of the four core goals to a specific, optimized storage engine, balancing high-speed clinical needs with long-term analytical power.

2. **Goal 1 (Predicting Readmission Risk)**: 

    2.1.  I selected a Cloud-based Data Lake. 
    
    2.2.  By using Change Data Capture (CDC) via Debezium, raw historical data from NoSQL and RDBMS sources is archived in a central repository.
    
    2.3.  This allows high-compute AI model training to occur in the cloud without consuming local hospital resources, utilizing years of data to identify patterns in patient readmissions.

3. **Goal 2 (Plain English Queries)**:

    3.1. I decided to utilise PostgreSQL with the pgvector extension on Server 1 (Primary). The Vector Database was then replicated onto Server 2 (Replica).
    
    3.2. A Python-based Smart Parser performs layout-aware chunking on medical history retrieved from the Data Lake, converting unstructured text into vector embeddings and storing it on Server 1. This is updated on Server 2.
    
    3.3. Server 2 is used to run a RAG (Retrieval-Augmented Generation) workflow where an LLM can semantically search patient history to answer complex clinical questions.

4. **Goal 3 (Monthly Reports)**:

    4.1.  I chose a Relational Database (PostgreSQL). 
    
    4.2.  Structured billing, insurance, and department-wise cost data are stored in traditional SQL tables.
    
    4.3.  By hosting this on Server 2 (the Replica), management can run resource-heavy aggregations and cost analyses without impacting the performance of live clinical systems.

5. **Goal 4 (Real-time Vitals)**:

    5.1.  I implemented a Kafka Buffer to handle high-velocity HTTP POST streams from ICU sensors. 
    
    5.2.  This data is landed in a dedicated local storage partition on Server 1, ensuring sub-second availability for the Real-Time Dashboard while maintaining a permanent record in the Cloud Data Lake for future analysis.

### OLTP vs OLAP Boundary

6. **OLTP**. 
    
    6.1.  In this architecture, the OLTP (Online Transactional Processing) boundary ends at the Primary Local Server (Server 1) and the source databases (NoSQL/RDBMS). 
    
    6.2.  These systems are optimized for "atomic" writes—recording a single heartbeat or a doctor’s specific note in real-time.

7. **OLAP**.

    7.1.  The OLAP (Online Analytical Processing) boundary begins at the Data Lake and the Server 2 hosting Replica data.
    
    7.2.  Once data is captured by Debezium and moved into the archive and thereafter forwarded to the replica Server via the Primary Server, it shifts from an "active record" to an "analytical asset." 
    
    7.3.  By separating these layers, we ensure that a doctor’s live terminal (OLTP) remains responsive even when the system is performing a deep semantic search or generating a large financial report (OLAP).

### Trade-Off


8. A significant trade-off in this design is **Replication Lag versus System Availability**. 

9. By using *Asynchronous WAL (Write-Ahead Log) Streaming* to update Server 2, there is a technical risk that the Replica may be a few milliseconds behind the Primary.

10. **Mitigation** : 

    10.1.  We mitigate this using a **Hybrid Consistency Model**.
    
    10.2.  For life-critical ICU vitals, the application layer is configured to read directly from the Primary Server (Server 1), ensuring zero-lag "Read-Your-Writes" consistency. 
    
    10.3.  For non-critical history queries and monthly reports, the system utilizes the Replica (Server 2). 
    
    10.3.  Furthermore, the AI-Analysis window can include a "*Last Synchronized*" timestamp, ensuring doctors are aware of the data's freshness before making clinical decisions.
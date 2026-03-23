# Anomaly Analysis
 - Insert Anomaly
    - The dataset has four types of data, i.e,
    
        - Customer
        - Order
        - Product
        - Sales

    - The insert anomaly exists since if any new product or customer or sales rep data is to be added - an order must exist and be added alongwith them.

- Modify Anomaly

    - Modify Anomaly exist in the office address of sales rep Deepak Joshi. His address is saved as two seperate address due to use of "**Pt**" instead of "**Point**".

        - **Address No. 1 :** Mumbai HQ, Nariman Point, Mumbai - 400021

        - **Address No. 2 :** Mumbai HQ, Nariman Pt, Mumbai - 400021
        
    - Cells where anomaly exist due to use of "**Pt**" are:

        - O39
        - 058
        - O91
        - O94
        - O98
        - O100
        - O112
        - O124
        - O127
        - O131
        - O154
        - O156
        - O160
        - O172
        - O182
        
        
- Delete Anomaly

    - Delete anomaly exists for Product Id P008 - Webcam.

    - It is there only in one order, and if the corresponding order id is deleted, then the data of Webcam will also be deleted and be lost.

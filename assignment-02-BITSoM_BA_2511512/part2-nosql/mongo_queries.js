// OP1: insertMany() — insert all 3 documents from sample_documents.json
// Here we insert three products: a Macbook Air (Electronics), a Raincoat (Clothing), and Cheetos Masala Balls (Groceries).


db.products.insertMany([

  {
    "name": "Macbook Air",
    "category": "Electronics",
    "price": 115000,
    "brand": "Apple",
    "specifications": {
      "warranty_years": 1,
      "voltage": "110-240V",
      "ram_gb": 16,
      "storage": "512GB SSD"
    },
    "tags": ["work", "high-performance"]
  },
  {
    "name": "Raincoat",
    "category": "Clothing",
    "price": 1200,
    "brand": "Cliff Climbers",
    "attributes": {
      "material": "Plastic Polymer",
      "sizes": ["S", "M", "L", "XL"],
      "color": "Charcoal Grey",
      "care": "Machine wash"
    }
  },
  {
    "name": "Cheetos Masala Balls",
    "category": "Groceries",
    "price": 50,
    "brand": "Cheetos",
    "expiry_date": "2024-09-01",
    "nutrition": {
      "calories": 120,
      "protein_g": 10,
      "fat_g": 5,
      "allergens": ["Chilli"]
    },
    "is_perishable": true
  }
]);

// OP2: find() — retrieve all Electronics products with price > 20000
// Here we query for all products in the "Electronics" category that are priced above 20,000.

db.products.find({
  "category": "Electronics",
  "price": { "$gt": 20000 }
});

// OP3: find() — retrieve all Groceries expiring before 2025-01-01
// Here we query for all products in the "Groceries" category that have an expiry date before  January 1, 2025.

db.products.find({
  "category": "Groceries",
  "expiry_date": { "$lt": new Date("2025-01-01") }
});

// OP4: updateOne() — add a "discount_percent" field to a specific product
// Here we add a 15% discount to the "Macbook Air" product.

db.products.updateOne(
  { "name": "Macbook Air" },
  { "$set": { "discount_percent": 15 } }
);

// OP5: createIndex() — create an index on category field and explain why
// Here we create an index on the "category" field to optimize queries that filter by category.

db.products.createIndex({ "category": 1 });

/* EXPLANATION: Indexing the 'category' field speeds up filtering. 
Instead of a full collection scan, MongoDB uses the index to quickly locate documents, 
which is vital for e-commerce scaling.*/
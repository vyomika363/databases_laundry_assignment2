# CS432 : Assignment 2 (Track 1)

**Group:** NULL VALUE  
**Course:** CS432 Databases | IIT Gandhinagar | 2025-2026  
**Instructor:** Dr. Yogesh K. Meena

---

## Project Structure
```
CS432_Track1_Submission/
├── Module A/
│   └── database/
│       ├── bplustree.py      # Core B+ Tree implementation
│       ├── table.py          # Table abstraction
│       ├── db_manager.py     # Database manager
│       ├── bruteforce.py     # Brute-force baseline
│       ├── performance.py    # Benchmarking
│       ├── report.ipynb      # Analysis and graphs
│       └── requirements.txt
│
├── Module B/
│   ├── app/
│   │   ├── server.js         # Express backend
│   │   ├── db.js             # MySQL connection
│   │   ├── index.html        # Frontend UI
│   │   ├── middleware/       # Auth and role middleware
│   │   ├── utils/            # Logger
│   │   └── logs/             # Audit logs
│   └── Report.pdf            # Module B report
│
└── README.md
```

## Features Module A

- Balanced B+ Tree structure
- Efficient search - O(log n)
- Fast range queries using linked leaf nodes
- Deletion with borrowing and merging
- Performance comparison with brute-force approach
## Module A - How to Run

**1. Install dependencies:**
```bash
cd "Module A/database"
pip install -r requirements.txt
```

**2. Run the notebook:**
```bash
jupyter notebook report.ipynb
```

---

## Module B — How to Run

**1. Set up MySQL** and import the database:
```bash
mysql -u root -p laundry_2 < laundry_2_sql.sql
```

**2. Configure environment:**
```bash
cd "Module B/app"
cp .env.example .env
# Fill in DB_PASSWORD in .env
```

**3. Install dependencies and start server:**
```bash
npm install
node server.js
```

**4. Open the app:**  
Go to `http://localhost:5000` in your browser.

---

## Team Contributions

| Member | Roll No | Module |
|--------|---------|--------|
| Aakash Venkatesan | 23110002 | Module B |
| BHC Karthikeya | 23110070 | Module A |
| Vyomika Vasireddy | 23110363 | Module B |
| D A S K R Manognya | 24110097 | Module B |
| Kaushik | 22110113 | Module A |

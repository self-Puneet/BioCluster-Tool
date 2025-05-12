# 🧬 BioCluster Tool – Interactive Bioinformatics Web App

**BioCluster Tool** is an interactive, web-based platform for the analysis and clustering of nucleotide sequences. Featuring a modern Flutter frontend and a robust FastAPI backend, it enables users to easily upload, analyze, and visualize biological sequence data. The tool supports intuitive clustering workflows, making advanced bioinformatics accessible to researchers, students, and developers—no deep programming or command-line experience required. BioCluster Tool streamlines sequence analysis, helping users gain insights from their data quickly and efficiently.

![screenshot](biocluster_test/assets/screenshorts/input_sequence.png)
![screenshot](biocluster_test/assets/screenshorts/clustering.png)

---

## 🗂 Project Structure

```bash
BioCluster-Tool/
├── biocluster/          # Flutter-based frontend for the web app
│   ├── lib/                  # Dart source code (main UI and logic)
│   ├── assets/               # Static assets (images, logos, etc.)
│   ├── web/                  # Web-specific files (HTML, manifest)
│   ├── pubspec.yaml          # Flutter dependencies and metadata
│   └── test/                 # Test files for the Flutter app
├── flask-backend/            # FastAPI-based backend for processing
│   ├── main.py               # Entry point for the FastAPI application
│   ├── routes/               # API route definitions
│   ├── utils/                # Utility functions for sequence analysis
│   ├── pyproject.toml        # Python dependencies and metadata
│   └── README.md             # Backend-specific documentation
├── README.md                 # Main project documentation
├── LICENSE                   # License information
└── sequences.txt             # Example input file for sequences
└── cluster.txt             # Example output cluster file for sequences
```

---

## 🛠 Getting Started

Follow these steps to run the app locally:

### Clone the Repository

```bash
git clone https://github.com/self-Puneet/BioCluster-Tool
```

### Backend Setup

```bash
# 1. Navigate to the backend directory
cd flask-backend

# 2. Install the required Python packages
pip install -r requirements.txt

# 3. Start the FastAPI server using Uvicorn
uvicorn main:app --reload
```

> ⚠️ **Make sure the backend server is running** (see backend setup above).

---

Once your backend is running locally, you can access the BioCluster Tool frontend by visiting the hosted web app at [https://biocluster-tool.netlify.app/](https://biocluster-tool.netlify.app/).

---

## 📄 Input and Output Text Document Formats

### Input File Format
The input file should be a text file containing sequences and their respective names in the following format:

```
cox2_dloop_human {2} : WTYEYTDYGGLILTTCST
cox2_dloop_human {3}  : WTYEYTDYTCST
cox2_dloop_human {4} : WTYEYTDYGGLILTTCST
cox2_dloop_human {5} : WTYEYTDYGGLIFNSYMLPTTCST
cox2_dloop_human {6} : WTYEYTDYGGLIFNSYEYCTVP
hemoglobin {1} : MVHLTPEEKSAVTALNALAHKYH
hemoglobin {2} : MVHLTGEEKSAVTLAHKYH
hemoglobin {3}: MVHLTPEEKNAVANALAHKYH
hemoglobin {4} : HLTPEEKSAVTAANALA
hemoglobin {5}: MVHLTPEEKTAVANALAHKYH
```

### Output File Format
The output file will contain the clustering results in the following format:

```
cluster1:
  hemoglobin {1}: MVHLTPEE...KYH
  hemoglobin {2}: MVHLTGEE...HKYH
  hemoglobin {3}: MVHLTPEE...AHKYH
  hemoglobin {4}: HLTPEEKSAV...ALA
  hemoglobin {5}: MVHLTPEEKTAVTTL...ALAHKYH

cluster2:
  cox2_dloop_human {2}: WTYEYTDYG...TTCST
  cox2_dloop_human {3}: WTYEYTDY...TLLPAT
  cox2_dloop_human {4}: WTYEYTD...IVRYHKYLTTCST
  cox2_dloop_human {5}: WTYEYTD...RYHKYLTTCST

cluster3:
  cox2_dloop_human {6}: WTYEYTDYGG...YCTVP

```

---

## 💬 Feedback & Contributions

We welcome contributions! Please open issues or submit pull requests to improve the functionality or design.

---

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](../LICENSE) file for details.

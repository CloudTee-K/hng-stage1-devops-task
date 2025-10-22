#  HNG Stage 1 DevOps Task — Automated Deployment

##  Project Overview
This project is part of the **HNG DevOps Internship (Stage 1)** challenge.  
The goal of this task is to **automate the deployment of a simple web application** using a **Bash script**, showcasing essential DevOps skills such as automation, containerization, and reliability.

The project includes:
- A lightweight **Flask web app** (`app.py`)
- A **Dockerfile** for containerizing the application
- A **Bash deployment script** (`deploy.sh`) that automates the entire setup and run process

---

##  Features
- Automated environment setup using Bash scripting  
- Dockerized Flask web application  
- Minimal manual intervention required for deployment  
- Easy to reproduce and modify  

---

## Technologies Used
- **Python (Flask)** — for the web application  
- **Docker** — for containerization  
- **Bash Script** — for automation  
- **Git & GitHub** — for version control and collaboration  

---

## How to Use

### 1. Clone the Repository
```bash
git clone https://github.com/CloudTee-K /HNG_Stage1_DevOps_Task.git
cd HNG_Stage1_DevOps_Task

###** 2. Make the Deployment Script Executable**
chmod +x deploy.sh

**3. Run the Deployment Script**
./deploy.sh

This script will:

Build the Docker image

Run the container

Expose the app on http://localhost:5000

Testing the Application

Once the container is up and running, open your browser and go to:

👉 http://localhost:5000

You should see a success message or your Flask app’s homepage.


Author

Name: KEHINDE PRECIOUS TOLUWALOPE 
GitHub: @CloudTee-K 

Role: DevOps Intern, HNG 13

License

This project is open-source and available under the MIT License

Acknowledgments

Special thanks to the HNG Internship Team for this opportunity to develop practical DevOps skills through hands-on projects.


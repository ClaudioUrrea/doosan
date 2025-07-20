# Human-Robot Collaboration (HRC) Simulation Artifacts

This repository contains the research artifacts for the paper "Advancing Human-Robot Collaboration for Industry 5.0: A Simulation-Based Hybrid Deep Learning and Reinforcement Learning Framework for Adaptive Task Allocation" by Claudio Urrea, submitted to *Systems* (MDPI, 2025). These artifacts include datasets, MATLAB scripts, tables, and figures to support the analysis of results presented in the paper (Section 4, Tables 2–3, Figures 2–6).

## Overview
The artifacts support a simulation-based Hybrid Deep Learning and Reinforcement Learning (DL-RL) framework for adaptive task allocation in Human-Robot Collaboration (HRC). Implemented in MATLAB R2025a and RoboDK 5.9, the framework integrates a Convolutional Neural Network (CNN) for human state perception with a Double Deep Q-Network (DDQN) for dynamic task allocation. The simulation evaluates 1,000 HRC episodes, achieving improvements in throughput, workload, and safety compared to rule-based and SARSA baselines.

## Repository Structure
HRC_Simulation_Artifacts/
├── README.md                # This file
├── Metadata.md              # Detailed file descriptions and dependencies
├── Paper_RoboDK.pdf         # Full manuscript
├── Dataset/
│   ├── Results/
│   │   ├── HRC_Simulation_Results.csv       # Performance metrics for 1,000 episodes
│   │   ├── HRC_Simulation_Log_Episodes.txt  # Simulation log
│   │   ├── HRC_Synthetic_Dataset.parquet    # Synthetic dataset (~100 KB) 
│   ├── Tables/
│   │   ├── Table_2.csv      # Performance metrics for methods (Table 2)
│   │   ├── Table_3.csv      # Metrics by human state (Table 3)
│   ├── Figures/
│   │   ├── Debug_Figure_4.txt   # Debug log for Figure 4
│   │   ├── Debug_Figure_6.txt   # Debug log for Figure 6
├── Scripts/
│   ├── hrc_simulation.m         # Main simulation script
│   ├── Table_2.m                # Generates Table 2
│   ├── Table_3.m                # Generates Table 3
│   ├── Figure_2.m               # Placeholder for Figure 2 (RoboDK snapshot)
│   ├── Figure_3.m               # Generates Figure 3 (Q-table heatmap)
│   ├── Figure_4.m               # Generates Figure 4 (conditional heatmaps)
│   ├── Figure_5.m               # Generates Figure 5 (dynamic task allocation)
│   ├── Figure_6.m               # Generates Figure 6 (proof-of-concept)
│   ├── Generate_Synthetic_Dataset.m  # Generates Parquet dataset
├── Figures/
│   ├── Figure_1.tiff            # System diagram illustrating the hybrid framework
│   ├── Figure_2.tiff            # RoboDK snapshot (placeholder)
│   ├── Figure_3.tiff            # Q-table heatmap
│   ├── Figure_4.tiff            # Conditional heatmaps
│   ├── Figure_5.tiff            # Dynamic task allocation
│   ├── Figure_6.tiff            # Proof-of-concept visualization
├── Simulation_Assets/
│   ├── Placeholder_Metadata.txt # Notes missing RoboDK templates, STEP/URDF models

## Installation
1. **MATLAB R2025a**:
   - Install MATLAB R2025a with the following toolboxes:
     - Reinforcement Learning Toolbox
     - Deep Learning Toolbox
     - Robotics System Toolbox
     - Statistics and Machine Learning Toolbox
   - Recommended hardware: NVIDIA RTX 4090 GPU for CNN training.

2. **RoboDK 5.9 (Optional)**:
   - Install RoboDK 5.9 for visualization (Section 2.1).
   - Set the API path to `C:\RoboDK\API\MATLAB` (modify as needed).
   - Note: Scripts run without RoboDK if connection fails (see `robodkAvailable` flag in `hrc_simulation.m`).

3. **Repository Setup**:
   - Clone this repository:
     ```bash
     git clone https://github.com/ClaudioUrrea/hrc-simulation.git

Alternatively, download files from FigShare ([DOI to be provided]).
Place all files in a MATLAB-accessible working directory.
Ensure HRC_Simulation_Results.csv is in the same directory as scripts.

Usage
1. Run the Simulation:
   - Execute hrc_simulation.m to simulate 1,000 HRC episodes.
   - Outputs:
     - HRC_Simulation_Results.csv: Performance metrics.
     - Plots: Throughput, workload, and safety trends (saved as PNGs if exported).
     - Note: RoboDK visualization requires a valid connection.

2. Generate Tables:
   - Run Table_2.m to produce Table_1.csv (Section 4.1, Table 2).
   - Run Table_3.m to produce Table_2.csv (Section 4.1, Table 3).
   - Inputs: HRC_Simulation_Results.csv.

3. Generate Figures:
   - Run Figure_1.m for the System diagram illustrating the hybrid framework (Section 2, Figure 1).
   - Run Figure_2.m for a placeholder RoboDK snapshot (Section 3.1, Figure 2).
   - Run Figure_3.m for the Q-table heatmap (Section 4, Figure 3).
   - Run Figure_4.m for conditional heatmaps (Section 4, Figure 4).
   - Run Figure_5.m for dynamic task allocation (Section 4, Figure 5).
   - Run Figure_6.m for proof-of-concept visualization (Section 4, Figure 6).
   - Outputs: PNG files in Figures/ directory.
   - Note: Figures 4–6 require HRC_Simulation_Results.csv and/or qTable from hrc_simulation.m.

4. Generate Synthetic Dataset:
   - Run generate_synthetic_dataset.m to create generate_synthetic_dataset.parquet (Section 2.2).
   - Input: HRC_Simulation_Results.csv.

5. View Results:
   - Open HRC_Simulation_Results.csv, Table_2.csv, Table_3.csv in a spreadsheet or MATLAB.
   - View figures in Figures/ using an image viewer.
   - Check debug logs in Dataset/Figures/ for Figure 4 and Figure 6 details.

Metadata
See Metadata.md for detailed file descriptions, column definitions (e.g., StateIndex = 1–9 for fatigue/skill combinations), and dependency information.

License
All files are licensed under Creative Commons Attribution 4.0 International (CC-BY 4.0), as per the paper’s open-access statement.

Citation
Urrea, C. (2025). Advancing Human-Robot Collaboration for Industry 5.0: A Simulation-Based Hybrid Deep Learning and Reinforcement Learning Framework for Adaptive Task Allocation. Systems, 13, [page range]. https://doi.org/10.3390/xxxxx.

Links
• Dataset: FigShare ([DOI to be provided])
• Code: GitHub (https://github.com/ClaudioUrrea/hrc-simulation)
• Preregistration: Open Science Framework ([URL to be provided])

Contact
For questions or possible missing files, contact Claudio Urrea at claudio.urrea@usach.cl


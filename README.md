# Movie Studio Management System

Welcome to the Movie Studio Management System! This project was developed as part of a bootcamp exercise to streamline various aspects of movie production management within a movie studio. Our system is built on Salesforce and is designed to help movie studios efficiently manage the complex processes of film production, budgeting, and financial tracking.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Setup Instructions](#setup-instructions)
- [Usage Guide](#usage-guide)
- [Future Enhancements](#future-enhancements)
- [Screenshots](#screenshots)
- [Contributing](#contributing)
- [License](#license)

## Overview

The Movie Studio Management System is a comprehensive Salesforce-based application that integrates with external APIs (like TMDB) to manage and track the entire lifecycle of movie production, from script creation to financial management and release planning.

Key features include:

- Budget allocation and tracking
- Partner and cast management
- Cost estimation based on team member rates and production timelines
- Movie catalog with search functionality
- External API integration for fetching movie details, reviews, and similar movies
- Data import and sync processes to keep movie information up-to-date

## Features

### 1. Budget Allocation and Tracking
- Allocate and manage the budget for each film.
- Track financial details such as revenue, actor costs, and overall production costs.
- Automated updates from CSV files to keep financial records current.

### 2. Partner and Cast Management
- Manage a list of partners who provide services like casting, directing, cinematography, etc.
- Track team member availability and costs to estimate production timelines and budgets.

### 3. Cost and Time Estimation
- Estimate the costs and production time required for a movie.
- Use script data to calculate the number of actors, locations, and production time needed.

### 4. Script Management
- Store detailed information about movie scripts, including production periods, actor requirements, and filming locations.
- Use script data to inform budgeting and timeline planning.

### 5. Financial Tracking
- Track financial information related to each movie, such as revenue, budget, and actor costs.
- Import financial data via CSV files to update movie records automatically.

### 6. Movie Catalog and Search
- A comprehensive movie catalog allows users to browse and search for movies by genre.
- The catalog improves efficiency in managing and searching for movies.

### 7. API Integration
- The system integrates with external APIs (such as TMDB) to fetch movie details, reviews, and similar movies.
- Movies not already in the database can be added via API by entering the TMDB ID.

### 8. Movie Importing and Syncing
- Movies can be imported via a movie loader from a file or by using the TMDB ID for API integration.
- A sync scheduler is available to periodically update movie information from the API.
- The Movie Batch process updates movie information, ensuring that all records are current.

## Setup Instructions

### Prerequisites
- Salesforce DX (SFDX) CLI installed
- A Salesforce Developer Org
- Visual Studio Code with Salesforce extensions

### Step-by-Step Setup

1. **Clone the repository**: 
    ```bash
    git clone <repository-url>
    cd movie-studio-management-system
    ```

2. **Authorize your Salesforce org**: 
    ```bash
    sfdx auth:web:login -a my-org-alias
    ```

3. **Deploy the project to your org**: 
    ```bash
    sfdx force:source:deploy -p force-app
    ```

4. **Assign Permission Sets**:
    - Assign the necessary permission sets to your user:
    ```bash
    sfdx force:user:permset:assign -n Movie_Studio_Permissions
    ```

5. **Import Sample Data**:
    - Load initial data into your Salesforce org using the provided data files.
    ```bash
    sfdx force:data:tree:import -p data/plan.json
    ```

6. **Run Tests**:
    - Validate the deployment by running all tests to ensure that everything is functioning as expected:
    ```bash
    sfdx force:apex:test:run --resultformat human --testlevel RunLocalTests
    ```

7. **Set Up Experience Cloud (Optional)**:
    - To migrate the application to Experience Cloud for external access, follow Salesforce’s Experience Cloud setup guide and deploy the necessary components.

## Usage Guide

### Movie Catalog
- Navigate to the "Movies" tab in the Salesforce app to access the movie catalog.
- Use the genre filter to search for movies by specific genres.
- Click on a movie to view details, reviews, similar movies, and other related information.

### Movie Loader
- Use the "Movie Loader" component to add new movies from a file or by entering a TMDB ID.
- You can import multiple movies at once via a CSV file or sync movie details using the sync scheduler.

### Reviews and Similar Movies
- Fetch movie reviews and similar movies directly from the TMDB API by navigating to a movie’s details page.

### Sync Scheduler
- The sync scheduler periodically updates movie information, ensuring that all records are up-to-date with the latest data from the API.

## Future Enhancements

- **Trailer Tab**: Implement a trailer tab on the movie record details page to embed trailers for each movie.
- **Experience Cloud Migration**: Migrate the application to Salesforce Experience Cloud for external-facing access, enabling partners and external users to interact with the movie catalog.
- **Enhanced Reporting**: Develop custom reports and dashboards to provide insights into production timelines, budget usage, and revenue forecasting.

## Screenshots



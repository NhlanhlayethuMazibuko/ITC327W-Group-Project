# ITC327W-Group-Project

Group project repository for ITC327W. This repository contains project planning, requirements, documentation, and source code for a Flutter mobile application, ASP.NET web application, and Supabase backend.

# ITC327W Group Project


## Project Overview

This repository contains the group project work for ITC327W: Work-Integrated Learning.

The project will involve developing:

- A Flutter mobile application
- An ASP.NET web application 
- A shared Supabase backend

## Group Members

- LW Simelane : 224022386
- M Lesenyelo : 224081110
- PA Mabusela : 222021446
- NL Mazibuko : 222044762
- AL Hadebe : 223000608
- M Mokhele : 221027626
- L Sandi : 223014209
- MN Dlamini : 224093660
- NP Khotle : 218013010
- JO Molaba : 224067603

## Technology

- Flutter 3 / Dart, `supabase_flutter`
- ASP.NET Core MVC (.NET 9), Supabase C# client + REST
- Supabase: PostgreSQL database, Auth, Storage, Row-Level Security

## Running the web app (`web/`)

Requirements: .NET 9 SDK, Visual Studio 2022 (or `dotnet` CLI).

1. Open `web/BigBrotherAccommodation.Web.sln`.
2. Add the Supabase settings as **user secrets** (never in `appsettings.json`):
   right-click the project → *Manage User Secrets* and add:
   ```json
   {
     "Supabase": { "Url": "...", "Key": "<publishable key>", "ServiceKey": "<service/secret key>" },
     "Payment": { "AccountHolder": "...", "BankName": "...", "AccountNumber": "...", "BranchCode": "..." }
   }
   ```
   Ask the project owner for the values.
3. Run (F5) or `dotnet run`. The site opens on `https://localhost:7067`.

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

## Design links

- Flutter wireframes (Figma): https://www.figma.com/design/wn4Il8WEIqOOEAMzvopEw1/Big-Brother-Student-accommodation-App?node-id=0-1&t=hWt4ymWWTZoOWg4z-1
- ASP.NET wireframes (Figma): https://www.figma.com/design/nsfe2RnSzAZCK1aHrkBLQn/Big-Brother-Student-Accom.?node-id=2479-2&t=nrbgrirBogvxMSpF-1

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

## Shared processes (Flutter - Supabase - ASP.NET)

1. **Application:** a student applies in the app, the application is stored in Supabase, and management reviews it on the website.
2. **Approval:** management approves on the website, the room is marked occupied (other applicants declined), and the app shows "Approved".
3. **Maintenance:** a tenant reports an issue in the app, management updates its status on the website, and the student sees the update.

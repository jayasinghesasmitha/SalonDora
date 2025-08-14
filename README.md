# 💇‍♀️ Salondora mobile app

Welcome to **SalonDora**, a full-featured salon booking platform designed for both **customers** and **salon owners**. Our system includes two separate apps—one for clients and one for salons—connected through a unified backend to streamline appointment scheduling, service customization, and location-based discovery.

## 📱 Project Overview

SmartSalon offers a seamless experience for both sides of the salon ecosystem:

### 👤 Customer App
- Register and log in
- View nearby salons via interactive map
- Browse services and stylists
- Book appointments with preferred time slots

### 🏪 Salon App
- Register salon and create a profile
- Customize available services and time slots
- Manage bookings and customer interactions

Both apps are built with distinct front ends but share a **common backend**, ensuring smooth data flow and real-time updates.

## 🧰 Tech Stack

| Layer        | Technology Used        |
|--------------|------------------------|
| Frontend     | Flutter (Dart)         |
| Backend      | Node.js                |
| Database     | Supabase (PostgreSQL)  |
| Location     | Map integration via Flutter plugins |

## 🗺️ Key Features

- 📍 **Location-Based Discovery**: Customers see salons near them on the home screen map
- 🧑‍🎨 **Stylist Selection**: Choose specific stylists and services
- 📆 **Time Slot Booking**: Real-time availability and scheduling
- 🛠️ **Salon Customization**: Salons manage their offerings and schedules


## 🚀 Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/jayasinghesasmitha/SalonDora.git
   ```
2. Set up Supabase and configure environment variables.
3. Run the Node.js backend:
   ```bash
   cd backend
   npm install
   npm run dev
   ```
4. Launch both Flutter apps:
   ```bash
   flutter run
   ```



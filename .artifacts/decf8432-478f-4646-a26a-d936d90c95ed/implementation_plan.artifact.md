# Implementation Plan - Customer Order Form & Gemini AI Chatbot ("Tailor Bot")

This plan outlines the implementation of two major features for the Tailor Management System:
1. **Customer Web/Mobile Order Form:** Allows customers/users to submit their name, phone, garment details, and measurements online, which automatically saves to MongoDB and triggers a real-time FCM push notification to the shop owner.
2. **Gemini AI Shop Assistant Chatbot ("Tailor Bot"):** An intelligent chat interface for the shop owner powered by Google Gemini AI (`google_generative_ai`) to query store analytics, pending orders, and revenues in English or Urdu.

## User Review Required

> [!IMPORTANT]
> The Customer Order submission endpoint (`POST /api/customer/orders`) will be public (or passcode/shop-linked) so customers can submit orders without needing shop owner login credentials.

## Proposed Changes

### Backend (`tailor-app-backend`)

#### [NEW] [customerOrderController.js](file:///C:/Users/LENOVO/Desktop/tailor-app-backend/controllers/customerOrderController.js)
- Handle incoming public customer orders, save to MongoDB, and trigger FCM notification to the shop owner's registered token.

#### [NEW] [customerOrderRoutes.js](file:///C:/Users/LENOVO/Desktop/tailor-app-backend/routes/customerOrderRoutes.js)
- Expose public POST route `/api/customer/orders`.

#### [MODIFY] [server.js](file:///C:/Users/LENOVO/Desktop/tailor-app-backend/server.js)
- Mount customer order routes.

---

### Frontend (`Tailor_Management_System`)

#### [NEW] [customer_order_screen.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tailor_Management_System/lib/views/customer_order_screen.dart)
- Form interface for customers to input info, select garments, fill out measurements, and submit online.

#### [NEW] [tailor_bot_screen.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tailor_Management_System/lib/views/tailor_bot_screen.dart)
- Gemini AI Chatbot interface where shop owners can ask questions about pending orders and revenue in English/Urdu.

#### [MODIFY] [home_screen.dart](file:///C:/Users/LENOVO/AndroidStudioProjects/Tailor_Management_System/lib/views/home_screen.dart)
- Add navigation drawer / dashboard shortcut to open the **Tailor Bot AI Chat**.
- Add a button or link to share the **Customer Order Form** link/view.

## Verification Plan

### Automated Tests
- Flutter analyze and build check.

### Manual Verification
- Submit a customer order via the form and verify that the shop owner receives the FCM push notification instantly.
- Open Tailor Bot and query pending orders and revenues in English and Urdu.

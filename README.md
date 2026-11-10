# BizReview - Business Review Mobile App

A clean, modern Flutter mobile application for discovering, reviewing, and managing businesses with Firebase backend, built using a **Feature-Based Architecture** with **BLoC (Cubit)** and **GetIt**.

---

## 👥 User Roles & Flow

BizReview is designed with two distinct roles:

### 1. 🏢 Business Owner
- **Dedicated Login & Signup**: Separate owner authentication.
- **Owner Dashboard**:
  - Add new businesses with immediate public visibility (no admin approval or pending status).
  - Manage and edit own businesses.
  - Monitor customer ratings and detailed feedback in real-time.
  - Edit owner profile and avatar.

### 2. 👤 Customer
- **Dedicated Login & Signup**: Separate customer authentication.
- **Customer Home**:
  - Explore public business listings with live search and category filters.
  - View comprehensive business details (Overview & Customer Reviews).
  - Rate and review businesses with an interactive 5-star rating system.
  - Manage and edit own submitted reviews.
  - Edit customer profile and avatar.

---

## 🔒 Permissions Matrix

| Feature | Business Owner | Customer |
|---|:---:|:---:|
| Separate Login & Signup | ✅ | ✅ |
| Public Business Listing (Browse) | ✅ | ✅ |
| View Ratings & Reviews | ✅ | ✅ |
| Add a Business | ✅ | ❌ |
| Edit Own Business | ✅ | ❌ |
| Add Ratings & Reviews | ❌ | ✅ |
| Edit Own Reviews | ❌ | ✅ |
| Delete Others' Reviews | ❌ | ❌ |

---

## 🗄️ Cloud Firestore Structure

```
Firebase Authentication
        │
        ├── Customer Accounts
        └── Business Owner Accounts

Cloud Firestore
        │
        ├── customers/
        │     └── customerUid
        │           ├── name
        │           ├── email
        │           └── profileImage
        │
        ├── business_owners/
        │     └── ownerUid
        │           ├── name
        │           ├── email
        │           └── profileImage
        │
        ├── businesses/
        │     └── businessId
        │           ├── businessName
        │           ├── ownerId
        │           ├── category
        │           ├── description
        │           ├── address
        │           ├── phone
        │           ├── images
        │           ├── averageRating
        │           ├── totalReviews
        │           └── createdAt
        │
        └── reviews/
              └── reviewId
                    ├── businessId
                    ├── customerId
                    ├── customerName
                    ├── customerProfileImage
                    ├── rating
                    ├── comment
                    └── createdAt
```

---

## 🏗️ Architecture & Pattern

The application follows a strictly decoupled **Feature-Based Architecture**:

```
Screen ➔ Cubit ➔ Repository ➔ Service ➔ Firebase
```

### Folder Structure
```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_constants.dart
│   ├── services/
│   │   └── notification_service.dart
│   ├── utils/
│   │   └── image_helper.dart
│   └── widgets/
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       └── rating_stars.dart
│
├── dependency_injection/
│   └── injection.dart
│
├── features/
│   ├── auth/
│   │   ├── cubit/
│   │   ├── models/
│   │   ├── repository/
│   │   ├── screens/
│   │   │   ├── role_selection_screen.dart
│   │   │   ├── customer_login_screen.dart
│   │   │   ├── customer_signup_screen.dart
│   │   │   ├── owner_login_screen.dart
│   │   │   ├── owner_signup_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   └── services/
│   │
│   ├── business/
│   │   ├── cubit/
│   │   ├── models/
│   │   ├── repository/
│   │   └── services/
│   │
│   ├── customer/
│   │   ├── business_details/
│   │   ├── home/
│   │   ├── profile/
│   │   └── reviews/
│   │
│   └── owner/
│       ├── add_business/
│       ├── dashboard/
│       ├── manage_business/
│       ├── profile/
│       └── view_reviews/
│
├── routes/
│   ├── app_routes.dart
│   └── route_guard.dart
│
└── main.dart
```

---

## 🛡️ Firebase Security Rules

See [firestore.rules](file:///C:/Users/Gopichand/Personal/BizReview/firestore.rules) for declarative security enforcing:
- Immediate public access to all businesses and reviews.
- Owner-only write permissions for their own businesses.
- Customer-only review creation and editing.
- Safe rating aggregation updates.

---

## 🚀 Setup & Installation

1. **Clone repository**:
   ```bash
   git clone https://github.com/GopiChandB1644/BizReview.git
   cd BizReview
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run application**:
   ```bash
   flutter run
   ```

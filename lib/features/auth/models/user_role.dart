enum UserRole {
  customer,
  owner;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.owner:
        return 'Business Owner';
    }
  }

  String get collectionName {
    switch (this) {
      case UserRole.customer:
        return 'customers';
      case UserRole.owner:
        return 'business_owners';
    }
  }
}

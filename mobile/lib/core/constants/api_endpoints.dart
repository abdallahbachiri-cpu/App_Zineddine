class ApiEndpoints {
  ApiEndpoints._();

  static const String authLogin = '/api/v2/auth/login';
  static const String authRegister = '/api/v2/auth/register';

  static const String user = '/api/user';
  static const String userProfileImage = '/api/user/profile-image';
  static const String userEmailConfirmationVerify =
      '/api/user/email-confirmation/verify';
  static const String userEmailConfirmationSend =
      '/api/user/email-confirmation/send';
  static const String userPasswordResetRequest =
      '/api/user/password-reset/request';
  static const String userPasswordResetVerify =
      '/api/user/password-reset/verify';
  static const String userPasswordResetConfirm =
      '/api/user/password-reset/confirm';

  static String userByType(String userType) => '/api/$userType';

  static String categoryTypes(String userType) =>
      '/api/$userType/category-types';



  static String categories(String userType) => '/api/$userType/categories';

  static String category(String userType, String categoryId) =>
      '/api/$userType/categories/$categoryId';

  static const String buyerCart = '/api/buyer/cart';
  static const String buyerCartDishes = '/api/buyer/cart/dishes';
  static const String buyerCartCheckout = '/api/buyer/cart/checkout';

  static String buyerCartDish(String cartDishId) =>
      '/api/buyer/cart/dishes/$cartDishId';
  static String buyerCartDishIngredients(String cartDishId) =>
      '/api/buyer/cart/dishes/$cartDishId/ingredients';
  static String buyerCartDishIngredient(
    String cartDishId,
    String ingredientId,
  ) => '/api/buyer/cart/dishes/$cartDishId/ingredients/$ingredientId';

  static const String buyerOrders = '/api/buyer/orders';

  static String buyerOrder(String orderId) => '/api/buyer/orders/$orderId';
  static String buyerOrderNote(String orderId) =>
      '/api/buyer/orders/$orderId/note';
  static String buyerOrderPay(String orderId) =>
      '/api/buyer/orders/$orderId/pay';
  static String buyerOrderCancel(String orderId) =>
      '/api/buyer/orders/$orderId/cancel';
  static String buyerOrderTip(String orderId) =>
      '/api/buyer/orders/$orderId/tip';
  static String buyerOrderProxyNumbers(String orderId) =>
      '/api/buyer/orders/$orderId/proxy-numbers';

  static const String buyerDishes = '/api/buyer/dishes';
  static const String buyerFoodStores = '/api/buyer/food-stores';
  static const String buyerFoodStoresNearby = '/api/buyer/food-stores/nearby';

  static String buyerDish(String dishId) => '/api/buyer/dishes/$dishId';
  static String buyerFoodStore(String foodStoreId) =>
      '/api/buyer/food-stores/$foodStoreId';
  static String buyerFoodStoreDishes(String foodStoreId) =>
      '/api/buyer/food-stores/$foodStoreId/dishes';

  static const String buyerRatings = '/api/buyer/ratings';

  static String buyerRating(String ratingId) => '/api/buyer/ratings/$ratingId';
  static String buyerDishRatings(String dishId) =>
      '/api/buyer/dishes/$dishId/ratings';

  static const String sellerFoodStore = '/api/seller/food-store';
  static const String sellerFoodStoreProfileImage =
      '/api/seller/food-store/profile-image';
  static const String sellerFoodStoreVerificationRequests =
      '/api/seller/food-store/verification-requests';

  static const String sellerStats = '/api/seller/stats';
  static const String sellerStatsRevenue = '/api/seller/stats/revenue';

  static String sellerStatsRevenueByYear(int year) =>
      '/api/seller/stats/revenue/$year';
  static String sellerStatsRevenueByMonth(int year, int month) =>
      '/api/seller/stats/revenue/$year/$month';

  static const String sellerOrders = '/api/seller/food-store/orders';

  static String sellerOrder(String orderId) =>
      '/api/seller/food-store/orders/$orderId';
  static String sellerOrderConfirm(String orderId) =>
      '/api/seller/food-store/orders/$orderId/confirm';
  static String sellerOrderMarkAsReady(String orderId) =>
      '/api/seller/food-store/orders/$orderId/ready';
  static String sellerOrderCancel(String orderId) =>
      '/api/seller/food-store/orders/$orderId/cancel';
  static String sellerOrderConfirmDelivery(String orderId) =>
      '/api/seller/food-store/orders/$orderId/confirm-delivery';
  static String sellerOrderProxyNumbers(String orderId) =>
      '/api/seller/orders/$orderId/proxy-numbers';

  static const String sellerDishes = '/api/seller/food-store/dishes';

  static String sellerDish(String dishId) =>
      '/api/seller/food-store/dishes/$dishId';
  static String sellerDishActivate(String dishId) =>
      '/api/seller/food-store/dishes/$dishId/activate';
  static String sellerDishDeactivate(String dishId) =>
      '/api/seller/food-store/dishes/$dishId/deactivate';
  static String sellerDishAddImages(String dishId) =>
      '/api/seller/food-store/dishes/$dishId/add-images';
  static String sellerDishMedia(String dishId, String mediaId) =>
      '/api/seller/food-store/dishes/$dishId/media/$mediaId';
  static String sellerDishCategories(String dishId) =>
      '/api/seller/food-store/dishes/$dishId/categories';
  static String sellerDishCategory(String dishId, String categoryId) =>
      '/api/seller/food-store/dishes/$dishId/categories/$categoryId';

  static String sellerDishIngredients(String dishId) =>
      '/api/seller/food-store/dishes/$dishId/ingredients';
  static String sellerDishIngredient(String dishId, String ingredientId) =>
      '/api/seller/food-store/dishes/$dishId/ingredients/$ingredientId';

  static const String sellerIngredients = '/api/seller/food-store/ingredients';

  static String sellerIngredient(String ingredientId) =>
      '/api/seller/food-store/ingredients/$ingredientId';

  static const String sellerRatings = '/api/seller/food-store/ratings';

  static String sellerDishRatings(String dishId) =>
      '/api/seller/food-store/dishes/$dishId/ratings';
  static String sellerDishRating(String dishId, String ratingId) =>
      '/api/seller/food-store/dishes/$dishId/ratings/$ratingId';

  static const String sellerWallet = '/api/seller/food-store/wallet';
  static const String sellerWalletTransactions =
      '/api/seller/food-store/wallet/transactions';

  static const String sellerStripeSetup = '/api/seller/food-store/stripe/setup';
  static const String sellerStripeStatus =
      '/api/seller/food-store/stripe/status';
  static const String sellerStripePayout =
      '/api/seller/food-store/stripe/payout';

  static const String sellerAllergens = '/api/seller/allergens';

  static String sellerDishAllergens(String dishId) =>
      '/api/seller/food-store/dishes/$dishId/allergens';
  static String sellerDishAllergen(String dishId, String allergenId) =>
      '/api/seller/food-store/dishes/$dishId/allergens/$allergenId';

  static const String sellerVendorAgreementAccept =
      '/api/seller/food-store/vendor-agreement/accept';

  static const String buyerLocations = '/api/buyer/locations';
  static String buyerLocation(String id) => '/api/buyer/locations/$id';

  // Notifications
  static String notificationsReceiver(String userId) =>
      '/api/notifications/receiver/$userId';
  static String notificationMarkShown(String notificationId) =>
      '/api/notifications/$notificationId/show';
  static String notificationDelete(String notificationId) =>
      '/api/notifications/$notificationId';
}

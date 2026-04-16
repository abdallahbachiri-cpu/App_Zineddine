// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(latitude, longitude) =>
      "Coordinates: ${latitude}, ${longitude}";

  static String m1(error) => "Error loading wallet data: ${error}";

  static String m2(name) => "Hello, ${name}!";

  static String m3(name) =>
      "Are you sure you want to delete \"${name}\"? This action cannot be undone.";

  static String m4(sortBy) => "Sorted by ${sortBy}";

  static String m5(count) => "${count} New";

  static String m6(error) => "Stripe error: ${error}";

  static String m7(error) => "Unexpected error: ${error}";

  static String m8(name, quantity) => "\$name x\$quantity";

  static String m9(sortBy) => "Sorted by ${sortBy}";

  static String m10(latitude, longitude) =>
      "Coordinates: ${latitude}, ${longitude}";

  static String m11(message) => "Stripe error: ${message}";

  static String m12(error) => "Unexpected error: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accountTypeSelection_accountTypeBuyer":
        MessageLookupByLibrary.simpleMessage("Looking for Homemade Meals"),
    "accountTypeSelection_accountTypeSeller":
        MessageLookupByLibrary.simpleMessage("Offering Homemade Meals"),
    "accountTypeSelection_accountTypeSubtitle":
        MessageLookupByLibrary.simpleMessage(
          "Are you here to enjoy delicious meals or share your culinary creations? Select your role to get started!",
        ),
    "accountTypeSelection_accountTypeTitle":
        MessageLookupByLibrary.simpleMessage("How You\'d Like to Join Us!"),
    "addButton": MessageLookupByLibrary.simpleMessage("Add"),
    "addPaymentCard_hintCardHolder": MessageLookupByLibrary.simpleMessage(
      "John Doe",
    ),
    "addPaymentCard_labelCVV": MessageLookupByLibrary.simpleMessage("CVV"),
    "addPaymentCard_labelCardHolder": MessageLookupByLibrary.simpleMessage(
      "Cardholder Name",
    ),
    "addPaymentCard_labelCardNumber": MessageLookupByLibrary.simpleMessage(
      "Card Number",
    ),
    "addPaymentCard_labelExpiryDate": MessageLookupByLibrary.simpleMessage(
      "Expiry Date",
    ),
    "addPaymentCard_save": MessageLookupByLibrary.simpleMessage("Save"),
    "addPaymentCard_setDefault": MessageLookupByLibrary.simpleMessage(
      "Set as default payment method",
    ),
    "addPaymentCard_title": MessageLookupByLibrary.simpleMessage("Add Card"),
    "addPaymentCard_validationCVVInvalid": MessageLookupByLibrary.simpleMessage(
      "Invalid CVV",
    ),
    "addPaymentCard_validationCVVRequired":
        MessageLookupByLibrary.simpleMessage("CVV required"),
    "addPaymentCard_validationCardNumberInvalid":
        MessageLookupByLibrary.simpleMessage("Enter valid Visa/MasterCard"),
    "addPaymentCard_validationCardNumberRequired":
        MessageLookupByLibrary.simpleMessage("Card number is required"),
    "addPaymentCard_validationExpiryInvalid":
        MessageLookupByLibrary.simpleMessage("Invalid format"),
    "addPaymentCard_validationExpiryRequired":
        MessageLookupByLibrary.simpleMessage("Expiry required"),
    "addPaymentCard_validationNameRequired":
        MessageLookupByLibrary.simpleMessage("Name is required"),
    "addTipTitle": MessageLookupByLibrary.simpleMessage("Add a Tip"),
    "additionalCostItem": MessageLookupByLibrary.simpleMessage(
      "Additional cost item",
    ),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "addressFormAddTitle": MessageLookupByLibrary.simpleMessage("Add Address"),
    "addressFormCurrentLocationButton": MessageLookupByLibrary.simpleMessage(
      "Use Current Location",
    ),
    "addressFormEditTitle": MessageLookupByLibrary.simpleMessage(
      "Edit Address",
    ),
    "addressFormMapTitle": MessageLookupByLibrary.simpleMessage(
      "Select Location on Map",
    ),
    "addressFormProcessing": MessageLookupByLibrary.simpleMessage(
      "Processing...",
    ),
    "addressFormSaveButton": MessageLookupByLibrary.simpleMessage(
      "Save Address",
    ),
    "addressFormStreetHint": MessageLookupByLibrary.simpleMessage(
      "Enter street address",
    ),
    "addressFormStreetLabel": MessageLookupByLibrary.simpleMessage(
      "Street Address",
    ),
    "addressFormUpdateButton": MessageLookupByLibrary.simpleMessage(
      "Update Address",
    ),
    "addressManagement_deleteCancel": MessageLookupByLibrary.simpleMessage(
      "Cancel",
    ),
    "addressManagement_deleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Delete",
    ),
    "addressManagement_deleteContent": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this address?",
    ),
    "addressManagement_deleteTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Address",
    ),
    "addressManagement_emptyButton": MessageLookupByLibrary.simpleMessage(
      "Add First Address",
    ),
    "addressManagement_emptyText": MessageLookupByLibrary.simpleMessage(
      "No saved addresses",
    ),
    "addressManagement_title": MessageLookupByLibrary.simpleMessage(
      "Saved Addresses",
    ),
    "addressManagement_yourAddresses": MessageLookupByLibrary.simpleMessage(
      "Your Addresses",
    ),
    "addressNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Address not available",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Agree"),
    "allFilesUploadedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "All files uploaded successfully",
    ),
    "amount": MessageLookupByLibrary.simpleMessage("Amount"),
    "availableAt": MessageLookupByLibrary.simpleMessage("Available At"),
    "buyerOrderDetails_cancelOrder": MessageLookupByLibrary.simpleMessage(
      "Cancel Order",
    ),
    "buyerOrderDetails_editNote": MessageLookupByLibrary.simpleMessage(
      "Edit Note",
    ),
    "buyerOrderDetails_labelConfirmationCode":
        MessageLookupByLibrary.simpleMessage("Confirmation Code:"),
    "buyerOrderDetails_labelDate": MessageLookupByLibrary.simpleMessage(
      "Date:",
    ),
    "buyerOrderDetails_labelDeliveryStatus":
        MessageLookupByLibrary.simpleMessage("Delivery Status:"),
    "buyerOrderDetails_labelEmail": MessageLookupByLibrary.simpleMessage(
      "Email:",
    ),
    "buyerOrderDetails_labelName": MessageLookupByLibrary.simpleMessage(
      "Name:",
    ),
    "buyerOrderDetails_labelOrderNumber": MessageLookupByLibrary.simpleMessage(
      "Order #:",
    ),
    "buyerOrderDetails_labelPaymentStatus":
        MessageLookupByLibrary.simpleMessage("Payment Status:"),
    "buyerOrderDetails_labelPhone": MessageLookupByLibrary.simpleMessage(
      "Phone:",
    ),
    "buyerOrderDetails_labelSubtotal": MessageLookupByLibrary.simpleMessage(
      "Subtotal:",
    ),
    "buyerOrderDetails_labelTipAmount": MessageLookupByLibrary.simpleMessage(
      "Tip Amount:",
    ),
    "buyerOrderDetails_noNotes": MessageLookupByLibrary.simpleMessage(
      "No notes added",
    ),
    "buyerOrderDetails_notFound": MessageLookupByLibrary.simpleMessage(
      "Receipt not found",
    ),
    "buyerOrderDetails_noteCancel": MessageLookupByLibrary.simpleMessage(
      "Cancel",
    ),
    "buyerOrderDetails_noteHint": MessageLookupByLibrary.simpleMessage(
      "Special instructions or notes...",
    ),
    "buyerOrderDetails_noteLabel": MessageLookupByLibrary.simpleMessage("Note"),
    "buyerOrderDetails_noteSave": MessageLookupByLibrary.simpleMessage("Save"),
    "buyerOrderDetails_payOrder": MessageLookupByLibrary.simpleMessage(
      "Pay Order",
    ),
    "buyerOrderDetails_sectionCustomer": MessageLookupByLibrary.simpleMessage(
      "CUSTOMER",
    ),
    "buyerOrderDetails_sectionDeliveryTo": MessageLookupByLibrary.simpleMessage(
      "DELIVERY TO",
    ),
    "buyerOrderDetails_sectionItems": MessageLookupByLibrary.simpleMessage(
      "ITEMS",
    ),
    "buyerOrderDetails_sectionOrderNotes": MessageLookupByLibrary.simpleMessage(
      "ORDER NOTES",
    ),
    "buyerOrderDetails_sectionPaymentDetails":
        MessageLookupByLibrary.simpleMessage("PAYMENT DETAILS"),
    "buyerOrderDetails_sectionTotal": MessageLookupByLibrary.simpleMessage(
      "TOTAL",
    ),
    "buyerOrderDetails_showCodeToSeller": MessageLookupByLibrary.simpleMessage(
      "Show this code to the seller",
    ),
    "buyerOrderDetails_thankYou": MessageLookupByLibrary.simpleMessage(
      "Thank you for your order!",
    ),
    "buyerOrderDetails_timelineConfirmed": MessageLookupByLibrary.simpleMessage(
      "Confirmed",
    ),
    "buyerOrderDetails_timelineDelivered": MessageLookupByLibrary.simpleMessage(
      "Delivered",
    ),
    "buyerOrderDetails_timelineOrdered": MessageLookupByLibrary.simpleMessage(
      "Ordered",
    ),
    "buyerOrderDetails_timelineReady": MessageLookupByLibrary.simpleMessage(
      "ready",
    ),
    "buyerOrderDetails_title": MessageLookupByLibrary.simpleMessage(
      "Order Receipt",
    ),
    "buyerOrderDetails_totalPaid": MessageLookupByLibrary.simpleMessage(
      "TOTAL PAID",
    ),
    "buyerOrderDetails_waitingForConfirmation":
        MessageLookupByLibrary.simpleMessage("Waiting for seller confirmation"),
    "buyerOrders_empty": MessageLookupByLibrary.simpleMessage(
      "No orders found",
    ),
    "buyerOrders_errorRetry": MessageLookupByLibrary.simpleMessage("Retry"),
    "buyerOrders_filterApply": MessageLookupByLibrary.simpleMessage("Apply"),
    "buyerOrders_filterMaxPrice": MessageLookupByLibrary.simpleMessage(
      "Max Price",
    ),
    "buyerOrders_filterMinPrice": MessageLookupByLibrary.simpleMessage(
      "Min Price",
    ),
    "buyerOrders_filterReset": MessageLookupByLibrary.simpleMessage("Reset"),
    "buyerOrders_filterTitle": MessageLookupByLibrary.simpleMessage(
      "Filter & Sort",
    ),
    "buyerOrders_itemBuyer": MessageLookupByLibrary.simpleMessage("Buyer:"),
    "buyerOrders_itemNumber": MessageLookupByLibrary.simpleMessage("Order"),
    "buyerOrders_itemPlaced": MessageLookupByLibrary.simpleMessage("Placed:"),
    "buyerOrders_itemTotal": MessageLookupByLibrary.simpleMessage("Total:"),
    "buyerOrders_searchHint": MessageLookupByLibrary.simpleMessage(
      "Order number, store name...",
    ),
    "buyerOrders_searchLabel": MessageLookupByLibrary.simpleMessage("Search"),
    "buyerOrders_sortCreated": MessageLookupByLibrary.simpleMessage(
      "Created Date",
    ),
    "buyerOrders_sortDeliveryStatus": MessageLookupByLibrary.simpleMessage(
      "Delivery Status",
    ),
    "buyerOrders_sortOrderAsc": MessageLookupByLibrary.simpleMessage(
      "Ascending",
    ),
    "buyerOrders_sortOrderDesc": MessageLookupByLibrary.simpleMessage(
      "Descending",
    ),
    "buyerOrders_sortPaymentStatus": MessageLookupByLibrary.simpleMessage(
      "Payment Status",
    ),
    "buyerOrders_sortPrice": MessageLookupByLibrary.simpleMessage(
      "Total Price",
    ),
    "buyerOrders_sortStatus": MessageLookupByLibrary.simpleMessage("Status"),
    "buyerOrders_title": MessageLookupByLibrary.simpleMessage("My Orders"),
    "callBuyer": MessageLookupByLibrary.simpleMessage("Call Buyer"),
    "callNowButton": MessageLookupByLibrary.simpleMessage("Call Now"),
    "callSeller": MessageLookupByLibrary.simpleMessage("Call Seller"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cart_checkoutButton": MessageLookupByLibrary.simpleMessage(
      "Proceed to Checkout",
    ),
    "cart_emptySubtitle": MessageLookupByLibrary.simpleMessage(
      "Add items to get started",
    ),
    "cart_emptyTitle": MessageLookupByLibrary.simpleMessage(
      "Your cart is empty",
    ),
    "cart_errorTryAgain": MessageLookupByLibrary.simpleMessage("Try Again"),
    "cart_itemDelete": MessageLookupByLibrary.simpleMessage("Remove item"),
    "cart_label": MessageLookupByLibrary.simpleMessage("Cart"),
    "cart_refreshTooltip": MessageLookupByLibrary.simpleMessage("Refresh cart"),
    "cart_title": MessageLookupByLibrary.simpleMessage("Your Cart"),
    "cart_total": MessageLookupByLibrary.simpleMessage("Total"),
    "changeImage": MessageLookupByLibrary.simpleMessage("Change Image"),
    "checkout_completeButton": MessageLookupByLibrary.simpleMessage(
      "Complete Checkout",
    ),
    "checkout_errorMessage": MessageLookupByLibrary.simpleMessage(
      "Checkout failed",
    ),
    "checkout_noLocations": MessageLookupByLibrary.simpleMessage(
      "No locations available. Add a location first.",
    ),
    "checkout_placeOrder": MessageLookupByLibrary.simpleMessage("Place Order"),
    "checkout_selectLocation": MessageLookupByLibrary.simpleMessage(
      "Select Delivery Location",
    ),
    "checkout_successMessage": MessageLookupByLibrary.simpleMessage(
      "Order placed successfully!",
    ),
    "checkout_title": MessageLookupByLibrary.simpleMessage("Checkout"),
    "checkout_yourOrder": MessageLookupByLibrary.simpleMessage("Your Order"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmDeliveryButton": MessageLookupByLibrary.simpleMessage(
      "Confirm Delivery",
    ),
    "confirmLocation": MessageLookupByLibrary.simpleMessage("Confirm Location"),
    "confirmOrderButton": MessageLookupByLibrary.simpleMessage("Confirm Order"),
    "confirmTip": MessageLookupByLibrary.simpleMessage("Pay Tip"),
    "confirmationCodeHint": MessageLookupByLibrary.simpleMessage(
      "Enter code provided by buyer",
    ),
    "connectStripeAccount": MessageLookupByLibrary.simpleMessage(
      "Connect Stripe Account",
    ),
    "coordinates": m0,
    "couldNotFetchAddress": MessageLookupByLibrary.simpleMessage(
      "Could not fetch address. Please try again.",
    ),
    "couldNotRetrieveAddressDetails": MessageLookupByLibrary.simpleMessage(
      "Could not retrieve address details",
    ),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "createNew": MessageLookupByLibrary.simpleMessage("Create New"),
    "createStore": MessageLookupByLibrary.simpleMessage("Create Store"),
    "createYourFirstIngredient": MessageLookupByLibrary.simpleMessage(
      "Create your first ingredient to get started",
    ),
    "currency": MessageLookupByLibrary.simpleMessage("Currency"),
    "customTipAmount": MessageLookupByLibrary.simpleMessage("Custom Amount"),
    "customTipHint": MessageLookupByLibrary.simpleMessage("Enter amount"),
    "date": MessageLookupByLibrary.simpleMessage("Date"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteIngredient": MessageLookupByLibrary.simpleMessage(
      "Delete Ingredient",
    ),
    "deleteIngredientContent": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this ingredient?",
    ),
    "deleteStore": MessageLookupByLibrary.simpleMessage("Delete Store"),
    "deleteStoreContent": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete your store? and log out",
    ),
    "deleteStoreTitle": MessageLookupByLibrary.simpleMessage("Delete Store"),
    "deliveryMethod": MessageLookupByLibrary.simpleMessage("Delivery Method"),
    "deliveryMethodLabel": MessageLookupByLibrary.simpleMessage("DELIVERY"),
    "description": MessageLookupByLibrary.simpleMessage("Description"),
    "dishDetailAvailable": MessageLookupByLibrary.simpleMessage("Available"),
    "dishDetailUnavailable": MessageLookupByLibrary.simpleMessage(
      "Unavailable",
    ),
    "dishDetail_allergens": MessageLookupByLibrary.simpleMessage("Allergens"),
    "dishDetail_basePrice": MessageLookupByLibrary.simpleMessage("Base Price:"),
    "dishDetail_categories": MessageLookupByLibrary.simpleMessage("Categories"),
    "dishDetail_editButton": MessageLookupByLibrary.simpleMessage("Edit"),
    "dishDetail_ingredients": MessageLookupByLibrary.simpleMessage(
      "Ingredients",
    ),
    "dishDetail_reviews": MessageLookupByLibrary.simpleMessage("Reviews"),
    "dishDetail_totalPrice": MessageLookupByLibrary.simpleMessage(
      "Dish Price:",
    ),
    "dishForm_createButton": MessageLookupByLibrary.simpleMessage(
      "Create Dish",
    ),
    "dishForm_createTitle": MessageLookupByLibrary.simpleMessage("Create Dish"),
    "dishForm_deleteImageContent": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this image?",
    ),
    "dishForm_deleteImageTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Image",
    ),
    "dishForm_descriptionHint": MessageLookupByLibrary.simpleMessage(
      "Enter dish description",
    ),
    "dishForm_descriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Description",
    ),
    "dishForm_editTitle": MessageLookupByLibrary.simpleMessage("Edit Dish"),
    "dishForm_imagesLabel": MessageLookupByLibrary.simpleMessage("Images"),
    "dishForm_nameHint": MessageLookupByLibrary.simpleMessage(
      "Enter dish name",
    ),
    "dishForm_nameLabel": MessageLookupByLibrary.simpleMessage("Dish Name"),
    "dishForm_priceHint": MessageLookupByLibrary.simpleMessage(
      "Enter dish price",
    ),
    "dishForm_priceLabel": MessageLookupByLibrary.simpleMessage("Price"),
    "dishForm_updateButton": MessageLookupByLibrary.simpleMessage(
      "Update Dish",
    ),
    "dishIngredientsTitle": MessageLookupByLibrary.simpleMessage(
      "Dish Ingredients",
    ),
    "dishList_noRecipes": MessageLookupByLibrary.simpleMessage(
      "No recipes found",
    ),
    "dishList_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "dishManagement_activate": MessageLookupByLibrary.simpleMessage("Activate"),
    "dishManagement_deactivate": MessageLookupByLibrary.simpleMessage(
      "Deactivate",
    ),
    "dishManagement_deleteCancel": MessageLookupByLibrary.simpleMessage(
      "Cancel",
    ),
    "dishManagement_deleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Delete",
    ),
    "dishManagement_deleteContent": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this dish?",
    ),
    "dishManagement_deleteTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Dish",
    ),
    "dishManagement_dishActivated": MessageLookupByLibrary.simpleMessage(
      "Dish activated",
    ),
    "dishManagement_dishDeactivated": MessageLookupByLibrary.simpleMessage(
      "Dish deactivated",
    ),
    "dishManagement_empty": MessageLookupByLibrary.simpleMessage(
      "No dishes found",
    ),
    "dishManagement_inactive": MessageLookupByLibrary.simpleMessage("Inactive"),
    "dishManagement_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "dishManagement_title": MessageLookupByLibrary.simpleMessage(
      "Manage Dishes",
    ),
    "dishReviews_rateDish": MessageLookupByLibrary.simpleMessage("Rate Dish"),
    "dishReviews_ratingCommentHint": MessageLookupByLibrary.simpleMessage(
      "Share your experience with this dish...",
    ),
    "dishReviews_ratingCommentLabel": MessageLookupByLibrary.simpleMessage(
      "Comment (Optional)",
    ),
    "dishReviews_reviews": MessageLookupByLibrary.simpleMessage("reviews"),
    "dishReviews_submitReview": MessageLookupByLibrary.simpleMessage(
      "Submit Review",
    ),
    "dishReviews_yourReview": MessageLookupByLibrary.simpleMessage(
      "Your Review",
    ),
    "editAddress_addTitle": MessageLookupByLibrary.simpleMessage("Add Address"),
    "editAddress_editTitle": MessageLookupByLibrary.simpleMessage(
      "Edit Address",
    ),
    "editAddress_failedToGetAddress": MessageLookupByLibrary.simpleMessage(
      "Failed to get address",
    ),
    "editAddress_failedToUpdateLocation": MessageLookupByLibrary.simpleMessage(
      "Failed to update location",
    ),
    "editAddress_mapTitle": MessageLookupByLibrary.simpleMessage(
      "Select Location on Map",
    ),
    "editAddress_processing": MessageLookupByLibrary.simpleMessage(
      "Processing...",
    ),
    "editAddress_saveButton": MessageLookupByLibrary.simpleMessage(
      "Save Address",
    ),
    "editAddress_streetHint": MessageLookupByLibrary.simpleMessage(
      "Enter street address",
    ),
    "editAddress_streetLabel": MessageLookupByLibrary.simpleMessage(
      "Street Address",
    ),
    "editAddress_updateButton": MessageLookupByLibrary.simpleMessage(
      "Update Address",
    ),
    "editStore": MessageLookupByLibrary.simpleMessage("Edit Store"),
    "edit_profile": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enterPriceEg250": MessageLookupByLibrary.simpleMessage(
      "Enter price (e.g., 2.50)",
    ),
    "errorLoadingStore": MessageLookupByLibrary.simpleMessage(
      "Failed to load store. Please retry.",
    ),
    "errorLoadingTransactions": MessageLookupByLibrary.simpleMessage(
      "Error loading transactions",
    ),
    "errorLoadingWalletData": m1,
    "error_updating_profile": MessageLookupByLibrary.simpleMessage(
      "Error updating profile",
    ),
    "exploreLabel": MessageLookupByLibrary.simpleMessage("Explore"),
    "failedToAddToCart": MessageLookupByLibrary.simpleMessage(
      "Failed to add to cart",
    ),
    "failedToInitializePayment": MessageLookupByLibrary.simpleMessage(
      "Failed to initialize payment sheet",
    ),
    "fetchingAddress": MessageLookupByLibrary.simpleMessage(
      "Fetching address...",
    ),
    "fileUploadBrowse": MessageLookupByLibrary.simpleMessage("Browse Files"),
    "fileUploadDragDrop": MessageLookupByLibrary.simpleMessage(
      "Drag & Drop files here",
    ),
    "fileUploadOr": MessageLookupByLibrary.simpleMessage("or"),
    "fileUploadRemove": MessageLookupByLibrary.simpleMessage("Remove"),
    "fileUploadStep1Title": MessageLookupByLibrary.simpleMessage(
      "Step 1: Justification of permit to work",
    ),
    "fileUploadStep2Title": MessageLookupByLibrary.simpleMessage(
      "Step 2: Certificate of MAPAQ",
    ),
    "fileUploadStep3Title": MessageLookupByLibrary.simpleMessage(
      "Step 3: Personal ID (driving license, passport)",
    ),
    "fileUploadStep4Title": MessageLookupByLibrary.simpleMessage(
      "Step 4: Establishment Certificate",
    ),
    "fileUploadUploading": MessageLookupByLibrary.simpleMessage("Uploading..."),
    "first_name": MessageLookupByLibrary.simpleMessage("First Name"),
    "foodStoreAboutUs": MessageLookupByLibrary.simpleMessage("About Us"),
    "foodStoreCategoryAll": MessageLookupByLibrary.simpleMessage("All"),
    "foodStoreCategoryBreakfast": MessageLookupByLibrary.simpleMessage(
      "Breakfast",
    ),
    "foodStoreCategoryDessert": MessageLookupByLibrary.simpleMessage("Dessert"),
    "foodStoreCategoryLunch": MessageLookupByLibrary.simpleMessage("Lunch"),
    "foodStoreMap_addressNotFound": MessageLookupByLibrary.simpleMessage(
      "Address not found. Please try a different one.",
    ),
    "foodStoreMap_genericError": MessageLookupByLibrary.simpleMessage(
      "An error occurred",
    ),
    "foodStoreMap_geocodingError": MessageLookupByLibrary.simpleMessage(
      "A map error occurred. Please check your connection and try again.",
    ),
    "foodStoreMap_locationDisabled": MessageLookupByLibrary.simpleMessage(
      "Location services are disabled",
    ),
    "foodStoreMap_noRecipes": MessageLookupByLibrary.simpleMessage(
      "No recipes found",
    ),
    "foodStoreMap_permissionDenied": MessageLookupByLibrary.simpleMessage(
      "Location permissions are denied",
    ),
    "foodStoreMap_permissionDeniedPermanently":
        MessageLookupByLibrary.simpleMessage(
          "Location permissions are permanently denied",
        ),
    "foodStoreMap_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "foodStoreMap_searchHint": MessageLookupByLibrary.simpleMessage(
      "Search by address...",
    ),
    "foodStoreMap_title": MessageLookupByLibrary.simpleMessage(
      "Nearby Food Stores",
    ),
    "foodStoreNoImages": MessageLookupByLibrary.simpleMessage(
      "No images available",
    ),
    "foodStoreRecipesCount": MessageLookupByLibrary.simpleMessage("Recipes"),
    "foodStoreStoreInfo": MessageLookupByLibrary.simpleMessage(
      "Store Information",
    ),
    "foodStoreTabAbout": MessageLookupByLibrary.simpleMessage("About"),
    "foodStoreTabGallery": MessageLookupByLibrary.simpleMessage("Gallery"),
    "foodStoreTabRecipes": MessageLookupByLibrary.simpleMessage("Recipes"),
    "french": MessageLookupByLibrary.simpleMessage("Français"),
    "goToCart": MessageLookupByLibrary.simpleMessage("Go to Cart"),
    "googleRegister_button": MessageLookupByLibrary.simpleMessage("Register"),
    "googleRegister_emailHint": MessageLookupByLibrary.simpleMessage(
      "Enter your email",
    ),
    "googleRegister_emailLabel": MessageLookupByLibrary.simpleMessage(
      "Email :",
    ),
    "googleRegister_firstNameHint": MessageLookupByLibrary.simpleMessage(
      "John",
    ),
    "googleRegister_firstNameLabel": MessageLookupByLibrary.simpleMessage(
      "First Name",
    ),
    "googleRegister_lastNameHint": MessageLookupByLibrary.simpleMessage("Doe"),
    "googleRegister_lastNameLabel": MessageLookupByLibrary.simpleMessage(
      "Last Name",
    ),
    "googleRegister_operationFailed": MessageLookupByLibrary.simpleMessage(
      "Operation failed",
    ),
    "googleRegister_requiredField": MessageLookupByLibrary.simpleMessage(
      "Required field",
    ),
    "googleRegister_slogan": MessageLookupByLibrary.simpleMessage(
      "VOS VOISINS, VOS CHEFS",
    ),
    "googleRegister_validationFirstNameRequired":
        MessageLookupByLibrary.simpleMessage("First name is required"),
    "googleRegister_validationLastNameRequired":
        MessageLookupByLibrary.simpleMessage("Last name is required"),
    "googleRegister_validationPhoneInvalid":
        MessageLookupByLibrary.simpleMessage("Enter a valid phone number"),
    "googleRegister_validationPhoneRequired":
        MessageLookupByLibrary.simpleMessage("Phone number is required"),
    "header_hello": m2,
    "header_searchHint": MessageLookupByLibrary.simpleMessage("Search..."),
    "homeLabel": MessageLookupByLibrary.simpleMessage("Home"),
    "home_allRecipes": MessageLookupByLibrary.simpleMessage("All Recipes"),
    "home_categories": MessageLookupByLibrary.simpleMessage("Categories"),
    "home_filterTitle": MessageLookupByLibrary.simpleMessage("Filter Dishes"),
    "home_ingredients": MessageLookupByLibrary.simpleMessage("Ingredients"),
    "home_noCategories": MessageLookupByLibrary.simpleMessage(
      "No categories found",
    ),
    "home_noRecipes": MessageLookupByLibrary.simpleMessage("No recipes found"),
    "home_popularChefs": MessageLookupByLibrary.simpleMessage("Popular Chefs"),
    "home_popularRecipes": MessageLookupByLibrary.simpleMessage(
      "Popular Recipes",
    ),
    "home_seeAll": MessageLookupByLibrary.simpleMessage("See All"),
    "home_selectedRecipes": MessageLookupByLibrary.simpleMessage("Recipes"),
    "home_sortPrice": MessageLookupByLibrary.simpleMessage("Price"),
    "home_sortRating": MessageLookupByLibrary.simpleMessage("Rating"),
    "ingredientAddedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Ingredient added successfully",
    ),
    "ingredientCreatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Ingredient created successfully",
    ),
    "ingredientDeletedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Ingredient deleted successfully",
    ),
    "ingredientManagement": MessageLookupByLibrary.simpleMessage(
      "Ingredient Management",
    ),
    "ingredientRemovedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Ingredient removed from dish successfully",
    ),
    "ingredientUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Ingredient updated successfully",
    ),
    "ingredients_empty": MessageLookupByLibrary.simpleMessage(
      "No ingredients available",
    ),
    "ingredients_title": MessageLookupByLibrary.simpleMessage("Ingredients"),
    "initializing": MessageLookupByLibrary.simpleMessage("Initializing..."),
    "invalidLocation": MessageLookupByLibrary.simpleMessage(
      "Location is not valid, latitude or longitude are needed to update store",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "languageChangeError": MessageLookupByLibrary.simpleMessage(
      "Failed to change language",
    ),
    "languageSelection_english": MessageLookupByLibrary.simpleMessage(
      "English",
    ),
    "languageSelection_french": MessageLookupByLibrary.simpleMessage("French"),
    "languageSelection_title": MessageLookupByLibrary.simpleMessage(
      "Choose your language:",
    ),
    "languageUpdated": MessageLookupByLibrary.simpleMessage(
      "Language updated successfully",
    ),
    "last_name": MessageLookupByLibrary.simpleMessage("Last Name"),
    "leaveATip": MessageLookupByLibrary.simpleMessage("Leave a Tip"),
    "link": MessageLookupByLibrary.simpleMessage("Link"),
    "linkIngredients": MessageLookupByLibrary.simpleMessage("Link Ingredients"),
    "linkIngredientsHint": MessageLookupByLibrary.simpleMessage(
      "Link ingredients from your seller list or manage your ingredient library",
    ),
    "linkIngredientsToDish": MessageLookupByLibrary.simpleMessage(
      "Link Ingredients to Dish",
    ),
    "linkedIngredients": MessageLookupByLibrary.simpleMessage(
      "linked ingredients",
    ),
    "loadingIngredients": MessageLookupByLibrary.simpleMessage(
      "Loading ingredients...",
    ),
    "loadingOrderDetails": MessageLookupByLibrary.simpleMessage(
      "Loading order details...",
    ),
    "loadingStoreInformation": MessageLookupByLibrary.simpleMessage(
      "Loading store information...",
    ),
    "locationError": MessageLookupByLibrary.simpleMessage("Location error"),
    "locationPermissionsDenied": MessageLookupByLibrary.simpleMessage(
      "Location permissions are denied",
    ),
    "locationPermissionsDeniedForever": MessageLookupByLibrary.simpleMessage(
      "Location permissions are permanently denied",
    ),
    "locationRequired": MessageLookupByLibrary.simpleMessage(
      "Location is required",
    ),
    "locationServicesDisabled": MessageLookupByLibrary.simpleMessage(
      "Location services are disabled",
    ),
    "login_button": MessageLookupByLibrary.simpleMessage("Login"),
    "login_continueWithEmail": MessageLookupByLibrary.simpleMessage(
      "Continue with Email",
    ),
    "login_emailHint": MessageLookupByLibrary.simpleMessage("Enter your email"),
    "login_emailLabel": MessageLookupByLibrary.simpleMessage("Email :"),
    "login_forgotPassword": MessageLookupByLibrary.simpleMessage(
      "Forgot Password?",
    ),
    "login_apple": MessageLookupByLibrary.simpleMessage("Sign in with Apple"),
    "login_google": MessageLookupByLibrary.simpleMessage("Sign in with Google"),
    "login_googleDisclaimer": MessageLookupByLibrary.simpleMessage(
      "By signing in with Google, you agree to our Terms and Conditions and Privacy Policy.",
    ),
    "login_passwordHint": MessageLookupByLibrary.simpleMessage(
      "Enter your password",
    ),
    "login_passwordLabel": MessageLookupByLibrary.simpleMessage("Password :"),
    "login_privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Privacy Policy",
    ),
    "login_registerPrompt": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account? Register",
    ),
    "login_slogan": MessageLookupByLibrary.simpleMessage(
      "VOS VOISINS, VOS CHEFS",
    ),
    "login_termsAndConditions": MessageLookupByLibrary.simpleMessage(
      "Terms and Conditions",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Log out"),
    "manageAllergensEmpty": MessageLookupByLibrary.simpleMessage(
      "No allergens available to add",
    ),
    "manageAllergensSelect": MessageLookupByLibrary.simpleMessage(
      "Select Allergen",
    ),
    "manageAllergensSpecification": MessageLookupByLibrary.simpleMessage(
      "Specification",
    ),
    "manageAllergensSpecificationHint": MessageLookupByLibrary.simpleMessage(
      "e.g., May contain traces of...",
    ),
    "manageAllergensSpecificationOptional":
        MessageLookupByLibrary.simpleMessage("Specification (Optional)"),
    "manageAllergensTitle": MessageLookupByLibrary.simpleMessage(
      "Manage Allergens",
    ),
    "manageCategoriesAddButton": MessageLookupByLibrary.simpleMessage(
      "Add Category",
    ),
    "manageCategoriesCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "manageCategoriesDiscardChanges": MessageLookupByLibrary.simpleMessage(
      "Discard Changes",
    ),
    "manageCategoriesEditTitle": MessageLookupByLibrary.simpleMessage(
      "Edit Dish Categories",
    ),
    "manageCategoriesEmptyDefault": MessageLookupByLibrary.simpleMessage(
      "No categories added yet",
    ),
    "manageCategoriesEmptyEditing": MessageLookupByLibrary.simpleMessage(
      "No categories for this dish",
    ),
    "manageCategoriesFinishEditing": MessageLookupByLibrary.simpleMessage(
      "Finish Editing",
    ),
    "manageCategoriesSaveChanges": MessageLookupByLibrary.simpleMessage(
      "Save Changes",
    ),
    "manageCategoriesSelectTitle": MessageLookupByLibrary.simpleMessage(
      "Select Category",
    ),
    "manageCategoriesTitle": MessageLookupByLibrary.simpleMessage(
      "Manage Categories",
    ),
    "manageDishIngredients_additionalCostItem":
        MessageLookupByLibrary.simpleMessage("Additional cost item"),
    "manageDishIngredients_cancel": MessageLookupByLibrary.simpleMessage(
      "Cancel",
    ),
    "manageDishIngredients_create": MessageLookupByLibrary.simpleMessage(
      "Create",
    ),
    "manageDishIngredients_createNew": MessageLookupByLibrary.simpleMessage(
      "Create New",
    ),
    "manageDishIngredients_createYourFirstIngredient":
        MessageLookupByLibrary.simpleMessage(
          "Create your first ingredient to get started",
        ),
    "manageDishIngredients_deleteCancel": MessageLookupByLibrary.simpleMessage(
      "Cancel",
    ),
    "manageDishIngredients_deleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Delete",
    ),
    "manageDishIngredients_deleteConfirmTitle":
        MessageLookupByLibrary.simpleMessage("Delete Ingredient"),
    "manageDishIngredients_deleteIngredientContent": m3,
    "manageDishIngredients_deleteIngredientTitle":
        MessageLookupByLibrary.simpleMessage("Delete Ingredient"),
    "manageDishIngredients_deleteTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Dish",
    ),
    "manageDishIngredients_deleteTooltip": MessageLookupByLibrary.simpleMessage(
      "Delete",
    ),
    "manageDishIngredients_editDialogAdd": MessageLookupByLibrary.simpleMessage(
      "Add Ingredient",
    ),
    "manageDishIngredients_editDialogEdit":
        MessageLookupByLibrary.simpleMessage("Edit Ingredient"),
    "manageDishIngredients_editDialogIngredient":
        MessageLookupByLibrary.simpleMessage("Ingredient"),
    "manageDishIngredients_editDialogSupplement":
        MessageLookupByLibrary.simpleMessage("Is Supplement"),
    "manageDishIngredients_editIngredientTitle":
        MessageLookupByLibrary.simpleMessage("Edit Ingredient"),
    "manageDishIngredients_editTitle": MessageLookupByLibrary.simpleMessage(
      "Edit Dish Ingredients",
    ),
    "manageDishIngredients_editTooltip": MessageLookupByLibrary.simpleMessage(
      "Edit",
    ),
    "manageDishIngredients_emptyDefault": MessageLookupByLibrary.simpleMessage(
      "No ingredients added yet",
    ),
    "manageDishIngredients_emptyEditing": MessageLookupByLibrary.simpleMessage(
      "No ingredients in this dish",
    ),
    "manageDishIngredients_enterPriceEg250":
        MessageLookupByLibrary.simpleMessage("Enter price (e.g., 2.50)"),
    "manageDishIngredients_finishEditing": MessageLookupByLibrary.simpleMessage(
      "Finish Editing",
    ),
    "manageDishIngredients_free": MessageLookupByLibrary.simpleMessage("Free"),
    "manageDishIngredients_ingredientAddedSuccessfully":
        MessageLookupByLibrary.simpleMessage("Ingredient added successfully"),
    "manageDishIngredients_ingredientCreatedSuccessfully":
        MessageLookupByLibrary.simpleMessage("Ingredient created successfully"),
    "manageDishIngredients_ingredientDeletedSuccessfully":
        MessageLookupByLibrary.simpleMessage("Ingredient deleted successfully"),
    "manageDishIngredients_ingredientManagement":
        MessageLookupByLibrary.simpleMessage("Ingredient Management"),
    "manageDishIngredients_ingredientRemovedSuccessfully":
        MessageLookupByLibrary.simpleMessage(
          "Ingredient removed from dish successfully",
        ),
    "manageDishIngredients_ingredientUpdatedSuccessfully":
        MessageLookupByLibrary.simpleMessage("Ingredient updated successfully"),
    "manageDishIngredients_ingredientsTitle":
        MessageLookupByLibrary.simpleMessage("Dish Ingredients"),
    "manageDishIngredients_link": MessageLookupByLibrary.simpleMessage("Link"),
    "manageDishIngredients_linkIngredients":
        MessageLookupByLibrary.simpleMessage("Link Ingredients"),
    "manageDishIngredients_linkIngredientsHint":
        MessageLookupByLibrary.simpleMessage(
          "Link ingredients from your seller list or manage your ingredient library",
        ),
    "manageDishIngredients_linkIngredientsToDish":
        MessageLookupByLibrary.simpleMessage("Link Ingredients to Dish"),
    "manageDishIngredients_linkedIngredients":
        MessageLookupByLibrary.simpleMessage("linked ingredients"),
    "manageDishIngredients_loadingIngredients":
        MessageLookupByLibrary.simpleMessage("Loading ingredients..."),
    "manageDishIngredients_manageIngredients":
        MessageLookupByLibrary.simpleMessage("Manage Ingredients"),
    "manageDishIngredients_nameEnLabel": MessageLookupByLibrary.simpleMessage(
      "Name (English)",
    ),
    "manageDishIngredients_nameFrLabel": MessageLookupByLibrary.simpleMessage(
      "Name (French)",
    ),
    "manageDishIngredients_nameValidation":
        MessageLookupByLibrary.simpleMessage("Please enter a name"),
    "manageDishIngredients_noIngredientsInLibrary":
        MessageLookupByLibrary.simpleMessage("No ingredients in your library"),
    "manageDishIngredients_noteSave": MessageLookupByLibrary.simpleMessage(
      "Save",
    ),
    "manageDishIngredients_price": MessageLookupByLibrary.simpleMessage(
      "Price",
    ),
    "manageDishIngredients_priceFree": MessageLookupByLibrary.simpleMessage(
      "Price (Free)",
    ),
    "manageDishIngredients_retry": MessageLookupByLibrary.simpleMessage(
      "Retry",
    ),
    "manageDishIngredients_searchEmpty": MessageLookupByLibrary.simpleMessage(
      "No ingredients found",
    ),
    "manageDishIngredients_searchIngredientsToLink":
        MessageLookupByLibrary.simpleMessage("Search ingredients to link..."),
    "manageDishIngredients_searchYourIngredients":
        MessageLookupByLibrary.simpleMessage("Search your ingredients..."),
    "manageDishIngredients_sortByName": MessageLookupByLibrary.simpleMessage(
      "Sort by Name",
    ),
    "manageDishIngredients_sortByPrice": MessageLookupByLibrary.simpleMessage(
      "Sort by Price",
    ),
    "manageDishIngredients_sortByType": MessageLookupByLibrary.simpleMessage(
      "Sort by Type",
    ),
    "manageDishIngredients_sortedBy": m4,
    "manageDishIngredients_standardIngredientFree":
        MessageLookupByLibrary.simpleMessage("Standard ingredient (free)"),
    "manageDishIngredients_standardIngredientsAreFree":
        MessageLookupByLibrary.simpleMessage("Standard ingredients are free"),
    "manageDishIngredients_standardLabel": MessageLookupByLibrary.simpleMessage(
      "Standard",
    ),
    "manageDishIngredients_supplementLabel":
        MessageLookupByLibrary.simpleMessage("Supplement"),
    "manageDishIngredients_supplementPrice":
        MessageLookupByLibrary.simpleMessage("Price"),
    "manageDishIngredients_supplementsMustHavePrice":
        MessageLookupByLibrary.simpleMessage(
          "Supplements must have a price greater than 0",
        ),
    "manageDishIngredients_title": MessageLookupByLibrary.simpleMessage(
      "Manage Ingredients",
    ),
    "manageDishIngredients_total": MessageLookupByLibrary.simpleMessage(
      "Total",
    ),
    "manageDishIngredients_update": MessageLookupByLibrary.simpleMessage(
      "Update",
    ),
    "manageIngredients": MessageLookupByLibrary.simpleMessage(
      "Manage Ingredients",
    ),
    "manageIngredientsAddButton": MessageLookupByLibrary.simpleMessage(
      "Add Ingredient",
    ),
    "manageIngredientsEditDialogAdd": MessageLookupByLibrary.simpleMessage(
      "Add Ingredient",
    ),
    "manageIngredientsEditDialogEdit": MessageLookupByLibrary.simpleMessage(
      "Edit Ingredient",
    ),
    "manageIngredientsEditDialogIngredient":
        MessageLookupByLibrary.simpleMessage("Ingredient"),
    "manageIngredientsEditDialogPrice": MessageLookupByLibrary.simpleMessage(
      "Price",
    ),
    "manageIngredientsEditDialogSupplement":
        MessageLookupByLibrary.simpleMessage("Is Supplement"),
    "manageIngredientsEditTitle": MessageLookupByLibrary.simpleMessage(
      "Edit Dish Ingredients",
    ),
    "manageIngredientsEmptyDefault": MessageLookupByLibrary.simpleMessage(
      "No ingredients added yet",
    ),
    "manageIngredientsEmptyEditing": MessageLookupByLibrary.simpleMessage(
      "No ingredients in this dish",
    ),
    "manageIngredientsFinishEditing": MessageLookupByLibrary.simpleMessage(
      "Finish Editing",
    ),
    "manageIngredientsPrice": MessageLookupByLibrary.simpleMessage("Price:"),
    "manageIngredientsSearchEmpty": MessageLookupByLibrary.simpleMessage(
      "No ingredients found",
    ),
    "manageIngredientsSearchHint": MessageLookupByLibrary.simpleMessage(
      "Search Ingredients",
    ),
    "manageIngredientsSelectTitle": MessageLookupByLibrary.simpleMessage(
      "Select Ingredient",
    ),
    "manageIngredientsStandard": MessageLookupByLibrary.simpleMessage(
      "Standard",
    ),
    "manageIngredientsSupplement": MessageLookupByLibrary.simpleMessage(
      "Supplement",
    ),
    "manageIngredientsTitle": MessageLookupByLibrary.simpleMessage(
      "Manage Ingredients",
    ),
    "manageIngredientsType": MessageLookupByLibrary.simpleMessage("Type:"),
    "manageIngredients_createTitle": MessageLookupByLibrary.simpleMessage(
      "Create Ingredient",
    ),
    "mapLaunchError": MessageLookupByLibrary.simpleMessage(
      "Could not open map",
    ),
    "markAsReadyButton": MessageLookupByLibrary.simpleMessage("Mark as ready"),
    "menuLabel": MessageLookupByLibrary.simpleMessage("Menu"),
    "menuScreen": MessageLookupByLibrary.simpleMessage("Menu Screen"),
    "method": MessageLookupByLibrary.simpleMessage("Method"),
    "moveTheMapToSelectLocation": MessageLookupByLibrary.simpleMessage(
      "Move the map to select a location",
    ),
    "myStore": MessageLookupByLibrary.simpleMessage("My Store"),
    "nameEnglish": MessageLookupByLibrary.simpleMessage("Name (English)"),
    "nameFrench": MessageLookupByLibrary.simpleMessage("Name (French)"),
    "newTotal": MessageLookupByLibrary.simpleMessage("New Total"),
    "noIngredients": MessageLookupByLibrary.simpleMessage(
      "No ingredients available",
    ),
    "noIngredientsInLibrary": MessageLookupByLibrary.simpleMessage(
      "No ingredients in your library",
    ),
    "noLocationWarning": MessageLookupByLibrary.simpleMessage(
      "No location set. Please select a location",
    ),
    "noName": MessageLookupByLibrary.simpleMessage("No name"),
    "noReviewsYet": MessageLookupByLibrary.simpleMessage("No reviews yet."),
    "noStoreFound": MessageLookupByLibrary.simpleMessage(
      "No store found. Create one!",
    ),
    "note": MessageLookupByLibrary.simpleMessage("Note"),
    "notification_emptyState": MessageLookupByLibrary.simpleMessage(
      "No notifications yet",
    ),
    "notification_errorTitle": MessageLookupByLibrary.simpleMessage(
      "Ops! Something went wrong",
    ),
    "notification_markAsRead": MessageLookupByLibrary.simpleMessage(
      "Mark Read",
    ),
    "notification_newCount": m5,
    "notification_title": MessageLookupByLibrary.simpleMessage("Notification"),
    "notification_tryAgain": MessageLookupByLibrary.simpleMessage("Try Again"),
    "onboarding_back": MessageLookupByLibrary.simpleMessage("Back"),
    "onboarding_getStarted": MessageLookupByLibrary.simpleMessage(
      "Get Started",
    ),
    "onboarding_next": MessageLookupByLibrary.simpleMessage("Next"),
    "onboarding_slide1Text": MessageLookupByLibrary.simpleMessage(
      "Get meals that are made with care, fresh ingredients, and a personal touch from local chefs near you.",
    ),
    "onboarding_slide1Title": MessageLookupByLibrary.simpleMessage(
      "Discover Delicious Homemade Meals",
    ),
    "onboarding_slide2Text": MessageLookupByLibrary.simpleMessage(
      "From traditional recipes to unique creations, find chefs who cater to your culinary cravings.",
    ),
    "onboarding_slide2Title": MessageLookupByLibrary.simpleMessage(
      "Connect with Passionate Chefs",
    ),
    "onboarding_slide3Text": MessageLookupByLibrary.simpleMessage(
      "Your favorite homemade meals, just a few taps away. Let\'s bring local cooking to your table.",
    ),
    "onboarding_slide3Title": MessageLookupByLibrary.simpleMessage(
      "Order Easily, Delivered Fresh",
    ),
    "operationFailed": MessageLookupByLibrary.simpleMessage("Operation Failed"),
    "optVerification_codeHint": MessageLookupByLibrary.simpleMessage(
      "Enter code",
    ),
    "optVerification_error": MessageLookupByLibrary.simpleMessage(
      "Invalid code. Please try again.",
    ),
    "optVerification_fieldHint": MessageLookupByLibrary.simpleMessage("0"),
    "optVerification_resend": MessageLookupByLibrary.simpleMessage(
      "Resend Code",
    ),
    "optVerification_submit": MessageLookupByLibrary.simpleMessage("Verify"),
    "optVerification_subtitle": MessageLookupByLibrary.simpleMessage(
      "Enter the 6-digit code sent to your email to verify your account.",
    ),
    "optVerification_success": MessageLookupByLibrary.simpleMessage(
      "Email confirmed!",
    ),
    "optVerification_title": MessageLookupByLibrary.simpleMessage(
      "Verify Your Email",
    ),
    "optVerification_validationRequired": MessageLookupByLibrary.simpleMessage(
      "Validation required",
    ),
    "orUseCurrentLocation": MessageLookupByLibrary.simpleMessage(
      "or use current location",
    ),
    "orderConfirmationCode": MessageLookupByLibrary.simpleMessage(
      "Confirmation Code",
    ),
    "orderFilter_labelDeliveryStatus": MessageLookupByLibrary.simpleMessage(
      "Delivery Status",
    ),
    "orderFilter_labelPaymentStatus": MessageLookupByLibrary.simpleMessage(
      "Payment Status",
    ),
    "orderFilter_labelSortBy": MessageLookupByLibrary.simpleMessage("Sort By"),
    "orderFilter_labelSortOrder": MessageLookupByLibrary.simpleMessage("Order"),
    "orderFilter_labelStatus": MessageLookupByLibrary.simpleMessage(
      "Order Status",
    ),
    "orderFilter_optionAll": MessageLookupByLibrary.simpleMessage("All"),
    "orderFilter_optionAsc": MessageLookupByLibrary.simpleMessage("Ascending"),
    "orderFilter_optionDesc": MessageLookupByLibrary.simpleMessage(
      "Descending",
    ),
    "orderId": MessageLookupByLibrary.simpleMessage("Order ID"),
    "orderStatusCancelled": MessageLookupByLibrary.simpleMessage("Cancelled"),
    "orderStatusCompleted": MessageLookupByLibrary.simpleMessage("Completed"),
    "orderStatusConfirmed": MessageLookupByLibrary.simpleMessage("Confirmed"),
    "orderStatusDelivered": MessageLookupByLibrary.simpleMessage("Delivered"),
    "orderStatusFailed": MessageLookupByLibrary.simpleMessage("Failed"),
    "orderStatusInTransit": MessageLookupByLibrary.simpleMessage("In Transit"),
    "orderStatusPaid": MessageLookupByLibrary.simpleMessage("Paid"),
    "orderStatusPending": MessageLookupByLibrary.simpleMessage("Pending"),
    "orderStatusProcessing": MessageLookupByLibrary.simpleMessage("Processing"),
    "orderStatusReady": MessageLookupByLibrary.simpleMessage("Ready"),
    "orderStatusRefundFailed": MessageLookupByLibrary.simpleMessage(
      "Refund Failed",
    ),
    "orderStatusRefundRequested": MessageLookupByLibrary.simpleMessage(
      "Refund Requested",
    ),
    "orderStatusRefunded": MessageLookupByLibrary.simpleMessage("Refunded"),
    "orderTotal": MessageLookupByLibrary.simpleMessage("Order Total"),
    "ordersLabel": MessageLookupByLibrary.simpleMessage("Orders"),
    "passwordRecoveryButton": MessageLookupByLibrary.simpleMessage(
      "Send Reset Link",
    ),
    "passwordRecoveryEmailHint": MessageLookupByLibrary.simpleMessage(
      "Enter your email address",
    ),
    "passwordRecoveryEmailInvalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email address",
    ),
    "passwordRecoveryEmailRequired": MessageLookupByLibrary.simpleMessage(
      "Email is required",
    ),
    "passwordRecoveryErrorMessage": MessageLookupByLibrary.simpleMessage(
      "Failed to send reset link",
    ),
    "passwordRecoverySubtitle": MessageLookupByLibrary.simpleMessage(
      "Enter your email to receive a reset link.",
    ),
    "passwordRecoverySuccessMessage": MessageLookupByLibrary.simpleMessage(
      "If the email exists, a reset link has been sent.",
    ),
    "passwordRecoveryTitle": MessageLookupByLibrary.simpleMessage(
      "Recover Password",
    ),
    "paymentCompleted": MessageLookupByLibrary.simpleMessage(
      "Payment completed!",
    ),
    "paymentFailedToInitialize": MessageLookupByLibrary.simpleMessage(
      "Failed to initialize payment sheet",
    ),
    "paymentInfo": MessageLookupByLibrary.simpleMessage("Payment Info"),
    "paymentInfo_default": MessageLookupByLibrary.simpleMessage(
      "Default Payment Card",
    ),
    "paymentInfo_empty": MessageLookupByLibrary.simpleMessage(
      "No payment cards found",
    ),
    "paymentInfo_expires": MessageLookupByLibrary.simpleMessage("Expires:"),
    "paymentInfo_title": MessageLookupByLibrary.simpleMessage("Payment Info"),
    "paymentStripeError": m6,
    "paymentUnexpectedError": m7,
    "pleaseEnterName": MessageLookupByLibrary.simpleMessage(
      "Please enter a name",
    ),
    "pleaseSelectLocation": MessageLookupByLibrary.simpleMessage(
      "Please select a location on the map.",
    ),
    "price": MessageLookupByLibrary.simpleMessage("Price"),
    "priceFree": MessageLookupByLibrary.simpleMessage("Price (Free)"),
    "priceText": m8,
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "privacyPolicy_conclusion": MessageLookupByLibrary.simpleMessage(
      "This Privacy Policy is effective as of 6 november 2025.",
    ),
    "privacyPolicy_intro": MessageLookupByLibrary.simpleMessage(
      "Welcome to Cuisinous! We value your privacy and are committed to protecting your personal information. This Privacy Policy explains what data we collect, how we use it, how it is protected, and your rights as a user of our application and website. By using Cuisinous, you agree to the practices described in this policy.",
    ),
    "privacyPolicy_section1Body": MessageLookupByLibrary.simpleMessage(
      "When you use our platform, we may collect the following information: Registration details: name, email address, phone number, password. Account verification: identity documents or licenses required under applicable regulations. Transaction details: order history, payments, invoices. Location data: to connect you with nearby meals and vendors. Usage data: browsing activity, preferences, ratings, and reviews.",
    ),
    "privacyPolicy_section1Title": MessageLookupByLibrary.simpleMessage(
      "1. Information We Collect",
    ),
    "privacyPolicy_section2Body": MessageLookupByLibrary.simpleMessage(
      "We use your personal information to: Create and manage your vendor or customer account. Facilitate secure ordering and payments. Provide personalized services (local menus, recommendations, promotions). Prevent fraud, ensure platform safety, and comply with legal obligations. Communicate with you regarding your account, orders, or updates to our services.",
    ),
    "privacyPolicy_section2Title": MessageLookupByLibrary.simpleMessage(
      "2. How We Use Your Information",
    ),
    "privacyPolicy_section3Body": MessageLookupByLibrary.simpleMessage(
      "We never sell your personal information. We may share certain information only with: Secure payment providers. Delivery partners (if applicable). Legal authorities when required by law.",
    ),
    "privacyPolicy_section3Title": MessageLookupByLibrary.simpleMessage(
      "3. Sharing of Information",
    ),
    "privacyPolicy_section4Body": MessageLookupByLibrary.simpleMessage(
      "Your data is securely stored in Canada or in servers compliant with applicable privacy laws. We implement technical and organizational measures to protect your information from unauthorized access, loss, or misuse.",
    ),
    "privacyPolicy_section4Title": MessageLookupByLibrary.simpleMessage(
      "4. Data Storage & Security",
    ),
    "privacyPolicy_section5Body": MessageLookupByLibrary.simpleMessage(
      "In accordance with Law 25 (Québec) and Canadian privacy laws, you have the right to: Access your personal data. Request corrections or deletion of certain data. Withdraw your consent to data processing. File a complaint with the Commission d\'accès à l\'information du Québec if necessary.",
    ),
    "privacyPolicy_section5Title": MessageLookupByLibrary.simpleMessage(
      "5. Your Rights",
    ),
    "privacyPolicy_section6Body": MessageLookupByLibrary.simpleMessage(
      "We use cookies and analytics tools to improve the user experience, personalize content, and measure performance. You can manage your preferences through your browser settings.",
    ),
    "privacyPolicy_section6Title": MessageLookupByLibrary.simpleMessage(
      "6. Cookies & Similar Technologies",
    ),
    "privacyPolicy_section7Body": MessageLookupByLibrary.simpleMessage(
      "We may update this Privacy Policy from time to time. Any changes will be posted on our website with the updated effective date.",
    ),
    "privacyPolicy_section7Title": MessageLookupByLibrary.simpleMessage(
      "7. Changes to this Policy",
    ),
    "privacyPolicy_section8Body": MessageLookupByLibrary.simpleMessage(
      "For any questions regarding this Policy or to exercise your rights, please contact us at: 📧 info@cuisinous.ca 📍 Cuisinous Inc., Québec, Canada",
    ),
    "privacyPolicy_section8Title": MessageLookupByLibrary.simpleMessage(
      "8. Contact",
    ),
    "privacyPolicy_title": MessageLookupByLibrary.simpleMessage(
      "Privacy Policy – Cuisinous",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profile_updated_successfully": MessageLookupByLibrary.simpleMessage(
      "Profile updated successfully",
    ),
    "proxyCallNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Calling is not yet available for this order.",
    ),
    "proxyCallNotSupported": MessageLookupByLibrary.simpleMessage(
      "Calling is not supported on this device.",
    ),
    "proxyCallOrderNotFound": MessageLookupByLibrary.simpleMessage(
      "Order not found.",
    ),
    "proxyCallServerError": MessageLookupByLibrary.simpleMessage(
      "Server error. Please try again later.",
    ),
    "proxyCallUnableToInitiate": MessageLookupByLibrary.simpleMessage(
      "Unable to initiate call. Please try again later.",
    ),
    "quickTipAmounts": MessageLookupByLibrary.simpleMessage("Quick Tip"),
    "rateApp": MessageLookupByLibrary.simpleMessage("Rate App"),
    "rateDish": MessageLookupByLibrary.simpleMessage("Rate Dish"),
    "rated": MessageLookupByLibrary.simpleMessage("Rated"),
    "ratingCommentHint": MessageLookupByLibrary.simpleMessage(
      "Share your experience with this dish...",
    ),
    "ratingCommentLabel": MessageLookupByLibrary.simpleMessage(
      "Comment (Optional)",
    ),
    "ratingSuccess": MessageLookupByLibrary.simpleMessage(
      "Thank you for your rating!",
    ),
    "recipe_addToCart": MessageLookupByLibrary.simpleMessage("Add to Cart -"),
    "recipe_addedToCart": MessageLookupByLibrary.simpleMessage(
      "Added to Cart -",
    ),
    "recipe_categories": MessageLookupByLibrary.simpleMessage("Categories"),
    "recipe_description": MessageLookupByLibrary.simpleMessage("Description"),
    "recipe_empty": MessageLookupByLibrary.simpleMessage("No recipes found"),
    "recipe_gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
    "recipe_ingredients": MessageLookupByLibrary.simpleMessage("Ingredients"),
    "recipe_noDescription": MessageLookupByLibrary.simpleMessage(
      "No Description Available",
    ),
    "recipe_noReviews": MessageLookupByLibrary.simpleMessage(
      "No reviews yet. Be the first to review!",
    ),
    "recipe_rating": MessageLookupByLibrary.simpleMessage("Rating:"),
    "recipe_ratingRequired": MessageLookupByLibrary.simpleMessage(
      "Please select a rating",
    ),
    "recipe_reviewRequired": MessageLookupByLibrary.simpleMessage(
      "Please write a review",
    ),
    "recipe_reviewSuccess": MessageLookupByLibrary.simpleMessage(
      "Review submitted successfully!",
    ),
    "recipe_reviews": MessageLookupByLibrary.simpleMessage("Reviews"),
    "recipe_shareExperience": MessageLookupByLibrary.simpleMessage(
      "Share your experience...",
    ),
    "recipe_submitReview": MessageLookupByLibrary.simpleMessage(
      "Submit Review",
    ),
    "recipe_vendor": MessageLookupByLibrary.simpleMessage("Vendor"),
    "recipe_writeReview": MessageLookupByLibrary.simpleMessage(
      "Write a Review",
    ),
    "recipe_yourReview": MessageLookupByLibrary.simpleMessage("Your review"),
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "register_acceptTermsPart1": MessageLookupByLibrary.simpleMessage(
      "I accept the ",
    ),
    "register_acceptTermsPart2": MessageLookupByLibrary.simpleMessage(" and "),
    "register_acceptTermsPart3": MessageLookupByLibrary.simpleMessage(
      " of Cuisinous",
    ),
    "register_button": MessageLookupByLibrary.simpleMessage("Register"),
    "register_emailHint": MessageLookupByLibrary.simpleMessage(
      "Enter your email",
    ),
    "register_emailLabel": MessageLookupByLibrary.simpleMessage("Email :"),
    "register_firstNameHint": MessageLookupByLibrary.simpleMessage("John"),
    "register_firstNameLabel": MessageLookupByLibrary.simpleMessage(
      "First Name",
    ),
    "register_googleButton": MessageLookupByLibrary.simpleMessage(
      "Sign in with Google",
    ),
    "register_lastNameHint": MessageLookupByLibrary.simpleMessage("Doe"),
    "register_lastNameLabel": MessageLookupByLibrary.simpleMessage("Last Name"),
    "register_loginPrompt": MessageLookupByLibrary.simpleMessage(
      "Already have an account? Login",
    ),
    "register_passwordHint": MessageLookupByLibrary.simpleMessage(
      "Enter your password",
    ),
    "register_passwordLabel": MessageLookupByLibrary.simpleMessage(
      "Password :",
    ),
    "register_phoneHint": MessageLookupByLibrary.simpleMessage(
      "Enter your phone number",
    ),
    "register_phoneLabel": MessageLookupByLibrary.simpleMessage("Phone Number"),
    "register_slogan": MessageLookupByLibrary.simpleMessage(
      "VOS VOISINS, VOS CHEFS",
    ),
    "register_validationEmailInvalid": MessageLookupByLibrary.simpleMessage(
      "Enter a valid email address",
    ),
    "register_validationEmailRequired": MessageLookupByLibrary.simpleMessage(
      "Email is required",
    ),
    "register_validationFirstNameRequired":
        MessageLookupByLibrary.simpleMessage("First name is required"),
    "register_validationLastNameRequired": MessageLookupByLibrary.simpleMessage(
      "Last name is required",
    ),
    "register_validationPasswordLength": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 8 characters long",
    ),
    "register_validationPasswordNumber": MessageLookupByLibrary.simpleMessage(
      "Password must contain at least one number",
    ),
    "register_validationPasswordRequired": MessageLookupByLibrary.simpleMessage(
      "Password cannot be empty",
    ),
    "register_validationPasswordSpecial": MessageLookupByLibrary.simpleMessage(
      "Password must contain at least one special character",
    ),
    "register_validationPasswordUppercase":
        MessageLookupByLibrary.simpleMessage(
          "Password must contain at least one uppercase letter",
        ),
    "register_validationPhoneInvalid": MessageLookupByLibrary.simpleMessage(
      "Enter a valid phone number",
    ),
    "register_validationPhoneRequired": MessageLookupByLibrary.simpleMessage(
      "Phone number is required",
    ),
    "requiredField": MessageLookupByLibrary.simpleMessage(
      "This field is required",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "retryAction": MessageLookupByLibrary.simpleMessage("Retry"),
    "retryButton": MessageLookupByLibrary.simpleMessage("Retry"),
    "reviews": MessageLookupByLibrary.simpleMessage("reviews"),
    "save": MessageLookupByLibrary.simpleMessage("Save Changes"),
    "searchIngredientsToLink": MessageLookupByLibrary.simpleMessage(
      "Search ingredients to link...",
    ),
    "searchYourIngredients": MessageLookupByLibrary.simpleMessage(
      "Search your ingredients...",
    ),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Select Language"),
    "selectedLocation": MessageLookupByLibrary.simpleMessage(
      "Selected Location",
    ),
    "sellerHome_adminFeedback": MessageLookupByLibrary.simpleMessage(
      "Admin Feedback",
    ),
    "sellerHome_analytics": MessageLookupByLibrary.simpleMessage(
      "View Analytics",
    ),
    "sellerHome_createStore": MessageLookupByLibrary.simpleMessage(
      "Create Your Store",
    ),
    "sellerHome_noStore": MessageLookupByLibrary.simpleMessage(
      "You haven\'t set up your store yet.",
    ),
    "sellerHome_pendingOrders": MessageLookupByLibrary.simpleMessage(
      "Pending Orders",
    ),
    "sellerHome_quickActions": MessageLookupByLibrary.simpleMessage(
      "Quick Actions",
    ),
    "sellerHome_sellerFallback": MessageLookupByLibrary.simpleMessage("Seller"),
    "sellerHome_statusApproved": MessageLookupByLibrary.simpleMessage(
      "Approved",
    ),
    "sellerHome_statusPending": MessageLookupByLibrary.simpleMessage("Pending"),
    "sellerHome_statusRejected": MessageLookupByLibrary.simpleMessage(
      "Rejected",
    ),
    "sellerHome_totalRevenue": MessageLookupByLibrary.simpleMessage(
      "Total Revenue",
    ),
    "sellerHome_updateStore": MessageLookupByLibrary.simpleMessage(
      "Update Store Info",
    ),
    "sellerHome_verificationStatus": MessageLookupByLibrary.simpleMessage(
      "Verification Status:",
    ),
    "sellerHome_welcome": MessageLookupByLibrary.simpleMessage("Welcome"),
    "sellerOrderManagement_cancel": MessageLookupByLibrary.simpleMessage(
      "Cancel",
    ),
    "sellerOrderManagement_cancelOrder": MessageLookupByLibrary.simpleMessage(
      "Cancel Order",
    ),
    "sellerOrderManagement_date": MessageLookupByLibrary.simpleMessage("Date:"),
    "sellerOrderManagement_empty": MessageLookupByLibrary.simpleMessage(
      "No orders found",
    ),
    "sellerOrderManagement_filter": MessageLookupByLibrary.simpleMessage(
      "Filter & Sort",
    ),
    "sellerOrderManagement_itemBuyer": MessageLookupByLibrary.simpleMessage(
      "Buyer:",
    ),
    "sellerOrderManagement_itemPlaced": MessageLookupByLibrary.simpleMessage(
      "Placed:",
    ),
    "sellerOrderManagement_itemTotal": MessageLookupByLibrary.simpleMessage(
      "Total:",
    ),
    "sellerOrderManagement_labelConfirmationCode":
        MessageLookupByLibrary.simpleMessage("Confirmation Code:"),
    "sellerOrderManagement_labelDeliveryStatus":
        MessageLookupByLibrary.simpleMessage("Delivery Status:"),
    "sellerOrderManagement_labelEmail": MessageLookupByLibrary.simpleMessage(
      "Email:",
    ),
    "sellerOrderManagement_labelName": MessageLookupByLibrary.simpleMessage(
      "Name:",
    ),
    "sellerOrderManagement_labelPaymentStatus":
        MessageLookupByLibrary.simpleMessage("Payment Status:"),
    "sellerOrderManagement_labelPhone": MessageLookupByLibrary.simpleMessage(
      "Phone:",
    ),
    "sellerOrderManagement_labelSubtotal": MessageLookupByLibrary.simpleMessage(
      "Subtotal:",
    ),
    "sellerOrderManagement_labelTipAmount":
        MessageLookupByLibrary.simpleMessage("Tip Amount:"),
    "sellerOrderManagement_notFound": MessageLookupByLibrary.simpleMessage(
      "Receipt not found",
    ),
    "sellerOrderManagement_orderDetailsTitle":
        MessageLookupByLibrary.simpleMessage("Order Details"),
    "sellerOrderManagement_orderFrom": MessageLookupByLibrary.simpleMessage(
      "FROM",
    ),
    "sellerOrderManagement_orderNumber": MessageLookupByLibrary.simpleMessage(
      "Order #:",
    ),
    "sellerOrderManagement_retry": MessageLookupByLibrary.simpleMessage(
      "Retry",
    ),
    "sellerOrderManagement_searchHint": MessageLookupByLibrary.simpleMessage(
      "Order number, buyer name...",
    ),
    "sellerOrderManagement_sectionCustomer":
        MessageLookupByLibrary.simpleMessage("CUSTOMER"),
    "sellerOrderManagement_sectionDeliveryTo":
        MessageLookupByLibrary.simpleMessage("DELIVERY TO"),
    "sellerOrderManagement_sectionItems": MessageLookupByLibrary.simpleMessage(
      "ITEMS",
    ),
    "sellerOrderManagement_sectionOrderNotes":
        MessageLookupByLibrary.simpleMessage("ORDER NOTES"),
    "sellerOrderManagement_sectionPaymentDetails":
        MessageLookupByLibrary.simpleMessage("PAYMENT DETAILS"),
    "sellerOrderManagement_sectionTotal": MessageLookupByLibrary.simpleMessage(
      "TOTAL",
    ),
    "sellerOrderManagement_thankYou": MessageLookupByLibrary.simpleMessage(
      "Thank you for your order!",
    ),
    "sellerOrderManagement_title": MessageLookupByLibrary.simpleMessage(
      "Seller Orders",
    ),
    "sellerOrderManagement_totalPaid": MessageLookupByLibrary.simpleMessage(
      "TOTAL PAID",
    ),
    "sellerStats_averageOrderValue": MessageLookupByLibrary.simpleMessage(
      "Average Order Value",
    ),
    "sellerStats_dailyRevenue": MessageLookupByLibrary.simpleMessage(
      "Daily Revenue",
    ),
    "sellerStats_monthlyRevenue": MessageLookupByLibrary.simpleMessage(
      "Monthly Revenue",
    ),
    "sellerStats_noDataMonth": MessageLookupByLibrary.simpleMessage(
      "No data for this month",
    ),
    "sellerStats_noDataYear": MessageLookupByLibrary.simpleMessage(
      "No data for this year",
    ),
    "sellerStats_noYearlyData": MessageLookupByLibrary.simpleMessage(
      "No yearly data available",
    ),
    "sellerStats_title": MessageLookupByLibrary.simpleMessage(
      "Store Analytics",
    ),
    "sellerStats_totalOrders": MessageLookupByLibrary.simpleMessage(
      "Total Orders",
    ),
    "sellerStats_yearlyRevenue": MessageLookupByLibrary.simpleMessage(
      "Yearly Revenue",
    ),
    "sellerWalletBalance": MessageLookupByLibrary.simpleMessage(
      "Current Balance",
    ),
    "sellerWalletNoTransactions": MessageLookupByLibrary.simpleMessage(
      "No transactions yet",
    ),
    "sellerWalletTitle": MessageLookupByLibrary.simpleMessage("Wallet"),
    "sellerWalletTransactionCredit": MessageLookupByLibrary.simpleMessage(
      "Credit",
    ),
    "sellerWalletTransactionDate": MessageLookupByLibrary.simpleMessage("Date"),
    "sellerWalletTransactionDebit": MessageLookupByLibrary.simpleMessage(
      "Debit",
    ),
    "sellerWalletTransactionDescription": MessageLookupByLibrary.simpleMessage(
      "Description",
    ),
    "sellerWalletTransactionReference": MessageLookupByLibrary.simpleMessage(
      "Reference",
    ),
    "sellerWalletTransactionType": MessageLookupByLibrary.simpleMessage("Type"),
    "settingsLabel": MessageLookupByLibrary.simpleMessage("Settings"),
    "settings_languageChangeError": MessageLookupByLibrary.simpleMessage(
      "Failed to change language",
    ),
    "settings_languageUpdated": MessageLookupByLibrary.simpleMessage(
      "Language updated successfully",
    ),
    "settings_noName": MessageLookupByLibrary.simpleMessage("No name"),
    "settings_selectLanguage": MessageLookupByLibrary.simpleMessage(
      "Select Language",
    ),
    "sortByName": MessageLookupByLibrary.simpleMessage("Sort by Name"),
    "sortByPrice": MessageLookupByLibrary.simpleMessage("Sort by Price"),
    "sortByType": MessageLookupByLibrary.simpleMessage("Sort by Type"),
    "sortedBy": m9,
    "standardIngredientFree": MessageLookupByLibrary.simpleMessage(
      "Standard ingredient (free)",
    ),
    "standardIngredientsAreFree": MessageLookupByLibrary.simpleMessage(
      "Standard ingredients are free",
    ),
    "statsLabel": MessageLookupByLibrary.simpleMessage("Stats"),
    "statsScreen": MessageLookupByLibrary.simpleMessage("Stats Screen"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "store": MessageLookupByLibrary.simpleMessage("Store"),
    "storeBioHint": MessageLookupByLibrary.simpleMessage("Describe your store"),
    "storeBioLabel": MessageLookupByLibrary.simpleMessage(
      "Store Bio / Description",
    ),
    "storeForm_addressNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Address not available",
    ),
    "storeForm_bioHint": MessageLookupByLibrary.simpleMessage(
      "Describe your store",
    ),
    "storeForm_bioLabel": MessageLookupByLibrary.simpleMessage(
      "Store Bio / Description",
    ),
    "storeForm_changeImage": MessageLookupByLibrary.simpleMessage(
      "Change Image",
    ),
    "storeForm_confirmLocation": MessageLookupByLibrary.simpleMessage(
      "Confirm Location",
    ),
    "storeForm_couldNotFetchAddress": MessageLookupByLibrary.simpleMessage(
      "Could not fetch address. Please try again.",
    ),
    "storeForm_createStore": MessageLookupByLibrary.simpleMessage(
      "Create Store",
    ),
    "storeForm_editStore": MessageLookupByLibrary.simpleMessage("Edit Store"),
    "storeForm_moveTheMapToSelectLocation":
        MessageLookupByLibrary.simpleMessage(
          "Move the map to select a location",
        ),
    "storeForm_nameHint": MessageLookupByLibrary.simpleMessage(
      "Enter your store\'s name",
    ),
    "storeForm_nameLabel": MessageLookupByLibrary.simpleMessage("Store Name"),
    "storeForm_operationFailed": MessageLookupByLibrary.simpleMessage(
      "Operation Failed",
    ),
    "storeForm_pleaseSelectLocation": MessageLookupByLibrary.simpleMessage(
      "Please select a location on the map.",
    ),
    "storeForm_requiredField": MessageLookupByLibrary.simpleMessage(
      "This field is required",
    ),
    "storeForm_save": MessageLookupByLibrary.simpleMessage("Save Changes"),
    "storeForm_selectedLocation": MessageLookupByLibrary.simpleMessage(
      "Selected Location",
    ),
    "storeForm_tapToSelectLocation": MessageLookupByLibrary.simpleMessage(
      "Tap to select location",
    ),
    "storeForm_uploadImage": MessageLookupByLibrary.simpleMessage(
      "Upload Image",
    ),
    "storeHome_createStore": MessageLookupByLibrary.simpleMessage(
      "Create Store",
    ),
    "storeHome_errorLoadingStore": MessageLookupByLibrary.simpleMessage(
      "Failed to load store. Please retry.",
    ),
    "storeHome_loadingStoreInformation": MessageLookupByLibrary.simpleMessage(
      "Loading store information...",
    ),
    "storeHome_noStoreFound": MessageLookupByLibrary.simpleMessage(
      "No store found. Create one!",
    ),
    "storeHome_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "storeHome_title": MessageLookupByLibrary.simpleMessage("My Store"),
    "storeInformation": MessageLookupByLibrary.simpleMessage(
      "Store Information",
    ),
    "storeLocation": MessageLookupByLibrary.simpleMessage("Store Location"),
    "storeName": MessageLookupByLibrary.simpleMessage("Store Name"),
    "storeNameHint": MessageLookupByLibrary.simpleMessage(
      "Enter your store\'s name",
    ),
    "storeNameLabel": MessageLookupByLibrary.simpleMessage("Store Name"),
    "storeNavigation_initializing": MessageLookupByLibrary.simpleMessage(
      "Initializing...",
    ),
    "storeNavigation_operationFailed": MessageLookupByLibrary.simpleMessage(
      "Operation failed",
    ),
    "storeNavigation_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "storeProfile_address": MessageLookupByLibrary.simpleMessage("Address"),
    "storeProfile_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "storeProfile_coordinates": m10,
    "storeProfile_deleteStore": MessageLookupByLibrary.simpleMessage(
      "Delete Store",
    ),
    "storeProfile_deleteStoreContent": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete your store? and log out",
    ),
    "storeProfile_description": MessageLookupByLibrary.simpleMessage(
      "Description",
    ),
    "storeProfile_editStore": MessageLookupByLibrary.simpleMessage(
      "Edit Store",
    ),
    "storeProfile_errorLoadingStore": MessageLookupByLibrary.simpleMessage(
      "Failed to load store. Please retry.",
    ),
    "storeProfile_storeName": MessageLookupByLibrary.simpleMessage(
      "Store Name",
    ),
    "storeVerificationAdminComment": MessageLookupByLibrary.simpleMessage(
      "Admin Comment",
    ),
    "storeVerificationContinue": MessageLookupByLibrary.simpleMessage(
      "Continue",
    ),
    "storeVerificationContinueHome": MessageLookupByLibrary.simpleMessage(
      "Continue To Home",
    ),
    "storeVerificationDate": MessageLookupByLibrary.simpleMessage(
      "Verification Date",
    ),
    "storeVerificationFoodStore": MessageLookupByLibrary.simpleMessage(
      "Food Store",
    ),
    "storeVerificationNoRequest": MessageLookupByLibrary.simpleMessage(
      "No verification request submitted yet",
    ),
    "storeVerificationPrompt": MessageLookupByLibrary.simpleMessage(
      "Please provide the needed documents to verify your store.",
    ),
    "storeVerificationRectify": MessageLookupByLibrary.simpleMessage(
      "Rectify Your Request",
    ),
    "storeVerificationRequestId": MessageLookupByLibrary.simpleMessage(
      "Request ID",
    ),
    "storeVerificationRequest_adminComment":
        MessageLookupByLibrary.simpleMessage("Admin Comment"),
    "storeVerificationRequest_continueHome":
        MessageLookupByLibrary.simpleMessage("Continue To Home"),
    "storeVerificationRequest_date": MessageLookupByLibrary.simpleMessage(
      "Verification Date",
    ),
    "storeVerificationRequest_foodStore": MessageLookupByLibrary.simpleMessage(
      "Food Store",
    ),
    "storeVerificationRequest_logout": MessageLookupByLibrary.simpleMessage(
      "Log out",
    ),
    "storeVerificationRequest_rectify": MessageLookupByLibrary.simpleMessage(
      "Rectify Your Request",
    ),
    "storeVerificationRequest_requestId": MessageLookupByLibrary.simpleMessage(
      "Request ID",
    ),
    "storeVerificationRequest_retry": MessageLookupByLibrary.simpleMessage(
      "Retry",
    ),
    "storeVerificationRequest_start": MessageLookupByLibrary.simpleMessage(
      "Start Verification",
    ),
    "storeVerificationRequest_status": MessageLookupByLibrary.simpleMessage(
      "Verification Status",
    ),
    "storeVerificationRequest_submittedDoc":
        MessageLookupByLibrary.simpleMessage("Submitted Document"),
    "storeVerificationRequest_swipeDown": MessageLookupByLibrary.simpleMessage(
      "Swipe down to refresh",
    ),
    "storeVerificationRequest_verifiedBy": MessageLookupByLibrary.simpleMessage(
      "Verified By",
    ),
    "storeVerificationRequest_welcomePrompt": MessageLookupByLibrary.simpleMessage(
      "Join our platform by submitting your store\'s documents for a quick verification process.",
    ),
    "storeVerificationRequest_welcomeTitle":
        MessageLookupByLibrary.simpleMessage("Become a Cuisinous Partner"),
    "storeVerificationStart": MessageLookupByLibrary.simpleMessage(
      "Start Verification",
    ),
    "storeVerificationStatus": MessageLookupByLibrary.simpleMessage(
      "Verification Status",
    ),
    "storeVerificationSubmittedDoc": MessageLookupByLibrary.simpleMessage(
      "Submitted Document",
    ),
    "storeVerificationSuccess": MessageLookupByLibrary.simpleMessage(
      "Your store has been verified and is now live!",
    ),
    "storeVerificationSwipeDown": MessageLookupByLibrary.simpleMessage(
      "Swipe down to refresh",
    ),
    "storeVerificationVerifiedBy": MessageLookupByLibrary.simpleMessage(
      "Verified By",
    ),
    "storeVerificationWelcomePrompt": MessageLookupByLibrary.simpleMessage(
      "Join our platform by submitting your store\'s documents for a quick verification process.",
    ),
    "storeVerificationWelcomeTitle": MessageLookupByLibrary.simpleMessage(
      "Become a Cuisinous Partner",
    ),
    "stripeConnectionError": MessageLookupByLibrary.simpleMessage(
      "Failed to connect Stripe account. Please try again.",
    ),
    "stripeError": m11,
    "stripePayoutId": MessageLookupByLibrary.simpleMessage("Stripe Payout ID"),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "submitReview": MessageLookupByLibrary.simpleMessage("Submit Review"),
    "supplementsMustHavePrice": MessageLookupByLibrary.simpleMessage(
      "Supplements must have a price greater than 0",
    ),
    "tapToChangeLocation": MessageLookupByLibrary.simpleMessage(
      "Tap to change location",
    ),
    "tapToSelectLocation": MessageLookupByLibrary.simpleMessage(
      "Tap to select location",
    ),
    "taxLabel": MessageLookupByLibrary.simpleMessage("Tax"),
    "termsAndConditions": MessageLookupByLibrary.simpleMessage(
      "Terms and Conditions",
    ),
    "termsAndConditions_conclusion": MessageLookupByLibrary.simpleMessage(""),
    "termsAndConditions_intro": MessageLookupByLibrary.simpleMessage(
      "Last updated: 01-01-2026\n\nThese Terms and Conditions (“Terms”) govern your access to and use of the Cuisinous mobile application and related services (the “App”), operated by 9534-9072 Québec Inc., doing business as Cuisinous (“Cuisinous”, “we”, “us”, “our”).\n\nBy creating an account or using the App, you confirm that you have read, understood, and agree to these Terms. If you do not agree, do not use the App.",
    ),
    "termsAndConditions_section10Body": MessageLookupByLibrary.simpleMessage(
      "All App content, branding, software, and trademarks belong to Cuisinous or its licensors.\nNo rights are granted except as expressly stated.",
    ),
    "termsAndConditions_section10Title": MessageLookupByLibrary.simpleMessage(
      "10. INTELLECTUAL PROPERTY",
    ),
    "termsAndConditions_section11Body": MessageLookupByLibrary.simpleMessage(
      "To the maximum extent permitted by law, Cuisinous is not liable for:\nfood-related illness, allergies, injuries, or dissatisfaction;\nVendor actions or failures;\nindirect or consequential damages;\nloss of profits, data, or reputation.\n\nNothing limits liability where prohibited by law (e.g. gross negligence).",
    ),
    "termsAndConditions_section11Title": MessageLookupByLibrary.simpleMessage(
      "11. LIMITATION OF LIABILITY",
    ),
    "termsAndConditions_section12Body": MessageLookupByLibrary.simpleMessage(
      "You agree to indemnify and hold harmless Cuisinous from claims arising from:\nyour use of the App;\nfood sold or consumed;\nviolation of these Terms or the law;\ncontent you provide.",
    ),
    "termsAndConditions_section12Title": MessageLookupByLibrary.simpleMessage(
      "12. INDEMNIFICATION",
    ),
    "termsAndConditions_section13Body": MessageLookupByLibrary.simpleMessage(
      "Cuisinous is not responsible for delays or failures caused by events beyond reasonable control, including natural disasters, government actions, pandemics, or technical failures.",
    ),
    "termsAndConditions_section13Title": MessageLookupByLibrary.simpleMessage(
      "13. FORCE MAJEURE",
    ),
    "termsAndConditions_section14Body": MessageLookupByLibrary.simpleMessage(
      "We may update these Terms at any time.\nContinued use of the App means you accept the updated Terms.",
    ),
    "termsAndConditions_section14Title": MessageLookupByLibrary.simpleMessage(
      "14. CHANGES TO TERMS",
    ),
    "termsAndConditions_section15Body": MessageLookupByLibrary.simpleMessage(
      "These Terms are governed by the laws of Québec, Canada.",
    ),
    "termsAndConditions_section15Title": MessageLookupByLibrary.simpleMessage(
      "15. GOVERNING LAW",
    ),
    "termsAndConditions_section16Body": MessageLookupByLibrary.simpleMessage(
      "Questions or legal notices: info@cuisinous.ca",
    ),
    "termsAndConditions_section16Title": MessageLookupByLibrary.simpleMessage(
      "16. CONTACT",
    ),
    "termsAndConditions_section1Body": MessageLookupByLibrary.simpleMessage(
      "Cuisinous is a technology marketplace that connects independent food Vendors with Customers.\n\nCuisinous:\ndoes not prepare, cook, store, inspect, package, transport, or deliver food;\nis not a restaurant, caterer, or food business;\ndoes not supervise or control Vendors or their kitchens;\ndoes not guarantee food quality, safety, legality, or compliance;\nis not an employer, agent, or partner of any Vendor.\n\nAll food transactions are strictly between the Vendor and the Customer.",
    ),
    "termsAndConditions_section1Title": MessageLookupByLibrary.simpleMessage(
      "1. WHAT CUISINOUS IS",
    ),
    "termsAndConditions_section2Body": MessageLookupByLibrary.simpleMessage(
      "To use the App, you must:\nbe 18 years or older;\nhave legal capacity to enter a contract;\nprovide accurate and current information.\n\nYou are responsible for:\nkeeping your login details secure;\nall activity under your account.\n\nNotify us immediately if you suspect unauthorized access.",
    ),
    "termsAndConditions_section2Title": MessageLookupByLibrary.simpleMessage(
      "2. ELIGIBILITY & ACCOUNTS",
    ),
    "termsAndConditions_section3Body": MessageLookupByLibrary.simpleMessage(
      "Vendors are subject to a separate Vendor Agreement.\nIf there is any conflict between these Terms and the Vendor Agreement, the Vendor Agreement prevails.",
    ),
    "termsAndConditions_section3Title": MessageLookupByLibrary.simpleMessage(
      "3. VENDORS",
    ),
    "termsAndConditions_section4Body": MessageLookupByLibrary.simpleMessage(
      "Vendors are solely responsible for:\ncomplying with all applicable laws and regulations;\nholding valid permits and certifications (including MAPAQ);\nfood safety, hygiene, labeling, allergens, and ingredient accuracy;\ntheir food products and preparation methods.\n\nCuisinous does not verify or inspect Vendor compliance.\n\nCustomers acknowledge that:\nfood is prepared by independent Vendors;\nfood consumption carries inherent risks;\nCuisinous makes no guarantees regarding food safety or suitability.",
    ),
    "termsAndConditions_section4Title": MessageLookupByLibrary.simpleMessage(
      "4. FOOD & LEGAL COMPLIANCE",
    ),
    "termsAndConditions_section5Body": MessageLookupByLibrary.simpleMessage(
      "Payments are processed by third-party providers.\nCuisinous does not store full payment details.\n\nPlatform fees or commissions may apply and are shown before confirmation.\nPlatform fees are non-refundable unless required by law.\n\nVendors are responsible for all applicable taxes (GST, QST, income tax).",
    ),
    "termsAndConditions_section5Title": MessageLookupByLibrary.simpleMessage(
      "5. ORDERS, PAYMENTS & FEES",
    ),
    "termsAndConditions_section6Body": MessageLookupByLibrary.simpleMessage(
      "Cancellation and refund policies are set by Vendors and applicable law.\nCuisinous may help facilitate communication but is not required to resolve disputes or issue refunds.",
    ),
    "termsAndConditions_section6Title": MessageLookupByLibrary.simpleMessage(
      "6. CANCELLATIONS & REFUNDS",
    ),
    "termsAndConditions_section7Body": MessageLookupByLibrary.simpleMessage(
      "You keep ownership of your content (photos, menus, reviews, text).\n\nBy posting content, you grant Cuisinous a worldwide, royalty-free license to use it for App operation, promotion, and analytics.\n\nYou confirm that you have the right to post your content.",
    ),
    "termsAndConditions_section7Title": MessageLookupByLibrary.simpleMessage(
      "7. USER CONTENT",
    ),
    "termsAndConditions_section8Body": MessageLookupByLibrary.simpleMessage(
      "You may not:\nbypass the App to transact off-platform;\nprovide false or misleading information;\nviolate laws or third-party rights;\npost harmful, illegal, or deceptive content;\nmisuse the App or harm Cuisinous’ reputation.",
    ),
    "termsAndConditions_section8Title": MessageLookupByLibrary.simpleMessage(
      "8. PROHIBITED USE",
    ),
    "termsAndConditions_section9Body": MessageLookupByLibrary.simpleMessage(
      "Cuisinous may, where legally permitted:\nsuspend or terminate accounts;\nremove listings or content;\nrestrict access to the App.\n\nNo compensation is owed unless required by law.",
    ),
    "termsAndConditions_section9Title": MessageLookupByLibrary.simpleMessage(
      "9. ACCOUNT SUSPENSION OR TERMINATION",
    ),
    "termsAndConditions_title": MessageLookupByLibrary.simpleMessage(
      "CUISINOUS – TERMS & CONDITIONS (MOBILE APP VERSION)",
    ),
    "tipAmount": MessageLookupByLibrary.simpleMessage("Tip"),
    "tipSuccess": MessageLookupByLibrary.simpleMessage(
      "Tip added successfully! Thank you.",
    ),
    "tipValidationMessage": MessageLookupByLibrary.simpleMessage(
      "Tip must be \$0.00 or between \$1.00 and \$100.00.",
    ),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "transactionDetailsTitle": MessageLookupByLibrary.simpleMessage(
      "Transaction Details",
    ),
    "transactionId": MessageLookupByLibrary.simpleMessage("Transaction ID"),
    "transactionStatusCanceled": MessageLookupByLibrary.simpleMessage(
      "Canceled",
    ),
    "transactionStatusCompleted": MessageLookupByLibrary.simpleMessage(
      "Completed",
    ),
    "transactionStatusFailed": MessageLookupByLibrary.simpleMessage("Failed"),
    "transactionStatusPending": MessageLookupByLibrary.simpleMessage("Pending"),
    "transactionTypeAdjustment": MessageLookupByLibrary.simpleMessage(
      "Adjustment",
    ),
    "transactionTypeDeposit": MessageLookupByLibrary.simpleMessage("Deposit"),
    "transactionTypeFee": MessageLookupByLibrary.simpleMessage("Fee"),
    "transactionTypeOrderIncome": MessageLookupByLibrary.simpleMessage(
      "Order Income",
    ),
    "transactionTypeOther": MessageLookupByLibrary.simpleMessage("Other"),
    "transactionTypePayment": MessageLookupByLibrary.simpleMessage("Payment"),
    "transactionTypeRefund": MessageLookupByLibrary.simpleMessage("Refund"),
    "transactionTypeTipIncome": MessageLookupByLibrary.simpleMessage(
      "Tip Income",
    ),
    "transactionTypeWithdrawal": MessageLookupByLibrary.simpleMessage(
      "Withdrawal",
    ),
    "unexpectedError": m12,
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "updateStore": MessageLookupByLibrary.simpleMessage("Update Store"),
    "uploadImage": MessageLookupByLibrary.simpleMessage("Upload Image"),
    "useCurrentLocation": MessageLookupByLibrary.simpleMessage(
      "Use Current Location",
    ),
    "userInfo_bio": MessageLookupByLibrary.simpleMessage("Bio"),
    "userInfo_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "userInfo_editProfile": MessageLookupByLibrary.simpleMessage(
      "Edit Profile",
    ),
    "userInfo_email": MessageLookupByLibrary.simpleMessage("Email"),
    "userInfo_errorUpdatingProfile": MessageLookupByLibrary.simpleMessage(
      "Error updating profile",
    ),
    "userInfo_firstName": MessageLookupByLibrary.simpleMessage("First Name"),
    "userInfo_lastName": MessageLookupByLibrary.simpleMessage("Last Name"),
    "userInfo_phoneNumber": MessageLookupByLibrary.simpleMessage(
      "Phone Number",
    ),
    "userInfo_phoneNumberTooLong": MessageLookupByLibrary.simpleMessage(
      "Phone number must be exactly 10 digits",
    ),
    "userInfo_profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "userInfo_profileUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Profile updated successfully",
    ),
    "userInfo_save": MessageLookupByLibrary.simpleMessage("Save"),
    "userInfo_username": MessageLookupByLibrary.simpleMessage("Username"),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "validationInvalidPrice": MessageLookupByLibrary.simpleMessage(
      "Invalid price",
    ),
    "validationRequired": MessageLookupByLibrary.simpleMessage(
      "Required field",
    ),
    "vendorAgreement_agreeAndContinue": MessageLookupByLibrary.simpleMessage(
      "Agree and Continue",
    ),
    "vendorAgreement_intro": MessageLookupByLibrary.simpleMessage(
      "This Service Agreement (the “Agreement”) is entered into and becomes effective on the date and at the time of its electronic acceptance by the Vendor through the Cuisinous platform.\n\nBETWEEN:\n9534-9072 QUÉBEC INC., a corporation duly incorporated under the Business Corporations Act, having its registered office at 401-5131, Place Leblanc, in the city of Sainte-Catherine, Province of Québec, J5C 1G6;\n(hereinafter referred to as “Cuisinous”)\n\nAND:\nAny natural or legal person who has created a vendor account on the Cuisinous platform and has accepted this Agreement electronically, whose identity, contact details, and relevant information are those provided at the time of vendor account creation;\n(hereinafter referred to as the “Vendor”)\n\n(Cuisinous and the Vendor are hereinafter collectively referred to as the “Parties”)",
    ),
    "vendorAgreement_preambleBody": MessageLookupByLibrary.simpleMessage(
      "A. Use of Platform.\nBy electronically accepting this Agreement, the Vendor acknowledges having carefully read, understood, and unconditionally accepted all of its terms, as well as any related documents, policies, or conditions, where applicable.\n\nB. Nature of Service.\nThe Vendor acknowledges that Cuisinous acts solely as a technology matchmaking platform, that it does not engage in any food preparation, manufacturing, processing, storage, inspection, or delivery activities, and that it assumes no responsibility whatsoever for the food products offered by the Vendor.\n\nC. Independent Status.\nThe Vendor further acknowledges acting independently, as a self-employed individual, and assumes full responsibility for its activities, products, operations, and legal obligations.\n\nD. Electronic Consent.\nThe electronic acceptance of this Agreement constitutes free and informed consent and has the same legal value as a handwritten signature, in accordance with applicable Québec laws.",
    ),
    "vendorAgreement_preambleTitle": MessageLookupByLibrary.simpleMessage(
      "PREAMBLE",
    ),
    "vendorAgreement_section10Body": MessageLookupByLibrary.simpleMessage(
      "10.1. “Confidential Information” includes all data or information disclosed through platform use, including customer data, transactions, pricing, business terms, platform features, technologies, and internal policies.\n\n10.2. The Vendor agrees to maintain confidentiality, use such information solely for contract performance, not disclose it without written authorization, and implement reasonable safeguards.\n\n10.3. The Vendor agrees to comply with applicable privacy laws, including Québec’s Private Sector Privacy Act, and to use customer data solely for order fulfillment.\n\n10.4. All customer and platform data remain the exclusive property of Cuisinous, subject to applicable legal rights.\n\n10.5. Confidentiality obligations survive indefinitely.\n\n10.6. Any breach may cause irreparable harm and justify injunctive relief.",
    ),
    "vendorAgreement_section10Title": MessageLookupByLibrary.simpleMessage(
      "10. CONFIDENTIALITY AND DATA PROTECTION",
    ),
    "vendorAgreement_section11Body": MessageLookupByLibrary.simpleMessage(
      "11.1. This Agreement is governed by Québec law. Québec judicial district courts have exclusive jurisdiction.\n\n11.2. Invalid provisions shall be severed without affecting remaining provisions.\n\n11.3. Neither Party is liable for force majeure events.\n\n11.4. Cuisinous may modify this Agreement at any time. Continued platform use constitutes acceptance.\n\n11.5. Failure to enforce a right does not constitute waiver.\n\n11.6. The Vendor may not assign this Agreement without consent. Cuisinous may assign freely.\n\n11.7. This Agreement constitutes the entire agreement between the Parties.",
    ),
    "vendorAgreement_section11Title": MessageLookupByLibrary.simpleMessage(
      "11. GENERAL PROVISIONS",
    ),
    "vendorAgreement_section12Body": MessageLookupByLibrary.simpleMessage(
      "12.1. Acceptance via “Accept and Continue” or continued platform use constitutes valid electronic signature under Québec law.\n\n12.2. The Vendor confirms that consent is given freely and knowingly after full review.",
    ),
    "vendorAgreement_section12Title": MessageLookupByLibrary.simpleMessage(
      "12. ELECTRONIC ACCEPTANCE AND CONSENT",
    ),
    "vendorAgreement_section1Body": MessageLookupByLibrary.simpleMessage(
      "1.1. Cuisinous operates a technology platform that facilitates connections between food product Vendors and Customers.\n\n1.2. Cuisinous does not engage in any food preparation, manufacturing, processing, storage, inspection, or delivery activities and is in no way a restaurateur, employer, agent, or representative of the Vendor.\n\n1.3. This Agreement defines the rights and obligations of the Vendor and Cuisinous regarding the use of the platform.",
    ),
    "vendorAgreement_section1Title": MessageLookupByLibrary.simpleMessage(
      "1. PURPOSE",
    ),
    "vendorAgreement_section2Body": MessageLookupByLibrary.simpleMessage(
      "2.1. The Vendor acts as an independent contractor and operates its business independently. Nothing in this Agreement shall be construed as creating an employment, agency, partnership, joint venture, or representative relationship between the Vendor and Cuisinous.\n\n2.2. The Vendor assumes all risks and responsibilities related to its business, including applicable tax, social, and regulatory obligations.",
    ),
    "vendorAgreement_section2Title": MessageLookupByLibrary.simpleMessage(
      "2. INDEPENDENT VENDOR STATUS",
    ),
    "vendorAgreement_section3Body": MessageLookupByLibrary.simpleMessage(
      "3.1. The Vendor is solely and fully responsible for, without limitation:\n\na) food safety, hygiene, and sanitation;\nb) product quality, labeling, composition, and allergen disclosure;\nc) preparation, storage, and distribution methods;\nd) obtaining and maintaining all required permits, licenses, and certifications, including those issued by the Québec Ministry of Agriculture, Fisheries and Food (“MAPAQ”);\ne) compliance with all applicable laws and regulations;\nf) the accuracy and truthfulness of information provided to Cuisinous;\ng) respecting intellectual property rights and refraining from selling counterfeit, illegal, or infringing products.\n\n3.2. Cuisinous does not verify, inspect, or certify the Vendor’s activities, kitchen, products, operations, permits, or insurance.\n\n3.3. The Vendor agrees to immediately notify Cuisinous of any change, suspension, or revocation of permits or certifications, or any information that may affect food safety, legal compliance, or the performance of this Agreement.",
    ),
    "vendorAgreement_section3Title": MessageLookupByLibrary.simpleMessage(
      "3. VENDOR OBLIGATIONS",
    ),
    "vendorAgreement_section4Body": MessageLookupByLibrary.simpleMessage(
      "4.1. The Vendor represents and warrants that it:\n\na) holds all required permits and certifications, which are valid and up to date;\nb) complies with all applicable laws, regulations, and standards;\nc) assumes full responsibility for its products and operations;\nd) agrees to indemnify and hold harmless Cuisinous, its directors, officers, and partners from any claim, fine, damage, or action arising from the Vendor’s non-compliance;\ne) acknowledges that providing false, misleading, or outdated information constitutes a material breach of this Agreement and may result in immediate suspension or termination;\nf) maintains, at its own expense, throughout the term of this Agreement, adequate civil liability insurance covering its activities, products, and any resulting bodily injury, property damage, or financial loss.\n\n4.2. The Vendor expressly acknowledges and agrees that Cuisinous does not require, verify, validate, or retain any proof of the Vendor’s insurance, and that the absence, insufficiency, invalidity, or non-compliance of the Vendor’s insurance shall in no event engage the liability of Cuisinous. The Vendor expressly releases Cuisinous from any liability, claim, or obligation arising from the Vendor’s failure to maintain adequate insurance.\n\n4.3. The Vendor acknowledges being entirely responsible for food safety, hygiene, ingredient accuracy, allergen disclosure, cross-contamination risks, and any consequences arising from the consumption of food sold through Cuisinous.",
    ),
    "vendorAgreement_section4Title": MessageLookupByLibrary.simpleMessage(
      "4. VENDOR REPRESENTATIONS AND WARRANTIES",
    ),
    "vendorAgreement_section5Body": MessageLookupByLibrary.simpleMessage(
      "5.1. The Vendor agrees to pay all applicable fees related to the use of the platform.\n\n5.2. The Vendor is strictly prohibited from bypassing the platform to conduct direct transactions with Customers obtained through Cuisinous. Any violation authorizes Cuisinous to immediately suspend or terminate the Vendor’s account and pursue available remedies.",
    ),
    "vendorAgreement_section5Title": MessageLookupByLibrary.simpleMessage(
      "5. FEES AND CIRCUMVENTION PROHIBITION",
    ),
    "vendorAgreement_section6Body": MessageLookupByLibrary.simpleMessage(
      "6.1. All Customer payments and amounts payable to the Vendor are processed exclusively through an independent third-party payment service provider, including Stripe or any equivalent provider.\n\n6.2. The Vendor acknowledges that Cuisinous is not a financial institution and does not act as a payment intermediary, trustee, or fund custodian, and does not store, process, or retain any banking, financial, or credit card information.\n\n6.3. The Vendor acknowledges that payment execution, processing, authorization, settlement, and disbursement are the sole responsibility of the third-party payment provider.\n\n6.4. The Vendor understands that Cuisinous cannot be held liable for any error, omission, delay, interruption, failure, payment refusal, fund hold, account suspension, or security incident attributable to the third-party payment provider or its systems.",
    ),
    "vendorAgreement_section6Title": MessageLookupByLibrary.simpleMessage(
      "6. PAYMENT TERMS",
    ),
    "vendorAgreement_section7Body": MessageLookupByLibrary.simpleMessage(
      "7.1. The Vendor acknowledges that Cuisinous acts solely as a technology platform provider and matchmaking intermediary and does not intervene in any manner in food preparation, manufacturing, processing, storage, packaging, labeling, handling, delivery, or sale.\n\n7.2. To the fullest extent permitted by law, Cuisinous and its directors, officers, employees, shareholders, and partners shall not be liable for any direct or indirect, incidental, consequential, special, or punitive damages, including:\n\na) illness, food poisoning, allergic reactions, bodily injury, or death;\nb) loss of income, business, or reputation;\nc) claims, complaints, penalties, fines, or legal actions by customers, third parties, or regulators;\n\narising directly or indirectly from the Vendor’s food, ingredients, information, omissions, or activities.\n\n7.3. Cuisinous provides no express or implied warranty regarding the quality, safety, legality, regulatory compliance, or fitness for consumption of Vendor products.\n\n7.4. The Vendor expressly waives any claim against Cuisinous relating to damages arising from Vendor food products or platform use, except in cases of gross negligence or intentional misconduct by Cuisinous.",
    ),
    "vendorAgreement_section7Title": MessageLookupByLibrary.simpleMessage(
      "7. LIMITATION OF LIABILITY",
    ),
    "vendorAgreement_section8Body": MessageLookupByLibrary.simpleMessage(
      "8.1. The Vendor agrees to indemnify, defend, and hold harmless Cuisinous and its directors, officers, employees, shareholders, representatives, and partners from any claim, demand, complaint, lawsuit, investigation, sanction, fine, penalty, damage, loss, liability, cost, or expense (including legal and expert fees on a solicitor-client basis) arising directly or indirectly from:\n\na) food, ingredients, products, or services offered by the Vendor;\nb) illness, food poisoning, allergic reactions, injury, death, or health impacts;\nc) non-compliance with laws, regulations, or MAPAQ requirements;\nd) false, misleading, incomplete, or outdated information provided by the Vendor;\ne) any breach of this Agreement or related policies;\nf) any actual or alleged violation of customer, third-party, or governmental rights.\n\n8.2. At Cuisinous’ request, the Vendor shall assume the full defense of such claims, at its expense, with counsel reasonably acceptable to Cuisinous. Cuisinous may participate in the defense at its own expense.\n\n8.3. These indemnification obligations survive termination or expiration of this Agreement.",
    ),
    "vendorAgreement_section8Title": MessageLookupByLibrary.simpleMessage(
      "8. INDEMNIFICATION",
    ),
    "vendorAgreement_section9Body": MessageLookupByLibrary.simpleMessage(
      "9.1. Cuisinous reserves the right, at its sole discretion, to suspend, restrict, remove products, disable platform access, or terminate the Vendor’s account at any time, with or without notice, including in cases of:\n\na) breach of this Agreement or related policies;\nb) false or misleading information;\nc) non-compliance with laws or food safety regulations;\nd) health or safety risks;\ne) regulatory complaints or investigations;\nf) reputational harm;\ng) reasonable suspicion of fraud or serious misconduct.\n\n9.2. Suspension or termination does not entitle the Vendor to any compensation or refund.\n\n9.3. Termination does not affect obligations that by their nature survive, including payment, confidentiality, indemnification, and liability provisions.",
    ),
    "vendorAgreement_section9Title": MessageLookupByLibrary.simpleMessage(
      "9. SUSPENSION AND TERMINATION",
    ),
    "vendorAgreement_title": MessageLookupByLibrary.simpleMessage(
      "SERVICE AGREEMENT v.1",
    ),
    "verifyYourNumberInProfile": MessageLookupByLibrary.simpleMessage(
      "Verify your number in your profile",
    ),
    "withdrawAmount": MessageLookupByLibrary.simpleMessage("Withdrawal Amount"),
    "withdrawAmountExceeded": MessageLookupByLibrary.simpleMessage(
      "Amount cannot exceed your current balance",
    ),
    "withdrawButton": MessageLookupByLibrary.simpleMessage("Withdraw"),
    "withdrawConfirm": MessageLookupByLibrary.simpleMessage(
      "Confirm Withdrawal",
    ),
    "withdrawCurrentBalance": MessageLookupByLibrary.simpleMessage(
      "Current Balance",
    ),
    "withdrawCustomAmount": MessageLookupByLibrary.simpleMessage(
      "Custom Amount",
    ),
    "withdrawError": MessageLookupByLibrary.simpleMessage(
      "Withdrawal failed. Please try again.",
    ),
    "withdrawFee": MessageLookupByLibrary.simpleMessage("Withdrawal Fee"),
    "withdrawFeeNotice": MessageLookupByLibrary.simpleMessage(
      "This instant withdrawal will cost you \$4. Please confirm before proceeding.",
    ),
    "withdrawInvalidAmount": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid amount",
    ),
    "withdrawProcessing": MessageLookupByLibrary.simpleMessage(
      "Processing withdrawal...",
    ),
    "withdrawQuickAmounts": MessageLookupByLibrary.simpleMessage(
      "Quick Amounts",
    ),
    "withdrawSuccess": MessageLookupByLibrary.simpleMessage(
      "Withdrawal successful!",
    ),
    "withdrawTitle": MessageLookupByLibrary.simpleMessage("Withdraw Funds"),
    "withdrawTotal": MessageLookupByLibrary.simpleMessage("Total Amount"),
    "writeReview_clickToUpload": MessageLookupByLibrary.simpleMessage(
      "Click here to upload",
    ),
    "writeReview_commentHint": MessageLookupByLibrary.simpleMessage(
      "Share your experience with this dish...",
    ),
    "writeReview_commentLabel": MessageLookupByLibrary.simpleMessage(
      "Comment (Optional)",
    ),
    "writeReview_rateDish": MessageLookupByLibrary.simpleMessage("Rate Dish"),
    "writeReview_submit": MessageLookupByLibrary.simpleMessage("Submit Review"),
    "yourReview": MessageLookupByLibrary.simpleMessage("Your Review"),
  };
}

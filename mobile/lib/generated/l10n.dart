// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Enter your email`
  String get login_emailHint {
    return Intl.message(
      'Enter your email',
      name: 'login_emailHint',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password`
  String get login_passwordHint {
    return Intl.message(
      'Enter your password',
      name: 'login_passwordHint',
      desc: '',
      args: [],
    );
  }

  /// `VOS VOISINS, VOS CHEFS`
  String get login_slogan {
    return Intl.message(
      'VOS VOISINS, VOS CHEFS',
      name: 'login_slogan',
      desc: '',
      args: [],
    );
  }

  /// `Email :`
  String get login_emailLabel {
    return Intl.message(
      'Email :',
      name: 'login_emailLabel',
      desc: '',
      args: [],
    );
  }

  /// `Password :`
  String get login_passwordLabel {
    return Intl.message(
      'Password :',
      name: 'login_passwordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login_button {
    return Intl.message('Login', name: 'login_button', desc: '', args: []);
  }

  /// `Don't have an account? Register`
  String get login_registerPrompt {
    return Intl.message(
      'Don\'t have an account? Register',
      name: 'login_registerPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Apple`
  String get login_apple {
    return Intl.message(
      'Sign in with Apple',
      name: 'login_apple',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Google`
  String get login_google {
    return Intl.message(
      'Sign in with Google',
      name: 'login_google',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Email`
  String get login_continueWithEmail {
    return Intl.message(
      'Continue with Email',
      name: 'login_continueWithEmail',
      desc: '',
      args: [],
    );
  }

  /// `By signing in with Google, you agree to our Terms and Conditions and Privacy Policy.`
  String get login_googleDisclaimer {
    return Intl.message(
      'By signing in with Google, you agree to our Terms and Conditions and Privacy Policy.',
      name: 'login_googleDisclaimer',
      desc: '',
      args: [],
    );
  }

  /// `How You'd Like to Join Us!`
  String get accountTypeSelection_accountTypeTitle {
    return Intl.message(
      'How You\'d Like to Join Us!',
      name: 'accountTypeSelection_accountTypeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you here to enjoy delicious meals or share your culinary creations? Select your role to get started!`
  String get accountTypeSelection_accountTypeSubtitle {
    return Intl.message(
      'Are you here to enjoy delicious meals or share your culinary creations? Select your role to get started!',
      name: 'accountTypeSelection_accountTypeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Looking for Homemade Meals`
  String get accountTypeSelection_accountTypeBuyer {
    return Intl.message(
      'Looking for Homemade Meals',
      name: 'accountTypeSelection_accountTypeBuyer',
      desc: '',
      args: [],
    );
  }

  /// `Offering Homemade Meals`
  String get accountTypeSelection_accountTypeSeller {
    return Intl.message(
      'Offering Homemade Meals',
      name: 'accountTypeSelection_accountTypeSeller',
      desc: '',
      args: [],
    );
  }

  /// `Add Card`
  String get addPaymentCard_title {
    return Intl.message(
      'Add Card',
      name: 'addPaymentCard_title',
      desc: '',
      args: [],
    );
  }

  /// `Card Number`
  String get addPaymentCard_labelCardNumber {
    return Intl.message(
      'Card Number',
      name: 'addPaymentCard_labelCardNumber',
      desc: '',
      args: [],
    );
  }

  /// `Card number is required`
  String get addPaymentCard_validationCardNumberRequired {
    return Intl.message(
      'Card number is required',
      name: 'addPaymentCard_validationCardNumberRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter valid Visa/MasterCard`
  String get addPaymentCard_validationCardNumberInvalid {
    return Intl.message(
      'Enter valid Visa/MasterCard',
      name: 'addPaymentCard_validationCardNumberInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Expiry Date`
  String get addPaymentCard_labelExpiryDate {
    return Intl.message(
      'Expiry Date',
      name: 'addPaymentCard_labelExpiryDate',
      desc: '',
      args: [],
    );
  }

  /// `Expiry required`
  String get addPaymentCard_validationExpiryRequired {
    return Intl.message(
      'Expiry required',
      name: 'addPaymentCard_validationExpiryRequired',
      desc: '',
      args: [],
    );
  }

  /// `Invalid format`
  String get addPaymentCard_validationExpiryInvalid {
    return Intl.message(
      'Invalid format',
      name: 'addPaymentCard_validationExpiryInvalid',
      desc: '',
      args: [],
    );
  }

  /// `CVV`
  String get addPaymentCard_labelCVV {
    return Intl.message(
      'CVV',
      name: 'addPaymentCard_labelCVV',
      desc: '',
      args: [],
    );
  }

  /// `CVV required`
  String get addPaymentCard_validationCVVRequired {
    return Intl.message(
      'CVV required',
      name: 'addPaymentCard_validationCVVRequired',
      desc: '',
      args: [],
    );
  }

  /// `Invalid CVV`
  String get addPaymentCard_validationCVVInvalid {
    return Intl.message(
      'Invalid CVV',
      name: 'addPaymentCard_validationCVVInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Cardholder Name`
  String get addPaymentCard_labelCardHolder {
    return Intl.message(
      'Cardholder Name',
      name: 'addPaymentCard_labelCardHolder',
      desc: '',
      args: [],
    );
  }

  /// `John Doe`
  String get addPaymentCard_hintCardHolder {
    return Intl.message(
      'John Doe',
      name: 'addPaymentCard_hintCardHolder',
      desc: '',
      args: [],
    );
  }

  /// `Name is required`
  String get addPaymentCard_validationNameRequired {
    return Intl.message(
      'Name is required',
      name: 'addPaymentCard_validationNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Set as default payment method`
  String get addPaymentCard_setDefault {
    return Intl.message(
      'Set as default payment method',
      name: 'addPaymentCard_setDefault',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get addPaymentCard_save {
    return Intl.message(
      'Save',
      name: 'addPaymentCard_save',
      desc: '',
      args: [],
    );
  }

  /// `Saved Addresses`
  String get addressManagement_title {
    return Intl.message(
      'Saved Addresses',
      name: 'addressManagement_title',
      desc: '',
      args: [],
    );
  }

  /// `No saved addresses`
  String get addressManagement_emptyText {
    return Intl.message(
      'No saved addresses',
      name: 'addressManagement_emptyText',
      desc: '',
      args: [],
    );
  }

  /// `Add First Address`
  String get addressManagement_emptyButton {
    return Intl.message(
      'Add First Address',
      name: 'addressManagement_emptyButton',
      desc: '',
      args: [],
    );
  }

  /// `Your Addresses`
  String get addressManagement_yourAddresses {
    return Intl.message(
      'Your Addresses',
      name: 'addressManagement_yourAddresses',
      desc: '',
      args: [],
    );
  }

  /// `Delete Address`
  String get addressManagement_deleteTitle {
    return Intl.message(
      'Delete Address',
      name: 'addressManagement_deleteTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this address?`
  String get addressManagement_deleteContent {
    return Intl.message(
      'Are you sure you want to delete this address?',
      name: 'addressManagement_deleteContent',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get addressManagement_deleteCancel {
    return Intl.message(
      'Cancel',
      name: 'addressManagement_deleteCancel',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get addressManagement_deleteConfirm {
    return Intl.message(
      'Delete',
      name: 'addressManagement_deleteConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Order Receipt`
  String get buyerOrderDetails_title {
    return Intl.message(
      'Order Receipt',
      name: 'buyerOrderDetails_title',
      desc: '',
      args: [],
    );
  }

  /// `Receipt not found`
  String get buyerOrderDetails_notFound {
    return Intl.message(
      'Receipt not found',
      name: 'buyerOrderDetails_notFound',
      desc: '',
      args: [],
    );
  }

  /// `Order #:`
  String get buyerOrderDetails_labelOrderNumber {
    return Intl.message(
      'Order #:',
      name: 'buyerOrderDetails_labelOrderNumber',
      desc: '',
      args: [],
    );
  }

  /// `Date:`
  String get buyerOrderDetails_labelDate {
    return Intl.message(
      'Date:',
      name: 'buyerOrderDetails_labelDate',
      desc: '',
      args: [],
    );
  }

  /// `CUSTOMER`
  String get buyerOrderDetails_sectionCustomer {
    return Intl.message(
      'CUSTOMER',
      name: 'buyerOrderDetails_sectionCustomer',
      desc: '',
      args: [],
    );
  }

  /// `DELIVERY TO`
  String get buyerOrderDetails_sectionDeliveryTo {
    return Intl.message(
      'DELIVERY TO',
      name: 'buyerOrderDetails_sectionDeliveryTo',
      desc: '',
      args: [],
    );
  }

  /// `ITEMS`
  String get buyerOrderDetails_sectionItems {
    return Intl.message(
      'ITEMS',
      name: 'buyerOrderDetails_sectionItems',
      desc: '',
      args: [],
    );
  }

  /// `TOTAL`
  String get buyerOrderDetails_sectionTotal {
    return Intl.message(
      'TOTAL',
      name: 'buyerOrderDetails_sectionTotal',
      desc: '',
      args: [],
    );
  }

  /// `PAYMENT DETAILS`
  String get buyerOrderDetails_sectionPaymentDetails {
    return Intl.message(
      'PAYMENT DETAILS',
      name: 'buyerOrderDetails_sectionPaymentDetails',
      desc: '',
      args: [],
    );
  }

  /// `ORDER NOTES`
  String get buyerOrderDetails_sectionOrderNotes {
    return Intl.message(
      'ORDER NOTES',
      name: 'buyerOrderDetails_sectionOrderNotes',
      desc: '',
      args: [],
    );
  }

  /// `Name:`
  String get buyerOrderDetails_labelName {
    return Intl.message(
      'Name:',
      name: 'buyerOrderDetails_labelName',
      desc: '',
      args: [],
    );
  }

  /// `Email:`
  String get buyerOrderDetails_labelEmail {
    return Intl.message(
      'Email:',
      name: 'buyerOrderDetails_labelEmail',
      desc: '',
      args: [],
    );
  }

  /// `Phone:`
  String get buyerOrderDetails_labelPhone {
    return Intl.message(
      'Phone:',
      name: 'buyerOrderDetails_labelPhone',
      desc: '',
      args: [],
    );
  }

  /// `Subtotal:`
  String get buyerOrderDetails_labelSubtotal {
    return Intl.message(
      'Subtotal:',
      name: 'buyerOrderDetails_labelSubtotal',
      desc: '',
      args: [],
    );
  }

  /// `Tip Amount:`
  String get buyerOrderDetails_labelTipAmount {
    return Intl.message(
      'Tip Amount:',
      name: 'buyerOrderDetails_labelTipAmount',
      desc: '',
      args: [],
    );
  }

  /// `TOTAL PAID`
  String get buyerOrderDetails_totalPaid {
    return Intl.message(
      'TOTAL PAID',
      name: 'buyerOrderDetails_totalPaid',
      desc: '',
      args: [],
    );
  }

  /// `Payment Status:`
  String get buyerOrderDetails_labelPaymentStatus {
    return Intl.message(
      'Payment Status:',
      name: 'buyerOrderDetails_labelPaymentStatus',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Status:`
  String get buyerOrderDetails_labelDeliveryStatus {
    return Intl.message(
      'Delivery Status:',
      name: 'buyerOrderDetails_labelDeliveryStatus',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation Code:`
  String get buyerOrderDetails_labelConfirmationCode {
    return Intl.message(
      'Confirmation Code:',
      name: 'buyerOrderDetails_labelConfirmationCode',
      desc: '',
      args: [],
    );
  }

  /// `Show this code to the seller`
  String get buyerOrderDetails_showCodeToSeller {
    return Intl.message(
      'Show this code to the seller',
      name: 'buyerOrderDetails_showCodeToSeller',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for your order!`
  String get buyerOrderDetails_thankYou {
    return Intl.message(
      'Thank you for your order!',
      name: 'buyerOrderDetails_thankYou',
      desc: '',
      args: [],
    );
  }

  /// `No notes added`
  String get buyerOrderDetails_noNotes {
    return Intl.message(
      'No notes added',
      name: 'buyerOrderDetails_noNotes',
      desc: '',
      args: [],
    );
  }

  /// `Edit Note`
  String get buyerOrderDetails_editNote {
    return Intl.message(
      'Edit Note',
      name: 'buyerOrderDetails_editNote',
      desc: '',
      args: [],
    );
  }

  /// `Pay Order`
  String get buyerOrderDetails_payOrder {
    return Intl.message(
      'Pay Order',
      name: 'buyerOrderDetails_payOrder',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for seller confirmation`
  String get buyerOrderDetails_waitingForConfirmation {
    return Intl.message(
      'Waiting for seller confirmation',
      name: 'buyerOrderDetails_waitingForConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Order`
  String get buyerOrderDetails_cancelOrder {
    return Intl.message(
      'Cancel Order',
      name: 'buyerOrderDetails_cancelOrder',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get buyerOrderDetails_noteLabel {
    return Intl.message(
      'Note',
      name: 'buyerOrderDetails_noteLabel',
      desc: '',
      args: [],
    );
  }

  /// `Special instructions or notes...`
  String get buyerOrderDetails_noteHint {
    return Intl.message(
      'Special instructions or notes...',
      name: 'buyerOrderDetails_noteHint',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get buyerOrderDetails_noteCancel {
    return Intl.message(
      'Cancel',
      name: 'buyerOrderDetails_noteCancel',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get buyerOrderDetails_noteSave {
    return Intl.message(
      'Save',
      name: 'buyerOrderDetails_noteSave',
      desc: '',
      args: [],
    );
  }

  /// `Ordered`
  String get buyerOrderDetails_timelineOrdered {
    return Intl.message(
      'Ordered',
      name: 'buyerOrderDetails_timelineOrdered',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get buyerOrderDetails_timelineConfirmed {
    return Intl.message(
      'Confirmed',
      name: 'buyerOrderDetails_timelineConfirmed',
      desc: '',
      args: [],
    );
  }

  /// `Delivered`
  String get buyerOrderDetails_timelineDelivered {
    return Intl.message(
      'Delivered',
      name: 'buyerOrderDetails_timelineDelivered',
      desc: '',
      args: [],
    );
  }

  /// `Paid`
  String get orderStatusPaid {
    return Intl.message('Paid', name: 'orderStatusPaid', desc: '', args: []);
  }

  /// `Pending`
  String get orderStatusPending {
    return Intl.message(
      'Pending',
      name: 'orderStatusPending',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get orderStatusCompleted {
    return Intl.message(
      'Completed',
      name: 'orderStatusCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get orderStatusCancelled {
    return Intl.message(
      'Cancelled',
      name: 'orderStatusCancelled',
      desc: '',
      args: [],
    );
  }

  /// `My Orders`
  String get buyerOrders_title {
    return Intl.message(
      'My Orders',
      name: 'buyerOrders_title',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get buyerOrders_errorRetry {
    return Intl.message(
      'Retry',
      name: 'buyerOrders_errorRetry',
      desc: '',
      args: [],
    );
  }

  /// `No orders found`
  String get buyerOrders_empty {
    return Intl.message(
      'No orders found',
      name: 'buyerOrders_empty',
      desc: '',
      args: [],
    );
  }

  /// `Filter & Sort`
  String get buyerOrders_filterTitle {
    return Intl.message(
      'Filter & Sort',
      name: 'buyerOrders_filterTitle',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get buyerOrders_searchLabel {
    return Intl.message(
      'Search',
      name: 'buyerOrders_searchLabel',
      desc: '',
      args: [],
    );
  }

  /// `Order number, store name...`
  String get buyerOrders_searchHint {
    return Intl.message(
      'Order number, store name...',
      name: 'buyerOrders_searchHint',
      desc: '',
      args: [],
    );
  }

  /// `Min Price`
  String get buyerOrders_filterMinPrice {
    return Intl.message(
      'Min Price',
      name: 'buyerOrders_filterMinPrice',
      desc: '',
      args: [],
    );
  }

  /// `Max Price`
  String get buyerOrders_filterMaxPrice {
    return Intl.message(
      'Max Price',
      name: 'buyerOrders_filterMaxPrice',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get buyerOrders_filterReset {
    return Intl.message(
      'Reset',
      name: 'buyerOrders_filterReset',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get buyerOrders_filterApply {
    return Intl.message(
      'Apply',
      name: 'buyerOrders_filterApply',
      desc: '',
      args: [],
    );
  }

  /// `Order`
  String get buyerOrders_itemNumber {
    return Intl.message(
      'Order',
      name: 'buyerOrders_itemNumber',
      desc: '',
      args: [],
    );
  }

  /// `Buyer:`
  String get buyerOrders_itemBuyer {
    return Intl.message(
      'Buyer:',
      name: 'buyerOrders_itemBuyer',
      desc: '',
      args: [],
    );
  }

  /// `Total:`
  String get buyerOrders_itemTotal {
    return Intl.message(
      'Total:',
      name: 'buyerOrders_itemTotal',
      desc: '',
      args: [],
    );
  }

  /// `Placed:`
  String get buyerOrders_itemPlaced {
    return Intl.message(
      'Placed:',
      name: 'buyerOrders_itemPlaced',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get buyerOrders_sortStatus {
    return Intl.message(
      'Status',
      name: 'buyerOrders_sortStatus',
      desc: '',
      args: [],
    );
  }

  /// `Payment Status`
  String get buyerOrders_sortPaymentStatus {
    return Intl.message(
      'Payment Status',
      name: 'buyerOrders_sortPaymentStatus',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Status`
  String get buyerOrders_sortDeliveryStatus {
    return Intl.message(
      'Delivery Status',
      name: 'buyerOrders_sortDeliveryStatus',
      desc: '',
      args: [],
    );
  }

  /// `Created Date`
  String get buyerOrders_sortCreated {
    return Intl.message(
      'Created Date',
      name: 'buyerOrders_sortCreated',
      desc: '',
      args: [],
    );
  }

  /// `Total Price`
  String get buyerOrders_sortPrice {
    return Intl.message(
      'Total Price',
      name: 'buyerOrders_sortPrice',
      desc: '',
      args: [],
    );
  }

  /// `Ascending`
  String get buyerOrders_sortOrderAsc {
    return Intl.message(
      'Ascending',
      name: 'buyerOrders_sortOrderAsc',
      desc: '',
      args: [],
    );
  }

  /// `Descending`
  String get buyerOrders_sortOrderDesc {
    return Intl.message(
      'Descending',
      name: 'buyerOrders_sortOrderDesc',
      desc: '',
      args: [],
    );
  }

  /// `Your Cart`
  String get cart_title {
    return Intl.message('Your Cart', name: 'cart_title', desc: '', args: []);
  }

  /// `Refresh cart`
  String get cart_refreshTooltip {
    return Intl.message(
      'Refresh cart',
      name: 'cart_refreshTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get cart_errorTryAgain {
    return Intl.message(
      'Try Again',
      name: 'cart_errorTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Your cart is empty`
  String get cart_emptyTitle {
    return Intl.message(
      'Your cart is empty',
      name: 'cart_emptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add items to get started`
  String get cart_emptySubtitle {
    return Intl.message(
      'Add items to get started',
      name: 'cart_emptySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Proceed to Checkout`
  String get cart_checkoutButton {
    return Intl.message(
      'Proceed to Checkout',
      name: 'cart_checkoutButton',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get cart_total {
    return Intl.message('Total', name: 'cart_total', desc: '', args: []);
  }

  /// `Remove item`
  String get cart_itemDelete {
    return Intl.message(
      'Remove item',
      name: 'cart_itemDelete',
      desc: '',
      args: [],
    );
  }

  /// `Go to Cart`
  String get goToCart {
    return Intl.message('Go to Cart', name: 'goToCart', desc: '', args: []);
  }

  /// `Checkout`
  String get checkout_title {
    return Intl.message('Checkout', name: 'checkout_title', desc: '', args: []);
  }

  /// `Place Order`
  String get checkout_placeOrder {
    return Intl.message(
      'Place Order',
      name: 'checkout_placeOrder',
      desc: '',
      args: [],
    );
  }

  /// `Your Order`
  String get checkout_yourOrder {
    return Intl.message(
      'Your Order',
      name: 'checkout_yourOrder',
      desc: '',
      args: [],
    );
  }

  /// `Select Delivery Location`
  String get checkout_selectLocation {
    return Intl.message(
      'Select Delivery Location',
      name: 'checkout_selectLocation',
      desc: '',
      args: [],
    );
  }

  /// `No locations available. Add a location first.`
  String get checkout_noLocations {
    return Intl.message(
      'No locations available. Add a location first.',
      name: 'checkout_noLocations',
      desc: '',
      args: [],
    );
  }

  /// `Complete Checkout`
  String get checkout_completeButton {
    return Intl.message(
      'Complete Checkout',
      name: 'checkout_completeButton',
      desc: '',
      args: [],
    );
  }

  /// `Order placed successfully!`
  String get checkout_successMessage {
    return Intl.message(
      'Order placed successfully!',
      name: 'checkout_successMessage',
      desc: '',
      args: [],
    );
  }

  /// `Checkout failed`
  String get checkout_errorMessage {
    return Intl.message(
      'Checkout failed',
      name: 'checkout_errorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get dishDetailAvailable {
    return Intl.message(
      'Available',
      name: 'dishDetailAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Unavailable`
  String get dishDetailUnavailable {
    return Intl.message(
      'Unavailable',
      name: 'dishDetailUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get dishDetail_categories {
    return Intl.message(
      'Categories',
      name: 'dishDetail_categories',
      desc: '',
      args: [],
    );
  }

  /// `Ingredients`
  String get dishDetail_ingredients {
    return Intl.message(
      'Ingredients',
      name: 'dishDetail_ingredients',
      desc: '',
      args: [],
    );
  }

  /// `No ingredients available`
  String get noIngredients {
    return Intl.message(
      'No ingredients available',
      name: 'noIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Base Price:`
  String get dishDetail_basePrice {
    return Intl.message(
      'Base Price:',
      name: 'dishDetail_basePrice',
      desc: '',
      args: [],
    );
  }

  /// `Dish Price:`
  String get dishDetail_totalPrice {
    return Intl.message(
      'Dish Price:',
      name: 'dishDetail_totalPrice',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get dishDetail_editButton {
    return Intl.message(
      'Edit',
      name: 'dishDetail_editButton',
      desc: '',
      args: [],
    );
  }

  /// `Edit Dish Categories`
  String get manageCategoriesEditTitle {
    return Intl.message(
      'Edit Dish Categories',
      name: 'manageCategoriesEditTitle',
      desc: '',
      args: [],
    );
  }

  /// `Manage Categories`
  String get manageCategoriesTitle {
    return Intl.message(
      'Manage Categories',
      name: 'manageCategoriesTitle',
      desc: '',
      args: [],
    );
  }

  /// `No categories for this dish`
  String get manageCategoriesEmptyEditing {
    return Intl.message(
      'No categories for this dish',
      name: 'manageCategoriesEmptyEditing',
      desc: '',
      args: [],
    );
  }

  /// `No categories added yet`
  String get manageCategoriesEmptyDefault {
    return Intl.message(
      'No categories added yet',
      name: 'manageCategoriesEmptyDefault',
      desc: '',
      args: [],
    );
  }

  /// `Add Category`
  String get manageCategoriesAddButton {
    return Intl.message(
      'Add Category',
      name: 'manageCategoriesAddButton',
      desc: '',
      args: [],
    );
  }

  /// `Finish Editing`
  String get manageCategoriesFinishEditing {
    return Intl.message(
      'Finish Editing',
      name: 'manageCategoriesFinishEditing',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get manageCategoriesSaveChanges {
    return Intl.message(
      'Save Changes',
      name: 'manageCategoriesSaveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Discard Changes`
  String get manageCategoriesDiscardChanges {
    return Intl.message(
      'Discard Changes',
      name: 'manageCategoriesDiscardChanges',
      desc: '',
      args: [],
    );
  }

  /// `Select Category`
  String get manageCategoriesSelectTitle {
    return Intl.message(
      'Select Category',
      name: 'manageCategoriesSelectTitle',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get manageCategoriesCancel {
    return Intl.message(
      'Cancel',
      name: 'manageCategoriesCancel',
      desc: '',
      args: [],
    );
  }

  /// `Edit Dish`
  String get dishForm_editTitle {
    return Intl.message(
      'Edit Dish',
      name: 'dishForm_editTitle',
      desc: '',
      args: [],
    );
  }

  /// `Create Dish`
  String get dishForm_createTitle {
    return Intl.message(
      'Create Dish',
      name: 'dishForm_createTitle',
      desc: '',
      args: [],
    );
  }

  /// `Dish Name`
  String get dishForm_nameLabel {
    return Intl.message(
      'Dish Name',
      name: 'dishForm_nameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter dish name`
  String get dishForm_nameHint {
    return Intl.message(
      'Enter dish name',
      name: 'dishForm_nameHint',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get dishForm_priceLabel {
    return Intl.message(
      'Price',
      name: 'dishForm_priceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter dish price`
  String get dishForm_priceHint {
    return Intl.message(
      'Enter dish price',
      name: 'dishForm_priceHint',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get dishForm_descriptionLabel {
    return Intl.message(
      'Description',
      name: 'dishForm_descriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter dish description`
  String get dishForm_descriptionHint {
    return Intl.message(
      'Enter dish description',
      name: 'dishForm_descriptionHint',
      desc: '',
      args: [],
    );
  }

  /// `Images`
  String get dishForm_imagesLabel {
    return Intl.message(
      'Images',
      name: 'dishForm_imagesLabel',
      desc: '',
      args: [],
    );
  }

  /// `Update Dish`
  String get dishForm_updateButton {
    return Intl.message(
      'Update Dish',
      name: 'dishForm_updateButton',
      desc: '',
      args: [],
    );
  }

  /// `Create Dish`
  String get dishForm_createButton {
    return Intl.message(
      'Create Dish',
      name: 'dishForm_createButton',
      desc: '',
      args: [],
    );
  }

  /// `Delete Image`
  String get dishForm_deleteImageTitle {
    return Intl.message(
      'Delete Image',
      name: 'dishForm_deleteImageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this image?`
  String get dishForm_deleteImageContent {
    return Intl.message(
      'Are you sure you want to delete this image?',
      name: 'dishForm_deleteImageContent',
      desc: '',
      args: [],
    );
  }

  /// `Required field`
  String get validationRequired {
    return Intl.message(
      'Required field',
      name: 'validationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Invalid price`
  String get validationInvalidPrice {
    return Intl.message(
      'Invalid price',
      name: 'validationInvalidPrice',
      desc: '',
      args: [],
    );
  }

  /// `Manage Dishes`
  String get dishManagement_title {
    return Intl.message(
      'Manage Dishes',
      name: 'dishManagement_title',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get dishManagement_retry {
    return Intl.message(
      'Retry',
      name: 'dishManagement_retry',
      desc: '',
      args: [],
    );
  }

  /// `No dishes found`
  String get dishManagement_empty {
    return Intl.message(
      'No dishes found',
      name: 'dishManagement_empty',
      desc: '',
      args: [],
    );
  }

  /// `Delete Dish`
  String get dishManagement_deleteTitle {
    return Intl.message(
      'Delete Dish',
      name: 'dishManagement_deleteTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this dish?`
  String get dishManagement_deleteContent {
    return Intl.message(
      'Are you sure you want to delete this dish?',
      name: 'dishManagement_deleteContent',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get dishManagement_deleteCancel {
    return Intl.message(
      'Cancel',
      name: 'dishManagement_deleteCancel',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get dishManagement_deleteConfirm {
    return Intl.message(
      'Delete',
      name: 'dishManagement_deleteConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Activate`
  String get dishManagement_activate {
    return Intl.message(
      'Activate',
      name: 'dishManagement_activate',
      desc: '',
      args: [],
    );
  }

  /// `Deactivate`
  String get dishManagement_deactivate {
    return Intl.message(
      'Deactivate',
      name: 'dishManagement_deactivate',
      desc: '',
      args: [],
    );
  }

  /// `Inactive`
  String get dishManagement_inactive {
    return Intl.message(
      'Inactive',
      name: 'dishManagement_inactive',
      desc: '',
      args: [],
    );
  }

  /// `Dish activated`
  String get dishManagement_dishActivated {
    return Intl.message(
      'Dish activated',
      name: 'dishManagement_dishActivated',
      desc: '',
      args: [],
    );
  }

  /// `Dish deactivated`
  String get dishManagement_dishDeactivated {
    return Intl.message(
      'Dish deactivated',
      name: 'dishManagement_dishDeactivated',
      desc: '',
      args: [],
    );
  }

  /// `Add Address`
  String get addressFormAddTitle {
    return Intl.message(
      'Add Address',
      name: 'addressFormAddTitle',
      desc: '',
      args: [],
    );
  }

  /// `Edit Address`
  String get addressFormEditTitle {
    return Intl.message(
      'Edit Address',
      name: 'addressFormEditTitle',
      desc: '',
      args: [],
    );
  }

  /// `Street Address`
  String get addressFormStreetLabel {
    return Intl.message(
      'Street Address',
      name: 'addressFormStreetLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter street address`
  String get addressFormStreetHint {
    return Intl.message(
      'Enter street address',
      name: 'addressFormStreetHint',
      desc: '',
      args: [],
    );
  }

  /// `Select Location on Map`
  String get addressFormMapTitle {
    return Intl.message(
      'Select Location on Map',
      name: 'addressFormMapTitle',
      desc: '',
      args: [],
    );
  }

  /// `Use Current Location`
  String get addressFormCurrentLocationButton {
    return Intl.message(
      'Use Current Location',
      name: 'addressFormCurrentLocationButton',
      desc: '',
      args: [],
    );
  }

  /// `Processing...`
  String get addressFormProcessing {
    return Intl.message(
      'Processing...',
      name: 'addressFormProcessing',
      desc: '',
      args: [],
    );
  }

  /// `Save Address`
  String get addressFormSaveButton {
    return Intl.message(
      'Save Address',
      name: 'addressFormSaveButton',
      desc: '',
      args: [],
    );
  }

  /// `Update Address`
  String get addressFormUpdateButton {
    return Intl.message(
      'Update Address',
      name: 'addressFormUpdateButton',
      desc: '',
      args: [],
    );
  }

  /// `Recipes`
  String get foodStoreTabRecipes {
    return Intl.message(
      'Recipes',
      name: 'foodStoreTabRecipes',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get foodStoreTabAbout {
    return Intl.message('About', name: 'foodStoreTabAbout', desc: '', args: []);
  }

  /// `Gallery`
  String get foodStoreTabGallery {
    return Intl.message(
      'Gallery',
      name: 'foodStoreTabGallery',
      desc: '',
      args: [],
    );
  }

  /// `About Us`
  String get foodStoreAboutUs {
    return Intl.message(
      'About Us',
      name: 'foodStoreAboutUs',
      desc: '',
      args: [],
    );
  }

  /// `Store Information`
  String get foodStoreStoreInfo {
    return Intl.message(
      'Store Information',
      name: 'foodStoreStoreInfo',
      desc: '',
      args: [],
    );
  }

  /// `Recipes`
  String get foodStoreRecipesCount {
    return Intl.message(
      'Recipes',
      name: 'foodStoreRecipesCount',
      desc: '',
      args: [],
    );
  }

  /// `No images available`
  String get foodStoreNoImages {
    return Intl.message(
      'No images available',
      name: 'foodStoreNoImages',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get foodStoreCategoryAll {
    return Intl.message(
      'All',
      name: 'foodStoreCategoryAll',
      desc: '',
      args: [],
    );
  }

  /// `Breakfast`
  String get foodStoreCategoryBreakfast {
    return Intl.message(
      'Breakfast',
      name: 'foodStoreCategoryBreakfast',
      desc: '',
      args: [],
    );
  }

  /// `Dessert`
  String get foodStoreCategoryDessert {
    return Intl.message(
      'Dessert',
      name: 'foodStoreCategoryDessert',
      desc: '',
      args: [],
    );
  }

  /// `Lunch`
  String get foodStoreCategoryLunch {
    return Intl.message(
      'Lunch',
      name: 'foodStoreCategoryLunch',
      desc: '',
      args: [],
    );
  }

  /// `Address not found. Please try a different one.`
  String get foodStoreMap_addressNotFound {
    return Intl.message(
      'Address not found. Please try a different one.',
      name: 'foodStoreMap_addressNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Search by address...`
  String get foodStoreMap_searchHint {
    return Intl.message(
      'Search by address...',
      name: 'foodStoreMap_searchHint',
      desc: '',
      args: [],
    );
  }

  /// `Nearby Food Stores`
  String get foodStoreMap_title {
    return Intl.message(
      'Nearby Food Stores',
      name: 'foodStoreMap_title',
      desc: '',
      args: [],
    );
  }

  /// `A map error occurred. Please check your connection and try again.`
  String get foodStoreMap_geocodingError {
    return Intl.message(
      'A map error occurred. Please check your connection and try again.',
      name: 'foodStoreMap_geocodingError',
      desc: '',
      args: [],
    );
  }

  /// `Location services are disabled`
  String get foodStoreMap_locationDisabled {
    return Intl.message(
      'Location services are disabled',
      name: 'foodStoreMap_locationDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Location permissions are denied`
  String get foodStoreMap_permissionDenied {
    return Intl.message(
      'Location permissions are denied',
      name: 'foodStoreMap_permissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Location permissions are permanently denied`
  String get foodStoreMap_permissionDeniedPermanently {
    return Intl.message(
      'Location permissions are permanently denied',
      name: 'foodStoreMap_permissionDeniedPermanently',
      desc: '',
      args: [],
    );
  }

  /// `No recipes found`
  String get foodStoreMap_noRecipes {
    return Intl.message(
      'No recipes found',
      name: 'foodStoreMap_noRecipes',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred`
  String get foodStoreMap_genericError {
    return Intl.message(
      'An error occurred',
      name: 'foodStoreMap_genericError',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get foodStoreMap_retry {
    return Intl.message(
      'Retry',
      name: 'foodStoreMap_retry',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get home_categories {
    return Intl.message(
      'Categories',
      name: 'home_categories',
      desc: '',
      args: [],
    );
  }

  /// `No categories found`
  String get home_noCategories {
    return Intl.message(
      'No categories found',
      name: 'home_noCategories',
      desc: '',
      args: [],
    );
  }

  /// `Popular Recipes`
  String get home_popularRecipes {
    return Intl.message(
      'Popular Recipes',
      name: 'home_popularRecipes',
      desc: '',
      args: [],
    );
  }

  /// `See All`
  String get home_seeAll {
    return Intl.message('See All', name: 'home_seeAll', desc: '', args: []);
  }

  /// `Popular Chefs`
  String get home_popularChefs {
    return Intl.message(
      'Popular Chefs',
      name: 'home_popularChefs',
      desc: '',
      args: [],
    );
  }

  /// `No recipes found`
  String get home_noRecipes {
    return Intl.message(
      'No recipes found',
      name: 'home_noRecipes',
      desc: '',
      args: [],
    );
  }

  /// `All Recipes`
  String get home_allRecipes {
    return Intl.message(
      'All Recipes',
      name: 'home_allRecipes',
      desc: '',
      args: [],
    );
  }

  /// `Recipes`
  String get home_selectedRecipes {
    return Intl.message(
      'Recipes',
      name: 'home_selectedRecipes',
      desc: '',
      args: [],
    );
  }

  /// `Choose your language:`
  String get languageSelection_title {
    return Intl.message(
      'Choose your language:',
      name: 'languageSelection_title',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get languageSelection_english {
    return Intl.message(
      'English',
      name: 'languageSelection_english',
      desc: '',
      args: [],
    );
  }

  /// `French`
  String get languageSelection_french {
    return Intl.message(
      'French',
      name: 'languageSelection_french',
      desc: '',
      args: [],
    );
  }

  /// `Edit Dish Ingredients`
  String get manageIngredientsEditTitle {
    return Intl.message(
      'Edit Dish Ingredients',
      name: 'manageIngredientsEditTitle',
      desc: '',
      args: [],
    );
  }

  /// `Manage Ingredients`
  String get manageIngredientsTitle {
    return Intl.message(
      'Manage Ingredients',
      name: 'manageIngredientsTitle',
      desc: '',
      args: [],
    );
  }

  /// `No ingredients in this dish`
  String get manageIngredientsEmptyEditing {
    return Intl.message(
      'No ingredients in this dish',
      name: 'manageIngredientsEmptyEditing',
      desc: '',
      args: [],
    );
  }

  /// `No ingredients added yet`
  String get manageIngredientsEmptyDefault {
    return Intl.message(
      'No ingredients added yet',
      name: 'manageIngredientsEmptyDefault',
      desc: '',
      args: [],
    );
  }

  /// `Add Ingredient`
  String get manageIngredientsAddButton {
    return Intl.message(
      'Add Ingredient',
      name: 'manageIngredientsAddButton',
      desc: '',
      args: [],
    );
  }

  /// `Finish Editing`
  String get manageIngredientsFinishEditing {
    return Intl.message(
      'Finish Editing',
      name: 'manageIngredientsFinishEditing',
      desc: '',
      args: [],
    );
  }

  /// `Price:`
  String get manageIngredientsPrice {
    return Intl.message(
      'Price:',
      name: 'manageIngredientsPrice',
      desc: '',
      args: [],
    );
  }

  /// `Type:`
  String get manageIngredientsType {
    return Intl.message(
      'Type:',
      name: 'manageIngredientsType',
      desc: '',
      args: [],
    );
  }

  /// `Supplement`
  String get manageIngredientsSupplement {
    return Intl.message(
      'Supplement',
      name: 'manageIngredientsSupplement',
      desc: '',
      args: [],
    );
  }

  /// `Standard`
  String get manageIngredientsStandard {
    return Intl.message(
      'Standard',
      name: 'manageIngredientsStandard',
      desc: '',
      args: [],
    );
  }

  /// `Select Ingredient`
  String get manageIngredientsSelectTitle {
    return Intl.message(
      'Select Ingredient',
      name: 'manageIngredientsSelectTitle',
      desc: '',
      args: [],
    );
  }

  /// `Search Ingredients`
  String get manageIngredientsSearchHint {
    return Intl.message(
      'Search Ingredients',
      name: 'manageIngredientsSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `No ingredients found`
  String get manageIngredientsSearchEmpty {
    return Intl.message(
      'No ingredients found',
      name: 'manageIngredientsSearchEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Edit Ingredient`
  String get manageIngredientsEditDialogEdit {
    return Intl.message(
      'Edit Ingredient',
      name: 'manageIngredientsEditDialogEdit',
      desc: '',
      args: [],
    );
  }

  /// `Add Ingredient`
  String get manageIngredientsEditDialogAdd {
    return Intl.message(
      'Add Ingredient',
      name: 'manageIngredientsEditDialogAdd',
      desc: '',
      args: [],
    );
  }

  /// `Ingredient`
  String get manageIngredientsEditDialogIngredient {
    return Intl.message(
      'Ingredient',
      name: 'manageIngredientsEditDialogIngredient',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get manageIngredientsEditDialogPrice {
    return Intl.message(
      'Price',
      name: 'manageIngredientsEditDialogPrice',
      desc: '',
      args: [],
    );
  }

  /// `Is Supplement`
  String get manageIngredientsEditDialogSupplement {
    return Intl.message(
      'Is Supplement',
      name: 'manageIngredientsEditDialogSupplement',
      desc: '',
      args: [],
    );
  }

  /// `Discover Delicious Homemade Meals`
  String get onboarding_slide1Title {
    return Intl.message(
      'Discover Delicious Homemade Meals',
      name: 'onboarding_slide1Title',
      desc: '',
      args: [],
    );
  }

  /// `Get meals that are made with care, fresh ingredients, and a personal touch from local chefs near you.`
  String get onboarding_slide1Text {
    return Intl.message(
      'Get meals that are made with care, fresh ingredients, and a personal touch from local chefs near you.',
      name: 'onboarding_slide1Text',
      desc: '',
      args: [],
    );
  }

  /// `Connect with Passionate Chefs`
  String get onboarding_slide2Title {
    return Intl.message(
      'Connect with Passionate Chefs',
      name: 'onboarding_slide2Title',
      desc: '',
      args: [],
    );
  }

  /// `From traditional recipes to unique creations, find chefs who cater to your culinary cravings.`
  String get onboarding_slide2Text {
    return Intl.message(
      'From traditional recipes to unique creations, find chefs who cater to your culinary cravings.',
      name: 'onboarding_slide2Text',
      desc: '',
      args: [],
    );
  }

  /// `Order Easily, Delivered Fresh`
  String get onboarding_slide3Title {
    return Intl.message(
      'Order Easily, Delivered Fresh',
      name: 'onboarding_slide3Title',
      desc: '',
      args: [],
    );
  }

  /// `Your favorite homemade meals, just a few taps away. Let's bring local cooking to your table.`
  String get onboarding_slide3Text {
    return Intl.message(
      'Your favorite homemade meals, just a few taps away. Let\'s bring local cooking to your table.',
      name: 'onboarding_slide3Text',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get onboarding_back {
    return Intl.message('Back', name: 'onboarding_back', desc: '', args: []);
  }

  /// `Next`
  String get onboarding_next {
    return Intl.message('Next', name: 'onboarding_next', desc: '', args: []);
  }

  /// `Get Started`
  String get onboarding_getStarted {
    return Intl.message(
      'Get Started',
      name: 'onboarding_getStarted',
      desc: '',
      args: [],
    );
  }

  /// `Payment Info`
  String get paymentInfo_title {
    return Intl.message(
      'Payment Info',
      name: 'paymentInfo_title',
      desc: '',
      args: [],
    );
  }

  /// `No payment cards found`
  String get paymentInfo_empty {
    return Intl.message(
      'No payment cards found',
      name: 'paymentInfo_empty',
      desc: '',
      args: [],
    );
  }

  /// `Expires:`
  String get paymentInfo_expires {
    return Intl.message(
      'Expires:',
      name: 'paymentInfo_expires',
      desc: '',
      args: [],
    );
  }

  /// `Default Payment Card`
  String get paymentInfo_default {
    return Intl.message(
      'Default Payment Card',
      name: 'paymentInfo_default',
      desc: '',
      args: [],
    );
  }

  /// `Add to Cart -`
  String get recipe_addToCart {
    return Intl.message(
      'Add to Cart -',
      name: 'recipe_addToCart',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get recipe_categories {
    return Intl.message(
      'Categories',
      name: 'recipe_categories',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get recipe_description {
    return Intl.message(
      'Description',
      name: 'recipe_description',
      desc: '',
      args: [],
    );
  }

  /// `No Description Available`
  String get recipe_noDescription {
    return Intl.message(
      'No Description Available',
      name: 'recipe_noDescription',
      desc: '',
      args: [],
    );
  }

  /// `Ingredients`
  String get recipe_ingredients {
    return Intl.message(
      'Ingredients',
      name: 'recipe_ingredients',
      desc: '',
      args: [],
    );
  }

  /// `Reviews`
  String get recipe_reviews {
    return Intl.message('Reviews', name: 'recipe_reviews', desc: '', args: []);
  }

  /// `No recipes found`
  String get recipe_empty {
    return Intl.message(
      'No recipes found',
      name: 'recipe_empty',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get recipe_gallery {
    return Intl.message('Gallery', name: 'recipe_gallery', desc: '', args: []);
  }

  /// `Reviews`
  String get dishDetail_reviews {
    return Intl.message(
      'Reviews',
      name: 'dishDetail_reviews',
      desc: '',
      args: [],
    );
  }

  /// `No reviews yet. Be the first to review!`
  String get recipe_noReviews {
    return Intl.message(
      'No reviews yet. Be the first to review!',
      name: 'recipe_noReviews',
      desc: '',
      args: [],
    );
  }

  /// `Vendor`
  String get recipe_vendor {
    return Intl.message('Vendor', name: 'recipe_vendor', desc: '', args: []);
  }

  /// `Write a Review`
  String get recipe_writeReview {
    return Intl.message(
      'Write a Review',
      name: 'recipe_writeReview',
      desc: '',
      args: [],
    );
  }

  /// `Your review`
  String get recipe_yourReview {
    return Intl.message(
      'Your review',
      name: 'recipe_yourReview',
      desc: '',
      args: [],
    );
  }

  /// `Share your experience...`
  String get recipe_shareExperience {
    return Intl.message(
      'Share your experience...',
      name: 'recipe_shareExperience',
      desc: '',
      args: [],
    );
  }

  /// `Please write a review`
  String get recipe_reviewRequired {
    return Intl.message(
      'Please write a review',
      name: 'recipe_reviewRequired',
      desc: '',
      args: [],
    );
  }

  /// `Submit Review`
  String get recipe_submitReview {
    return Intl.message(
      'Submit Review',
      name: 'recipe_submitReview',
      desc: '',
      args: [],
    );
  }

  /// `Rating:`
  String get recipe_rating {
    return Intl.message('Rating:', name: 'recipe_rating', desc: '', args: []);
  }

  /// `Review submitted successfully!`
  String get recipe_reviewSuccess {
    return Intl.message(
      'Review submitted successfully!',
      name: 'recipe_reviewSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Please select a rating`
  String get recipe_ratingRequired {
    return Intl.message(
      'Please select a rating',
      name: 'recipe_ratingRequired',
      desc: '',
      args: [],
    );
  }

  /// `Added to Cart -`
  String get recipe_addedToCart {
    return Intl.message(
      'Added to Cart -',
      name: 'recipe_addedToCart',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add to cart`
  String get failedToAddToCart {
    return Intl.message(
      'Failed to add to cart',
      name: 'failedToAddToCart',
      desc: '',
      args: [],
    );
  }

  /// `VOS VOISINS, VOS CHEFS`
  String get register_slogan {
    return Intl.message(
      'VOS VOISINS, VOS CHEFS',
      name: 'register_slogan',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get register_firstNameLabel {
    return Intl.message(
      'First Name',
      name: 'register_firstNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `John`
  String get register_firstNameHint {
    return Intl.message(
      'John',
      name: 'register_firstNameHint',
      desc: '',
      args: [],
    );
  }

  /// `First name is required`
  String get register_validationFirstNameRequired {
    return Intl.message(
      'First name is required',
      name: 'register_validationFirstNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Last Name`
  String get register_lastNameLabel {
    return Intl.message(
      'Last Name',
      name: 'register_lastNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Doe`
  String get register_lastNameHint {
    return Intl.message(
      'Doe',
      name: 'register_lastNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Last name is required`
  String get register_validationLastNameRequired {
    return Intl.message(
      'Last name is required',
      name: 'register_validationLastNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Email :`
  String get register_emailLabel {
    return Intl.message(
      'Email :',
      name: 'register_emailLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email`
  String get register_emailHint {
    return Intl.message(
      'Enter your email',
      name: 'register_emailHint',
      desc: '',
      args: [],
    );
  }

  /// `Email is required`
  String get register_validationEmailRequired {
    return Intl.message(
      'Email is required',
      name: 'register_validationEmailRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid email address`
  String get register_validationEmailInvalid {
    return Intl.message(
      'Enter a valid email address',
      name: 'register_validationEmailInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Password :`
  String get register_passwordLabel {
    return Intl.message(
      'Password :',
      name: 'register_passwordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password`
  String get register_passwordHint {
    return Intl.message(
      'Enter your password',
      name: 'register_passwordHint',
      desc: '',
      args: [],
    );
  }

  /// `Password cannot be empty`
  String get register_validationPasswordRequired {
    return Intl.message(
      'Password cannot be empty',
      name: 'register_validationPasswordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 8 characters long`
  String get register_validationPasswordLength {
    return Intl.message(
      'Password must be at least 8 characters long',
      name: 'register_validationPasswordLength',
      desc: '',
      args: [],
    );
  }

  /// `Password must contain at least one uppercase letter`
  String get register_validationPasswordUppercase {
    return Intl.message(
      'Password must contain at least one uppercase letter',
      name: 'register_validationPasswordUppercase',
      desc: '',
      args: [],
    );
  }

  /// `Password must contain at least one number`
  String get register_validationPasswordNumber {
    return Intl.message(
      'Password must contain at least one number',
      name: 'register_validationPasswordNumber',
      desc: '',
      args: [],
    );
  }

  /// `Password must contain at least one special character`
  String get register_validationPasswordSpecial {
    return Intl.message(
      'Password must contain at least one special character',
      name: 'register_validationPasswordSpecial',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register_button {
    return Intl.message(
      'Register',
      name: 'register_button',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? Login`
  String get register_loginPrompt {
    return Intl.message(
      'Already have an account? Login',
      name: 'register_loginPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Google`
  String get register_googleButton {
    return Intl.message(
      'Sign in with Google',
      name: 'register_googleButton',
      desc: '',
      args: [],
    );
  }

  /// `Seller Orders`
  String get sellerOrderManagement_title {
    return Intl.message(
      'Seller Orders',
      name: 'sellerOrderManagement_title',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get sellerOrderManagement_retry {
    return Intl.message(
      'Retry',
      name: 'sellerOrderManagement_retry',
      desc: '',
      args: [],
    );
  }

  /// `No orders found`
  String get sellerOrderManagement_empty {
    return Intl.message(
      'No orders found',
      name: 'sellerOrderManagement_empty',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get sellerOrderManagement_cancel {
    return Intl.message(
      'Cancel',
      name: 'sellerOrderManagement_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Order number, buyer name...`
  String get sellerOrderManagement_searchHint {
    return Intl.message(
      'Order number, buyer name...',
      name: 'sellerOrderManagement_searchHint',
      desc: '',
      args: [],
    );
  }

  /// `Order Details`
  String get sellerOrderManagement_orderDetailsTitle {
    return Intl.message(
      'Order Details',
      name: 'sellerOrderManagement_orderDetailsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Order #:`
  String get sellerOrderManagement_orderNumber {
    return Intl.message(
      'Order #:',
      name: 'sellerOrderManagement_orderNumber',
      desc: '',
      args: [],
    );
  }

  /// `Date:`
  String get sellerOrderManagement_date {
    return Intl.message(
      'Date:',
      name: 'sellerOrderManagement_date',
      desc: '',
      args: [],
    );
  }

  /// `CUSTOMER`
  String get sellerOrderManagement_sectionCustomer {
    return Intl.message(
      'CUSTOMER',
      name: 'sellerOrderManagement_sectionCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Name:`
  String get sellerOrderManagement_labelName {
    return Intl.message(
      'Name:',
      name: 'sellerOrderManagement_labelName',
      desc: '',
      args: [],
    );
  }

  /// `Email:`
  String get sellerOrderManagement_labelEmail {
    return Intl.message(
      'Email:',
      name: 'sellerOrderManagement_labelEmail',
      desc: '',
      args: [],
    );
  }

  /// `Phone:`
  String get sellerOrderManagement_labelPhone {
    return Intl.message(
      'Phone:',
      name: 'sellerOrderManagement_labelPhone',
      desc: '',
      args: [],
    );
  }

  /// `DELIVERY TO`
  String get sellerOrderManagement_sectionDeliveryTo {
    return Intl.message(
      'DELIVERY TO',
      name: 'sellerOrderManagement_sectionDeliveryTo',
      desc: '',
      args: [],
    );
  }

  /// `ORDER NOTES`
  String get sellerOrderManagement_sectionOrderNotes {
    return Intl.message(
      'ORDER NOTES',
      name: 'sellerOrderManagement_sectionOrderNotes',
      desc: '',
      args: [],
    );
  }

  /// `ITEMS`
  String get sellerOrderManagement_sectionItems {
    return Intl.message(
      'ITEMS',
      name: 'sellerOrderManagement_sectionItems',
      desc: '',
      args: [],
    );
  }

  /// `TOTAL`
  String get sellerOrderManagement_sectionTotal {
    return Intl.message(
      'TOTAL',
      name: 'sellerOrderManagement_sectionTotal',
      desc: '',
      args: [],
    );
  }

  /// `Subtotal:`
  String get sellerOrderManagement_labelSubtotal {
    return Intl.message(
      'Subtotal:',
      name: 'sellerOrderManagement_labelSubtotal',
      desc: '',
      args: [],
    );
  }

  /// `Tip Amount:`
  String get sellerOrderManagement_labelTipAmount {
    return Intl.message(
      'Tip Amount:',
      name: 'sellerOrderManagement_labelTipAmount',
      desc: '',
      args: [],
    );
  }

  /// `TOTAL PAID`
  String get sellerOrderManagement_totalPaid {
    return Intl.message(
      'TOTAL PAID',
      name: 'sellerOrderManagement_totalPaid',
      desc: '',
      args: [],
    );
  }

  /// `PAYMENT DETAILS`
  String get sellerOrderManagement_sectionPaymentDetails {
    return Intl.message(
      'PAYMENT DETAILS',
      name: 'sellerOrderManagement_sectionPaymentDetails',
      desc: '',
      args: [],
    );
  }

  /// `Payment Status:`
  String get sellerOrderManagement_labelPaymentStatus {
    return Intl.message(
      'Payment Status:',
      name: 'sellerOrderManagement_labelPaymentStatus',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Status:`
  String get sellerOrderManagement_labelDeliveryStatus {
    return Intl.message(
      'Delivery Status:',
      name: 'sellerOrderManagement_labelDeliveryStatus',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation Code:`
  String get sellerOrderManagement_labelConfirmationCode {
    return Intl.message(
      'Confirmation Code:',
      name: 'sellerOrderManagement_labelConfirmationCode',
      desc: '',
      args: [],
    );
  }

  /// `FROM`
  String get sellerOrderManagement_orderFrom {
    return Intl.message(
      'FROM',
      name: 'sellerOrderManagement_orderFrom',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for your order!`
  String get sellerOrderManagement_thankYou {
    return Intl.message(
      'Thank you for your order!',
      name: 'sellerOrderManagement_thankYou',
      desc: '',
      args: [],
    );
  }

  /// `Receipt not found`
  String get sellerOrderManagement_notFound {
    return Intl.message(
      'Receipt not found',
      name: 'sellerOrderManagement_notFound',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Order`
  String get sellerOrderManagement_cancelOrder {
    return Intl.message(
      'Cancel Order',
      name: 'sellerOrderManagement_cancelOrder',
      desc: '',
      args: [],
    );
  }

  /// `Buyer:`
  String get sellerOrderManagement_itemBuyer {
    return Intl.message(
      'Buyer:',
      name: 'sellerOrderManagement_itemBuyer',
      desc: '',
      args: [],
    );
  }

  /// `Total:`
  String get sellerOrderManagement_itemTotal {
    return Intl.message(
      'Total:',
      name: 'sellerOrderManagement_itemTotal',
      desc: '',
      args: [],
    );
  }

  /// `Placed:`
  String get sellerOrderManagement_itemPlaced {
    return Intl.message(
      'Placed:',
      name: 'sellerOrderManagement_itemPlaced',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Order`
  String get confirmOrderButton {
    return Intl.message(
      'Confirm Order',
      name: 'confirmOrderButton',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Delivery`
  String get confirmDeliveryButton {
    return Intl.message(
      'Confirm Delivery',
      name: 'confirmDeliveryButton',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation Code`
  String get orderConfirmationCode {
    return Intl.message(
      'Confirmation Code',
      name: 'orderConfirmationCode',
      desc: '',
      args: [],
    );
  }

  /// `Filter & Sort`
  String get sellerOrderManagement_filter {
    return Intl.message(
      'Filter & Sort',
      name: 'sellerOrderManagement_filter',
      desc: '',
      args: [],
    );
  }

  /// `Enter code provided by buyer`
  String get confirmationCodeHint {
    return Intl.message(
      'Enter code provided by buyer',
      name: 'confirmationCodeHint',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Payment Info`
  String get paymentInfo {
    return Intl.message(
      'Payment Info',
      name: 'paymentInfo',
      desc: '',
      args: [],
    );
  }

  /// `Store`
  String get store {
    return Intl.message('Store', name: 'store', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Rate App`
  String get rateApp {
    return Intl.message('Rate App', name: 'rateApp', desc: '', args: []);
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Terms and Conditions`
  String get termsAndConditions {
    return Intl.message(
      'Terms and Conditions',
      name: 'termsAndConditions',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get logout {
    return Intl.message('Log out', name: 'logout', desc: '', args: []);
  }

  /// `No name`
  String get settings_noName {
    return Intl.message('No name', name: 'settings_noName', desc: '', args: []);
  }

  /// `No name`
  String get noName {
    return Intl.message('No name', name: 'noName', desc: '', args: []);
  }

  /// `Create Store`
  String get createStore {
    return Intl.message(
      'Create Store',
      name: 'createStore',
      desc: '',
      args: [],
    );
  }

  /// `Edit Store`
  String get editStore {
    return Intl.message('Edit Store', name: 'editStore', desc: '', args: []);
  }

  /// `Update Store`
  String get updateStore {
    return Intl.message(
      'Update Store',
      name: 'updateStore',
      desc: '',
      args: [],
    );
  }

  /// `Upload Image`
  String get uploadImage {
    return Intl.message(
      'Upload Image',
      name: 'uploadImage',
      desc: '',
      args: [],
    );
  }

  /// `Change Image`
  String get changeImage {
    return Intl.message(
      'Change Image',
      name: 'changeImage',
      desc: '',
      args: [],
    );
  }

  /// `Enter your store's name`
  String get storeNameHint {
    return Intl.message(
      'Enter your store\'s name',
      name: 'storeNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Store Name`
  String get storeNameLabel {
    return Intl.message(
      'Store Name',
      name: 'storeNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Describe your store`
  String get storeBioHint {
    return Intl.message(
      'Describe your store',
      name: 'storeBioHint',
      desc: '',
      args: [],
    );
  }

  /// `Store Bio / Description`
  String get storeBioLabel {
    return Intl.message(
      'Store Bio / Description',
      name: 'storeBioLabel',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get requiredField {
    return Intl.message(
      'This field is required',
      name: 'requiredField',
      desc: '',
      args: [],
    );
  }

  /// `Store Location`
  String get storeLocation {
    return Intl.message(
      'Store Location',
      name: 'storeLocation',
      desc: '',
      args: [],
    );
  }

  /// `No location set. Please select a location`
  String get noLocationWarning {
    return Intl.message(
      'No location set. Please select a location',
      name: 'noLocationWarning',
      desc: '',
      args: [],
    );
  }

  /// `Use Current Location`
  String get useCurrentLocation {
    return Intl.message(
      'Use Current Location',
      name: 'useCurrentLocation',
      desc: '',
      args: [],
    );
  }

  /// `Location services are disabled`
  String get locationServicesDisabled {
    return Intl.message(
      'Location services are disabled',
      name: 'locationServicesDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Location permissions are denied`
  String get locationPermissionsDenied {
    return Intl.message(
      'Location permissions are denied',
      name: 'locationPermissionsDenied',
      desc: '',
      args: [],
    );
  }

  /// `Location permissions are permanently denied`
  String get locationPermissionsDeniedForever {
    return Intl.message(
      'Location permissions are permanently denied',
      name: 'locationPermissionsDeniedForever',
      desc: '',
      args: [],
    );
  }

  /// `Location error`
  String get locationError {
    return Intl.message(
      'Location error',
      name: 'locationError',
      desc: '',
      args: [],
    );
  }

  /// `Please select a location on the map.`
  String get pleaseSelectLocation {
    return Intl.message(
      'Please select a location on the map.',
      name: 'pleaseSelectLocation',
      desc: '',
      args: [],
    );
  }

  /// `Operation Failed`
  String get operationFailed {
    return Intl.message(
      'Operation Failed',
      name: 'operationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Location is not valid, latitude or longitude are needed to update store`
  String get invalidLocation {
    return Intl.message(
      'Location is not valid, latitude or longitude are needed to update store',
      name: 'invalidLocation',
      desc: '',
      args: [],
    );
  }

  /// `My Store`
  String get storeHome_title {
    return Intl.message(
      'My Store',
      name: 'storeHome_title',
      desc: '',
      args: [],
    );
  }

  /// `No store found. Create one!`
  String get storeHome_noStoreFound {
    return Intl.message(
      'No store found. Create one!',
      name: 'storeHome_noStoreFound',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load store. Please retry.`
  String get storeHome_errorLoadingStore {
    return Intl.message(
      'Failed to load store. Please retry.',
      name: 'storeHome_errorLoadingStore',
      desc: '',
      args: [],
    );
  }

  /// `Create Store`
  String get storeHome_createStore {
    return Intl.message(
      'Create Store',
      name: 'storeHome_createStore',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get storeHome_retry {
    return Intl.message('Retry', name: 'storeHome_retry', desc: '', args: []);
  }

  /// `Loading store information...`
  String get storeHome_loadingStoreInformation {
    return Intl.message(
      'Loading store information...',
      name: 'storeHome_loadingStoreInformation',
      desc: '',
      args: [],
    );
  }

  /// `My Store`
  String get myStore {
    return Intl.message('My Store', name: 'myStore', desc: '', args: []);
  }

  /// `No store found. Create one!`
  String get noStoreFound {
    return Intl.message(
      'No store found. Create one!',
      name: 'noStoreFound',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load store. Please retry.`
  String get errorLoadingStore {
    return Intl.message(
      'Failed to load store. Please retry.',
      name: 'errorLoadingStore',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load store. Please retry.`
  String get storeProfile_errorLoadingStore {
    return Intl.message(
      'Failed to load store. Please retry.',
      name: 'storeProfile_errorLoadingStore',
      desc: '',
      args: [],
    );
  }

  /// `Store Name`
  String get storeProfile_storeName {
    return Intl.message(
      'Store Name',
      name: 'storeProfile_storeName',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get storeProfile_description {
    return Intl.message(
      'Description',
      name: 'storeProfile_description',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get storeProfile_address {
    return Intl.message(
      'Address',
      name: 'storeProfile_address',
      desc: '',
      args: [],
    );
  }

  /// `Coordinates: {latitude}, {longitude}`
  String storeProfile_coordinates(String latitude, String longitude) {
    return Intl.message(
      'Coordinates: $latitude, $longitude',
      name: 'storeProfile_coordinates',
      desc: '',
      args: [latitude, longitude],
    );
  }

  /// `Edit Store`
  String get storeProfile_editStore {
    return Intl.message(
      'Edit Store',
      name: 'storeProfile_editStore',
      desc: '',
      args: [],
    );
  }

  /// `Delete Store`
  String get storeProfile_deleteStore {
    return Intl.message(
      'Delete Store',
      name: 'storeProfile_deleteStore',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your store? and log out`
  String get storeProfile_deleteStoreContent {
    return Intl.message(
      'Are you sure you want to delete your store? and log out',
      name: 'storeProfile_deleteStoreContent',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get storeProfile_cancel {
    return Intl.message(
      'Cancel',
      name: 'storeProfile_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Store Name`
  String get storeName {
    return Intl.message('Store Name', name: 'storeName', desc: '', args: []);
  }

  /// `Description`
  String get description {
    return Intl.message('Description', name: 'description', desc: '', args: []);
  }

  /// `Address`
  String get address {
    return Intl.message('Address', name: 'address', desc: '', args: []);
  }

  /// `Coordinates: {latitude}, {longitude}`
  String coordinates(String latitude, String longitude) {
    return Intl.message(
      'Coordinates: $latitude, $longitude',
      name: 'coordinates',
      desc: '',
      args: [latitude, longitude],
    );
  }

  /// `Delete Store`
  String get deleteStore {
    return Intl.message(
      'Delete Store',
      name: 'deleteStore',
      desc: '',
      args: [],
    );
  }

  /// `Delete Store`
  String get deleteStoreTitle {
    return Intl.message(
      'Delete Store',
      name: 'deleteStoreTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your store? and log out`
  String get deleteStoreContent {
    return Intl.message(
      'Are you sure you want to delete your store? and log out',
      name: 'deleteStoreContent',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Edit Profile`
  String get edit_profile {
    return Intl.message(
      'Edit Profile',
      name: 'edit_profile',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get save {
    return Intl.message('Save Changes', name: 'save', desc: '', args: []);
  }

  /// `Profile`
  String get userInfo_profile {
    return Intl.message(
      'Profile',
      name: 'userInfo_profile',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get userInfo_editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'userInfo_editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get userInfo_username {
    return Intl.message(
      'Username',
      name: 'userInfo_username',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get userInfo_firstName {
    return Intl.message(
      'First Name',
      name: 'userInfo_firstName',
      desc: '',
      args: [],
    );
  }

  /// `Last Name`
  String get userInfo_lastName {
    return Intl.message(
      'Last Name',
      name: 'userInfo_lastName',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get userInfo_email {
    return Intl.message('Email', name: 'userInfo_email', desc: '', args: []);
  }

  /// `Bio`
  String get userInfo_bio {
    return Intl.message('Bio', name: 'userInfo_bio', desc: '', args: []);
  }

  /// `Save`
  String get userInfo_save {
    return Intl.message('Save', name: 'userInfo_save', desc: '', args: []);
  }

  /// `Cancel`
  String get userInfo_cancel {
    return Intl.message('Cancel', name: 'userInfo_cancel', desc: '', args: []);
  }

  /// `Error updating profile`
  String get userInfo_errorUpdatingProfile {
    return Intl.message(
      'Error updating profile',
      name: 'userInfo_errorUpdatingProfile',
      desc: '',
      args: [],
    );
  }

  /// `Profile updated successfully`
  String get userInfo_profileUpdatedSuccessfully {
    return Intl.message(
      'Profile updated successfully',
      name: 'userInfo_profileUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Phone number must be exactly 10 digits`
  String get userInfo_phoneNumberTooLong {
    return Intl.message(
      'Phone number must be exactly 10 digits',
      name: 'userInfo_phoneNumberTooLong',
      desc: '',
      args: [],
    );
  }

  /// `Verify your number in your profile`
  String get verifyYourNumberInProfile {
    return Intl.message(
      'Verify your number in your profile',
      name: 'verifyYourNumberInProfile',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `First Name`
  String get first_name {
    return Intl.message('First Name', name: 'first_name', desc: '', args: []);
  }

  /// `Last Name`
  String get last_name {
    return Intl.message('Last Name', name: 'last_name', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Refresh`
  String get refresh {
    return Intl.message('Refresh', name: 'refresh', desc: '', args: []);
  }

  /// `Error updating profile`
  String get error_updating_profile {
    return Intl.message(
      'Error updating profile',
      name: 'error_updating_profile',
      desc: '',
      args: [],
    );
  }

  /// `Profile updated successfully`
  String get profile_updated_successfully {
    return Intl.message(
      'Profile updated successfully',
      name: 'profile_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get settings_selectLanguage {
    return Intl.message(
      'Select Language',
      name: 'settings_selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get selectLanguage {
    return Intl.message(
      'Select Language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Français`
  String get french {
    return Intl.message('Français', name: 'french', desc: '', args: []);
  }

  /// `Language updated successfully`
  String get settings_languageUpdated {
    return Intl.message(
      'Language updated successfully',
      name: 'settings_languageUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Failed to change language`
  String get settings_languageChangeError {
    return Intl.message(
      'Failed to change language',
      name: 'settings_languageChangeError',
      desc: '',
      args: [],
    );
  }

  /// `Language updated successfully`
  String get languageUpdated {
    return Intl.message(
      'Language updated successfully',
      name: 'languageUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Failed to change language`
  String get languageChangeError {
    return Intl.message(
      'Failed to change language',
      name: 'languageChangeError',
      desc: '',
      args: [],
    );
  }

  /// `CUISINOUS – TERMS & CONDITIONS (MOBILE APP VERSION)`
  String get termsAndConditions_title {
    return Intl.message(
      'CUISINOUS – TERMS & CONDITIONS (MOBILE APP VERSION)',
      name: 'termsAndConditions_title',
      desc: '',
      args: [],
    );
  }

  /// `Last updated: 01-01-2026\n\nThese Terms and Conditions (“Terms”) govern your access to and use of the Cuisinous mobile application and related services (the “App”), operated by 9534-9072 Québec Inc., doing business as Cuisinous (“Cuisinous”, “we”, “us”, “our”).\n\nBy creating an account or using the App, you confirm that you have read, understood, and agree to these Terms. If you do not agree, do not use the App.`
  String get termsAndConditions_intro {
    return Intl.message(
      'Last updated: 01-01-2026\n\nThese Terms and Conditions (“Terms”) govern your access to and use of the Cuisinous mobile application and related services (the “App”), operated by 9534-9072 Québec Inc., doing business as Cuisinous (“Cuisinous”, “we”, “us”, “our”).\n\nBy creating an account or using the App, you confirm that you have read, understood, and agree to these Terms. If you do not agree, do not use the App.',
      name: 'termsAndConditions_intro',
      desc: '',
      args: [],
    );
  }

  /// `1. WHAT CUISINOUS IS`
  String get termsAndConditions_section1Title {
    return Intl.message(
      '1. WHAT CUISINOUS IS',
      name: 'termsAndConditions_section1Title',
      desc: '',
      args: [],
    );
  }

  /// `Cuisinous is a technology marketplace that connects independent food Vendors with Customers.\n\nCuisinous:\ndoes not prepare, cook, store, inspect, package, transport, or deliver food;\nis not a restaurant, caterer, or food business;\ndoes not supervise or control Vendors or their kitchens;\ndoes not guarantee food quality, safety, legality, or compliance;\nis not an employer, agent, or partner of any Vendor.\n\nAll food transactions are strictly between the Vendor and the Customer.`
  String get termsAndConditions_section1Body {
    return Intl.message(
      'Cuisinous is a technology marketplace that connects independent food Vendors with Customers.\n\nCuisinous:\ndoes not prepare, cook, store, inspect, package, transport, or deliver food;\nis not a restaurant, caterer, or food business;\ndoes not supervise or control Vendors or their kitchens;\ndoes not guarantee food quality, safety, legality, or compliance;\nis not an employer, agent, or partner of any Vendor.\n\nAll food transactions are strictly between the Vendor and the Customer.',
      name: 'termsAndConditions_section1Body',
      desc: '',
      args: [],
    );
  }

  /// `2. ELIGIBILITY & ACCOUNTS`
  String get termsAndConditions_section2Title {
    return Intl.message(
      '2. ELIGIBILITY & ACCOUNTS',
      name: 'termsAndConditions_section2Title',
      desc: '',
      args: [],
    );
  }

  /// `To use the App, you must:\nbe 18 years or older;\nhave legal capacity to enter a contract;\nprovide accurate and current information.\n\nYou are responsible for:\nkeeping your login details secure;\nall activity under your account.\n\nNotify us immediately if you suspect unauthorized access.`
  String get termsAndConditions_section2Body {
    return Intl.message(
      'To use the App, you must:\nbe 18 years or older;\nhave legal capacity to enter a contract;\nprovide accurate and current information.\n\nYou are responsible for:\nkeeping your login details secure;\nall activity under your account.\n\nNotify us immediately if you suspect unauthorized access.',
      name: 'termsAndConditions_section2Body',
      desc: '',
      args: [],
    );
  }

  /// `3. VENDORS`
  String get termsAndConditions_section3Title {
    return Intl.message(
      '3. VENDORS',
      name: 'termsAndConditions_section3Title',
      desc: '',
      args: [],
    );
  }

  /// `Vendors are subject to a separate Vendor Agreement.\nIf there is any conflict between these Terms and the Vendor Agreement, the Vendor Agreement prevails.`
  String get termsAndConditions_section3Body {
    return Intl.message(
      'Vendors are subject to a separate Vendor Agreement.\nIf there is any conflict between these Terms and the Vendor Agreement, the Vendor Agreement prevails.',
      name: 'termsAndConditions_section3Body',
      desc: '',
      args: [],
    );
  }

  /// `4. FOOD & LEGAL COMPLIANCE`
  String get termsAndConditions_section4Title {
    return Intl.message(
      '4. FOOD & LEGAL COMPLIANCE',
      name: 'termsAndConditions_section4Title',
      desc: '',
      args: [],
    );
  }

  /// `Vendors are solely responsible for:\ncomplying with all applicable laws and regulations;\nholding valid permits and certifications (including MAPAQ);\nfood safety, hygiene, labeling, allergens, and ingredient accuracy;\ntheir food products and preparation methods.\n\nCuisinous does not verify or inspect Vendor compliance.\n\nCustomers acknowledge that:\nfood is prepared by independent Vendors;\nfood consumption carries inherent risks;\nCuisinous makes no guarantees regarding food safety or suitability.`
  String get termsAndConditions_section4Body {
    return Intl.message(
      'Vendors are solely responsible for:\ncomplying with all applicable laws and regulations;\nholding valid permits and certifications (including MAPAQ);\nfood safety, hygiene, labeling, allergens, and ingredient accuracy;\ntheir food products and preparation methods.\n\nCuisinous does not verify or inspect Vendor compliance.\n\nCustomers acknowledge that:\nfood is prepared by independent Vendors;\nfood consumption carries inherent risks;\nCuisinous makes no guarantees regarding food safety or suitability.',
      name: 'termsAndConditions_section4Body',
      desc: '',
      args: [],
    );
  }

  /// `5. ORDERS, PAYMENTS & FEES`
  String get termsAndConditions_section5Title {
    return Intl.message(
      '5. ORDERS, PAYMENTS & FEES',
      name: 'termsAndConditions_section5Title',
      desc: '',
      args: [],
    );
  }

  /// `Payments are processed by third-party providers.\nCuisinous does not store full payment details.\n\nPlatform fees or commissions may apply and are shown before confirmation.\nPlatform fees are non-refundable unless required by law.\n\nVendors are responsible for all applicable taxes (GST, QST, income tax).`
  String get termsAndConditions_section5Body {
    return Intl.message(
      'Payments are processed by third-party providers.\nCuisinous does not store full payment details.\n\nPlatform fees or commissions may apply and are shown before confirmation.\nPlatform fees are non-refundable unless required by law.\n\nVendors are responsible for all applicable taxes (GST, QST, income tax).',
      name: 'termsAndConditions_section5Body',
      desc: '',
      args: [],
    );
  }

  /// `6. CANCELLATIONS & REFUNDS`
  String get termsAndConditions_section6Title {
    return Intl.message(
      '6. CANCELLATIONS & REFUNDS',
      name: 'termsAndConditions_section6Title',
      desc: '',
      args: [],
    );
  }

  /// `Cancellation and refund policies are set by Vendors and applicable law.\nCuisinous may help facilitate communication but is not required to resolve disputes or issue refunds.`
  String get termsAndConditions_section6Body {
    return Intl.message(
      'Cancellation and refund policies are set by Vendors and applicable law.\nCuisinous may help facilitate communication but is not required to resolve disputes or issue refunds.',
      name: 'termsAndConditions_section6Body',
      desc: '',
      args: [],
    );
  }

  /// `7. USER CONTENT`
  String get termsAndConditions_section7Title {
    return Intl.message(
      '7. USER CONTENT',
      name: 'termsAndConditions_section7Title',
      desc: '',
      args: [],
    );
  }

  /// `You keep ownership of your content (photos, menus, reviews, text).\n\nBy posting content, you grant Cuisinous a worldwide, royalty-free license to use it for App operation, promotion, and analytics.\n\nYou confirm that you have the right to post your content.`
  String get termsAndConditions_section7Body {
    return Intl.message(
      'You keep ownership of your content (photos, menus, reviews, text).\n\nBy posting content, you grant Cuisinous a worldwide, royalty-free license to use it for App operation, promotion, and analytics.\n\nYou confirm that you have the right to post your content.',
      name: 'termsAndConditions_section7Body',
      desc: '',
      args: [],
    );
  }

  /// `8. PROHIBITED USE`
  String get termsAndConditions_section8Title {
    return Intl.message(
      '8. PROHIBITED USE',
      name: 'termsAndConditions_section8Title',
      desc: '',
      args: [],
    );
  }

  /// `You may not:\nbypass the App to transact off-platform;\nprovide false or misleading information;\nviolate laws or third-party rights;\npost harmful, illegal, or deceptive content;\nmisuse the App or harm Cuisinous’ reputation.`
  String get termsAndConditions_section8Body {
    return Intl.message(
      'You may not:\nbypass the App to transact off-platform;\nprovide false or misleading information;\nviolate laws or third-party rights;\npost harmful, illegal, or deceptive content;\nmisuse the App or harm Cuisinous’ reputation.',
      name: 'termsAndConditions_section8Body',
      desc: '',
      args: [],
    );
  }

  /// `9. ACCOUNT SUSPENSION OR TERMINATION`
  String get termsAndConditions_section9Title {
    return Intl.message(
      '9. ACCOUNT SUSPENSION OR TERMINATION',
      name: 'termsAndConditions_section9Title',
      desc: '',
      args: [],
    );
  }

  /// `Cuisinous may, where legally permitted:\nsuspend or terminate accounts;\nremove listings or content;\nrestrict access to the App.\n\nNo compensation is owed unless required by law.`
  String get termsAndConditions_section9Body {
    return Intl.message(
      'Cuisinous may, where legally permitted:\nsuspend or terminate accounts;\nremove listings or content;\nrestrict access to the App.\n\nNo compensation is owed unless required by law.',
      name: 'termsAndConditions_section9Body',
      desc: '',
      args: [],
    );
  }

  /// `10. INTELLECTUAL PROPERTY`
  String get termsAndConditions_section10Title {
    return Intl.message(
      '10. INTELLECTUAL PROPERTY',
      name: 'termsAndConditions_section10Title',
      desc: '',
      args: [],
    );
  }

  /// `All App content, branding, software, and trademarks belong to Cuisinous or its licensors.\nNo rights are granted except as expressly stated.`
  String get termsAndConditions_section10Body {
    return Intl.message(
      'All App content, branding, software, and trademarks belong to Cuisinous or its licensors.\nNo rights are granted except as expressly stated.',
      name: 'termsAndConditions_section10Body',
      desc: '',
      args: [],
    );
  }

  /// `11. LIMITATION OF LIABILITY`
  String get termsAndConditions_section11Title {
    return Intl.message(
      '11. LIMITATION OF LIABILITY',
      name: 'termsAndConditions_section11Title',
      desc: '',
      args: [],
    );
  }

  /// `To the maximum extent permitted by law, Cuisinous is not liable for:\nfood-related illness, allergies, injuries, or dissatisfaction;\nVendor actions or failures;\nindirect or consequential damages;\nloss of profits, data, or reputation.\n\nNothing limits liability where prohibited by law (e.g. gross negligence).`
  String get termsAndConditions_section11Body {
    return Intl.message(
      'To the maximum extent permitted by law, Cuisinous is not liable for:\nfood-related illness, allergies, injuries, or dissatisfaction;\nVendor actions or failures;\nindirect or consequential damages;\nloss of profits, data, or reputation.\n\nNothing limits liability where prohibited by law (e.g. gross negligence).',
      name: 'termsAndConditions_section11Body',
      desc: '',
      args: [],
    );
  }

  /// `12. INDEMNIFICATION`
  String get termsAndConditions_section12Title {
    return Intl.message(
      '12. INDEMNIFICATION',
      name: 'termsAndConditions_section12Title',
      desc: '',
      args: [],
    );
  }

  /// `You agree to indemnify and hold harmless Cuisinous from claims arising from:\nyour use of the App;\nfood sold or consumed;\nviolation of these Terms or the law;\ncontent you provide.`
  String get termsAndConditions_section12Body {
    return Intl.message(
      'You agree to indemnify and hold harmless Cuisinous from claims arising from:\nyour use of the App;\nfood sold or consumed;\nviolation of these Terms or the law;\ncontent you provide.',
      name: 'termsAndConditions_section12Body',
      desc: '',
      args: [],
    );
  }

  /// `13. FORCE MAJEURE`
  String get termsAndConditions_section13Title {
    return Intl.message(
      '13. FORCE MAJEURE',
      name: 'termsAndConditions_section13Title',
      desc: '',
      args: [],
    );
  }

  /// `Cuisinous is not responsible for delays or failures caused by events beyond reasonable control, including natural disasters, government actions, pandemics, or technical failures.`
  String get termsAndConditions_section13Body {
    return Intl.message(
      'Cuisinous is not responsible for delays or failures caused by events beyond reasonable control, including natural disasters, government actions, pandemics, or technical failures.',
      name: 'termsAndConditions_section13Body',
      desc: '',
      args: [],
    );
  }

  /// `14. CHANGES TO TERMS`
  String get termsAndConditions_section14Title {
    return Intl.message(
      '14. CHANGES TO TERMS',
      name: 'termsAndConditions_section14Title',
      desc: '',
      args: [],
    );
  }

  /// `We may update these Terms at any time.\nContinued use of the App means you accept the updated Terms.`
  String get termsAndConditions_section14Body {
    return Intl.message(
      'We may update these Terms at any time.\nContinued use of the App means you accept the updated Terms.',
      name: 'termsAndConditions_section14Body',
      desc: '',
      args: [],
    );
  }

  /// `15. GOVERNING LAW`
  String get termsAndConditions_section15Title {
    return Intl.message(
      '15. GOVERNING LAW',
      name: 'termsAndConditions_section15Title',
      desc: '',
      args: [],
    );
  }

  /// `These Terms are governed by the laws of Québec, Canada.`
  String get termsAndConditions_section15Body {
    return Intl.message(
      'These Terms are governed by the laws of Québec, Canada.',
      name: 'termsAndConditions_section15Body',
      desc: '',
      args: [],
    );
  }

  /// `16. CONTACT`
  String get termsAndConditions_section16Title {
    return Intl.message(
      '16. CONTACT',
      name: 'termsAndConditions_section16Title',
      desc: '',
      args: [],
    );
  }

  /// `Questions or legal notices: info@cuisinous.ca`
  String get termsAndConditions_section16Body {
    return Intl.message(
      'Questions or legal notices: info@cuisinous.ca',
      name: 'termsAndConditions_section16Body',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get termsAndConditions_conclusion {
    return Intl.message(
      '',
      name: 'termsAndConditions_conclusion',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `I accept the `
  String get register_acceptTermsPart1 {
    return Intl.message(
      'I accept the ',
      name: 'register_acceptTermsPart1',
      desc: '',
      args: [],
    );
  }

  /// ` and `
  String get register_acceptTermsPart2 {
    return Intl.message(
      ' and ',
      name: 'register_acceptTermsPart2',
      desc: '',
      args: [],
    );
  }

  /// ` of Cuisinous`
  String get register_acceptTermsPart3 {
    return Intl.message(
      ' of Cuisinous',
      name: 'register_acceptTermsPart3',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get storeVerificationRequest_retry {
    return Intl.message(
      'Retry',
      name: 'storeVerificationRequest_retry',
      desc: '',
      args: [],
    );
  }

  /// `Start Verification`
  String get storeVerificationRequest_start {
    return Intl.message(
      'Start Verification',
      name: 'storeVerificationRequest_start',
      desc: '',
      args: [],
    );
  }

  /// `Verification Status`
  String get storeVerificationRequest_status {
    return Intl.message(
      'Verification Status',
      name: 'storeVerificationRequest_status',
      desc: '',
      args: [],
    );
  }

  /// `Swipe down to refresh`
  String get storeVerificationRequest_swipeDown {
    return Intl.message(
      'Swipe down to refresh',
      name: 'storeVerificationRequest_swipeDown',
      desc: '',
      args: [],
    );
  }

  /// `Continue To Home`
  String get storeVerificationRequest_continueHome {
    return Intl.message(
      'Continue To Home',
      name: 'storeVerificationRequest_continueHome',
      desc: '',
      args: [],
    );
  }

  /// `Rectify Your Request`
  String get storeVerificationRequest_rectify {
    return Intl.message(
      'Rectify Your Request',
      name: 'storeVerificationRequest_rectify',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get storeVerificationRequest_logout {
    return Intl.message(
      'Log out',
      name: 'storeVerificationRequest_logout',
      desc: '',
      args: [],
    );
  }

  /// `Food Store`
  String get storeVerificationRequest_foodStore {
    return Intl.message(
      'Food Store',
      name: 'storeVerificationRequest_foodStore',
      desc: '',
      args: [],
    );
  }

  /// `Request ID`
  String get storeVerificationRequest_requestId {
    return Intl.message(
      'Request ID',
      name: 'storeVerificationRequest_requestId',
      desc: '',
      args: [],
    );
  }

  /// `Submitted Document`
  String get storeVerificationRequest_submittedDoc {
    return Intl.message(
      'Submitted Document',
      name: 'storeVerificationRequest_submittedDoc',
      desc: '',
      args: [],
    );
  }

  /// `Admin Comment`
  String get storeVerificationRequest_adminComment {
    return Intl.message(
      'Admin Comment',
      name: 'storeVerificationRequest_adminComment',
      desc: '',
      args: [],
    );
  }

  /// `Verified By`
  String get storeVerificationRequest_verifiedBy {
    return Intl.message(
      'Verified By',
      name: 'storeVerificationRequest_verifiedBy',
      desc: '',
      args: [],
    );
  }

  /// `Verification Date`
  String get storeVerificationRequest_date {
    return Intl.message(
      'Verification Date',
      name: 'storeVerificationRequest_date',
      desc: '',
      args: [],
    );
  }

  /// `Verification Status`
  String get storeVerificationStatus {
    return Intl.message(
      'Verification Status',
      name: 'storeVerificationStatus',
      desc: '',
      args: [],
    );
  }

  /// `Please provide the needed documents to verify your store.`
  String get storeVerificationPrompt {
    return Intl.message(
      'Please provide the needed documents to verify your store.',
      name: 'storeVerificationPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get storeVerificationContinue {
    return Intl.message(
      'Continue',
      name: 'storeVerificationContinue',
      desc: '',
      args: [],
    );
  }

  /// `Your store has been verified and is now live!`
  String get storeVerificationSuccess {
    return Intl.message(
      'Your store has been verified and is now live!',
      name: 'storeVerificationSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Rectify Your Request`
  String get storeVerificationRectify {
    return Intl.message(
      'Rectify Your Request',
      name: 'storeVerificationRectify',
      desc: '',
      args: [],
    );
  }

  /// `Continue To Home`
  String get storeVerificationContinueHome {
    return Intl.message(
      'Continue To Home',
      name: 'storeVerificationContinueHome',
      desc: '',
      args: [],
    );
  }

  /// `No verification request submitted yet`
  String get storeVerificationNoRequest {
    return Intl.message(
      'No verification request submitted yet',
      name: 'storeVerificationNoRequest',
      desc: '',
      args: [],
    );
  }

  /// `Food Store`
  String get storeVerificationFoodStore {
    return Intl.message(
      'Food Store',
      name: 'storeVerificationFoodStore',
      desc: '',
      args: [],
    );
  }

  /// `Request ID`
  String get storeVerificationRequestId {
    return Intl.message(
      'Request ID',
      name: 'storeVerificationRequestId',
      desc: '',
      args: [],
    );
  }

  /// `Submitted Document`
  String get storeVerificationSubmittedDoc {
    return Intl.message(
      'Submitted Document',
      name: 'storeVerificationSubmittedDoc',
      desc: '',
      args: [],
    );
  }

  /// `Admin Comment`
  String get storeVerificationAdminComment {
    return Intl.message(
      'Admin Comment',
      name: 'storeVerificationAdminComment',
      desc: '',
      args: [],
    );
  }

  /// `Verified By`
  String get storeVerificationVerifiedBy {
    return Intl.message(
      'Verified By',
      name: 'storeVerificationVerifiedBy',
      desc: '',
      args: [],
    );
  }

  /// `Verification Date`
  String get storeVerificationDate {
    return Intl.message(
      'Verification Date',
      name: 'storeVerificationDate',
      desc: '',
      args: [],
    );
  }

  /// `Step 1: Justification of permit to work`
  String get fileUploadStep1Title {
    return Intl.message(
      'Step 1: Justification of permit to work',
      name: 'fileUploadStep1Title',
      desc: '',
      args: [],
    );
  }

  /// `Step 2: Certificate of MAPAQ`
  String get fileUploadStep2Title {
    return Intl.message(
      'Step 2: Certificate of MAPAQ',
      name: 'fileUploadStep2Title',
      desc: '',
      args: [],
    );
  }

  /// `Step 3: Personal ID (driving license, passport)`
  String get fileUploadStep3Title {
    return Intl.message(
      'Step 3: Personal ID (driving license, passport)',
      name: 'fileUploadStep3Title',
      desc: '',
      args: [],
    );
  }

  /// `Step 4: Establishment Certificate`
  String get fileUploadStep4Title {
    return Intl.message(
      'Step 4: Establishment Certificate',
      name: 'fileUploadStep4Title',
      desc: '',
      args: [],
    );
  }

  /// `Drag & Drop files here`
  String get fileUploadDragDrop {
    return Intl.message(
      'Drag & Drop files here',
      name: 'fileUploadDragDrop',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get fileUploadOr {
    return Intl.message('or', name: 'fileUploadOr', desc: '', args: []);
  }

  /// `Browse Files`
  String get fileUploadBrowse {
    return Intl.message(
      'Browse Files',
      name: 'fileUploadBrowse',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get fileUploadRemove {
    return Intl.message('Remove', name: 'fileUploadRemove', desc: '', args: []);
  }

  /// `Uploading...`
  String get fileUploadUploading {
    return Intl.message(
      'Uploading...',
      name: 'fileUploadUploading',
      desc: '',
      args: [],
    );
  }

  /// `Wallet`
  String get sellerWalletTitle {
    return Intl.message(
      'Wallet',
      name: 'sellerWalletTitle',
      desc: '',
      args: [],
    );
  }

  /// `Current Balance`
  String get sellerWalletBalance {
    return Intl.message(
      'Current Balance',
      name: 'sellerWalletBalance',
      desc: '',
      args: [],
    );
  }

  /// `No transactions yet`
  String get sellerWalletNoTransactions {
    return Intl.message(
      'No transactions yet',
      name: 'sellerWalletNoTransactions',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get sellerWalletTransactionType {
    return Intl.message(
      'Type',
      name: 'sellerWalletTransactionType',
      desc: '',
      args: [],
    );
  }

  /// `Credit`
  String get sellerWalletTransactionCredit {
    return Intl.message(
      'Credit',
      name: 'sellerWalletTransactionCredit',
      desc: '',
      args: [],
    );
  }

  /// `Debit`
  String get sellerWalletTransactionDebit {
    return Intl.message(
      'Debit',
      name: 'sellerWalletTransactionDebit',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get sellerWalletTransactionDate {
    return Intl.message(
      'Date',
      name: 'sellerWalletTransactionDate',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get sellerWalletTransactionDescription {
    return Intl.message(
      'Description',
      name: 'sellerWalletTransactionDescription',
      desc: '',
      args: [],
    );
  }

  /// `Reference`
  String get sellerWalletTransactionReference {
    return Intl.message(
      'Reference',
      name: 'sellerWalletTransactionReference',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `Withdraw`
  String get withdrawButton {
    return Intl.message('Withdraw', name: 'withdrawButton', desc: '', args: []);
  }

  /// `Withdraw Funds`
  String get withdrawTitle {
    return Intl.message(
      'Withdraw Funds',
      name: 'withdrawTitle',
      desc: '',
      args: [],
    );
  }

  /// `Current Balance`
  String get withdrawCurrentBalance {
    return Intl.message(
      'Current Balance',
      name: 'withdrawCurrentBalance',
      desc: '',
      args: [],
    );
  }

  /// `Quick Amounts`
  String get withdrawQuickAmounts {
    return Intl.message(
      'Quick Amounts',
      name: 'withdrawQuickAmounts',
      desc: '',
      args: [],
    );
  }

  /// `Custom Amount`
  String get withdrawCustomAmount {
    return Intl.message(
      'Custom Amount',
      name: 'withdrawCustomAmount',
      desc: '',
      args: [],
    );
  }

  /// `This instant withdrawal will cost you $4. Please confirm before proceeding.`
  String get withdrawFeeNotice {
    return Intl.message(
      'This instant withdrawal will cost you \$4. Please confirm before proceeding.',
      name: 'withdrawFeeNotice',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Withdrawal`
  String get withdrawConfirm {
    return Intl.message(
      'Confirm Withdrawal',
      name: 'withdrawConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Withdrawal successful!`
  String get withdrawSuccess {
    return Intl.message(
      'Withdrawal successful!',
      name: 'withdrawSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Withdrawal failed. Please try again.`
  String get withdrawError {
    return Intl.message(
      'Withdrawal failed. Please try again.',
      name: 'withdrawError',
      desc: '',
      args: [],
    );
  }

  /// `Amount cannot exceed your current balance`
  String get withdrawAmountExceeded {
    return Intl.message(
      'Amount cannot exceed your current balance',
      name: 'withdrawAmountExceeded',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid amount`
  String get withdrawInvalidAmount {
    return Intl.message(
      'Please enter a valid amount',
      name: 'withdrawInvalidAmount',
      desc: '',
      args: [],
    );
  }

  /// `Processing withdrawal...`
  String get withdrawProcessing {
    return Intl.message(
      'Processing withdrawal...',
      name: 'withdrawProcessing',
      desc: '',
      args: [],
    );
  }

  /// `Withdrawal Amount`
  String get withdrawAmount {
    return Intl.message(
      'Withdrawal Amount',
      name: 'withdrawAmount',
      desc: '',
      args: [],
    );
  }

  /// `Withdrawal Fee`
  String get withdrawFee {
    return Intl.message(
      'Withdrawal Fee',
      name: 'withdrawFee',
      desc: '',
      args: [],
    );
  }

  /// `Total Amount`
  String get withdrawTotal {
    return Intl.message(
      'Total Amount',
      name: 'withdrawTotal',
      desc: '',
      args: [],
    );
  }

  /// `Failed to connect Stripe account. Please try again.`
  String get stripeConnectionError {
    return Intl.message(
      'Failed to connect Stripe account. Please try again.',
      name: 'stripeConnectionError',
      desc: '',
      args: [],
    );
  }

  /// `Rate Dish`
  String get writeReview_rateDish {
    return Intl.message(
      'Rate Dish',
      name: 'writeReview_rateDish',
      desc: '',
      args: [],
    );
  }

  /// `Comment (Optional)`
  String get writeReview_commentLabel {
    return Intl.message(
      'Comment (Optional)',
      name: 'writeReview_commentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Share your experience with this dish...`
  String get writeReview_commentHint {
    return Intl.message(
      'Share your experience with this dish...',
      name: 'writeReview_commentHint',
      desc: '',
      args: [],
    );
  }

  /// `Submit Review`
  String get writeReview_submit {
    return Intl.message(
      'Submit Review',
      name: 'writeReview_submit',
      desc: '',
      args: [],
    );
  }

  /// `Click here to upload`
  String get writeReview_clickToUpload {
    return Intl.message(
      'Click here to upload',
      name: 'writeReview_clickToUpload',
      desc: '',
      args: [],
    );
  }

  /// `Rate Dish`
  String get rateDish {
    return Intl.message('Rate Dish', name: 'rateDish', desc: '', args: []);
  }

  /// `Comment (Optional)`
  String get ratingCommentLabel {
    return Intl.message(
      'Comment (Optional)',
      name: 'ratingCommentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Share your experience with this dish...`
  String get ratingCommentHint {
    return Intl.message(
      'Share your experience with this dish...',
      name: 'ratingCommentHint',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for your rating!`
  String get ratingSuccess {
    return Intl.message(
      'Thank you for your rating!',
      name: 'ratingSuccess',
      desc: '',
      args: [],
    );
  }

  /// `reviews`
  String get reviews {
    return Intl.message('reviews', name: 'reviews', desc: '', args: []);
  }

  /// `No reviews yet.`
  String get noReviewsYet {
    return Intl.message(
      'No reviews yet.',
      name: 'noReviewsYet',
      desc: '',
      args: [],
    );
  }

  /// `Your Review`
  String get yourReview {
    return Intl.message('Your Review', name: 'yourReview', desc: '', args: []);
  }

  /// `Submit Review`
  String get submitReview {
    return Intl.message(
      'Submit Review',
      name: 'submitReview',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Email`
  String get optVerification_title {
    return Intl.message(
      'Verify Your Email',
      name: 'optVerification_title',
      desc: '',
      args: [],
    );
  }

  /// `Enter the 6-digit code sent to your email to verify your account.`
  String get optVerification_subtitle {
    return Intl.message(
      'Enter the 6-digit code sent to your email to verify your account.',
      name: 'optVerification_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Email confirmed!`
  String get optVerification_success {
    return Intl.message(
      'Email confirmed!',
      name: 'optVerification_success',
      desc: '',
      args: [],
    );
  }

  /// `Invalid code. Please try again.`
  String get optVerification_error {
    return Intl.message(
      'Invalid code. Please try again.',
      name: 'optVerification_error',
      desc: '',
      args: [],
    );
  }

  /// `Resend Code`
  String get optVerification_resend {
    return Intl.message(
      'Resend Code',
      name: 'optVerification_resend',
      desc: '',
      args: [],
    );
  }

  /// `Enter code`
  String get optVerification_codeHint {
    return Intl.message(
      'Enter code',
      name: 'optVerification_codeHint',
      desc: '',
      args: [],
    );
  }

  /// `0`
  String get optVerification_fieldHint {
    return Intl.message(
      '0',
      name: 'optVerification_fieldHint',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get optVerification_submit {
    return Intl.message(
      'Verify',
      name: 'optVerification_submit',
      desc: '',
      args: [],
    );
  }

  /// `Validation required`
  String get optVerification_validationRequired {
    return Intl.message(
      'Validation required',
      name: 'optVerification_validationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get register_phoneLabel {
    return Intl.message(
      'Phone Number',
      name: 'register_phoneLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter your phone number`
  String get register_phoneHint {
    return Intl.message(
      'Enter your phone number',
      name: 'register_phoneHint',
      desc: '',
      args: [],
    );
  }

  /// `Phone number is required`
  String get register_validationPhoneRequired {
    return Intl.message(
      'Phone number is required',
      name: 'register_validationPhoneRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid phone number`
  String get register_validationPhoneInvalid {
    return Intl.message(
      'Enter a valid phone number',
      name: 'register_validationPhoneInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Operation Failed`
  String get storeForm_operationFailed {
    return Intl.message(
      'Operation Failed',
      name: 'storeForm_operationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Could not fetch address. Please try again.`
  String get storeForm_couldNotFetchAddress {
    return Intl.message(
      'Could not fetch address. Please try again.',
      name: 'storeForm_couldNotFetchAddress',
      desc: '',
      args: [],
    );
  }

  /// `Move the map to select a location`
  String get storeForm_moveTheMapToSelectLocation {
    return Intl.message(
      'Move the map to select a location',
      name: 'storeForm_moveTheMapToSelectLocation',
      desc: '',
      args: [],
    );
  }

  /// `Selected Location`
  String get storeForm_selectedLocation {
    return Intl.message(
      'Selected Location',
      name: 'storeForm_selectedLocation',
      desc: '',
      args: [],
    );
  }

  /// `Address not available`
  String get storeForm_addressNotAvailable {
    return Intl.message(
      'Address not available',
      name: 'storeForm_addressNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Create Store`
  String get storeForm_createStore {
    return Intl.message(
      'Create Store',
      name: 'storeForm_createStore',
      desc: '',
      args: [],
    );
  }

  /// `Edit Store`
  String get storeForm_editStore {
    return Intl.message(
      'Edit Store',
      name: 'storeForm_editStore',
      desc: '',
      args: [],
    );
  }

  /// `Please select a location on the map.`
  String get storeForm_pleaseSelectLocation {
    return Intl.message(
      'Please select a location on the map.',
      name: 'storeForm_pleaseSelectLocation',
      desc: '',
      args: [],
    );
  }

  /// `Change Image`
  String get storeForm_changeImage {
    return Intl.message(
      'Change Image',
      name: 'storeForm_changeImage',
      desc: '',
      args: [],
    );
  }

  /// `Upload Image`
  String get storeForm_uploadImage {
    return Intl.message(
      'Upload Image',
      name: 'storeForm_uploadImage',
      desc: '',
      args: [],
    );
  }

  /// `Enter your store's name`
  String get storeForm_nameHint {
    return Intl.message(
      'Enter your store\'s name',
      name: 'storeForm_nameHint',
      desc: '',
      args: [],
    );
  }

  /// `Store Name`
  String get storeForm_nameLabel {
    return Intl.message(
      'Store Name',
      name: 'storeForm_nameLabel',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get storeForm_requiredField {
    return Intl.message(
      'This field is required',
      name: 'storeForm_requiredField',
      desc: '',
      args: [],
    );
  }

  /// `Describe your store`
  String get storeForm_bioHint {
    return Intl.message(
      'Describe your store',
      name: 'storeForm_bioHint',
      desc: '',
      args: [],
    );
  }

  /// `Store Bio / Description`
  String get storeForm_bioLabel {
    return Intl.message(
      'Store Bio / Description',
      name: 'storeForm_bioLabel',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get storeForm_save {
    return Intl.message(
      'Save Changes',
      name: 'storeForm_save',
      desc: '',
      args: [],
    );
  }

  /// `Could not fetch address. Please try again.`
  String get couldNotFetchAddress {
    return Intl.message(
      'Could not fetch address. Please try again.',
      name: 'couldNotFetchAddress',
      desc: '',
      args: [],
    );
  }

  /// `Move the map to select a location`
  String get moveTheMapToSelectLocation {
    return Intl.message(
      'Move the map to select a location',
      name: 'moveTheMapToSelectLocation',
      desc: '',
      args: [],
    );
  }

  /// `Selected Location`
  String get selectedLocation {
    return Intl.message(
      'Selected Location',
      name: 'selectedLocation',
      desc: '',
      args: [],
    );
  }

  /// `Address not available`
  String get addressNotAvailable {
    return Intl.message(
      'Address not available',
      name: 'addressNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Become a Cuisinous Partner`
  String get storeVerificationRequest_welcomeTitle {
    return Intl.message(
      'Become a Cuisinous Partner',
      name: 'storeVerificationRequest_welcomeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Join our platform by submitting your store's documents for a quick verification process.`
  String get storeVerificationRequest_welcomePrompt {
    return Intl.message(
      'Join our platform by submitting your store\'s documents for a quick verification process.',
      name: 'storeVerificationRequest_welcomePrompt',
      desc: '',
      args: [],
    );
  }

  /// `Swipe down to refresh`
  String get storeVerificationSwipeDown {
    return Intl.message(
      'Swipe down to refresh',
      name: 'storeVerificationSwipeDown',
      desc: '',
      args: [],
    );
  }

  /// `Become a Cuisinous Partner`
  String get storeVerificationWelcomeTitle {
    return Intl.message(
      'Become a Cuisinous Partner',
      name: 'storeVerificationWelcomeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Join our platform by submitting your store's documents for a quick verification process.`
  String get storeVerificationWelcomePrompt {
    return Intl.message(
      'Join our platform by submitting your store\'s documents for a quick verification process.',
      name: 'storeVerificationWelcomePrompt',
      desc: '',
      args: [],
    );
  }

  /// `Start Verification`
  String get storeVerificationStart {
    return Intl.message(
      'Start Verification',
      name: 'storeVerificationStart',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get sellerHome_welcome {
    return Intl.message(
      'Welcome',
      name: 'sellerHome_welcome',
      desc: '',
      args: [],
    );
  }

  /// `Seller`
  String get sellerHome_sellerFallback {
    return Intl.message(
      'Seller',
      name: 'sellerHome_sellerFallback',
      desc: '',
      args: [],
    );
  }

  /// `Verification Status:`
  String get sellerHome_verificationStatus {
    return Intl.message(
      'Verification Status:',
      name: 'sellerHome_verificationStatus',
      desc: '',
      args: [],
    );
  }

  /// `Admin Feedback`
  String get sellerHome_adminFeedback {
    return Intl.message(
      'Admin Feedback',
      name: 'sellerHome_adminFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Quick Actions`
  String get sellerHome_quickActions {
    return Intl.message(
      'Quick Actions',
      name: 'sellerHome_quickActions',
      desc: '',
      args: [],
    );
  }

  /// `Update Store Info`
  String get sellerHome_updateStore {
    return Intl.message(
      'Update Store Info',
      name: 'sellerHome_updateStore',
      desc: '',
      args: [],
    );
  }

  /// `View Analytics`
  String get sellerHome_analytics {
    return Intl.message(
      'View Analytics',
      name: 'sellerHome_analytics',
      desc: '',
      args: [],
    );
  }

  /// `You haven't set up your store yet.`
  String get sellerHome_noStore {
    return Intl.message(
      'You haven\'t set up your store yet.',
      name: 'sellerHome_noStore',
      desc: '',
      args: [],
    );
  }

  /// `Create Your Store`
  String get sellerHome_createStore {
    return Intl.message(
      'Create Your Store',
      name: 'sellerHome_createStore',
      desc: '',
      args: [],
    );
  }

  /// `Approved`
  String get sellerHome_statusApproved {
    return Intl.message(
      'Approved',
      name: 'sellerHome_statusApproved',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get sellerHome_statusPending {
    return Intl.message(
      'Pending',
      name: 'sellerHome_statusPending',
      desc: '',
      args: [],
    );
  }

  /// `Rejected`
  String get sellerHome_statusRejected {
    return Intl.message(
      'Rejected',
      name: 'sellerHome_statusRejected',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get homeLabel {
    return Intl.message('Home', name: 'homeLabel', desc: '', args: []);
  }

  /// `Explore`
  String get exploreLabel {
    return Intl.message('Explore', name: 'exploreLabel', desc: '', args: []);
  }

  /// `Orders`
  String get ordersLabel {
    return Intl.message('Orders', name: 'ordersLabel', desc: '', args: []);
  }

  /// `Menu`
  String get menuLabel {
    return Intl.message('Menu', name: 'menuLabel', desc: '', args: []);
  }

  /// `Stats`
  String get statsLabel {
    return Intl.message('Stats', name: 'statsLabel', desc: '', args: []);
  }

  /// `Settings`
  String get settingsLabel {
    return Intl.message('Settings', name: 'settingsLabel', desc: '', args: []);
  }

  /// `Cart`
  String get cart_label {
    return Intl.message('Cart', name: 'cart_label', desc: '', args: []);
  }

  /// `Add a Tip`
  String get addTipTitle {
    return Intl.message('Add a Tip', name: 'addTipTitle', desc: '', args: []);
  }

  /// `Order Total`
  String get orderTotal {
    return Intl.message('Order Total', name: 'orderTotal', desc: '', args: []);
  }

  /// `Quick Tip`
  String get quickTipAmounts {
    return Intl.message(
      'Quick Tip',
      name: 'quickTipAmounts',
      desc: '',
      args: [],
    );
  }

  /// `Custom Amount`
  String get customTipAmount {
    return Intl.message(
      'Custom Amount',
      name: 'customTipAmount',
      desc: '',
      args: [],
    );
  }

  /// `Tip`
  String get tipAmount {
    return Intl.message('Tip', name: 'tipAmount', desc: '', args: []);
  }

  /// `New Total`
  String get newTotal {
    return Intl.message('New Total', name: 'newTotal', desc: '', args: []);
  }

  /// `Pay Tip`
  String get confirmTip {
    return Intl.message('Pay Tip', name: 'confirmTip', desc: '', args: []);
  }

  /// `Recover Password`
  String get passwordRecoveryTitle {
    return Intl.message(
      'Recover Password',
      name: 'passwordRecoveryTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email to receive a reset link.`
  String get passwordRecoverySubtitle {
    return Intl.message(
      'Enter your email to receive a reset link.',
      name: 'passwordRecoverySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email address`
  String get passwordRecoveryEmailHint {
    return Intl.message(
      'Enter your email address',
      name: 'passwordRecoveryEmailHint',
      desc: '',
      args: [],
    );
  }

  /// `Send Reset Link`
  String get passwordRecoveryButton {
    return Intl.message(
      'Send Reset Link',
      name: 'passwordRecoveryButton',
      desc: '',
      args: [],
    );
  }

  /// `If the email exists, a reset link has been sent.`
  String get passwordRecoverySuccessMessage {
    return Intl.message(
      'If the email exists, a reset link has been sent.',
      name: 'passwordRecoverySuccessMessage',
      desc: '',
      args: [],
    );
  }

  /// `Failed to send reset link`
  String get passwordRecoveryErrorMessage {
    return Intl.message(
      'Failed to send reset link',
      name: 'passwordRecoveryErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Email is required`
  String get passwordRecoveryEmailRequired {
    return Intl.message(
      'Email is required',
      name: 'passwordRecoveryEmailRequired',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address`
  String get passwordRecoveryEmailInvalid {
    return Intl.message(
      'Please enter a valid email address',
      name: 'passwordRecoveryEmailInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get login_forgotPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'login_forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Details`
  String get transactionDetailsTitle {
    return Intl.message(
      'Transaction Details',
      name: 'transactionDetailsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Transaction ID`
  String get transactionId {
    return Intl.message(
      'Transaction ID',
      name: 'transactionId',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get amount {
    return Intl.message('Amount', name: 'amount', desc: '', args: []);
  }

  /// `Currency`
  String get currency {
    return Intl.message('Currency', name: 'currency', desc: '', args: []);
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `Date`
  String get date {
    return Intl.message('Date', name: 'date', desc: '', args: []);
  }

  /// `Available At`
  String get availableAt {
    return Intl.message(
      'Available At',
      name: 'availableAt',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get note {
    return Intl.message('Note', name: 'note', desc: '', args: []);
  }

  /// `Order ID`
  String get orderId {
    return Intl.message('Order ID', name: 'orderId', desc: '', args: []);
  }

  /// `Stripe Payout ID`
  String get stripePayoutId {
    return Intl.message(
      'Stripe Payout ID',
      name: 'stripePayoutId',
      desc: '',
      args: [],
    );
  }

  /// `Order Income`
  String get transactionTypeOrderIncome {
    return Intl.message(
      'Order Income',
      name: 'transactionTypeOrderIncome',
      desc: '',
      args: [],
    );
  }

  /// `Tip Income`
  String get transactionTypeTipIncome {
    return Intl.message(
      'Tip Income',
      name: 'transactionTypeTipIncome',
      desc: '',
      args: [],
    );
  }

  /// `Deposit`
  String get transactionTypeDeposit {
    return Intl.message(
      'Deposit',
      name: 'transactionTypeDeposit',
      desc: '',
      args: [],
    );
  }

  /// `Withdrawal`
  String get transactionTypeWithdrawal {
    return Intl.message(
      'Withdrawal',
      name: 'transactionTypeWithdrawal',
      desc: '',
      args: [],
    );
  }

  /// `Payment`
  String get transactionTypePayment {
    return Intl.message(
      'Payment',
      name: 'transactionTypePayment',
      desc: '',
      args: [],
    );
  }

  /// `Refund`
  String get transactionTypeRefund {
    return Intl.message(
      'Refund',
      name: 'transactionTypeRefund',
      desc: '',
      args: [],
    );
  }

  /// `Fee`
  String get transactionTypeFee {
    return Intl.message('Fee', name: 'transactionTypeFee', desc: '', args: []);
  }

  /// `Adjustment`
  String get transactionTypeAdjustment {
    return Intl.message(
      'Adjustment',
      name: 'transactionTypeAdjustment',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get transactionTypeOther {
    return Intl.message(
      'Other',
      name: 'transactionTypeOther',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get transactionStatusCompleted {
    return Intl.message(
      'Completed',
      name: 'transactionStatusCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get transactionStatusPending {
    return Intl.message(
      'Pending',
      name: 'transactionStatusPending',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get transactionStatusFailed {
    return Intl.message(
      'Failed',
      name: 'transactionStatusFailed',
      desc: '',
      args: [],
    );
  }

  /// `Canceled`
  String get transactionStatusCanceled {
    return Intl.message(
      'Canceled',
      name: 'transactionStatusCanceled',
      desc: '',
      args: [],
    );
  }

  /// `Error loading transactions`
  String get errorLoadingTransactions {
    return Intl.message(
      'Error loading transactions',
      name: 'errorLoadingTransactions',
      desc: '',
      args: [],
    );
  }

  /// `Connect Stripe Account`
  String get connectStripeAccount {
    return Intl.message(
      'Connect Stripe Account',
      name: 'connectStripeAccount',
      desc: '',
      args: [],
    );
  }

  /// `Dish Ingredients`
  String get dishIngredientsTitle {
    return Intl.message(
      'Dish Ingredients',
      name: 'dishIngredientsTitle',
      desc: '',
      args: [],
    );
  }

  /// `linked ingredients`
  String get linkedIngredients {
    return Intl.message(
      'linked ingredients',
      name: 'linkedIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message('Total', name: 'total', desc: '', args: []);
  }

  /// `Link Ingredients`
  String get linkIngredients {
    return Intl.message(
      'Link Ingredients',
      name: 'linkIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Manage Ingredients`
  String get manageIngredients {
    return Intl.message(
      'Manage Ingredients',
      name: 'manageIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Sort by Name`
  String get sortByName {
    return Intl.message('Sort by Name', name: 'sortByName', desc: '', args: []);
  }

  /// `Sort by Price`
  String get sortByPrice {
    return Intl.message(
      'Sort by Price',
      name: 'sortByPrice',
      desc: '',
      args: [],
    );
  }

  /// `Sort by Type`
  String get sortByType {
    return Intl.message('Sort by Type', name: 'sortByType', desc: '', args: []);
  }

  /// `Sorted by {sortBy}`
  String sortedBy(String sortBy) {
    return Intl.message(
      'Sorted by $sortBy',
      name: 'sortedBy',
      desc: '',
      args: [sortBy],
    );
  }

  /// `Loading ingredients...`
  String get loadingIngredients {
    return Intl.message(
      'Loading ingredients...',
      name: 'loadingIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Link ingredients from your seller list or manage your ingredient library`
  String get linkIngredientsHint {
    return Intl.message(
      'Link ingredients from your seller list or manage your ingredient library',
      name: 'linkIngredientsHint',
      desc: '',
      args: [],
    );
  }

  /// `Link Ingredients to Dish`
  String get linkIngredientsToDish {
    return Intl.message(
      'Link Ingredients to Dish',
      name: 'linkIngredientsToDish',
      desc: '',
      args: [],
    );
  }

  /// `Search ingredients to link...`
  String get searchIngredientsToLink {
    return Intl.message(
      'Search ingredients to link...',
      name: 'searchIngredientsToLink',
      desc: '',
      args: [],
    );
  }

  /// `Ingredient Management`
  String get ingredientManagement {
    return Intl.message(
      'Ingredient Management',
      name: 'ingredientManagement',
      desc: '',
      args: [],
    );
  }

  /// `Create New`
  String get createNew {
    return Intl.message('Create New', name: 'createNew', desc: '', args: []);
  }

  /// `Search your ingredients...`
  String get searchYourIngredients {
    return Intl.message(
      'Search your ingredients...',
      name: 'searchYourIngredients',
      desc: '',
      args: [],
    );
  }

  /// `No ingredients in your library`
  String get noIngredientsInLibrary {
    return Intl.message(
      'No ingredients in your library',
      name: 'noIngredientsInLibrary',
      desc: '',
      args: [],
    );
  }

  /// `Create your first ingredient to get started`
  String get createYourFirstIngredient {
    return Intl.message(
      'Create your first ingredient to get started',
      name: 'createYourFirstIngredient',
      desc: '',
      args: [],
    );
  }

  /// `Name (English)`
  String get nameEnglish {
    return Intl.message(
      'Name (English)',
      name: 'nameEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Name (French)`
  String get nameFrench {
    return Intl.message(
      'Name (French)',
      name: 'nameFrench',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a name`
  String get pleaseEnterName {
    return Intl.message(
      'Please enter a name',
      name: 'pleaseEnterName',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
  }

  /// `Link`
  String get link {
    return Intl.message('Link', name: 'link', desc: '', args: []);
  }

  /// `Ingredient removed from dish successfully`
  String get ingredientRemovedSuccessfully {
    return Intl.message(
      'Ingredient removed from dish successfully',
      name: 'ingredientRemovedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Ingredient deleted successfully`
  String get ingredientDeletedSuccessfully {
    return Intl.message(
      'Ingredient deleted successfully',
      name: 'ingredientDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Ingredient updated successfully`
  String get ingredientUpdatedSuccessfully {
    return Intl.message(
      'Ingredient updated successfully',
      name: 'ingredientUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Ingredient created successfully`
  String get ingredientCreatedSuccessfully {
    return Intl.message(
      'Ingredient created successfully',
      name: 'ingredientCreatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Ingredient added successfully`
  String get ingredientAddedSuccessfully {
    return Intl.message(
      'Ingredient added successfully',
      name: 'ingredientAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Supplements must have a price greater than 0`
  String get supplementsMustHavePrice {
    return Intl.message(
      'Supplements must have a price greater than 0',
      name: 'supplementsMustHavePrice',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get price {
    return Intl.message('Price', name: 'price', desc: '', args: []);
  }

  /// `Price (Free)`
  String get priceFree {
    return Intl.message('Price (Free)', name: 'priceFree', desc: '', args: []);
  }

  /// `Enter price (e.g., 2.50)`
  String get enterPriceEg250 {
    return Intl.message(
      'Enter price (e.g., 2.50)',
      name: 'enterPriceEg250',
      desc: '',
      args: [],
    );
  }

  /// `Standard ingredients are free`
  String get standardIngredientsAreFree {
    return Intl.message(
      'Standard ingredients are free',
      name: 'standardIngredientsAreFree',
      desc: '',
      args: [],
    );
  }

  /// `Additional cost item`
  String get additionalCostItem {
    return Intl.message(
      'Additional cost item',
      name: 'additionalCostItem',
      desc: '',
      args: [],
    );
  }

  /// `Standard ingredient (free)`
  String get standardIngredientFree {
    return Intl.message(
      'Standard ingredient (free)',
      name: 'standardIngredientFree',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Location`
  String get storeForm_confirmLocation {
    return Intl.message(
      'Confirm Location',
      name: 'storeForm_confirmLocation',
      desc: '',
      args: [],
    );
  }

  /// `Tap to select location`
  String get storeForm_tapToSelectLocation {
    return Intl.message(
      'Tap to select location',
      name: 'storeForm_tapToSelectLocation',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Location`
  String get confirmLocation {
    return Intl.message(
      'Confirm Location',
      name: 'confirmLocation',
      desc: '',
      args: [],
    );
  }

  /// `Tap to select location`
  String get tapToSelectLocation {
    return Intl.message(
      'Tap to select location',
      name: 'tapToSelectLocation',
      desc: '',
      args: [],
    );
  }

  /// `Fetching address...`
  String get fetchingAddress {
    return Intl.message(
      'Fetching address...',
      name: 'fetchingAddress',
      desc: '',
      args: [],
    );
  }

  /// `Menu Screen`
  String get menuScreen {
    return Intl.message('Menu Screen', name: 'menuScreen', desc: '', args: []);
  }

  /// `Stats Screen`
  String get statsScreen {
    return Intl.message(
      'Stats Screen',
      name: 'statsScreen',
      desc: '',
      args: [],
    );
  }

  /// `Loading store information...`
  String get loadingStoreInformation {
    return Intl.message(
      'Loading store information...',
      name: 'loadingStoreInformation',
      desc: '',
      args: [],
    );
  }

  /// `$name x$quantity`
  String priceText(String name, String quantity) {
    return Intl.message(
      '\$name x\$quantity',
      name: 'priceText',
      desc: '',
      args: [name, quantity],
    );
  }

  /// `Tip must be $0.00 or between $1.00 and $100.00.`
  String get tipValidationMessage {
    return Intl.message(
      'Tip must be \$0.00 or between \$1.00 and \$100.00.',
      name: 'tipValidationMessage',
      desc: '',
      args: [],
    );
  }

  /// `Failed to initialize payment sheet`
  String get failedToInitializePayment {
    return Intl.message(
      'Failed to initialize payment sheet',
      name: 'failedToInitializePayment',
      desc: '',
      args: [],
    );
  }

  /// `Payment completed!`
  String get paymentCompleted {
    return Intl.message(
      'Payment completed!',
      name: 'paymentCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Stripe error: {message}`
  String stripeError(String message) {
    return Intl.message(
      'Stripe error: $message',
      name: 'stripeError',
      desc: '',
      args: [message],
    );
  }

  /// `Unexpected error: {error}`
  String unexpectedError(String error) {
    return Intl.message(
      'Unexpected error: $error',
      name: 'unexpectedError',
      desc: '',
      args: [error],
    );
  }

  /// `Error loading wallet data: {error}`
  String errorLoadingWalletData(String error) {
    return Intl.message(
      'Error loading wallet data: $error',
      name: 'errorLoadingWalletData',
      desc: '',
      args: [error],
    );
  }

  /// `Delivery Method`
  String get deliveryMethod {
    return Intl.message(
      'Delivery Method',
      name: 'deliveryMethod',
      desc: '',
      args: [],
    );
  }

  /// `Method`
  String get method {
    return Intl.message('Method', name: 'method', desc: '', args: []);
  }

  /// `Store Information`
  String get storeInformation {
    return Intl.message(
      'Store Information',
      name: 'storeInformation',
      desc: '',
      args: [],
    );
  }

  /// `Rated`
  String get rated {
    return Intl.message('Rated', name: 'rated', desc: '', args: []);
  }

  /// `Loading order details...`
  String get loadingOrderDetails {
    return Intl.message(
      'Loading order details...',
      name: 'loadingOrderDetails',
      desc: '',
      args: [],
    );
  }

  /// `Operation failed`
  String get storeNavigation_operationFailed {
    return Intl.message(
      'Operation failed',
      name: 'storeNavigation_operationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get storeNavigation_retry {
    return Intl.message(
      'Retry',
      name: 'storeNavigation_retry',
      desc: '',
      args: [],
    );
  }

  /// `Initializing...`
  String get storeNavigation_initializing {
    return Intl.message(
      'Initializing...',
      name: 'storeNavigation_initializing',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retryAction {
    return Intl.message('Retry', name: 'retryAction', desc: '', args: []);
  }

  /// `Initializing...`
  String get initializing {
    return Intl.message(
      'Initializing...',
      name: 'initializing',
      desc: '',
      args: [],
    );
  }

  /// `Delete Ingredient`
  String get deleteIngredient {
    return Intl.message(
      'Delete Ingredient',
      name: 'deleteIngredient',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this ingredient?`
  String get deleteIngredientContent {
    return Intl.message(
      'Are you sure you want to delete this ingredient?',
      name: 'deleteIngredientContent',
      desc: '',
      args: [],
    );
  }

  /// `All files uploaded successfully`
  String get allFilesUploadedSuccessfully {
    return Intl.message(
      'All files uploaded successfully',
      name: 'allFilesUploadedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Location is required`
  String get locationRequired {
    return Intl.message(
      'Location is required',
      name: 'locationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Could not retrieve address details`
  String get couldNotRetrieveAddressDetails {
    return Intl.message(
      'Could not retrieve address details',
      name: 'couldNotRetrieveAddressDetails',
      desc: '',
      args: [],
    );
  }

  /// `or use current location`
  String get orUseCurrentLocation {
    return Intl.message(
      'or use current location',
      name: 'orUseCurrentLocation',
      desc: '',
      args: [],
    );
  }

  /// `Tap to change location`
  String get tapToChangeLocation {
    return Intl.message(
      'Tap to change location',
      name: 'tapToChangeLocation',
      desc: '',
      args: [],
    );
  }

  /// `Rate Dish`
  String get dishReviews_rateDish {
    return Intl.message(
      'Rate Dish',
      name: 'dishReviews_rateDish',
      desc: '',
      args: [],
    );
  }

  /// `Comment (Optional)`
  String get dishReviews_ratingCommentLabel {
    return Intl.message(
      'Comment (Optional)',
      name: 'dishReviews_ratingCommentLabel',
      desc: '',
      args: [],
    );
  }

  /// `Share your experience with this dish...`
  String get dishReviews_ratingCommentHint {
    return Intl.message(
      'Share your experience with this dish...',
      name: 'dishReviews_ratingCommentHint',
      desc: '',
      args: [],
    );
  }

  /// `Submit Review`
  String get dishReviews_submitReview {
    return Intl.message(
      'Submit Review',
      name: 'dishReviews_submitReview',
      desc: '',
      args: [],
    );
  }

  /// `reviews`
  String get dishReviews_reviews {
    return Intl.message(
      'reviews',
      name: 'dishReviews_reviews',
      desc: '',
      args: [],
    );
  }

  /// `Your Review`
  String get dishReviews_yourReview {
    return Intl.message(
      'Your Review',
      name: 'dishReviews_yourReview',
      desc: '',
      args: [],
    );
  }

  /// `Add Address`
  String get editAddress_addTitle {
    return Intl.message(
      'Add Address',
      name: 'editAddress_addTitle',
      desc: '',
      args: [],
    );
  }

  /// `Edit Address`
  String get editAddress_editTitle {
    return Intl.message(
      'Edit Address',
      name: 'editAddress_editTitle',
      desc: '',
      args: [],
    );
  }

  /// `Street Address`
  String get editAddress_streetLabel {
    return Intl.message(
      'Street Address',
      name: 'editAddress_streetLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter street address`
  String get editAddress_streetHint {
    return Intl.message(
      'Enter street address',
      name: 'editAddress_streetHint',
      desc: '',
      args: [],
    );
  }

  /// `Processing...`
  String get editAddress_processing {
    return Intl.message(
      'Processing...',
      name: 'editAddress_processing',
      desc: '',
      args: [],
    );
  }

  /// `Save Address`
  String get editAddress_saveButton {
    return Intl.message(
      'Save Address',
      name: 'editAddress_saveButton',
      desc: '',
      args: [],
    );
  }

  /// `Update Address`
  String get editAddress_updateButton {
    return Intl.message(
      'Update Address',
      name: 'editAddress_updateButton',
      desc: '',
      args: [],
    );
  }

  /// `Select Location on Map`
  String get editAddress_mapTitle {
    return Intl.message(
      'Select Location on Map',
      name: 'editAddress_mapTitle',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get address`
  String get editAddress_failedToGetAddress {
    return Intl.message(
      'Failed to get address',
      name: 'editAddress_failedToGetAddress',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update location`
  String get editAddress_failedToUpdateLocation {
    return Intl.message(
      'Failed to update location',
      name: 'editAddress_failedToUpdateLocation',
      desc: '',
      args: [],
    );
  }

  /// `VOS VOISINS, VOS CHEFS`
  String get googleRegister_slogan {
    return Intl.message(
      'VOS VOISINS, VOS CHEFS',
      name: 'googleRegister_slogan',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get googleRegister_firstNameLabel {
    return Intl.message(
      'First Name',
      name: 'googleRegister_firstNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `John`
  String get googleRegister_firstNameHint {
    return Intl.message(
      'John',
      name: 'googleRegister_firstNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Last Name`
  String get googleRegister_lastNameLabel {
    return Intl.message(
      'Last Name',
      name: 'googleRegister_lastNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Doe`
  String get googleRegister_lastNameHint {
    return Intl.message(
      'Doe',
      name: 'googleRegister_lastNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Email :`
  String get googleRegister_emailLabel {
    return Intl.message(
      'Email :',
      name: 'googleRegister_emailLabel',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email`
  String get googleRegister_emailHint {
    return Intl.message(
      'Enter your email',
      name: 'googleRegister_emailHint',
      desc: '',
      args: [],
    );
  }

  /// `First name is required`
  String get googleRegister_validationFirstNameRequired {
    return Intl.message(
      'First name is required',
      name: 'googleRegister_validationFirstNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Last name is required`
  String get googleRegister_validationLastNameRequired {
    return Intl.message(
      'Last name is required',
      name: 'googleRegister_validationLastNameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Phone number is required`
  String get googleRegister_validationPhoneRequired {
    return Intl.message(
      'Phone number is required',
      name: 'googleRegister_validationPhoneRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid phone number`
  String get googleRegister_validationPhoneInvalid {
    return Intl.message(
      'Enter a valid phone number',
      name: 'googleRegister_validationPhoneInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Required field`
  String get googleRegister_requiredField {
    return Intl.message(
      'Required field',
      name: 'googleRegister_requiredField',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get googleRegister_button {
    return Intl.message(
      'Register',
      name: 'googleRegister_button',
      desc: '',
      args: [],
    );
  }

  /// `Operation failed`
  String get googleRegister_operationFailed {
    return Intl.message(
      'Operation failed',
      name: 'googleRegister_operationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get dishList_retry {
    return Intl.message('Retry', name: 'dishList_retry', desc: '', args: []);
  }

  /// `No recipes found`
  String get dishList_noRecipes {
    return Intl.message(
      'No recipes found',
      name: 'dishList_noRecipes',
      desc: '',
      args: [],
    );
  }

  /// `Ingredients`
  String get ingredients_title {
    return Intl.message(
      'Ingredients',
      name: 'ingredients_title',
      desc: '',
      args: [],
    );
  }

  /// `No ingredients available`
  String get ingredients_empty {
    return Intl.message(
      'No ingredients available',
      name: 'ingredients_empty',
      desc: '',
      args: [],
    );
  }

  /// `Terms and Conditions`
  String get login_termsAndConditions {
    return Intl.message(
      'Terms and Conditions',
      name: 'login_termsAndConditions',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get login_privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'login_privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Manage Ingredients`
  String get manageDishIngredients_title {
    return Intl.message(
      'Manage Ingredients',
      name: 'manageDishIngredients_title',
      desc: '',
      args: [],
    );
  }

  /// `Edit Dish Ingredients`
  String get manageDishIngredients_editTitle {
    return Intl.message(
      'Edit Dish Ingredients',
      name: 'manageDishIngredients_editTitle',
      desc: '',
      args: [],
    );
  }

  /// `Dish Ingredients`
  String get manageDishIngredients_ingredientsTitle {
    return Intl.message(
      'Dish Ingredients',
      name: 'manageDishIngredients_ingredientsTitle',
      desc: '',
      args: [],
    );
  }

  /// `linked ingredients`
  String get manageDishIngredients_linkedIngredients {
    return Intl.message(
      'linked ingredients',
      name: 'manageDishIngredients_linkedIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get manageDishIngredients_total {
    return Intl.message(
      'Total',
      name: 'manageDishIngredients_total',
      desc: '',
      args: [],
    );
  }

  /// `Link Ingredients`
  String get manageDishIngredients_linkIngredients {
    return Intl.message(
      'Link Ingredients',
      name: 'manageDishIngredients_linkIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Manage Ingredients`
  String get manageDishIngredients_manageIngredients {
    return Intl.message(
      'Manage Ingredients',
      name: 'manageDishIngredients_manageIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Sort by Name`
  String get manageDishIngredients_sortByName {
    return Intl.message(
      'Sort by Name',
      name: 'manageDishIngredients_sortByName',
      desc: '',
      args: [],
    );
  }

  /// `Sort by Price`
  String get manageDishIngredients_sortByPrice {
    return Intl.message(
      'Sort by Price',
      name: 'manageDishIngredients_sortByPrice',
      desc: '',
      args: [],
    );
  }

  /// `Sort by Type`
  String get manageDishIngredients_sortByType {
    return Intl.message(
      'Sort by Type',
      name: 'manageDishIngredients_sortByType',
      desc: '',
      args: [],
    );
  }

  /// `Sorted by {sortBy}`
  String manageDishIngredients_sortedBy(String sortBy) {
    return Intl.message(
      'Sorted by $sortBy',
      name: 'manageDishIngredients_sortedBy',
      desc: '',
      args: [sortBy],
    );
  }

  /// `Delete Dish`
  String get manageDishIngredients_deleteTitle {
    return Intl.message(
      'Delete Dish',
      name: 'manageDishIngredients_deleteTitle',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get manageDishIngredients_deleteCancel {
    return Intl.message(
      'Cancel',
      name: 'manageDishIngredients_deleteCancel',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get manageDishIngredients_deleteConfirm {
    return Intl.message(
      'Delete',
      name: 'manageDishIngredients_deleteConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Ingredient removed from dish successfully`
  String get manageDishIngredients_ingredientRemovedSuccessfully {
    return Intl.message(
      'Ingredient removed from dish successfully',
      name: 'manageDishIngredients_ingredientRemovedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Loading ingredients...`
  String get manageDishIngredients_loadingIngredients {
    return Intl.message(
      'Loading ingredients...',
      name: 'manageDishIngredients_loadingIngredients',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get manageDishIngredients_retry {
    return Intl.message(
      'Retry',
      name: 'manageDishIngredients_retry',
      desc: '',
      args: [],
    );
  }

  /// `No ingredients in this dish`
  String get manageDishIngredients_emptyEditing {
    return Intl.message(
      'No ingredients in this dish',
      name: 'manageDishIngredients_emptyEditing',
      desc: '',
      args: [],
    );
  }

  /// `Order Status`
  String get orderFilter_labelStatus {
    return Intl.message(
      'Order Status',
      name: 'orderFilter_labelStatus',
      desc: '',
      args: [],
    );
  }

  /// `Payment Status`
  String get orderFilter_labelPaymentStatus {
    return Intl.message(
      'Payment Status',
      name: 'orderFilter_labelPaymentStatus',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Status`
  String get orderFilter_labelDeliveryStatus {
    return Intl.message(
      'Delivery Status',
      name: 'orderFilter_labelDeliveryStatus',
      desc: '',
      args: [],
    );
  }

  /// `Sort By`
  String get orderFilter_labelSortBy {
    return Intl.message(
      'Sort By',
      name: 'orderFilter_labelSortBy',
      desc: '',
      args: [],
    );
  }

  /// `Order`
  String get orderFilter_labelSortOrder {
    return Intl.message(
      'Order',
      name: 'orderFilter_labelSortOrder',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get orderFilter_optionAll {
    return Intl.message(
      'All',
      name: 'orderFilter_optionAll',
      desc: '',
      args: [],
    );
  }

  /// `Ascending`
  String get orderFilter_optionAsc {
    return Intl.message(
      'Ascending',
      name: 'orderFilter_optionAsc',
      desc: '',
      args: [],
    );
  }

  /// `Descending`
  String get orderFilter_optionDesc {
    return Intl.message(
      'Descending',
      name: 'orderFilter_optionDesc',
      desc: '',
      args: [],
    );
  }

  /// `No ingredients added yet`
  String get manageDishIngredients_emptyDefault {
    return Intl.message(
      'No ingredients added yet',
      name: 'manageDishIngredients_emptyDefault',
      desc: '',
      args: [],
    );
  }

  /// `Link ingredients from your seller list or manage your ingredient library`
  String get manageDishIngredients_linkIngredientsHint {
    return Intl.message(
      'Link ingredients from your seller list or manage your ingredient library',
      name: 'manageDishIngredients_linkIngredientsHint',
      desc: '',
      args: [],
    );
  }

  /// `SERVICE AGREEMENT v.1`
  String get vendorAgreement_title {
    return Intl.message(
      'SERVICE AGREEMENT v.1',
      name: 'vendorAgreement_title',
      desc: '',
      args: [],
    );
  }

  /// `This Service Agreement (the “Agreement”) is entered into and becomes effective on the date and at the time of its electronic acceptance by the Vendor through the Cuisinous platform.\n\nBETWEEN:\n9534-9072 QUÉBEC INC., a corporation duly incorporated under the Business Corporations Act, having its registered office at 401-5131, Place Leblanc, in the city of Sainte-Catherine, Province of Québec, J5C 1G6;\n(hereinafter referred to as “Cuisinous”)\n\nAND:\nAny natural or legal person who has created a vendor account on the Cuisinous platform and has accepted this Agreement electronically, whose identity, contact details, and relevant information are those provided at the time of vendor account creation;\n(hereinafter referred to as the “Vendor”)\n\n(Cuisinous and the Vendor are hereinafter collectively referred to as the “Parties”)`
  String get vendorAgreement_intro {
    return Intl.message(
      'This Service Agreement (the “Agreement”) is entered into and becomes effective on the date and at the time of its electronic acceptance by the Vendor through the Cuisinous platform.\n\nBETWEEN:\n9534-9072 QUÉBEC INC., a corporation duly incorporated under the Business Corporations Act, having its registered office at 401-5131, Place Leblanc, in the city of Sainte-Catherine, Province of Québec, J5C 1G6;\n(hereinafter referred to as “Cuisinous”)\n\nAND:\nAny natural or legal person who has created a vendor account on the Cuisinous platform and has accepted this Agreement electronically, whose identity, contact details, and relevant information are those provided at the time of vendor account creation;\n(hereinafter referred to as the “Vendor”)\n\n(Cuisinous and the Vendor are hereinafter collectively referred to as the “Parties”)',
      name: 'vendorAgreement_intro',
      desc: '',
      args: [],
    );
  }

  /// `PREAMBLE`
  String get vendorAgreement_preambleTitle {
    return Intl.message(
      'PREAMBLE',
      name: 'vendorAgreement_preambleTitle',
      desc: '',
      args: [],
    );
  }

  /// `A. Use of Platform.\nBy electronically accepting this Agreement, the Vendor acknowledges having carefully read, understood, and unconditionally accepted all of its terms, as well as any related documents, policies, or conditions, where applicable.\n\nB. Nature of Service.\nThe Vendor acknowledges that Cuisinous acts solely as a technology matchmaking platform, that it does not engage in any food preparation, manufacturing, processing, storage, inspection, or delivery activities, and that it assumes no responsibility whatsoever for the food products offered by the Vendor.\n\nC. Independent Status.\nThe Vendor further acknowledges acting independently, as a self-employed individual, and assumes full responsibility for its activities, products, operations, and legal obligations.\n\nD. Electronic Consent.\nThe electronic acceptance of this Agreement constitutes free and informed consent and has the same legal value as a handwritten signature, in accordance with applicable Québec laws.`
  String get vendorAgreement_preambleBody {
    return Intl.message(
      'A. Use of Platform.\nBy electronically accepting this Agreement, the Vendor acknowledges having carefully read, understood, and unconditionally accepted all of its terms, as well as any related documents, policies, or conditions, where applicable.\n\nB. Nature of Service.\nThe Vendor acknowledges that Cuisinous acts solely as a technology matchmaking platform, that it does not engage in any food preparation, manufacturing, processing, storage, inspection, or delivery activities, and that it assumes no responsibility whatsoever for the food products offered by the Vendor.\n\nC. Independent Status.\nThe Vendor further acknowledges acting independently, as a self-employed individual, and assumes full responsibility for its activities, products, operations, and legal obligations.\n\nD. Electronic Consent.\nThe electronic acceptance of this Agreement constitutes free and informed consent and has the same legal value as a handwritten signature, in accordance with applicable Québec laws.',
      name: 'vendorAgreement_preambleBody',
      desc: '',
      args: [],
    );
  }

  /// `1. PURPOSE`
  String get vendorAgreement_section1Title {
    return Intl.message(
      '1. PURPOSE',
      name: 'vendorAgreement_section1Title',
      desc: '',
      args: [],
    );
  }

  /// `1.1. Cuisinous operates a technology platform that facilitates connections between food product Vendors and Customers.\n\n1.2. Cuisinous does not engage in any food preparation, manufacturing, processing, storage, inspection, or delivery activities and is in no way a restaurateur, employer, agent, or representative of the Vendor.\n\n1.3. This Agreement defines the rights and obligations of the Vendor and Cuisinous regarding the use of the platform.`
  String get vendorAgreement_section1Body {
    return Intl.message(
      '1.1. Cuisinous operates a technology platform that facilitates connections between food product Vendors and Customers.\n\n1.2. Cuisinous does not engage in any food preparation, manufacturing, processing, storage, inspection, or delivery activities and is in no way a restaurateur, employer, agent, or representative of the Vendor.\n\n1.3. This Agreement defines the rights and obligations of the Vendor and Cuisinous regarding the use of the platform.',
      name: 'vendorAgreement_section1Body',
      desc: '',
      args: [],
    );
  }

  /// `2. INDEPENDENT VENDOR STATUS`
  String get vendorAgreement_section2Title {
    return Intl.message(
      '2. INDEPENDENT VENDOR STATUS',
      name: 'vendorAgreement_section2Title',
      desc: '',
      args: [],
    );
  }

  /// `2.1. The Vendor acts as an independent contractor and operates its business independently. Nothing in this Agreement shall be construed as creating an employment, agency, partnership, joint venture, or representative relationship between the Vendor and Cuisinous.\n\n2.2. The Vendor assumes all risks and responsibilities related to its business, including applicable tax, social, and regulatory obligations.`
  String get vendorAgreement_section2Body {
    return Intl.message(
      '2.1. The Vendor acts as an independent contractor and operates its business independently. Nothing in this Agreement shall be construed as creating an employment, agency, partnership, joint venture, or representative relationship between the Vendor and Cuisinous.\n\n2.2. The Vendor assumes all risks and responsibilities related to its business, including applicable tax, social, and regulatory obligations.',
      name: 'vendorAgreement_section2Body',
      desc: '',
      args: [],
    );
  }

  /// `3. VENDOR OBLIGATIONS`
  String get vendorAgreement_section3Title {
    return Intl.message(
      '3. VENDOR OBLIGATIONS',
      name: 'vendorAgreement_section3Title',
      desc: '',
      args: [],
    );
  }

  /// `3.1. The Vendor is solely and fully responsible for, without limitation:\n\na) food safety, hygiene, and sanitation;\nb) product quality, labeling, composition, and allergen disclosure;\nc) preparation, storage, and distribution methods;\nd) obtaining and maintaining all required permits, licenses, and certifications, including those issued by the Québec Ministry of Agriculture, Fisheries and Food (“MAPAQ”);\ne) compliance with all applicable laws and regulations;\nf) the accuracy and truthfulness of information provided to Cuisinous;\ng) respecting intellectual property rights and refraining from selling counterfeit, illegal, or infringing products.\n\n3.2. Cuisinous does not verify, inspect, or certify the Vendor’s activities, kitchen, products, operations, permits, or insurance.\n\n3.3. The Vendor agrees to immediately notify Cuisinous of any change, suspension, or revocation of permits or certifications, or any information that may affect food safety, legal compliance, or the performance of this Agreement.`
  String get vendorAgreement_section3Body {
    return Intl.message(
      '3.1. The Vendor is solely and fully responsible for, without limitation:\n\na) food safety, hygiene, and sanitation;\nb) product quality, labeling, composition, and allergen disclosure;\nc) preparation, storage, and distribution methods;\nd) obtaining and maintaining all required permits, licenses, and certifications, including those issued by the Québec Ministry of Agriculture, Fisheries and Food (“MAPAQ”);\ne) compliance with all applicable laws and regulations;\nf) the accuracy and truthfulness of information provided to Cuisinous;\ng) respecting intellectual property rights and refraining from selling counterfeit, illegal, or infringing products.\n\n3.2. Cuisinous does not verify, inspect, or certify the Vendor’s activities, kitchen, products, operations, permits, or insurance.\n\n3.3. The Vendor agrees to immediately notify Cuisinous of any change, suspension, or revocation of permits or certifications, or any information that may affect food safety, legal compliance, or the performance of this Agreement.',
      name: 'vendorAgreement_section3Body',
      desc: '',
      args: [],
    );
  }

  /// `4. VENDOR REPRESENTATIONS AND WARRANTIES`
  String get vendorAgreement_section4Title {
    return Intl.message(
      '4. VENDOR REPRESENTATIONS AND WARRANTIES',
      name: 'vendorAgreement_section4Title',
      desc: '',
      args: [],
    );
  }

  /// `4.1. The Vendor represents and warrants that it:\n\na) holds all required permits and certifications, which are valid and up to date;\nb) complies with all applicable laws, regulations, and standards;\nc) assumes full responsibility for its products and operations;\nd) agrees to indemnify and hold harmless Cuisinous, its directors, officers, and partners from any claim, fine, damage, or action arising from the Vendor’s non-compliance;\ne) acknowledges that providing false, misleading, or outdated information constitutes a material breach of this Agreement and may result in immediate suspension or termination;\nf) maintains, at its own expense, throughout the term of this Agreement, adequate civil liability insurance covering its activities, products, and any resulting bodily injury, property damage, or financial loss.\n\n4.2. The Vendor expressly acknowledges and agrees that Cuisinous does not require, verify, validate, or retain any proof of the Vendor’s insurance, and that the absence, insufficiency, invalidity, or non-compliance of the Vendor’s insurance shall in no event engage the liability of Cuisinous. The Vendor expressly releases Cuisinous from any liability, claim, or obligation arising from the Vendor’s failure to maintain adequate insurance.\n\n4.3. The Vendor acknowledges being entirely responsible for food safety, hygiene, ingredient accuracy, allergen disclosure, cross-contamination risks, and any consequences arising from the consumption of food sold through Cuisinous.`
  String get vendorAgreement_section4Body {
    return Intl.message(
      '4.1. The Vendor represents and warrants that it:\n\na) holds all required permits and certifications, which are valid and up to date;\nb) complies with all applicable laws, regulations, and standards;\nc) assumes full responsibility for its products and operations;\nd) agrees to indemnify and hold harmless Cuisinous, its directors, officers, and partners from any claim, fine, damage, or action arising from the Vendor’s non-compliance;\ne) acknowledges that providing false, misleading, or outdated information constitutes a material breach of this Agreement and may result in immediate suspension or termination;\nf) maintains, at its own expense, throughout the term of this Agreement, adequate civil liability insurance covering its activities, products, and any resulting bodily injury, property damage, or financial loss.\n\n4.2. The Vendor expressly acknowledges and agrees that Cuisinous does not require, verify, validate, or retain any proof of the Vendor’s insurance, and that the absence, insufficiency, invalidity, or non-compliance of the Vendor’s insurance shall in no event engage the liability of Cuisinous. The Vendor expressly releases Cuisinous from any liability, claim, or obligation arising from the Vendor’s failure to maintain adequate insurance.\n\n4.3. The Vendor acknowledges being entirely responsible for food safety, hygiene, ingredient accuracy, allergen disclosure, cross-contamination risks, and any consequences arising from the consumption of food sold through Cuisinous.',
      name: 'vendorAgreement_section4Body',
      desc: '',
      args: [],
    );
  }

  /// `5. FEES AND CIRCUMVENTION PROHIBITION`
  String get vendorAgreement_section5Title {
    return Intl.message(
      '5. FEES AND CIRCUMVENTION PROHIBITION',
      name: 'vendorAgreement_section5Title',
      desc: '',
      args: [],
    );
  }

  /// `5.1. The Vendor agrees to pay all applicable fees related to the use of the platform.\n\n5.2. The Vendor is strictly prohibited from bypassing the platform to conduct direct transactions with Customers obtained through Cuisinous. Any violation authorizes Cuisinous to immediately suspend or terminate the Vendor’s account and pursue available remedies.`
  String get vendorAgreement_section5Body {
    return Intl.message(
      '5.1. The Vendor agrees to pay all applicable fees related to the use of the platform.\n\n5.2. The Vendor is strictly prohibited from bypassing the platform to conduct direct transactions with Customers obtained through Cuisinous. Any violation authorizes Cuisinous to immediately suspend or terminate the Vendor’s account and pursue available remedies.',
      name: 'vendorAgreement_section5Body',
      desc: '',
      args: [],
    );
  }

  /// `6. PAYMENT TERMS`
  String get vendorAgreement_section6Title {
    return Intl.message(
      '6. PAYMENT TERMS',
      name: 'vendorAgreement_section6Title',
      desc: '',
      args: [],
    );
  }

  /// `6.1. All Customer payments and amounts payable to the Vendor are processed exclusively through an independent third-party payment service provider, including Stripe or any equivalent provider.\n\n6.2. The Vendor acknowledges that Cuisinous is not a financial institution and does not act as a payment intermediary, trustee, or fund custodian, and does not store, process, or retain any banking, financial, or credit card information.\n\n6.3. The Vendor acknowledges that payment execution, processing, authorization, settlement, and disbursement are the sole responsibility of the third-party payment provider.\n\n6.4. The Vendor understands that Cuisinous cannot be held liable for any error, omission, delay, interruption, failure, payment refusal, fund hold, account suspension, or security incident attributable to the third-party payment provider or its systems.`
  String get vendorAgreement_section6Body {
    return Intl.message(
      '6.1. All Customer payments and amounts payable to the Vendor are processed exclusively through an independent third-party payment service provider, including Stripe or any equivalent provider.\n\n6.2. The Vendor acknowledges that Cuisinous is not a financial institution and does not act as a payment intermediary, trustee, or fund custodian, and does not store, process, or retain any banking, financial, or credit card information.\n\n6.3. The Vendor acknowledges that payment execution, processing, authorization, settlement, and disbursement are the sole responsibility of the third-party payment provider.\n\n6.4. The Vendor understands that Cuisinous cannot be held liable for any error, omission, delay, interruption, failure, payment refusal, fund hold, account suspension, or security incident attributable to the third-party payment provider or its systems.',
      name: 'vendorAgreement_section6Body',
      desc: '',
      args: [],
    );
  }

  /// `7. LIMITATION OF LIABILITY`
  String get vendorAgreement_section7Title {
    return Intl.message(
      '7. LIMITATION OF LIABILITY',
      name: 'vendorAgreement_section7Title',
      desc: '',
      args: [],
    );
  }

  /// `7.1. The Vendor acknowledges that Cuisinous acts solely as a technology platform provider and matchmaking intermediary and does not intervene in any manner in food preparation, manufacturing, processing, storage, packaging, labeling, handling, delivery, or sale.\n\n7.2. To the fullest extent permitted by law, Cuisinous and its directors, officers, employees, shareholders, and partners shall not be liable for any direct or indirect, incidental, consequential, special, or punitive damages, including:\n\na) illness, food poisoning, allergic reactions, bodily injury, or death;\nb) loss of income, business, or reputation;\nc) claims, complaints, penalties, fines, or legal actions by customers, third parties, or regulators;\n\narising directly or indirectly from the Vendor’s food, ingredients, information, omissions, or activities.\n\n7.3. Cuisinous provides no express or implied warranty regarding the quality, safety, legality, regulatory compliance, or fitness for consumption of Vendor products.\n\n7.4. The Vendor expressly waives any claim against Cuisinous relating to damages arising from Vendor food products or platform use, except in cases of gross negligence or intentional misconduct by Cuisinous.`
  String get vendorAgreement_section7Body {
    return Intl.message(
      '7.1. The Vendor acknowledges that Cuisinous acts solely as a technology platform provider and matchmaking intermediary and does not intervene in any manner in food preparation, manufacturing, processing, storage, packaging, labeling, handling, delivery, or sale.\n\n7.2. To the fullest extent permitted by law, Cuisinous and its directors, officers, employees, shareholders, and partners shall not be liable for any direct or indirect, incidental, consequential, special, or punitive damages, including:\n\na) illness, food poisoning, allergic reactions, bodily injury, or death;\nb) loss of income, business, or reputation;\nc) claims, complaints, penalties, fines, or legal actions by customers, third parties, or regulators;\n\narising directly or indirectly from the Vendor’s food, ingredients, information, omissions, or activities.\n\n7.3. Cuisinous provides no express or implied warranty regarding the quality, safety, legality, regulatory compliance, or fitness for consumption of Vendor products.\n\n7.4. The Vendor expressly waives any claim against Cuisinous relating to damages arising from Vendor food products or platform use, except in cases of gross negligence or intentional misconduct by Cuisinous.',
      name: 'vendorAgreement_section7Body',
      desc: '',
      args: [],
    );
  }

  /// `8. INDEMNIFICATION`
  String get vendorAgreement_section8Title {
    return Intl.message(
      '8. INDEMNIFICATION',
      name: 'vendorAgreement_section8Title',
      desc: '',
      args: [],
    );
  }

  /// `8.1. The Vendor agrees to indemnify, defend, and hold harmless Cuisinous and its directors, officers, employees, shareholders, representatives, and partners from any claim, demand, complaint, lawsuit, investigation, sanction, fine, penalty, damage, loss, liability, cost, or expense (including legal and expert fees on a solicitor-client basis) arising directly or indirectly from:\n\na) food, ingredients, products, or services offered by the Vendor;\nb) illness, food poisoning, allergic reactions, injury, death, or health impacts;\nc) non-compliance with laws, regulations, or MAPAQ requirements;\nd) false, misleading, incomplete, or outdated information provided by the Vendor;\ne) any breach of this Agreement or related policies;\nf) any actual or alleged violation of customer, third-party, or governmental rights.\n\n8.2. At Cuisinous’ request, the Vendor shall assume the full defense of such claims, at its expense, with counsel reasonably acceptable to Cuisinous. Cuisinous may participate in the defense at its own expense.\n\n8.3. These indemnification obligations survive termination or expiration of this Agreement.`
  String get vendorAgreement_section8Body {
    return Intl.message(
      '8.1. The Vendor agrees to indemnify, defend, and hold harmless Cuisinous and its directors, officers, employees, shareholders, representatives, and partners from any claim, demand, complaint, lawsuit, investigation, sanction, fine, penalty, damage, loss, liability, cost, or expense (including legal and expert fees on a solicitor-client basis) arising directly or indirectly from:\n\na) food, ingredients, products, or services offered by the Vendor;\nb) illness, food poisoning, allergic reactions, injury, death, or health impacts;\nc) non-compliance with laws, regulations, or MAPAQ requirements;\nd) false, misleading, incomplete, or outdated information provided by the Vendor;\ne) any breach of this Agreement or related policies;\nf) any actual or alleged violation of customer, third-party, or governmental rights.\n\n8.2. At Cuisinous’ request, the Vendor shall assume the full defense of such claims, at its expense, with counsel reasonably acceptable to Cuisinous. Cuisinous may participate in the defense at its own expense.\n\n8.3. These indemnification obligations survive termination or expiration of this Agreement.',
      name: 'vendorAgreement_section8Body',
      desc: '',
      args: [],
    );
  }

  /// `9. SUSPENSION AND TERMINATION`
  String get vendorAgreement_section9Title {
    return Intl.message(
      '9. SUSPENSION AND TERMINATION',
      name: 'vendorAgreement_section9Title',
      desc: '',
      args: [],
    );
  }

  /// `9.1. Cuisinous reserves the right, at its sole discretion, to suspend, restrict, remove products, disable platform access, or terminate the Vendor’s account at any time, with or without notice, including in cases of:\n\na) breach of this Agreement or related policies;\nb) false or misleading information;\nc) non-compliance with laws or food safety regulations;\nd) health or safety risks;\ne) regulatory complaints or investigations;\nf) reputational harm;\ng) reasonable suspicion of fraud or serious misconduct.\n\n9.2. Suspension or termination does not entitle the Vendor to any compensation or refund.\n\n9.3. Termination does not affect obligations that by their nature survive, including payment, confidentiality, indemnification, and liability provisions.`
  String get vendorAgreement_section9Body {
    return Intl.message(
      '9.1. Cuisinous reserves the right, at its sole discretion, to suspend, restrict, remove products, disable platform access, or terminate the Vendor’s account at any time, with or without notice, including in cases of:\n\na) breach of this Agreement or related policies;\nb) false or misleading information;\nc) non-compliance with laws or food safety regulations;\nd) health or safety risks;\ne) regulatory complaints or investigations;\nf) reputational harm;\ng) reasonable suspicion of fraud or serious misconduct.\n\n9.2. Suspension or termination does not entitle the Vendor to any compensation or refund.\n\n9.3. Termination does not affect obligations that by their nature survive, including payment, confidentiality, indemnification, and liability provisions.',
      name: 'vendorAgreement_section9Body',
      desc: '',
      args: [],
    );
  }

  /// `10. CONFIDENTIALITY AND DATA PROTECTION`
  String get vendorAgreement_section10Title {
    return Intl.message(
      '10. CONFIDENTIALITY AND DATA PROTECTION',
      name: 'vendorAgreement_section10Title',
      desc: '',
      args: [],
    );
  }

  /// `10.1. “Confidential Information” includes all data or information disclosed through platform use, including customer data, transactions, pricing, business terms, platform features, technologies, and internal policies.\n\n10.2. The Vendor agrees to maintain confidentiality, use such information solely for contract performance, not disclose it without written authorization, and implement reasonable safeguards.\n\n10.3. The Vendor agrees to comply with applicable privacy laws, including Québec’s Private Sector Privacy Act, and to use customer data solely for order fulfillment.\n\n10.4. All customer and platform data remain the exclusive property of Cuisinous, subject to applicable legal rights.\n\n10.5. Confidentiality obligations survive indefinitely.\n\n10.6. Any breach may cause irreparable harm and justify injunctive relief.`
  String get vendorAgreement_section10Body {
    return Intl.message(
      '10.1. “Confidential Information” includes all data or information disclosed through platform use, including customer data, transactions, pricing, business terms, platform features, technologies, and internal policies.\n\n10.2. The Vendor agrees to maintain confidentiality, use such information solely for contract performance, not disclose it without written authorization, and implement reasonable safeguards.\n\n10.3. The Vendor agrees to comply with applicable privacy laws, including Québec’s Private Sector Privacy Act, and to use customer data solely for order fulfillment.\n\n10.4. All customer and platform data remain the exclusive property of Cuisinous, subject to applicable legal rights.\n\n10.5. Confidentiality obligations survive indefinitely.\n\n10.6. Any breach may cause irreparable harm and justify injunctive relief.',
      name: 'vendorAgreement_section10Body',
      desc: '',
      args: [],
    );
  }

  /// `11. GENERAL PROVISIONS`
  String get vendorAgreement_section11Title {
    return Intl.message(
      '11. GENERAL PROVISIONS',
      name: 'vendorAgreement_section11Title',
      desc: '',
      args: [],
    );
  }

  /// `11.1. This Agreement is governed by Québec law. Québec judicial district courts have exclusive jurisdiction.\n\n11.2. Invalid provisions shall be severed without affecting remaining provisions.\n\n11.3. Neither Party is liable for force majeure events.\n\n11.4. Cuisinous may modify this Agreement at any time. Continued platform use constitutes acceptance.\n\n11.5. Failure to enforce a right does not constitute waiver.\n\n11.6. The Vendor may not assign this Agreement without consent. Cuisinous may assign freely.\n\n11.7. This Agreement constitutes the entire agreement between the Parties.`
  String get vendorAgreement_section11Body {
    return Intl.message(
      '11.1. This Agreement is governed by Québec law. Québec judicial district courts have exclusive jurisdiction.\n\n11.2. Invalid provisions shall be severed without affecting remaining provisions.\n\n11.3. Neither Party is liable for force majeure events.\n\n11.4. Cuisinous may modify this Agreement at any time. Continued platform use constitutes acceptance.\n\n11.5. Failure to enforce a right does not constitute waiver.\n\n11.6. The Vendor may not assign this Agreement without consent. Cuisinous may assign freely.\n\n11.7. This Agreement constitutes the entire agreement between the Parties.',
      name: 'vendorAgreement_section11Body',
      desc: '',
      args: [],
    );
  }

  /// `12. ELECTRONIC ACCEPTANCE AND CONSENT`
  String get vendorAgreement_section12Title {
    return Intl.message(
      '12. ELECTRONIC ACCEPTANCE AND CONSENT',
      name: 'vendorAgreement_section12Title',
      desc: '',
      args: [],
    );
  }

  /// `12.1. Acceptance via “Accept and Continue” or continued platform use constitutes valid electronic signature under Québec law.\n\n12.2. The Vendor confirms that consent is given freely and knowingly after full review.`
  String get vendorAgreement_section12Body {
    return Intl.message(
      '12.1. Acceptance via “Accept and Continue” or continued platform use constitutes valid electronic signature under Québec law.\n\n12.2. The Vendor confirms that consent is given freely and knowingly after full review.',
      name: 'vendorAgreement_section12Body',
      desc: '',
      args: [],
    );
  }

  /// `Agree and Continue`
  String get vendorAgreement_agreeAndContinue {
    return Intl.message(
      'Agree and Continue',
      name: 'vendorAgreement_agreeAndContinue',
      desc: '',
      args: [],
    );
  }

  /// `Finish Editing`
  String get manageDishIngredients_finishEditing {
    return Intl.message(
      'Finish Editing',
      name: 'manageDishIngredients_finishEditing',
      desc: '',
      args: [],
    );
  }

  /// `Link Ingredients to Dish`
  String get manageDishIngredients_linkIngredientsToDish {
    return Intl.message(
      'Link Ingredients to Dish',
      name: 'manageDishIngredients_linkIngredientsToDish',
      desc: '',
      args: [],
    );
  }

  /// `Search ingredients to link...`
  String get manageDishIngredients_searchIngredientsToLink {
    return Intl.message(
      'Search ingredients to link...',
      name: 'manageDishIngredients_searchIngredientsToLink',
      desc: '',
      args: [],
    );
  }

  /// `No ingredients found`
  String get manageDishIngredients_searchEmpty {
    return Intl.message(
      'No ingredients found',
      name: 'manageDishIngredients_searchEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Ingredient Management`
  String get manageDishIngredients_ingredientManagement {
    return Intl.message(
      'Ingredient Management',
      name: 'manageDishIngredients_ingredientManagement',
      desc: '',
      args: [],
    );
  }

  /// `Create New`
  String get manageDishIngredients_createNew {
    return Intl.message(
      'Create New',
      name: 'manageDishIngredients_createNew',
      desc: '',
      args: [],
    );
  }

  /// `Search your ingredients...`
  String get manageDishIngredients_searchYourIngredients {
    return Intl.message(
      'Search your ingredients...',
      name: 'manageDishIngredients_searchYourIngredients',
      desc: '',
      args: [],
    );
  }

  /// `No ingredients in your library`
  String get manageDishIngredients_noIngredientsInLibrary {
    return Intl.message(
      'No ingredients in your library',
      name: 'manageDishIngredients_noIngredientsInLibrary',
      desc: '',
      args: [],
    );
  }

  /// `Create your first ingredient to get started`
  String get manageDishIngredients_createYourFirstIngredient {
    return Intl.message(
      'Create your first ingredient to get started',
      name: 'manageDishIngredients_createYourFirstIngredient',
      desc: '',
      args: [],
    );
  }

  /// `Ingredient deleted successfully`
  String get manageDishIngredients_ingredientDeletedSuccessfully {
    return Intl.message(
      'Ingredient deleted successfully',
      name: 'manageDishIngredients_ingredientDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get manageDishIngredients_update {
    return Intl.message(
      'Update',
      name: 'manageDishIngredients_update',
      desc: '',
      args: [],
    );
  }

  /// `Ingredient updated successfully`
  String get manageDishIngredients_ingredientUpdatedSuccessfully {
    return Intl.message(
      'Ingredient updated successfully',
      name: 'manageDishIngredients_ingredientUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Create Ingredient`
  String get manageIngredients_createTitle {
    return Intl.message(
      'Create Ingredient',
      name: 'manageIngredients_createTitle',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get manageDishIngredients_create {
    return Intl.message(
      'Create',
      name: 'manageDishIngredients_create',
      desc: '',
      args: [],
    );
  }

  /// `Ingredient created successfully`
  String get manageDishIngredients_ingredientCreatedSuccessfully {
    return Intl.message(
      'Ingredient created successfully',
      name: 'manageDishIngredients_ingredientCreatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Link`
  String get manageDishIngredients_link {
    return Intl.message(
      'Link',
      name: 'manageDishIngredients_link',
      desc: '',
      args: [],
    );
  }

  /// `Edit Ingredient`
  String get manageDishIngredients_editDialogEdit {
    return Intl.message(
      'Edit Ingredient',
      name: 'manageDishIngredients_editDialogEdit',
      desc: '',
      args: [],
    );
  }

  /// `Add Ingredient`
  String get manageDishIngredients_editDialogAdd {
    return Intl.message(
      'Add Ingredient',
      name: 'manageDishIngredients_editDialogAdd',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get manageDishIngredients_noteSave {
    return Intl.message(
      'Save',
      name: 'manageDishIngredients_noteSave',
      desc: '',
      args: [],
    );
  }

  /// `Ingredient`
  String get manageDishIngredients_editDialogIngredient {
    return Intl.message(
      'Ingredient',
      name: 'manageDishIngredients_editDialogIngredient',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get manageDishIngredients_price {
    return Intl.message(
      'Price',
      name: 'manageDishIngredients_price',
      desc: '',
      args: [],
    );
  }

  /// `Price (Free)`
  String get manageDishIngredients_priceFree {
    return Intl.message(
      'Price (Free)',
      name: 'manageDishIngredients_priceFree',
      desc: '',
      args: [],
    );
  }

  /// `Enter price (e.g., 2.50)`
  String get manageDishIngredients_enterPriceEg250 {
    return Intl.message(
      'Enter price (e.g., 2.50)',
      name: 'manageDishIngredients_enterPriceEg250',
      desc: '',
      args: [],
    );
  }

  /// `Standard ingredients are free`
  String get manageDishIngredients_standardIngredientsAreFree {
    return Intl.message(
      'Standard ingredients are free',
      name: 'manageDishIngredients_standardIngredientsAreFree',
      desc: '',
      args: [],
    );
  }

  /// `Is Supplement`
  String get manageDishIngredients_editDialogSupplement {
    return Intl.message(
      'Is Supplement',
      name: 'manageDishIngredients_editDialogSupplement',
      desc: '',
      args: [],
    );
  }

  /// `Additional cost item`
  String get manageDishIngredients_additionalCostItem {
    return Intl.message(
      'Additional cost item',
      name: 'manageDishIngredients_additionalCostItem',
      desc: '',
      args: [],
    );
  }

  /// `Standard ingredient (free)`
  String get manageDishIngredients_standardIngredientFree {
    return Intl.message(
      'Standard ingredient (free)',
      name: 'manageDishIngredients_standardIngredientFree',
      desc: '',
      args: [],
    );
  }

  /// `Supplements must have a price greater than 0`
  String get manageDishIngredients_supplementsMustHavePrice {
    return Intl.message(
      'Supplements must have a price greater than 0',
      name: 'manageDishIngredients_supplementsMustHavePrice',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy – Cuisinous`
  String get privacyPolicy_title {
    return Intl.message(
      'Privacy Policy – Cuisinous',
      name: 'privacyPolicy_title',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Cuisinous! We value your privacy and are committed to protecting your personal information. This Privacy Policy explains what data we collect, how we use it, how it is protected, and your rights as a user of our application and website. By using Cuisinous, you agree to the practices described in this policy.`
  String get privacyPolicy_intro {
    return Intl.message(
      'Welcome to Cuisinous! We value your privacy and are committed to protecting your personal information. This Privacy Policy explains what data we collect, how we use it, how it is protected, and your rights as a user of our application and website. By using Cuisinous, you agree to the practices described in this policy.',
      name: 'privacyPolicy_intro',
      desc: '',
      args: [],
    );
  }

  /// `1. Information We Collect`
  String get privacyPolicy_section1Title {
    return Intl.message(
      '1. Information We Collect',
      name: 'privacyPolicy_section1Title',
      desc: '',
      args: [],
    );
  }

  /// `When you use our platform, we may collect the following information: Registration details: name, email address, phone number, password. Account verification: identity documents or licenses required under applicable regulations. Transaction details: order history, payments, invoices. Location data: to connect you with nearby meals and vendors. Usage data: browsing activity, preferences, ratings, and reviews.`
  String get privacyPolicy_section1Body {
    return Intl.message(
      'When you use our platform, we may collect the following information: Registration details: name, email address, phone number, password. Account verification: identity documents or licenses required under applicable regulations. Transaction details: order history, payments, invoices. Location data: to connect you with nearby meals and vendors. Usage data: browsing activity, preferences, ratings, and reviews.',
      name: 'privacyPolicy_section1Body',
      desc: '',
      args: [],
    );
  }

  /// `2. How We Use Your Information`
  String get privacyPolicy_section2Title {
    return Intl.message(
      '2. How We Use Your Information',
      name: 'privacyPolicy_section2Title',
      desc: '',
      args: [],
    );
  }

  /// `We use your personal information to: Create and manage your vendor or customer account. Facilitate secure ordering and payments. Provide personalized services (local menus, recommendations, promotions). Prevent fraud, ensure platform safety, and comply with legal obligations. Communicate with you regarding your account, orders, or updates to our services.`
  String get privacyPolicy_section2Body {
    return Intl.message(
      'We use your personal information to: Create and manage your vendor or customer account. Facilitate secure ordering and payments. Provide personalized services (local menus, recommendations, promotions). Prevent fraud, ensure platform safety, and comply with legal obligations. Communicate with you regarding your account, orders, or updates to our services.',
      name: 'privacyPolicy_section2Body',
      desc: '',
      args: [],
    );
  }

  /// `3. Sharing of Information`
  String get privacyPolicy_section3Title {
    return Intl.message(
      '3. Sharing of Information',
      name: 'privacyPolicy_section3Title',
      desc: '',
      args: [],
    );
  }

  /// `We never sell your personal information. We may share certain information only with: Secure payment providers. Delivery partners (if applicable). Legal authorities when required by law.`
  String get privacyPolicy_section3Body {
    return Intl.message(
      'We never sell your personal information. We may share certain information only with: Secure payment providers. Delivery partners (if applicable). Legal authorities when required by law.',
      name: 'privacyPolicy_section3Body',
      desc: '',
      args: [],
    );
  }

  /// `4. Data Storage & Security`
  String get privacyPolicy_section4Title {
    return Intl.message(
      '4. Data Storage & Security',
      name: 'privacyPolicy_section4Title',
      desc: '',
      args: [],
    );
  }

  /// `Your data is securely stored in Canada or in servers compliant with applicable privacy laws. We implement technical and organizational measures to protect your information from unauthorized access, loss, or misuse.`
  String get privacyPolicy_section4Body {
    return Intl.message(
      'Your data is securely stored in Canada or in servers compliant with applicable privacy laws. We implement technical and organizational measures to protect your information from unauthorized access, loss, or misuse.',
      name: 'privacyPolicy_section4Body',
      desc: '',
      args: [],
    );
  }

  /// `5. Your Rights`
  String get privacyPolicy_section5Title {
    return Intl.message(
      '5. Your Rights',
      name: 'privacyPolicy_section5Title',
      desc: '',
      args: [],
    );
  }

  /// `In accordance with Law 25 (Québec) and Canadian privacy laws, you have the right to: Access your personal data. Request corrections or deletion of certain data. Withdraw your consent to data processing. File a complaint with the Commission d'accès à l'information du Québec if necessary.`
  String get privacyPolicy_section5Body {
    return Intl.message(
      'In accordance with Law 25 (Québec) and Canadian privacy laws, you have the right to: Access your personal data. Request corrections or deletion of certain data. Withdraw your consent to data processing. File a complaint with the Commission d\'accès à l\'information du Québec if necessary.',
      name: 'privacyPolicy_section5Body',
      desc: '',
      args: [],
    );
  }

  /// `6. Cookies & Similar Technologies`
  String get privacyPolicy_section6Title {
    return Intl.message(
      '6. Cookies & Similar Technologies',
      name: 'privacyPolicy_section6Title',
      desc: '',
      args: [],
    );
  }

  /// `We use cookies and analytics tools to improve the user experience, personalize content, and measure performance. You can manage your preferences through your browser settings.`
  String get privacyPolicy_section6Body {
    return Intl.message(
      'We use cookies and analytics tools to improve the user experience, personalize content, and measure performance. You can manage your preferences through your browser settings.',
      name: 'privacyPolicy_section6Body',
      desc: '',
      args: [],
    );
  }

  /// `7. Changes to this Policy`
  String get privacyPolicy_section7Title {
    return Intl.message(
      '7. Changes to this Policy',
      name: 'privacyPolicy_section7Title',
      desc: '',
      args: [],
    );
  }

  /// `We may update this Privacy Policy from time to time. Any changes will be posted on our website with the updated effective date.`
  String get privacyPolicy_section7Body {
    return Intl.message(
      'We may update this Privacy Policy from time to time. Any changes will be posted on our website with the updated effective date.',
      name: 'privacyPolicy_section7Body',
      desc: '',
      args: [],
    );
  }

  /// `8. Contact`
  String get privacyPolicy_section8Title {
    return Intl.message(
      '8. Contact',
      name: 'privacyPolicy_section8Title',
      desc: '',
      args: [],
    );
  }

  /// `For any questions regarding this Policy or to exercise your rights, please contact us at: 📧 info@cuisinous.ca 📍 Cuisinous Inc., Québec, Canada`
  String get privacyPolicy_section8Body {
    return Intl.message(
      'For any questions regarding this Policy or to exercise your rights, please contact us at: 📧 info@cuisinous.ca 📍 Cuisinous Inc., Québec, Canada',
      name: 'privacyPolicy_section8Body',
      desc: '',
      args: [],
    );
  }

  /// `This Privacy Policy is effective as of 6 november 2025.`
  String get privacyPolicy_conclusion {
    return Intl.message(
      'This Privacy Policy is effective as of 6 november 2025.',
      name: 'privacyPolicy_conclusion',
      desc: '',
      args: [],
    );
  }

  /// `Call Now`
  String get callNowButton {
    return Intl.message('Call Now', name: 'callNowButton', desc: '', args: []);
  }

  /// `Call Buyer`
  String get callBuyer {
    return Intl.message('Call Buyer', name: 'callBuyer', desc: '', args: []);
  }

  /// `Call Seller`
  String get callSeller {
    return Intl.message('Call Seller', name: 'callSeller', desc: '', args: []);
  }

  /// `Order not found.`
  String get proxyCallOrderNotFound {
    return Intl.message(
      'Order not found.',
      name: 'proxyCallOrderNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Calling is not yet available for this order.`
  String get proxyCallNotAvailable {
    return Intl.message(
      'Calling is not yet available for this order.',
      name: 'proxyCallNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Server error. Please try again later.`
  String get proxyCallServerError {
    return Intl.message(
      'Server error. Please try again later.',
      name: 'proxyCallServerError',
      desc: '',
      args: [],
    );
  }

  /// `Unable to initiate call. Please try again later.`
  String get proxyCallUnableToInitiate {
    return Intl.message(
      'Unable to initiate call. Please try again later.',
      name: 'proxyCallUnableToInitiate',
      desc: '',
      args: [],
    );
  }

  /// `Calling is not supported on this device.`
  String get proxyCallNotSupported {
    return Intl.message(
      'Calling is not supported on this device.',
      name: 'proxyCallNotSupported',
      desc: '',
      args: [],
    );
  }

  /// `Leave a Tip`
  String get leaveATip {
    return Intl.message('Leave a Tip', name: 'leaveATip', desc: '', args: []);
  }

  /// `Enter amount`
  String get customTipHint {
    return Intl.message(
      'Enter amount',
      name: 'customTipHint',
      desc: '',
      args: [],
    );
  }

  /// `Tip added successfully! Thank you.`
  String get tipSuccess {
    return Intl.message(
      'Tip added successfully! Thank you.',
      name: 'tipSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get userInfo_phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'userInfo_phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Manage Allergens`
  String get manageAllergensTitle {
    return Intl.message(
      'Manage Allergens',
      name: 'manageAllergensTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select Allergen`
  String get manageAllergensSelect {
    return Intl.message(
      'Select Allergen',
      name: 'manageAllergensSelect',
      desc: '',
      args: [],
    );
  }

  /// `Specification`
  String get manageAllergensSpecification {
    return Intl.message(
      'Specification',
      name: 'manageAllergensSpecification',
      desc: '',
      args: [],
    );
  }

  /// `Specification (Optional)`
  String get manageAllergensSpecificationOptional {
    return Intl.message(
      'Specification (Optional)',
      name: 'manageAllergensSpecificationOptional',
      desc: '',
      args: [],
    );
  }

  /// `e.g., May contain traces of...`
  String get manageAllergensSpecificationHint {
    return Intl.message(
      'e.g., May contain traces of...',
      name: 'manageAllergensSpecificationHint',
      desc: '',
      args: [],
    );
  }

  /// `No allergens available to add`
  String get manageAllergensEmpty {
    return Intl.message(
      'No allergens available to add',
      name: 'manageAllergensEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Allergens`
  String get dishDetail_allergens {
    return Intl.message(
      'Allergens',
      name: 'dishDetail_allergens',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get addButton {
    return Intl.message('Add', name: 'addButton', desc: '', args: []);
  }

  /// `Pending Orders`
  String get sellerHome_pendingOrders {
    return Intl.message(
      'Pending Orders',
      name: 'sellerHome_pendingOrders',
      desc: '',
      args: [],
    );
  }

  /// `Total Revenue`
  String get sellerHome_totalRevenue {
    return Intl.message(
      'Total Revenue',
      name: 'sellerHome_totalRevenue',
      desc: '',
      args: [],
    );
  }

  /// `Store Analytics`
  String get sellerStats_title {
    return Intl.message(
      'Store Analytics',
      name: 'sellerStats_title',
      desc: '',
      args: [],
    );
  }

  /// `Average Order Value`
  String get sellerStats_averageOrderValue {
    return Intl.message(
      'Average Order Value',
      name: 'sellerStats_averageOrderValue',
      desc: '',
      args: [],
    );
  }

  /// `Daily Revenue`
  String get sellerStats_dailyRevenue {
    return Intl.message(
      'Daily Revenue',
      name: 'sellerStats_dailyRevenue',
      desc: '',
      args: [],
    );
  }

  /// `Monthly Revenue`
  String get sellerStats_monthlyRevenue {
    return Intl.message(
      'Monthly Revenue',
      name: 'sellerStats_monthlyRevenue',
      desc: '',
      args: [],
    );
  }

  /// `Yearly Revenue`
  String get sellerStats_yearlyRevenue {
    return Intl.message(
      'Yearly Revenue',
      name: 'sellerStats_yearlyRevenue',
      desc: '',
      args: [],
    );
  }

  /// `Total Orders`
  String get sellerStats_totalOrders {
    return Intl.message(
      'Total Orders',
      name: 'sellerStats_totalOrders',
      desc: '',
      args: [],
    );
  }

  /// `No yearly data available`
  String get sellerStats_noYearlyData {
    return Intl.message(
      'No yearly data available',
      name: 'sellerStats_noYearlyData',
      desc: '',
      args: [],
    );
  }

  /// `No data for this year`
  String get sellerStats_noDataYear {
    return Intl.message(
      'No data for this year',
      name: 'sellerStats_noDataYear',
      desc: '',
      args: [],
    );
  }

  /// `No data for this month`
  String get sellerStats_noDataMonth {
    return Intl.message(
      'No data for this month',
      name: 'sellerStats_noDataMonth',
      desc: '',
      args: [],
    );
  }

  /// `Agree`
  String get agree {
    return Intl.message('Agree', name: 'agree', desc: '', args: []);
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Filter Dishes`
  String get home_filterTitle {
    return Intl.message(
      'Filter Dishes',
      name: 'home_filterTitle',
      desc: '',
      args: [],
    );
  }

  /// `Ingredients`
  String get home_ingredients {
    return Intl.message(
      'Ingredients',
      name: 'home_ingredients',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get home_sortPrice {
    return Intl.message('Price', name: 'home_sortPrice', desc: '', args: []);
  }

  /// `Rating`
  String get home_sortRating {
    return Intl.message('Rating', name: 'home_sortRating', desc: '', args: []);
  }

  /// `Price`
  String get manageDishIngredients_supplementPrice {
    return Intl.message(
      'Price',
      name: 'manageDishIngredients_supplementPrice',
      desc: '',
      args: [],
    );
  }

  /// `Free`
  String get manageDishIngredients_free {
    return Intl.message(
      'Free',
      name: 'manageDishIngredients_free',
      desc: '',
      args: [],
    );
  }

  /// `Supplement`
  String get manageDishIngredients_supplementLabel {
    return Intl.message(
      'Supplement',
      name: 'manageDishIngredients_supplementLabel',
      desc: '',
      args: [],
    );
  }

  /// `Standard`
  String get manageDishIngredients_standardLabel {
    return Intl.message(
      'Standard',
      name: 'manageDishIngredients_standardLabel',
      desc: '',
      args: [],
    );
  }

  /// `Delete Ingredient`
  String get manageDishIngredients_deleteIngredientTitle {
    return Intl.message(
      'Delete Ingredient',
      name: 'manageDishIngredients_deleteIngredientTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete "{name}"? This action cannot be undone.`
  String manageDishIngredients_deleteIngredientContent(String name) {
    return Intl.message(
      'Are you sure you want to delete "$name"? This action cannot be undone.',
      name: 'manageDishIngredients_deleteIngredientContent',
      desc: '',
      args: [name],
    );
  }

  /// `Edit Ingredient`
  String get manageDishIngredients_editIngredientTitle {
    return Intl.message(
      'Edit Ingredient',
      name: 'manageDishIngredients_editIngredientTitle',
      desc: '',
      args: [],
    );
  }

  /// `Name (English)`
  String get manageDishIngredients_nameEnLabel {
    return Intl.message(
      'Name (English)',
      name: 'manageDishIngredients_nameEnLabel',
      desc: '',
      args: [],
    );
  }

  /// `Name (French)`
  String get manageDishIngredients_nameFrLabel {
    return Intl.message(
      'Name (French)',
      name: 'manageDishIngredients_nameFrLabel',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a name`
  String get manageDishIngredients_nameValidation {
    return Intl.message(
      'Please enter a name',
      name: 'manageDishIngredients_nameValidation',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get manageDishIngredients_cancel {
    return Intl.message(
      'Cancel',
      name: 'manageDishIngredients_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get manageDishIngredients_editTooltip {
    return Intl.message(
      'Edit',
      name: 'manageDishIngredients_editTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get manageDishIngredients_deleteTooltip {
    return Intl.message(
      'Delete',
      name: 'manageDishIngredients_deleteTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Ingredient added successfully`
  String get manageDishIngredients_ingredientAddedSuccessfully {
    return Intl.message(
      'Ingredient added successfully',
      name: 'manageDishIngredients_ingredientAddedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Delete Ingredient`
  String get manageDishIngredients_deleteConfirmTitle {
    return Intl.message(
      'Delete Ingredient',
      name: 'manageDishIngredients_deleteConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Could not open map`
  String get mapLaunchError {
    return Intl.message(
      'Could not open map',
      name: 'mapLaunchError',
      desc: '',
      args: [],
    );
  }

  /// `Hello, {name}!`
  String header_hello(String name) {
    return Intl.message(
      'Hello, $name!',
      name: 'header_hello',
      desc: '',
      args: [name],
    );
  }

  /// `Search...`
  String get header_searchHint {
    return Intl.message(
      'Search...',
      name: 'header_searchHint',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get notification_title {
    return Intl.message(
      'Notification',
      name: 'notification_title',
      desc: '',
      args: [],
    );
  }

  /// `No notifications yet`
  String get notification_emptyState {
    return Intl.message(
      'No notifications yet',
      name: 'notification_emptyState',
      desc: '',
      args: [],
    );
  }

  /// `Mark Read`
  String get notification_markAsRead {
    return Intl.message(
      'Mark Read',
      name: 'notification_markAsRead',
      desc: '',
      args: [],
    );
  }

  /// `{count} New`
  String notification_newCount(int count) {
    return Intl.message(
      '$count New',
      name: 'notification_newCount',
      desc: '',
      args: [count],
    );
  }

  /// `Ops! Something went wrong`
  String get notification_errorTitle {
    return Intl.message(
      'Ops! Something went wrong',
      name: 'notification_errorTitle',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get notification_tryAgain {
    return Intl.message(
      'Try Again',
      name: 'notification_tryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Mark as ready`
  String get markAsReadyButton {
    return Intl.message(
      'Mark as ready',
      name: 'markAsReadyButton',
      desc: '',
      args: [],
    );
  }

  /// `ready`
  String get buyerOrderDetails_timelineReady {
    return Intl.message(
      'ready',
      name: 'buyerOrderDetails_timelineReady',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get orderStatusConfirmed {
    return Intl.message(
      'Confirmed',
      name: 'orderStatusConfirmed',
      desc: '',
      args: [],
    );
  }

  /// `Ready`
  String get orderStatusReady {
    return Intl.message('Ready', name: 'orderStatusReady', desc: '', args: []);
  }

  /// `Processing`
  String get orderStatusProcessing {
    return Intl.message(
      'Processing',
      name: 'orderStatusProcessing',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get orderStatusFailed {
    return Intl.message(
      'Failed',
      name: 'orderStatusFailed',
      desc: '',
      args: [],
    );
  }

  /// `Refund Requested`
  String get orderStatusRefundRequested {
    return Intl.message(
      'Refund Requested',
      name: 'orderStatusRefundRequested',
      desc: '',
      args: [],
    );
  }

  /// `Refunded`
  String get orderStatusRefunded {
    return Intl.message(
      'Refunded',
      name: 'orderStatusRefunded',
      desc: '',
      args: [],
    );
  }

  /// `Refund Failed`
  String get orderStatusRefundFailed {
    return Intl.message(
      'Refund Failed',
      name: 'orderStatusRefundFailed',
      desc: '',
      args: [],
    );
  }

  /// `In Transit`
  String get orderStatusInTransit {
    return Intl.message(
      'In Transit',
      name: 'orderStatusInTransit',
      desc: '',
      args: [],
    );
  }

  /// `Delivered`
  String get orderStatusDelivered {
    return Intl.message(
      'Delivered',
      name: 'orderStatusDelivered',
      desc: '',
      args: [],
    );
  }

  /// `Failed to initialize payment sheet`
  String get paymentFailedToInitialize {
    return Intl.message(
      'Failed to initialize payment sheet',
      name: 'paymentFailedToInitialize',
      desc: '',
      args: [],
    );
  }

  /// `Stripe error: {error}`
  String paymentStripeError(String error) {
    return Intl.message(
      'Stripe error: $error',
      name: 'paymentStripeError',
      desc: '',
      args: [error],
    );
  }

  /// `Unexpected error: {error}`
  String paymentUnexpectedError(String error) {
    return Intl.message(
      'Unexpected error: $error',
      name: 'paymentUnexpectedError',
      desc: '',
      args: [error],
    );
  }

  /// `DELIVERY`
  String get deliveryMethodLabel {
    return Intl.message(
      'DELIVERY',
      name: 'deliveryMethodLabel',
      desc: '',
      args: [],
    );
  }

  /// `Tax`
  String get taxLabel {
    return Intl.message('Tax', name: 'taxLabel', desc: '', args: []);
  }

  /// `Retry`
  String get retryButton {
    return Intl.message('Retry', name: 'retryButton', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

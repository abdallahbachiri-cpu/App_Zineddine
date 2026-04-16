// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static String m0(latitude, longitude) =>
      "Coordonnées : ${latitude}, ${longitude}";

  static String m1(error) =>
      "Erreur de chargement des données du portefeuille : ${error}";

  static String m2(name) => "Bonjour, ${name} !";

  static String m3(name) =>
      "Êtes-vous sûr de vouloir supprimer \"${name}\" ? Cette action est irréversible.";

  static String m4(sortBy) => "Trié par ${sortBy}";

  static String m5(count) => "${count} Nouveau";

  static String m6(error) => "Erreur Stripe : ${error}";

  static String m7(error) => "Erreur inattendue : ${error}";

  static String m8(name, quantity) => "\$name x\$quantity";

  static String m9(sortBy) => "Trié par ${sortBy}";

  static String m10(latitude, longitude) =>
      "Coordonnées : ${latitude}, ${longitude}";

  static String m11(message) => "Erreur Stripe : ${message}";

  static String m12(error) => "Erreur inattendue : ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accountTypeSelection_accountTypeBuyer":
        MessageLookupByLibrary.simpleMessage(
          "Je cherche des plats faits maison",
        ),
    "accountTypeSelection_accountTypeSeller":
        MessageLookupByLibrary.simpleMessage(
          "Je propose des plats faits maison",
        ),
    "accountTypeSelection_accountTypeSubtitle":
        MessageLookupByLibrary.simpleMessage(
          "Vous êtes ici pour savourer de délicieux plats ou pour partager vos créations culinaires ? Sélectionnez votre rôle pour commencer !",
        ),
    "accountTypeSelection_accountTypeTitle":
        MessageLookupByLibrary.simpleMessage(
          "Comment souhaitez-vous nous rejoindre ?",
        ),
    "addButton": MessageLookupByLibrary.simpleMessage("Ajouter"),
    "addPaymentCard_hintCardHolder": MessageLookupByLibrary.simpleMessage(
      "John Doe",
    ),
    "addPaymentCard_labelCVV": MessageLookupByLibrary.simpleMessage("CVV"),
    "addPaymentCard_labelCardHolder": MessageLookupByLibrary.simpleMessage(
      "Nom du titulaire",
    ),
    "addPaymentCard_labelCardNumber": MessageLookupByLibrary.simpleMessage(
      "Numéro de carte",
    ),
    "addPaymentCard_labelExpiryDate": MessageLookupByLibrary.simpleMessage(
      "Date d\'expiration",
    ),
    "addPaymentCard_save": MessageLookupByLibrary.simpleMessage("Enregistrer"),
    "addPaymentCard_setDefault": MessageLookupByLibrary.simpleMessage(
      "Définir comme moyen de paiement par défaut",
    ),
    "addPaymentCard_title": MessageLookupByLibrary.simpleMessage(
      "Ajouter une carte",
    ),
    "addPaymentCard_validationCVVInvalid": MessageLookupByLibrary.simpleMessage(
      "CVV invalide",
    ),
    "addPaymentCard_validationCVVRequired":
        MessageLookupByLibrary.simpleMessage("CVV requis"),
    "addPaymentCard_validationCardNumberInvalid":
        MessageLookupByLibrary.simpleMessage(
          "Veuillez entrer une Visa/MasterCard valide",
        ),
    "addPaymentCard_validationCardNumberRequired":
        MessageLookupByLibrary.simpleMessage("Le numéro de carte est requis"),
    "addPaymentCard_validationExpiryInvalid":
        MessageLookupByLibrary.simpleMessage("Format invalide"),
    "addPaymentCard_validationExpiryRequired":
        MessageLookupByLibrary.simpleMessage("Date d\'expiration requise"),
    "addPaymentCard_validationNameRequired":
        MessageLookupByLibrary.simpleMessage("Le nom est requis"),
    "addTipTitle": MessageLookupByLibrary.simpleMessage("Ajouter un pourboire"),
    "additionalCostItem": MessageLookupByLibrary.simpleMessage(
      "Article à coût supplémentaire",
    ),
    "address": MessageLookupByLibrary.simpleMessage("Adresse"),
    "addressFormAddTitle": MessageLookupByLibrary.simpleMessage(
      "Ajouter une adresse",
    ),
    "addressFormCurrentLocationButton": MessageLookupByLibrary.simpleMessage(
      "Utiliser ma position actuelle",
    ),
    "addressFormEditTitle": MessageLookupByLibrary.simpleMessage(
      "Modifier l\'adresse",
    ),
    "addressFormMapTitle": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez l\'emplacement sur la carte",
    ),
    "addressFormProcessing": MessageLookupByLibrary.simpleMessage(
      "Traitement en cours...",
    ),
    "addressFormSaveButton": MessageLookupByLibrary.simpleMessage(
      "Enregistrer l\'adresse",
    ),
    "addressFormStreetHint": MessageLookupByLibrary.simpleMessage(
      "Entrez l\'adresse",
    ),
    "addressFormStreetLabel": MessageLookupByLibrary.simpleMessage("Adresse"),
    "addressFormUpdateButton": MessageLookupByLibrary.simpleMessage(
      "Mettre à jour l\'adresse",
    ),
    "addressManagement_deleteCancel": MessageLookupByLibrary.simpleMessage(
      "Annuler",
    ),
    "addressManagement_deleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Supprimer",
    ),
    "addressManagement_deleteContent": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir supprimer cette adresse ?",
    ),
    "addressManagement_deleteTitle": MessageLookupByLibrary.simpleMessage(
      "Supprimer l\'adresse",
    ),
    "addressManagement_emptyButton": MessageLookupByLibrary.simpleMessage(
      "Ajouter une première adresse",
    ),
    "addressManagement_emptyText": MessageLookupByLibrary.simpleMessage(
      "Aucune adresse enregistrée",
    ),
    "addressManagement_title": MessageLookupByLibrary.simpleMessage(
      "Adresses enregistrées",
    ),
    "addressManagement_yourAddresses": MessageLookupByLibrary.simpleMessage(
      "Vos adresses",
    ),
    "addressNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Adresse non disponible",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Accepter"),
    "allFilesUploadedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Tous les fichiers ont été téléchargés avec succès",
    ),
    "amount": MessageLookupByLibrary.simpleMessage("Montant"),
    "availableAt": MessageLookupByLibrary.simpleMessage("Disponible le"),
    "buyerOrderDetails_cancelOrder": MessageLookupByLibrary.simpleMessage(
      "Annuler la commande",
    ),
    "buyerOrderDetails_editNote": MessageLookupByLibrary.simpleMessage(
      "Modifier la note",
    ),
    "buyerOrderDetails_labelConfirmationCode":
        MessageLookupByLibrary.simpleMessage("Code de confirmation :"),
    "buyerOrderDetails_labelDate": MessageLookupByLibrary.simpleMessage(
      "Date :",
    ),
    "buyerOrderDetails_labelDeliveryStatus":
        MessageLookupByLibrary.simpleMessage("Statut de la livraison :"),
    "buyerOrderDetails_labelEmail": MessageLookupByLibrary.simpleMessage(
      "E-mail :",
    ),
    "buyerOrderDetails_labelName": MessageLookupByLibrary.simpleMessage(
      "Nom :",
    ),
    "buyerOrderDetails_labelOrderNumber": MessageLookupByLibrary.simpleMessage(
      "Commande n° :",
    ),
    "buyerOrderDetails_labelPaymentStatus":
        MessageLookupByLibrary.simpleMessage("Statut du paiement :"),
    "buyerOrderDetails_labelPhone": MessageLookupByLibrary.simpleMessage(
      "Téléphone :",
    ),
    "buyerOrderDetails_labelSubtotal": MessageLookupByLibrary.simpleMessage(
      "Sous-total :",
    ),
    "buyerOrderDetails_labelTipAmount": MessageLookupByLibrary.simpleMessage(
      "Montant du pourboire :",
    ),
    "buyerOrderDetails_noNotes": MessageLookupByLibrary.simpleMessage(
      "Aucune note ajoutée",
    ),
    "buyerOrderDetails_notFound": MessageLookupByLibrary.simpleMessage(
      "Facture introuvable",
    ),
    "buyerOrderDetails_noteCancel": MessageLookupByLibrary.simpleMessage(
      "Annuler",
    ),
    "buyerOrderDetails_noteHint": MessageLookupByLibrary.simpleMessage(
      "Instructions spéciales ou notes...",
    ),
    "buyerOrderDetails_noteLabel": MessageLookupByLibrary.simpleMessage("Note"),
    "buyerOrderDetails_noteSave": MessageLookupByLibrary.simpleMessage(
      "Enregistrer",
    ),
    "buyerOrderDetails_payOrder": MessageLookupByLibrary.simpleMessage(
      "Payer la commande",
    ),
    "buyerOrderDetails_sectionCustomer": MessageLookupByLibrary.simpleMessage(
      "CLIENT",
    ),
    "buyerOrderDetails_sectionDeliveryTo": MessageLookupByLibrary.simpleMessage(
      "LIVRAISON À",
    ),
    "buyerOrderDetails_sectionItems": MessageLookupByLibrary.simpleMessage(
      "ARTICLES",
    ),
    "buyerOrderDetails_sectionOrderNotes": MessageLookupByLibrary.simpleMessage(
      "NOTES DE COMMANDE",
    ),
    "buyerOrderDetails_sectionPaymentDetails":
        MessageLookupByLibrary.simpleMessage("DÉTAILS DE PAIEMENT"),
    "buyerOrderDetails_sectionTotal": MessageLookupByLibrary.simpleMessage(
      "TOTAL",
    ),
    "buyerOrderDetails_showCodeToSeller": MessageLookupByLibrary.simpleMessage(
      "Présentez ce code au vendeur",
    ),
    "buyerOrderDetails_thankYou": MessageLookupByLibrary.simpleMessage(
      "Merci pour votre commande !",
    ),
    "buyerOrderDetails_timelineConfirmed": MessageLookupByLibrary.simpleMessage(
      "Confirmé",
    ),
    "buyerOrderDetails_timelineDelivered": MessageLookupByLibrary.simpleMessage(
      "Livré",
    ),
    "buyerOrderDetails_timelineOrdered": MessageLookupByLibrary.simpleMessage(
      "Commandé",
    ),
    "buyerOrderDetails_timelineReady": MessageLookupByLibrary.simpleMessage(
      "prêt",
    ),
    "buyerOrderDetails_title": MessageLookupByLibrary.simpleMessage(
      "Facture de commande",
    ),
    "buyerOrderDetails_totalPaid": MessageLookupByLibrary.simpleMessage(
      "TOTAL PAYÉ",
    ),
    "buyerOrderDetails_waitingForConfirmation":
        MessageLookupByLibrary.simpleMessage("En attente de confirmation"),
    "buyerOrders_empty": MessageLookupByLibrary.simpleMessage(
      "Aucune commande trouvée",
    ),
    "buyerOrders_errorRetry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "buyerOrders_filterApply": MessageLookupByLibrary.simpleMessage(
      "Appliquer",
    ),
    "buyerOrders_filterMaxPrice": MessageLookupByLibrary.simpleMessage(
      "Prix maximum",
    ),
    "buyerOrders_filterMinPrice": MessageLookupByLibrary.simpleMessage(
      "Prix minimum",
    ),
    "buyerOrders_filterReset": MessageLookupByLibrary.simpleMessage(
      "Réinitialiser",
    ),
    "buyerOrders_filterTitle": MessageLookupByLibrary.simpleMessage(
      "Filtrer et trier",
    ),
    "buyerOrders_itemBuyer": MessageLookupByLibrary.simpleMessage("Acheteur :"),
    "buyerOrders_itemNumber": MessageLookupByLibrary.simpleMessage(
      "Commande n°",
    ),
    "buyerOrders_itemPlaced": MessageLookupByLibrary.simpleMessage(
      "Passée le :",
    ),
    "buyerOrders_itemTotal": MessageLookupByLibrary.simpleMessage("Total :"),
    "buyerOrders_searchHint": MessageLookupByLibrary.simpleMessage(
      "Numéro de commande, nom du restaurant...",
    ),
    "buyerOrders_searchLabel": MessageLookupByLibrary.simpleMessage(
      "Rechercher",
    ),
    "buyerOrders_sortCreated": MessageLookupByLibrary.simpleMessage(
      "Date de création",
    ),
    "buyerOrders_sortDeliveryStatus": MessageLookupByLibrary.simpleMessage(
      "Statut livraison",
    ),
    "buyerOrders_sortOrderAsc": MessageLookupByLibrary.simpleMessage(
      "Croissant",
    ),
    "buyerOrders_sortOrderDesc": MessageLookupByLibrary.simpleMessage(
      "Décroissant",
    ),
    "buyerOrders_sortPaymentStatus": MessageLookupByLibrary.simpleMessage(
      "Statut paiement",
    ),
    "buyerOrders_sortPrice": MessageLookupByLibrary.simpleMessage("Prix total"),
    "buyerOrders_sortStatus": MessageLookupByLibrary.simpleMessage("Statut"),
    "buyerOrders_title": MessageLookupByLibrary.simpleMessage("Mes Commandes"),
    "callBuyer": MessageLookupByLibrary.simpleMessage("Appeler l\'acheteur"),
    "callNowButton": MessageLookupByLibrary.simpleMessage("Appeler maintenant"),
    "callSeller": MessageLookupByLibrary.simpleMessage("Appeler le vendeur"),
    "cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
    "cart_checkoutButton": MessageLookupByLibrary.simpleMessage(
      "Passer à la caisse",
    ),
    "cart_emptySubtitle": MessageLookupByLibrary.simpleMessage(
      "Ajoutez des articles pour commencer",
    ),
    "cart_emptyTitle": MessageLookupByLibrary.simpleMessage(
      "Votre panier est vide",
    ),
    "cart_errorTryAgain": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "cart_itemDelete": MessageLookupByLibrary.simpleMessage(
      "Supprimer l\'article",
    ),
    "cart_label": MessageLookupByLibrary.simpleMessage("Panier"),
    "cart_refreshTooltip": MessageLookupByLibrary.simpleMessage(
      "Rafraîchir le panier",
    ),
    "cart_title": MessageLookupByLibrary.simpleMessage("Votre panier"),
    "cart_total": MessageLookupByLibrary.simpleMessage("Total"),
    "changeImage": MessageLookupByLibrary.simpleMessage("Changer l\'Image"),
    "checkout_completeButton": MessageLookupByLibrary.simpleMessage(
      "Finaliser la commande",
    ),
    "checkout_errorMessage": MessageLookupByLibrary.simpleMessage(
      "Échec de la commande",
    ),
    "checkout_noLocations": MessageLookupByLibrary.simpleMessage(
      "Aucun lieu disponible. Ajoutez d\'abord un lieu.",
    ),
    "checkout_placeOrder": MessageLookupByLibrary.simpleMessage(
      "Passer la commande",
    ),
    "checkout_selectLocation": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez le lieu de livraison",
    ),
    "checkout_successMessage": MessageLookupByLibrary.simpleMessage(
      "Commande passée avec succès !",
    ),
    "checkout_title": MessageLookupByLibrary.simpleMessage(
      "Passer la commande",
    ),
    "checkout_yourOrder": MessageLookupByLibrary.simpleMessage(
      "Votre commande",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Fermer"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirmer"),
    "confirmDeliveryButton": MessageLookupByLibrary.simpleMessage(
      "Confirmer la livraison",
    ),
    "confirmLocation": MessageLookupByLibrary.simpleMessage(
      "Confirmer l\'emplacement",
    ),
    "confirmOrderButton": MessageLookupByLibrary.simpleMessage(
      "Confirmer la commande",
    ),
    "confirmTip": MessageLookupByLibrary.simpleMessage("Payer le pourboire"),
    "confirmationCodeHint": MessageLookupByLibrary.simpleMessage(
      "Entrez le code fourni par l\'acheteur",
    ),
    "connectStripeAccount": MessageLookupByLibrary.simpleMessage(
      "Connecter le compte Stripe",
    ),
    "coordinates": m0,
    "couldNotFetchAddress": MessageLookupByLibrary.simpleMessage(
      "Impossible de récupérer l\'adresse. Veuillez réessayer.",
    ),
    "couldNotRetrieveAddressDetails": MessageLookupByLibrary.simpleMessage(
      "Impossible de récupérer les détails de l\'adresse",
    ),
    "create": MessageLookupByLibrary.simpleMessage("Créer"),
    "createNew": MessageLookupByLibrary.simpleMessage("Créer"),
    "createStore": MessageLookupByLibrary.simpleMessage("Créer un boutique"),
    "createYourFirstIngredient": MessageLookupByLibrary.simpleMessage(
      "Créez votre premier ingrédient pour commencer",
    ),
    "currency": MessageLookupByLibrary.simpleMessage("Devise"),
    "customTipAmount": MessageLookupByLibrary.simpleMessage(
      "Montant personnalisé",
    ),
    "customTipHint": MessageLookupByLibrary.simpleMessage("Entrer le montant"),
    "date": MessageLookupByLibrary.simpleMessage("Date"),
    "delete": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "deleteIngredient": MessageLookupByLibrary.simpleMessage(
      "Supprimer l\'ingrédient",
    ),
    "deleteIngredientContent": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir supprimer cet ingrédient ?",
    ),
    "deleteStore": MessageLookupByLibrary.simpleMessage(
      "Supprimer la boutique",
    ),
    "deleteStoreContent": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir supprimer votre boutique et vous déconnecter ?",
    ),
    "deleteStoreTitle": MessageLookupByLibrary.simpleMessage(
      "Supprimer la boutique",
    ),
    "deliveryMethod": MessageLookupByLibrary.simpleMessage(
      "Méthode de livraison",
    ),
    "deliveryMethodLabel": MessageLookupByLibrary.simpleMessage("LIVRAISON"),
    "description": MessageLookupByLibrary.simpleMessage("Description"),
    "dishDetailAvailable": MessageLookupByLibrary.simpleMessage("Disponible"),
    "dishDetailUnavailable": MessageLookupByLibrary.simpleMessage(
      "Indisponible",
    ),
    "dishDetail_allergens": MessageLookupByLibrary.simpleMessage("Allergènes"),
    "dishDetail_basePrice": MessageLookupByLibrary.simpleMessage(
      "Prix de base :",
    ),
    "dishDetail_categories": MessageLookupByLibrary.simpleMessage("Catégories"),
    "dishDetail_editButton": MessageLookupByLibrary.simpleMessage("Modifier"),
    "dishDetail_ingredients": MessageLookupByLibrary.simpleMessage(
      "Ingrédients",
    ),
    "dishDetail_reviews": MessageLookupByLibrary.simpleMessage("Avis"),
    "dishDetail_totalPrice": MessageLookupByLibrary.simpleMessage(
      "Prix total :",
    ),
    "dishForm_createButton": MessageLookupByLibrary.simpleMessage(
      "Créer le plat",
    ),
    "dishForm_createTitle": MessageLookupByLibrary.simpleMessage(
      "Créer un plat",
    ),
    "dishForm_deleteImageContent": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir supprimer cette image ?",
    ),
    "dishForm_deleteImageTitle": MessageLookupByLibrary.simpleMessage(
      "Supprimer l\'image",
    ),
    "dishForm_descriptionHint": MessageLookupByLibrary.simpleMessage(
      "Entrez la description du plat",
    ),
    "dishForm_descriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Description",
    ),
    "dishForm_editTitle": MessageLookupByLibrary.simpleMessage(
      "Modifier le plat",
    ),
    "dishForm_imagesLabel": MessageLookupByLibrary.simpleMessage("Images"),
    "dishForm_nameHint": MessageLookupByLibrary.simpleMessage(
      "Entrez le nom du plat",
    ),
    "dishForm_nameLabel": MessageLookupByLibrary.simpleMessage("Nom du plat"),
    "dishForm_priceHint": MessageLookupByLibrary.simpleMessage(
      "Entrez le prix du plat",
    ),
    "dishForm_priceLabel": MessageLookupByLibrary.simpleMessage("Prix"),
    "dishForm_updateButton": MessageLookupByLibrary.simpleMessage(
      "Mettre à jour le plat",
    ),
    "dishIngredientsTitle": MessageLookupByLibrary.simpleMessage(
      "Ingrédients du plat",
    ),
    "dishList_noRecipes": MessageLookupByLibrary.simpleMessage(
      "Aucune recette trouvée",
    ),
    "dishList_retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "dishManagement_activate": MessageLookupByLibrary.simpleMessage("Activer"),
    "dishManagement_deactivate": MessageLookupByLibrary.simpleMessage(
      "Désactiver",
    ),
    "dishManagement_deleteCancel": MessageLookupByLibrary.simpleMessage(
      "Annuler",
    ),
    "dishManagement_deleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Supprimer",
    ),
    "dishManagement_deleteContent": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir supprimer ce plat ?",
    ),
    "dishManagement_deleteTitle": MessageLookupByLibrary.simpleMessage(
      "Supprimer le plat",
    ),
    "dishManagement_dishActivated": MessageLookupByLibrary.simpleMessage(
      "Plat activé",
    ),
    "dishManagement_dishDeactivated": MessageLookupByLibrary.simpleMessage(
      "Plat désactivé",
    ),
    "dishManagement_empty": MessageLookupByLibrary.simpleMessage(
      "Aucun plat trouvé",
    ),
    "dishManagement_inactive": MessageLookupByLibrary.simpleMessage("Inactif"),
    "dishManagement_retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "dishManagement_title": MessageLookupByLibrary.simpleMessage(
      "Gérer les plats",
    ),
    "dishReviews_rateDish": MessageLookupByLibrary.simpleMessage(
      "Évaluer le plat",
    ),
    "dishReviews_ratingCommentHint": MessageLookupByLibrary.simpleMessage(
      "Partagez votre expérience avec ce plat...",
    ),
    "dishReviews_ratingCommentLabel": MessageLookupByLibrary.simpleMessage(
      "Commentaire (Facultatif)",
    ),
    "dishReviews_reviews": MessageLookupByLibrary.simpleMessage("avis"),
    "dishReviews_submitReview": MessageLookupByLibrary.simpleMessage(
      "Soumettre l\'avis",
    ),
    "dishReviews_yourReview": MessageLookupByLibrary.simpleMessage(
      "Votre avis",
    ),
    "editAddress_addTitle": MessageLookupByLibrary.simpleMessage(
      "Ajouter une adresse",
    ),
    "editAddress_editTitle": MessageLookupByLibrary.simpleMessage(
      "Modifier l\'adresse",
    ),
    "editAddress_failedToGetAddress": MessageLookupByLibrary.simpleMessage(
      "Impossible d\'obtenir l\'adresse",
    ),
    "editAddress_failedToUpdateLocation": MessageLookupByLibrary.simpleMessage(
      "Échec de la mise à jour de l\'emplacement",
    ),
    "editAddress_mapTitle": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez l\'emplacement sur la carte",
    ),
    "editAddress_processing": MessageLookupByLibrary.simpleMessage(
      "Traitement en cours...",
    ),
    "editAddress_saveButton": MessageLookupByLibrary.simpleMessage(
      "Enregistrer l\'adresse",
    ),
    "editAddress_streetHint": MessageLookupByLibrary.simpleMessage(
      "Entrez l\'adresse",
    ),
    "editAddress_streetLabel": MessageLookupByLibrary.simpleMessage("Adresse"),
    "editAddress_updateButton": MessageLookupByLibrary.simpleMessage(
      "Mettre à jour l\'adresse",
    ),
    "editStore": MessageLookupByLibrary.simpleMessage("Modifier le boutique"),
    "edit_profile": MessageLookupByLibrary.simpleMessage("Modifier le profil"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "english": MessageLookupByLibrary.simpleMessage("Anglais"),
    "enterPriceEg250": MessageLookupByLibrary.simpleMessage(
      "Entrez le prix (ex. 2.50)",
    ),
    "errorLoadingStore": MessageLookupByLibrary.simpleMessage(
      "Échec du chargement de la boutique. Veuillez réessayer.",
    ),
    "errorLoadingTransactions": MessageLookupByLibrary.simpleMessage(
      "Erreur lors du chargement des transactions",
    ),
    "errorLoadingWalletData": m1,
    "error_updating_profile": MessageLookupByLibrary.simpleMessage(
      "Erreur lors de la mise à jour du profil",
    ),
    "exploreLabel": MessageLookupByLibrary.simpleMessage("Découvrir"),
    "failedToAddToCart": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'ajout au panier",
    ),
    "failedToInitializePayment": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'initialisation de la feuille de paiement",
    ),
    "fetchingAddress": MessageLookupByLibrary.simpleMessage(
      "Récupération de l\'adresse...",
    ),
    "fileUploadBrowse": MessageLookupByLibrary.simpleMessage(
      "Parcourir les fichiers",
    ),
    "fileUploadDragDrop": MessageLookupByLibrary.simpleMessage(
      "Glissez et déposez les fichiers ici",
    ),
    "fileUploadOr": MessageLookupByLibrary.simpleMessage("ou"),
    "fileUploadRemove": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "fileUploadStep1Title": MessageLookupByLibrary.simpleMessage(
      "Étape 1 : Justification du permis de travail",
    ),
    "fileUploadStep2Title": MessageLookupByLibrary.simpleMessage(
      "Étape 2 : Certificat MAPAQ",
    ),
    "fileUploadStep3Title": MessageLookupByLibrary.simpleMessage(
      "Étape 3 : Pièce d\'identité (permis, passeport)",
    ),
    "fileUploadStep4Title": MessageLookupByLibrary.simpleMessage(
      "Étape 4 : Certificat d’établissement",
    ),
    "fileUploadUploading": MessageLookupByLibrary.simpleMessage(
      "Téléchargement en cours...",
    ),
    "first_name": MessageLookupByLibrary.simpleMessage("Prénom"),
    "foodStoreAboutUs": MessageLookupByLibrary.simpleMessage(
      "À propos de nous",
    ),
    "foodStoreCategoryAll": MessageLookupByLibrary.simpleMessage("Toutes"),
    "foodStoreCategoryBreakfast": MessageLookupByLibrary.simpleMessage(
      "Petit-déjeuner",
    ),
    "foodStoreCategoryDessert": MessageLookupByLibrary.simpleMessage("Dessert"),
    "foodStoreCategoryLunch": MessageLookupByLibrary.simpleMessage("Déjeuner"),
    "foodStoreMap_addressNotFound": MessageLookupByLibrary.simpleMessage(
      "Adresse non trouvée. Veuillez en essayer une autre.",
    ),
    "foodStoreMap_genericError": MessageLookupByLibrary.simpleMessage(
      "Une erreur est survenue",
    ),
    "foodStoreMap_geocodingError": MessageLookupByLibrary.simpleMessage(
      "Une erreur de carte s\'est produite. Veuillez vérifier votre connexion et réessayer.",
    ),
    "foodStoreMap_locationDisabled": MessageLookupByLibrary.simpleMessage(
      "Services de localisation désactivés",
    ),
    "foodStoreMap_noRecipes": MessageLookupByLibrary.simpleMessage(
      "Aucune recette trouvée",
    ),
    "foodStoreMap_permissionDenied": MessageLookupByLibrary.simpleMessage(
      "Autorisations de localisation refusées",
    ),
    "foodStoreMap_permissionDeniedPermanently":
        MessageLookupByLibrary.simpleMessage(
          "Les autorisations de localisation sont définitivement refusées",
        ),
    "foodStoreMap_retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "foodStoreMap_searchHint": MessageLookupByLibrary.simpleMessage(
      "Rechercher par adresse...",
    ),
    "foodStoreMap_title": MessageLookupByLibrary.simpleMessage(
      "Restaurants à proximité",
    ),
    "foodStoreNoImages": MessageLookupByLibrary.simpleMessage(
      "Aucune image disponible",
    ),
    "foodStoreRecipesCount": MessageLookupByLibrary.simpleMessage("recettes"),
    "foodStoreStoreInfo": MessageLookupByLibrary.simpleMessage(
      "Informations du boutique",
    ),
    "foodStoreTabAbout": MessageLookupByLibrary.simpleMessage("À propos"),
    "foodStoreTabGallery": MessageLookupByLibrary.simpleMessage("Galerie"),
    "foodStoreTabRecipes": MessageLookupByLibrary.simpleMessage("Recettes"),
    "french": MessageLookupByLibrary.simpleMessage("Français"),
    "goToCart": MessageLookupByLibrary.simpleMessage("Aller au panier"),
    "googleRegister_button": MessageLookupByLibrary.simpleMessage(
      "S\'inscrire",
    ),
    "googleRegister_emailHint": MessageLookupByLibrary.simpleMessage(
      "Entrez votre e-mail",
    ),
    "googleRegister_emailLabel": MessageLookupByLibrary.simpleMessage(
      "Email :",
    ),
    "googleRegister_firstNameHint": MessageLookupByLibrary.simpleMessage(
      "Jean",
    ),
    "googleRegister_firstNameLabel": MessageLookupByLibrary.simpleMessage(
      "Prénom",
    ),
    "googleRegister_lastNameHint": MessageLookupByLibrary.simpleMessage(
      "Dupont",
    ),
    "googleRegister_lastNameLabel": MessageLookupByLibrary.simpleMessage(
      "Nom de famille",
    ),
    "googleRegister_operationFailed": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'opération",
    ),
    "googleRegister_requiredField": MessageLookupByLibrary.simpleMessage(
      "Champ requis",
    ),
    "googleRegister_slogan": MessageLookupByLibrary.simpleMessage(
      "VOS VOISINS, VOS CHEFS",
    ),
    "googleRegister_validationFirstNameRequired":
        MessageLookupByLibrary.simpleMessage("Le prénom est requis"),
    "googleRegister_validationLastNameRequired":
        MessageLookupByLibrary.simpleMessage("Le nom de famille est requis"),
    "googleRegister_validationPhoneInvalid":
        MessageLookupByLibrary.simpleMessage(
          "Entrez un numéro de téléphone valide",
        ),
    "googleRegister_validationPhoneRequired":
        MessageLookupByLibrary.simpleMessage(
          "Le numéro de téléphone est requis",
        ),
    "header_hello": m2,
    "header_searchHint": MessageLookupByLibrary.simpleMessage("Rechercher..."),
    "homeLabel": MessageLookupByLibrary.simpleMessage("Accueil"),
    "home_allRecipes": MessageLookupByLibrary.simpleMessage(
      "Toutes les recettes",
    ),
    "home_categories": MessageLookupByLibrary.simpleMessage("Catégories"),
    "home_filterTitle": MessageLookupByLibrary.simpleMessage(
      "Filtrer les plats",
    ),
    "home_ingredients": MessageLookupByLibrary.simpleMessage("Ingrédients"),
    "home_noCategories": MessageLookupByLibrary.simpleMessage(
      "Aucune catégorie trouvée",
    ),
    "home_noRecipes": MessageLookupByLibrary.simpleMessage(
      "Aucune recette trouvée",
    ),
    "home_popularChefs": MessageLookupByLibrary.simpleMessage(
      "Chefs populaires",
    ),
    "home_popularRecipes": MessageLookupByLibrary.simpleMessage(
      "Recettes populaires",
    ),
    "home_seeAll": MessageLookupByLibrary.simpleMessage("Voir tout"),
    "home_selectedRecipes": MessageLookupByLibrary.simpleMessage("Recettes"),
    "home_sortPrice": MessageLookupByLibrary.simpleMessage("Prix"),
    "home_sortRating": MessageLookupByLibrary.simpleMessage("Note"),
    "ingredientAddedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Ingrédient ajouté avec succès",
    ),
    "ingredientCreatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Ingrédient créé avec succès",
    ),
    "ingredientDeletedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Ingrédient supprimé avec succès",
    ),
    "ingredientManagement": MessageLookupByLibrary.simpleMessage(
      "Gestion des ingrédients",
    ),
    "ingredientRemovedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Ingrédient retiré du plat avec succès",
    ),
    "ingredientUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Ingrédient mis à jour avec succès",
    ),
    "ingredients_empty": MessageLookupByLibrary.simpleMessage(
      "Aucun ingrédient disponible",
    ),
    "ingredients_title": MessageLookupByLibrary.simpleMessage("Ingrédients"),
    "initializing": MessageLookupByLibrary.simpleMessage("Initialisation..."),
    "invalidLocation": MessageLookupByLibrary.simpleMessage(
      "L\'emplacement n\'est pas valide, la latitude ou la longitude est nécessaire pour mettre à jour la boutique",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Langue"),
    "languageChangeError": MessageLookupByLibrary.simpleMessage(
      "Échec du changement de langue",
    ),
    "languageSelection_english": MessageLookupByLibrary.simpleMessage(
      "Anglais",
    ),
    "languageSelection_french": MessageLookupByLibrary.simpleMessage(
      "Français",
    ),
    "languageSelection_title": MessageLookupByLibrary.simpleMessage(
      "Choisissez votre langue :",
    ),
    "languageUpdated": MessageLookupByLibrary.simpleMessage(
      "Langue mise à jour",
    ),
    "last_name": MessageLookupByLibrary.simpleMessage("Nom de famille"),
    "leaveATip": MessageLookupByLibrary.simpleMessage("Laisser un pourboire"),
    "link": MessageLookupByLibrary.simpleMessage("Lier"),
    "linkIngredients": MessageLookupByLibrary.simpleMessage(
      "Lier les ingrédients",
    ),
    "linkIngredientsHint": MessageLookupByLibrary.simpleMessage(
      "Lier des ingrédients de votre liste de vendeur ou gérer votre bibliothèque d\'ingrédients",
    ),
    "linkIngredientsToDish": MessageLookupByLibrary.simpleMessage(
      "Lier des ingrédients au plat",
    ),
    "linkedIngredients": MessageLookupByLibrary.simpleMessage(
      "ingrédients liés",
    ),
    "loadingIngredients": MessageLookupByLibrary.simpleMessage(
      "Chargement des ingrédients...",
    ),
    "loadingOrderDetails": MessageLookupByLibrary.simpleMessage(
      "Chargement des détails de la commande...",
    ),
    "loadingStoreInformation": MessageLookupByLibrary.simpleMessage(
      "Chargement des informations du magasin...",
    ),
    "locationError": MessageLookupByLibrary.simpleMessage(
      "Erreur de localisation",
    ),
    "locationPermissionsDenied": MessageLookupByLibrary.simpleMessage(
      "Les autorisations de localisation sont refusées",
    ),
    "locationPermissionsDeniedForever": MessageLookupByLibrary.simpleMessage(
      "Les autorisations de localisation sont définitivement refusées",
    ),
    "locationRequired": MessageLookupByLibrary.simpleMessage(
      "L\'emplacement est requis",
    ),
    "locationServicesDisabled": MessageLookupByLibrary.simpleMessage(
      "Les services de localisation sont désactivés",
    ),
    "login_button": MessageLookupByLibrary.simpleMessage("Connexion"),
    "login_continueWithEmail": MessageLookupByLibrary.simpleMessage(
      "Continuer avec Email",
    ),
    "login_emailHint": MessageLookupByLibrary.simpleMessage(
      "Entrez votre e-mail",
    ),
    "login_emailLabel": MessageLookupByLibrary.simpleMessage("Email :"),
    "login_forgotPassword": MessageLookupByLibrary.simpleMessage(
      "Mot de passe oublié ?",
    ),
    "login_apple": MessageLookupByLibrary.simpleMessage(
      "Se connecter avec Apple",
    ),
    "login_google": MessageLookupByLibrary.simpleMessage(
      "Se connecter avec Google",
    ),
    "login_googleDisclaimer": MessageLookupByLibrary.simpleMessage(
      "En vous connectant avec Google, vous acceptez nos Conditions Générales et notre Politique de Confidentialité.",
    ),
    "login_passwordHint": MessageLookupByLibrary.simpleMessage(
      "Entrez votre mot de passe",
    ),
    "login_passwordLabel": MessageLookupByLibrary.simpleMessage(
      "Mot de passe :",
    ),
    "login_privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Politique de confidentialité",
    ),
    "login_registerPrompt": MessageLookupByLibrary.simpleMessage(
      "Vous n\'avez pas de compte ? Inscrivez-vous",
    ),
    "login_slogan": MessageLookupByLibrary.simpleMessage(
      "VOS VOISINS, VOS CHEFS",
    ),
    "login_termsAndConditions": MessageLookupByLibrary.simpleMessage(
      "Conditions générales",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Se déconnecter"),
    "manageAllergensEmpty": MessageLookupByLibrary.simpleMessage(
      "Aucun allergène disponible à ajouter",
    ),
    "manageAllergensSelect": MessageLookupByLibrary.simpleMessage(
      "Sélectionner un allergène",
    ),
    "manageAllergensSpecification": MessageLookupByLibrary.simpleMessage(
      "Spécification",
    ),
    "manageAllergensSpecificationHint": MessageLookupByLibrary.simpleMessage(
      "ex : Peut contenir des traces de...",
    ),
    "manageAllergensSpecificationOptional":
        MessageLookupByLibrary.simpleMessage("Spécification (Optionnel)"),
    "manageAllergensTitle": MessageLookupByLibrary.simpleMessage(
      "Gérer les allergènes",
    ),
    "manageCategoriesAddButton": MessageLookupByLibrary.simpleMessage(
      "Ajouter une catégorie",
    ),
    "manageCategoriesCancel": MessageLookupByLibrary.simpleMessage("Annuler"),
    "manageCategoriesDiscardChanges": MessageLookupByLibrary.simpleMessage(
      "Annuler les modifications",
    ),
    "manageCategoriesEditTitle": MessageLookupByLibrary.simpleMessage(
      "Modifier les catégories",
    ),
    "manageCategoriesEmptyDefault": MessageLookupByLibrary.simpleMessage(
      "Aucune catégorie ajoutée",
    ),
    "manageCategoriesEmptyEditing": MessageLookupByLibrary.simpleMessage(
      "Aucune catégorie pour ce plat",
    ),
    "manageCategoriesFinishEditing": MessageLookupByLibrary.simpleMessage(
      "Terminer la modification",
    ),
    "manageCategoriesSaveChanges": MessageLookupByLibrary.simpleMessage(
      "Enregistrer",
    ),
    "manageCategoriesSelectTitle": MessageLookupByLibrary.simpleMessage(
      "Sélectionner une catégorie",
    ),
    "manageCategoriesTitle": MessageLookupByLibrary.simpleMessage(
      "Gérer les catégories",
    ),
    "manageDishIngredients_additionalCostItem":
        MessageLookupByLibrary.simpleMessage("Article à coût supplémentaire"),
    "manageDishIngredients_cancel": MessageLookupByLibrary.simpleMessage(
      "Annuler",
    ),
    "manageDishIngredients_create": MessageLookupByLibrary.simpleMessage(
      "Créer",
    ),
    "manageDishIngredients_createNew": MessageLookupByLibrary.simpleMessage(
      "Créer",
    ),
    "manageDishIngredients_createYourFirstIngredient":
        MessageLookupByLibrary.simpleMessage(
          "Créez votre premier ingrédient pour commencer",
        ),
    "manageDishIngredients_deleteCancel": MessageLookupByLibrary.simpleMessage(
      "Annuler",
    ),
    "manageDishIngredients_deleteConfirm": MessageLookupByLibrary.simpleMessage(
      "Supprimer",
    ),
    "manageDishIngredients_deleteConfirmTitle":
        MessageLookupByLibrary.simpleMessage("Supprimer l\'ingrédient"),
    "manageDishIngredients_deleteIngredientContent": m3,
    "manageDishIngredients_deleteIngredientTitle":
        MessageLookupByLibrary.simpleMessage("Supprimer l\'ingrédient"),
    "manageDishIngredients_deleteTitle": MessageLookupByLibrary.simpleMessage(
      "Supprimer le plat",
    ),
    "manageDishIngredients_deleteTooltip": MessageLookupByLibrary.simpleMessage(
      "Supprimer",
    ),
    "manageDishIngredients_editDialogAdd": MessageLookupByLibrary.simpleMessage(
      "Ajouter un ingrédient",
    ),
    "manageDishIngredients_editDialogEdit":
        MessageLookupByLibrary.simpleMessage("Modifier l\'ingrédient"),
    "manageDishIngredients_editDialogIngredient":
        MessageLookupByLibrary.simpleMessage("Ingrédient"),
    "manageDishIngredients_editDialogSupplement":
        MessageLookupByLibrary.simpleMessage("Est un supplément"),
    "manageDishIngredients_editIngredientTitle":
        MessageLookupByLibrary.simpleMessage("Modifier l\'ingrédient"),
    "manageDishIngredients_editTitle": MessageLookupByLibrary.simpleMessage(
      "Modifier les ingrédients du plat",
    ),
    "manageDishIngredients_editTooltip": MessageLookupByLibrary.simpleMessage(
      "Modifier",
    ),
    "manageDishIngredients_emptyDefault": MessageLookupByLibrary.simpleMessage(
      "Aucun ingrédient ajouté",
    ),
    "manageDishIngredients_emptyEditing": MessageLookupByLibrary.simpleMessage(
      "Aucun ingrédient dans ce plat",
    ),
    "manageDishIngredients_enterPriceEg250":
        MessageLookupByLibrary.simpleMessage("Entrez le prix (ex. 2.50)"),
    "manageDishIngredients_finishEditing": MessageLookupByLibrary.simpleMessage(
      "Terminer la modification",
    ),
    "manageDishIngredients_free": MessageLookupByLibrary.simpleMessage(
      "Gratuit",
    ),
    "manageDishIngredients_ingredientAddedSuccessfully":
        MessageLookupByLibrary.simpleMessage("Ingrédient ajouté avec succès"),
    "manageDishIngredients_ingredientCreatedSuccessfully":
        MessageLookupByLibrary.simpleMessage("Ingrédient créé avec succès"),
    "manageDishIngredients_ingredientDeletedSuccessfully":
        MessageLookupByLibrary.simpleMessage("Ingrédient supprimé avec succès"),
    "manageDishIngredients_ingredientManagement":
        MessageLookupByLibrary.simpleMessage("Gestion des ingrédients"),
    "manageDishIngredients_ingredientRemovedSuccessfully":
        MessageLookupByLibrary.simpleMessage(
          "Ingrédient retiré du plat avec succès",
        ),
    "manageDishIngredients_ingredientUpdatedSuccessfully":
        MessageLookupByLibrary.simpleMessage(
          "Ingrédient mis à jour avec succès",
        ),
    "manageDishIngredients_ingredientsTitle":
        MessageLookupByLibrary.simpleMessage("Ingrédients du plat"),
    "manageDishIngredients_link": MessageLookupByLibrary.simpleMessage("Lier"),
    "manageDishIngredients_linkIngredients":
        MessageLookupByLibrary.simpleMessage("Lier les ingrédients"),
    "manageDishIngredients_linkIngredientsHint":
        MessageLookupByLibrary.simpleMessage(
          "Lier des ingrédients de votre liste de vendeur ou gérer votre bibliothèque d\'ingrédients",
        ),
    "manageDishIngredients_linkIngredientsToDish":
        MessageLookupByLibrary.simpleMessage("Lier des ingrédients au plat"),
    "manageDishIngredients_linkedIngredients":
        MessageLookupByLibrary.simpleMessage("ingrédients liés"),
    "manageDishIngredients_loadingIngredients":
        MessageLookupByLibrary.simpleMessage("Chargement des ingrédients..."),
    "manageDishIngredients_manageIngredients":
        MessageLookupByLibrary.simpleMessage("Gérer les ingrédients"),
    "manageDishIngredients_nameEnLabel": MessageLookupByLibrary.simpleMessage(
      "Nom (Anglais)",
    ),
    "manageDishIngredients_nameFrLabel": MessageLookupByLibrary.simpleMessage(
      "Nom (Français)",
    ),
    "manageDishIngredients_nameValidation":
        MessageLookupByLibrary.simpleMessage("Veuillez entrer un nom"),
    "manageDishIngredients_noIngredientsInLibrary":
        MessageLookupByLibrary.simpleMessage(
          "Aucun ingrédient dans votre bibliothèque",
        ),
    "manageDishIngredients_noteSave": MessageLookupByLibrary.simpleMessage(
      "Enregistrer",
    ),
    "manageDishIngredients_price": MessageLookupByLibrary.simpleMessage("Prix"),
    "manageDishIngredients_priceFree": MessageLookupByLibrary.simpleMessage(
      "Prix (gratuit)",
    ),
    "manageDishIngredients_retry": MessageLookupByLibrary.simpleMessage(
      "Réessayer",
    ),
    "manageDishIngredients_searchEmpty": MessageLookupByLibrary.simpleMessage(
      "Aucun ingrédient trouvé",
    ),
    "manageDishIngredients_searchIngredientsToLink":
        MessageLookupByLibrary.simpleMessage(
          "Rechercher des ingrédients à lier...",
        ),
    "manageDishIngredients_searchYourIngredients":
        MessageLookupByLibrary.simpleMessage("Rechercher vos ingrédients..."),
    "manageDishIngredients_sortByName": MessageLookupByLibrary.simpleMessage(
      "Trier par nom",
    ),
    "manageDishIngredients_sortByPrice": MessageLookupByLibrary.simpleMessage(
      "Trier par prix",
    ),
    "manageDishIngredients_sortByType": MessageLookupByLibrary.simpleMessage(
      "Trier par type",
    ),
    "manageDishIngredients_sortedBy": m4,
    "manageDishIngredients_standardIngredientFree":
        MessageLookupByLibrary.simpleMessage("Ingrédient standard (gratuit)"),
    "manageDishIngredients_standardIngredientsAreFree":
        MessageLookupByLibrary.simpleMessage(
          "Les ingrédients standard sont gratuits",
        ),
    "manageDishIngredients_standardLabel": MessageLookupByLibrary.simpleMessage(
      "Standard",
    ),
    "manageDishIngredients_supplementLabel":
        MessageLookupByLibrary.simpleMessage("Supplément"),
    "manageDishIngredients_supplementPrice":
        MessageLookupByLibrary.simpleMessage("Prix"),
    "manageDishIngredients_supplementsMustHavePrice":
        MessageLookupByLibrary.simpleMessage(
          "Les suppléments doivent avoir un prix supérieur à 0",
        ),
    "manageDishIngredients_title": MessageLookupByLibrary.simpleMessage(
      "Gérer les ingrédients",
    ),
    "manageDishIngredients_total": MessageLookupByLibrary.simpleMessage(
      "Total",
    ),
    "manageDishIngredients_update": MessageLookupByLibrary.simpleMessage(
      "Mettre à jour",
    ),
    "manageIngredients": MessageLookupByLibrary.simpleMessage(
      "Gérer les ingrédients",
    ),
    "manageIngredientsAddButton": MessageLookupByLibrary.simpleMessage(
      "Ajouter un ingrédient",
    ),
    "manageIngredientsEditDialogAdd": MessageLookupByLibrary.simpleMessage(
      "Ajouter un ingrédient",
    ),
    "manageIngredientsEditDialogEdit": MessageLookupByLibrary.simpleMessage(
      "Modifier l\'ingrédient",
    ),
    "manageIngredientsEditDialogIngredient":
        MessageLookupByLibrary.simpleMessage("Ingrédient"),
    "manageIngredientsEditDialogPrice": MessageLookupByLibrary.simpleMessage(
      "Prix",
    ),
    "manageIngredientsEditDialogSupplement":
        MessageLookupByLibrary.simpleMessage("Est un supplément"),
    "manageIngredientsEditTitle": MessageLookupByLibrary.simpleMessage(
      "Modifier les ingrédients du plat",
    ),
    "manageIngredientsEmptyDefault": MessageLookupByLibrary.simpleMessage(
      "Aucun ingrédient ajouté",
    ),
    "manageIngredientsEmptyEditing": MessageLookupByLibrary.simpleMessage(
      "Aucun ingrédient dans ce plat",
    ),
    "manageIngredientsFinishEditing": MessageLookupByLibrary.simpleMessage(
      "Terminer la modification",
    ),
    "manageIngredientsPrice": MessageLookupByLibrary.simpleMessage("Prix :"),
    "manageIngredientsSearchEmpty": MessageLookupByLibrary.simpleMessage(
      "Aucun ingrédient trouvé",
    ),
    "manageIngredientsSearchHint": MessageLookupByLibrary.simpleMessage(
      "Rechercher des ingrédients",
    ),
    "manageIngredientsSelectTitle": MessageLookupByLibrary.simpleMessage(
      "Sélectionner un ingrédient",
    ),
    "manageIngredientsStandard": MessageLookupByLibrary.simpleMessage(
      "Standard",
    ),
    "manageIngredientsSupplement": MessageLookupByLibrary.simpleMessage(
      "Supplément",
    ),
    "manageIngredientsTitle": MessageLookupByLibrary.simpleMessage(
      "Gérer les ingrédients",
    ),
    "manageIngredientsType": MessageLookupByLibrary.simpleMessage("Type :"),
    "manageIngredients_createTitle": MessageLookupByLibrary.simpleMessage(
      "Créer un ingrédient",
    ),
    "mapLaunchError": MessageLookupByLibrary.simpleMessage(
      "Impossible d\'ouvrir la carte",
    ),
    "markAsReadyButton": MessageLookupByLibrary.simpleMessage(
      "Prêt à emporter",
    ),
    "menuLabel": MessageLookupByLibrary.simpleMessage("Menu"),
    "menuScreen": MessageLookupByLibrary.simpleMessage("Écran Menu"),
    "method": MessageLookupByLibrary.simpleMessage("Méthode"),
    "moveTheMapToSelectLocation": MessageLookupByLibrary.simpleMessage(
      "Déplacez la carte pour sélectionner un emplacement",
    ),
    "myStore": MessageLookupByLibrary.simpleMessage("Ma boutique"),
    "nameEnglish": MessageLookupByLibrary.simpleMessage("Nom (anglais)"),
    "nameFrench": MessageLookupByLibrary.simpleMessage("Nom (français)"),
    "newTotal": MessageLookupByLibrary.simpleMessage("Nouveau total"),
    "noIngredients": MessageLookupByLibrary.simpleMessage(
      "Aucun ingrédient disponible",
    ),
    "noIngredientsInLibrary": MessageLookupByLibrary.simpleMessage(
      "Aucun ingrédient dans votre bibliothèque",
    ),
    "noLocationWarning": MessageLookupByLibrary.simpleMessage(
      "Aucun emplacement défini. Veuillez sélectionner un emplacement",
    ),
    "noName": MessageLookupByLibrary.simpleMessage("Sans nom"),
    "noStoreFound": MessageLookupByLibrary.simpleMessage(
      "Aucune boutique trouvée. Créez-en une !",
    ),
    "note": MessageLookupByLibrary.simpleMessage("Note"),
    "notification_emptyState": MessageLookupByLibrary.simpleMessage(
      "Aucune notification pour le moment",
    ),
    "notification_errorTitle": MessageLookupByLibrary.simpleMessage(
      "Oups ! Quelque chose s\'est mal passé",
    ),
    "notification_markAsRead": MessageLookupByLibrary.simpleMessage(
      "Marquer comme lu",
    ),
    "notification_newCount": m5,
    "notification_title": MessageLookupByLibrary.simpleMessage("Notification"),
    "notification_tryAgain": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "onboarding_back": MessageLookupByLibrary.simpleMessage("Retour"),
    "onboarding_getStarted": MessageLookupByLibrary.simpleMessage("Commencer"),
    "onboarding_next": MessageLookupByLibrary.simpleMessage("Suivant"),
    "onboarding_slide1Text": MessageLookupByLibrary.simpleMessage(
      "Des repas préparés avec soin, des ingrédients frais et une touche personnelle par des chefs locaux près de chez vous.",
    ),
    "onboarding_slide1Title": MessageLookupByLibrary.simpleMessage(
      "Découvrez des plats maison délicieux",
    ),
    "onboarding_slide2Text": MessageLookupByLibrary.simpleMessage(
      "Des recettes traditionnelles aux créations uniques, trouvez des chefs qui répondent à vos envies culinaires.",
    ),
    "onboarding_slide2Title": MessageLookupByLibrary.simpleMessage(
      "Connectez-vous avec des chefs passionnés",
    ),
    "onboarding_slide3Text": MessageLookupByLibrary.simpleMessage(
      "Vos plats maison préférés, à quelques clics. Faisons venir la cuisine locale à votre table.",
    ),
    "onboarding_slide3Title": MessageLookupByLibrary.simpleMessage(
      "Commandez facilement, livré frais",
    ),
    "operationFailed": MessageLookupByLibrary.simpleMessage(
      "L\'opération a échoué",
    ),
    "optVerification_codeHint": MessageLookupByLibrary.simpleMessage(
      "Entrez le code",
    ),
    "optVerification_error": MessageLookupByLibrary.simpleMessage(
      "Code invalide. Veuillez réessayer.",
    ),
    "optVerification_fieldHint": MessageLookupByLibrary.simpleMessage("0"),
    "optVerification_resend": MessageLookupByLibrary.simpleMessage(
      "Renvoyer le code",
    ),
    "optVerification_submit": MessageLookupByLibrary.simpleMessage("Vérifier"),
    "optVerification_subtitle": MessageLookupByLibrary.simpleMessage(
      "Entrez le code à 6 chiffres envoyé à votre e-mail pour vérifier votre compte.",
    ),
    "optVerification_success": MessageLookupByLibrary.simpleMessage(
      "E-mail confirmé !",
    ),
    "optVerification_title": MessageLookupByLibrary.simpleMessage(
      "Vérifiez votre e-mail",
    ),
    "optVerification_validationRequired": MessageLookupByLibrary.simpleMessage(
      "Validation requise",
    ),
    "orUseCurrentLocation": MessageLookupByLibrary.simpleMessage(
      "ou utilisez la position actuelle",
    ),
    "orderConfirmationCode": MessageLookupByLibrary.simpleMessage(
      "Code de confirmation",
    ),
    "orderFilter_labelDeliveryStatus": MessageLookupByLibrary.simpleMessage(
      "Statut de la livraison",
    ),
    "orderFilter_labelPaymentStatus": MessageLookupByLibrary.simpleMessage(
      "Statut du paiement",
    ),
    "orderFilter_labelSortBy": MessageLookupByLibrary.simpleMessage(
      "Trier par",
    ),
    "orderFilter_labelSortOrder": MessageLookupByLibrary.simpleMessage("Ordre"),
    "orderFilter_labelStatus": MessageLookupByLibrary.simpleMessage(
      "Statut de la commande",
    ),
    "orderFilter_optionAll": MessageLookupByLibrary.simpleMessage("Tout"),
    "orderFilter_optionAsc": MessageLookupByLibrary.simpleMessage("Croissant"),
    "orderFilter_optionDesc": MessageLookupByLibrary.simpleMessage(
      "Décroissant",
    ),
    "orderId": MessageLookupByLibrary.simpleMessage("ID de commande"),
    "orderStatusCancelled": MessageLookupByLibrary.simpleMessage("Annulé"),
    "orderStatusCompleted": MessageLookupByLibrary.simpleMessage("Terminé"),
    "orderStatusConfirmed": MessageLookupByLibrary.simpleMessage("Confirmé"),
    "orderStatusDelivered": MessageLookupByLibrary.simpleMessage("Livré"),
    "orderStatusFailed": MessageLookupByLibrary.simpleMessage("Échoué"),
    "orderStatusInTransit": MessageLookupByLibrary.simpleMessage("En transit"),
    "orderStatusPaid": MessageLookupByLibrary.simpleMessage("Payé"),
    "orderStatusPending": MessageLookupByLibrary.simpleMessage("En attente"),
    "orderStatusProcessing": MessageLookupByLibrary.simpleMessage(
      "Traitement en cours",
    ),
    "orderStatusReady": MessageLookupByLibrary.simpleMessage("Prêt"),
    "orderStatusRefundFailed": MessageLookupByLibrary.simpleMessage(
      "Échec du remboursement",
    ),
    "orderStatusRefundRequested": MessageLookupByLibrary.simpleMessage(
      "Remboursement demandé",
    ),
    "orderStatusRefunded": MessageLookupByLibrary.simpleMessage("Remboursé"),
    "orderTotal": MessageLookupByLibrary.simpleMessage("Total de la commande"),
    "ordersLabel": MessageLookupByLibrary.simpleMessage("Commandes"),
    "passwordRecoveryButton": MessageLookupByLibrary.simpleMessage(
      "Envoyer le lien de réinitialisation",
    ),
    "passwordRecoveryEmailHint": MessageLookupByLibrary.simpleMessage(
      "Entrez votre adresse e-mail",
    ),
    "passwordRecoveryEmailInvalid": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer une adresse e-mail valide",
    ),
    "passwordRecoveryEmailRequired": MessageLookupByLibrary.simpleMessage(
      "L\'e-mail est requis",
    ),
    "passwordRecoveryErrorMessage": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'envoi du lien de réinitialisation",
    ),
    "passwordRecoverySubtitle": MessageLookupByLibrary.simpleMessage(
      "Entrez votre e-mail pour recevoir un lien de réinitialisation.",
    ),
    "passwordRecoverySuccessMessage": MessageLookupByLibrary.simpleMessage(
      "Si l\'e-mail existe, un lien de réinitialisation a été envoyé.",
    ),
    "passwordRecoveryTitle": MessageLookupByLibrary.simpleMessage(
      "Récupérer le mot de passe",
    ),
    "paymentCompleted": MessageLookupByLibrary.simpleMessage(
      "Paiement effectué !",
    ),
    "paymentFailedToInitialize": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'initialisation du formulaire de paiement",
    ),
    "paymentInfo": MessageLookupByLibrary.simpleMessage(
      "Informations de paiement",
    ),
    "paymentInfo_default": MessageLookupByLibrary.simpleMessage(
      "Carte de paiement par défaut",
    ),
    "paymentInfo_empty": MessageLookupByLibrary.simpleMessage(
      "Aucune carte de paiement trouvée",
    ),
    "paymentInfo_expires": MessageLookupByLibrary.simpleMessage("Expire le :"),
    "paymentInfo_title": MessageLookupByLibrary.simpleMessage(
      "Informations de paiement",
    ),
    "paymentStripeError": m6,
    "paymentUnexpectedError": m7,
    "pleaseEnterName": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer un nom",
    ),
    "pleaseSelectLocation": MessageLookupByLibrary.simpleMessage(
      "Veuillez sélectionner un emplacement sur la carte.",
    ),
    "price": MessageLookupByLibrary.simpleMessage("Prix"),
    "priceFree": MessageLookupByLibrary.simpleMessage("Prix (gratuit)"),
    "priceText": m8,
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Politique de confidentialité",
    ),
    "privacyPolicy_conclusion": MessageLookupByLibrary.simpleMessage(
      "Cette Politique de confidentialité entre en vigueur à compter du 6 november 2025.",
    ),
    "privacyPolicy_intro": MessageLookupByLibrary.simpleMessage(
      "Bienvenue chez Cuisinous ! Nous accordons une grande importance à la confidentialité et à la protection de vos renseignements personnels. La présente Politique de confidentialité explique quelles données nous recueillons, comment nous les utilisons, comment elles sont protégées, ainsi que les droits dont vous disposez en tant qu’utilisateur de notre application et de notre site web. En utilisant Cuisinous, vous acceptez les pratiques décrites dans cette politique.",
    ),
    "privacyPolicy_section1Body": MessageLookupByLibrary.simpleMessage(
      "Lorsque vous utilisez notre plateforme, nous pouvons recueillir les informations suivantes : Informations d’inscription : nom, adresse courriel, numéro de téléphone, mot de passe. Vérification de compte : documents d’identité ou licences nécessaires selon les exigences légales. Informations de transaction : détails des commandes, paiements, factures et historique d’achats. Données de localisation : pour identifier les repas et vendeurs près de vous. Données d’utilisation : navigation dans l’application, préférences, évaluations et commentaires.",
    ),
    "privacyPolicy_section1Title": MessageLookupByLibrary.simpleMessage(
      "1. Renseignements que nous recueillons",
    ),
    "privacyPolicy_section2Body": MessageLookupByLibrary.simpleMessage(
      "Nous utilisons vos renseignements personnels afin de : Créer et gérer vos comptes de vendeur ou de client. Faciliter les commandes et paiements sécurisés. Offrir des services personnalisés (menus locaux, recommandations, promotions). Prévenir la fraude, assurer la sécurité de la plateforme et respecter les obligations légales. Communiquer avec vous concernant votre compte, vos commandes ou nos services.",
    ),
    "privacyPolicy_section2Title": MessageLookupByLibrary.simpleMessage(
      "2. Utilisation de vos renseignements",
    ),
    "privacyPolicy_section3Body": MessageLookupByLibrary.simpleMessage(
      "Nous ne vendons jamais vos renseignements personnels. Nous pouvons partager certaines données uniquement avec : Les fournisseurs de paiement sécurisés. Les partenaires de livraison (si applicable). Les autorités légales lorsque requis par la loi.",
    ),
    "privacyPolicy_section3Title": MessageLookupByLibrary.simpleMessage(
      "3. Partage des renseignements",
    ),
    "privacyPolicy_section4Body": MessageLookupByLibrary.simpleMessage(
      "Vos données sont stockées de manière sécurisée au Canada ou dans des serveurs conformes aux lois applicables. Nous mettons en place des mesures techniques et organisationnelles pour protéger vos renseignements contre l’accès non autorisé, la perte ou l’utilisation abusive.",
    ),
    "privacyPolicy_section4Title": MessageLookupByLibrary.simpleMessage(
      "4. Conservation et sécurité",
    ),
    "privacyPolicy_section5Body": MessageLookupByLibrary.simpleMessage(
      "Conformément à la Loi 25 (Québec) et aux lois canadiennes sur la protection des renseignements personnels, vous avez le droit de : Accéder à vos données personnelles. Demander la correction ou la suppression de certaines données. Retirer votre consentement au traitement de vos informations. Déposer une plainte auprès de la Commission d’accès à l’information du Québec si nécessaire.",
    ),
    "privacyPolicy_section5Title": MessageLookupByLibrary.simpleMessage(
      "5. Vos droits",
    ),
    "privacyPolicy_section6Body": MessageLookupByLibrary.simpleMessage(
      "Nous utilisons des cookies et outils d’analyse afin d’améliorer l’expérience utilisateur, personnaliser le contenu et mesurer la performance de notre application. Vous pouvez gérer vos préférences dans les paramètres de votre navigateur.",
    ),
    "privacyPolicy_section6Title": MessageLookupByLibrary.simpleMessage(
      "6. Témoins (cookies) et technologies similaires",
    ),
    "privacyPolicy_section7Body": MessageLookupByLibrary.simpleMessage(
      "Nous pouvons mettre à jour cette Politique de confidentialité de temps à autre. Toute modification sera publiée sur notre site avec la date de mise à jour.",
    ),
    "privacyPolicy_section7Title": MessageLookupByLibrary.simpleMessage(
      "7. Modifications de la politique",
    ),
    "privacyPolicy_section8Body": MessageLookupByLibrary.simpleMessage(
      "Pour toute question concernant cette Politique ou pour exercer vos droits, vous pouvez nous contacter à : 📧 info@cuisinous.ca 📍 Cuisinous Inc., Québec, Canada",
    ),
    "privacyPolicy_section8Title": MessageLookupByLibrary.simpleMessage(
      "8. Contact",
    ),
    "privacyPolicy_title": MessageLookupByLibrary.simpleMessage(
      "Politique de confidentialité – Cuisinous",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "profile_updated_successfully": MessageLookupByLibrary.simpleMessage(
      "Profil mis à jour avec succès",
    ),
    "proxyCallNotAvailable": MessageLookupByLibrary.simpleMessage(
      "L\'appel n\'est pas encore disponible pour cette commande.",
    ),
    "proxyCallNotSupported": MessageLookupByLibrary.simpleMessage(
      "L\'appel n\'est pas pris en charge sur cet appareil.",
    ),
    "proxyCallOrderNotFound": MessageLookupByLibrary.simpleMessage(
      "Commande introuvable.",
    ),
    "proxyCallServerError": MessageLookupByLibrary.simpleMessage(
      "Erreur serveur. Veuillez réessayer plus tard.",
    ),
    "proxyCallUnableToInitiate": MessageLookupByLibrary.simpleMessage(
      "Impossible d\'initier l\'appel. Veuillez réessayer plus tard.",
    ),
    "quickTipAmounts": MessageLookupByLibrary.simpleMessage("Pourboire rapide"),
    "rateApp": MessageLookupByLibrary.simpleMessage("Évaluer l\'application"),
    "rated": MessageLookupByLibrary.simpleMessage("Évalué"),
    "recipe_addToCart": MessageLookupByLibrary.simpleMessage(
      "Ajouter au panier -",
    ),
    "recipe_addedToCart": MessageLookupByLibrary.simpleMessage(
      "Ajouté au panier -",
    ),
    "recipe_categories": MessageLookupByLibrary.simpleMessage("Catégories"),
    "recipe_description": MessageLookupByLibrary.simpleMessage("Description"),
    "recipe_empty": MessageLookupByLibrary.simpleMessage(
      "Aucune recette trouvée",
    ),
    "recipe_gallery": MessageLookupByLibrary.simpleMessage("Galerie"),
    "recipe_ingredients": MessageLookupByLibrary.simpleMessage("Ingrédients"),
    "recipe_noDescription": MessageLookupByLibrary.simpleMessage(
      "Aucune description disponible",
    ),
    "recipe_noReviews": MessageLookupByLibrary.simpleMessage(
      "Aucun avis pour l\'instant. Soyez le premier à donner votre avis !",
    ),
    "recipe_rating": MessageLookupByLibrary.simpleMessage("Note :"),
    "recipe_ratingRequired": MessageLookupByLibrary.simpleMessage(
      "Veuillez sélectionner une note",
    ),
    "recipe_reviewRequired": MessageLookupByLibrary.simpleMessage(
      "Veuillez écrire un avis",
    ),
    "recipe_reviewSuccess": MessageLookupByLibrary.simpleMessage(
      "Avis soumis avec succès !",
    ),
    "recipe_reviews": MessageLookupByLibrary.simpleMessage("Avis"),
    "recipe_shareExperience": MessageLookupByLibrary.simpleMessage(
      "Partagez votre expérience...",
    ),
    "recipe_submitReview": MessageLookupByLibrary.simpleMessage(
      "Soumettre l\'avis",
    ),
    "recipe_vendor": MessageLookupByLibrary.simpleMessage("Vendeur"),
    "recipe_writeReview": MessageLookupByLibrary.simpleMessage(
      "Écrire un avis",
    ),
    "recipe_yourReview": MessageLookupByLibrary.simpleMessage("Votre avis"),
    "refresh": MessageLookupByLibrary.simpleMessage("Actualiser"),
    "register_acceptTermsPart1": MessageLookupByLibrary.simpleMessage(
      "J\'accepte les ",
    ),
    "register_acceptTermsPart2": MessageLookupByLibrary.simpleMessage(
      " et les ",
    ),
    "register_acceptTermsPart3": MessageLookupByLibrary.simpleMessage(
      " de Cuisinous",
    ),
    "register_button": MessageLookupByLibrary.simpleMessage("S\'inscrire"),
    "register_emailHint": MessageLookupByLibrary.simpleMessage(
      "Entrez votre e-mail",
    ),
    "register_emailLabel": MessageLookupByLibrary.simpleMessage("Email :"),
    "register_firstNameHint": MessageLookupByLibrary.simpleMessage("Jean"),
    "register_firstNameLabel": MessageLookupByLibrary.simpleMessage("Prénom"),
    "register_googleButton": MessageLookupByLibrary.simpleMessage(
      "Se connecter avec Google",
    ),
    "register_lastNameHint": MessageLookupByLibrary.simpleMessage("Dupont"),
    "register_lastNameLabel": MessageLookupByLibrary.simpleMessage(
      "Nom de famille",
    ),
    "register_loginPrompt": MessageLookupByLibrary.simpleMessage(
      "Vous avez déjà un compte ? Connectez-vous",
    ),
    "register_passwordHint": MessageLookupByLibrary.simpleMessage(
      "Entrez votre mot de passe",
    ),
    "register_passwordLabel": MessageLookupByLibrary.simpleMessage(
      "Mot de passe :",
    ),
    "register_phoneHint": MessageLookupByLibrary.simpleMessage(
      "Entrez votre numéro de téléphone",
    ),
    "register_phoneLabel": MessageLookupByLibrary.simpleMessage(
      "Numéro de téléphone",
    ),
    "register_slogan": MessageLookupByLibrary.simpleMessage(
      "VOS VOISINS, VOS CHEFS",
    ),
    "register_validationEmailInvalid": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer une adresse e-mail valide",
    ),
    "register_validationEmailRequired": MessageLookupByLibrary.simpleMessage(
      "L\'e-mail est requis",
    ),
    "register_validationFirstNameRequired":
        MessageLookupByLibrary.simpleMessage("Le prénom est requis"),
    "register_validationLastNameRequired": MessageLookupByLibrary.simpleMessage(
      "Le nom de famille est requis",
    ),
    "register_validationPasswordLength": MessageLookupByLibrary.simpleMessage(
      "Le mot de passe doit contenir au moins 8 caractères",
    ),
    "register_validationPasswordNumber": MessageLookupByLibrary.simpleMessage(
      "Le mot de passe doit contenir au moins un chiffre",
    ),
    "register_validationPasswordRequired": MessageLookupByLibrary.simpleMessage(
      "Le mot de passe ne peut pas être vide",
    ),
    "register_validationPasswordSpecial": MessageLookupByLibrary.simpleMessage(
      "Le mot de passe doit contenir au moins un caractère spécial",
    ),
    "register_validationPasswordUppercase":
        MessageLookupByLibrary.simpleMessage(
          "Le mot de passe doit contenir au moins une majuscule",
        ),
    "register_validationPhoneInvalid": MessageLookupByLibrary.simpleMessage(
      "Entrez un numéro de téléphone valide",
    ),
    "register_validationPhoneRequired": MessageLookupByLibrary.simpleMessage(
      "Le numéro de téléphone est requis",
    ),
    "requiredField": MessageLookupByLibrary.simpleMessage(
      "Ce champ est requis",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "retryAction": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "retryButton": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "save": MessageLookupByLibrary.simpleMessage(
      "Enregistrer les Modifications",
    ),
    "searchIngredientsToLink": MessageLookupByLibrary.simpleMessage(
      "Rechercher des ingrédients à lier...",
    ),
    "searchYourIngredients": MessageLookupByLibrary.simpleMessage(
      "Rechercher vos ingrédients...",
    ),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("Choisir la langue"),
    "selectedLocation": MessageLookupByLibrary.simpleMessage(
      "Emplacement Sélectionné",
    ),
    "sellerHome_adminFeedback": MessageLookupByLibrary.simpleMessage(
      "Commentaire de l\'Admin",
    ),
    "sellerHome_analytics": MessageLookupByLibrary.simpleMessage(
      "Voir les Statistiques",
    ),
    "sellerHome_createStore": MessageLookupByLibrary.simpleMessage(
      "Créer Votre boutique",
    ),
    "sellerHome_noStore": MessageLookupByLibrary.simpleMessage(
      "Vous n\'avez pas encore configuré votre boutique.",
    ),
    "sellerHome_pendingOrders": MessageLookupByLibrary.simpleMessage(
      "Commandes en attente",
    ),
    "sellerHome_quickActions": MessageLookupByLibrary.simpleMessage(
      "Actions Rapides",
    ),
    "sellerHome_sellerFallback": MessageLookupByLibrary.simpleMessage(
      "Vendeur",
    ),
    "sellerHome_statusApproved": MessageLookupByLibrary.simpleMessage(
      "Approuvé",
    ),
    "sellerHome_statusPending": MessageLookupByLibrary.simpleMessage(
      "En attente",
    ),
    "sellerHome_statusRejected": MessageLookupByLibrary.simpleMessage("Rejeté"),
    "sellerHome_totalRevenue": MessageLookupByLibrary.simpleMessage(
      "Revenu total",
    ),
    "sellerHome_updateStore": MessageLookupByLibrary.simpleMessage(
      "Modifier le boutique",
    ),
    "sellerHome_verificationStatus": MessageLookupByLibrary.simpleMessage(
      "Statut de Vérification :",
    ),
    "sellerHome_welcome": MessageLookupByLibrary.simpleMessage("Bienvenue"),
    "sellerOrderManagement_cancel": MessageLookupByLibrary.simpleMessage(
      "Annuler",
    ),
    "sellerOrderManagement_cancelOrder": MessageLookupByLibrary.simpleMessage(
      "Annuler la commande",
    ),
    "sellerOrderManagement_date": MessageLookupByLibrary.simpleMessage(
      "Date :",
    ),
    "sellerOrderManagement_empty": MessageLookupByLibrary.simpleMessage(
      "Aucune commande trouvée",
    ),
    "sellerOrderManagement_filter": MessageLookupByLibrary.simpleMessage(
      "Filtrer et trier",
    ),
    "sellerOrderManagement_itemBuyer": MessageLookupByLibrary.simpleMessage(
      "Acheteur :",
    ),
    "sellerOrderManagement_itemPlaced": MessageLookupByLibrary.simpleMessage(
      "Passée le :",
    ),
    "sellerOrderManagement_itemTotal": MessageLookupByLibrary.simpleMessage(
      "Total :",
    ),
    "sellerOrderManagement_labelConfirmationCode":
        MessageLookupByLibrary.simpleMessage("Code de confirmation :"),
    "sellerOrderManagement_labelDeliveryStatus":
        MessageLookupByLibrary.simpleMessage("Statut de livraison :"),
    "sellerOrderManagement_labelEmail": MessageLookupByLibrary.simpleMessage(
      "Email :",
    ),
    "sellerOrderManagement_labelName": MessageLookupByLibrary.simpleMessage(
      "Nom :",
    ),
    "sellerOrderManagement_labelPaymentStatus":
        MessageLookupByLibrary.simpleMessage("Statut du paiement :"),
    "sellerOrderManagement_labelPhone": MessageLookupByLibrary.simpleMessage(
      "Téléphone :",
    ),
    "sellerOrderManagement_labelSubtotal": MessageLookupByLibrary.simpleMessage(
      "Sous-total :",
    ),
    "sellerOrderManagement_labelTipAmount":
        MessageLookupByLibrary.simpleMessage("Montant du pourboire :"),
    "sellerOrderManagement_notFound": MessageLookupByLibrary.simpleMessage(
      "Reçu introuvable",
    ),
    "sellerOrderManagement_orderDetailsTitle":
        MessageLookupByLibrary.simpleMessage("Détails de la commande"),
    "sellerOrderManagement_orderFrom": MessageLookupByLibrary.simpleMessage(
      "DE",
    ),
    "sellerOrderManagement_orderNumber": MessageLookupByLibrary.simpleMessage(
      "Commande n° :",
    ),
    "sellerOrderManagement_retry": MessageLookupByLibrary.simpleMessage(
      "Réessayer",
    ),
    "sellerOrderManagement_searchHint": MessageLookupByLibrary.simpleMessage(
      "Numéro de commande, nom de l\'acheteur...",
    ),
    "sellerOrderManagement_sectionCustomer":
        MessageLookupByLibrary.simpleMessage("CLIENT"),
    "sellerOrderManagement_sectionDeliveryTo":
        MessageLookupByLibrary.simpleMessage("LIVRAISON À"),
    "sellerOrderManagement_sectionItems": MessageLookupByLibrary.simpleMessage(
      "ARTICLES",
    ),
    "sellerOrderManagement_sectionOrderNotes":
        MessageLookupByLibrary.simpleMessage("NOTES DE COMMANDE"),
    "sellerOrderManagement_sectionPaymentDetails":
        MessageLookupByLibrary.simpleMessage("DÉTAILS DE PAIEMENT"),
    "sellerOrderManagement_sectionTotal": MessageLookupByLibrary.simpleMessage(
      "TOTAL",
    ),
    "sellerOrderManagement_thankYou": MessageLookupByLibrary.simpleMessage(
      "Merci pour votre commande !",
    ),
    "sellerOrderManagement_title": MessageLookupByLibrary.simpleMessage(
      "Commandes du vendeur",
    ),
    "sellerOrderManagement_totalPaid": MessageLookupByLibrary.simpleMessage(
      "TOTAL PAYÉ",
    ),
    "sellerStats_averageOrderValue": MessageLookupByLibrary.simpleMessage(
      "Valeur moyenne de commande",
    ),
    "sellerStats_dailyRevenue": MessageLookupByLibrary.simpleMessage(
      "Revenu quotidien",
    ),
    "sellerStats_monthlyRevenue": MessageLookupByLibrary.simpleMessage(
      "Revenu mensuel",
    ),
    "sellerStats_noDataMonth": MessageLookupByLibrary.simpleMessage(
      "Aucune donnée pour ce mois",
    ),
    "sellerStats_noDataYear": MessageLookupByLibrary.simpleMessage(
      "Aucune donnée pour cette année",
    ),
    "sellerStats_noYearlyData": MessageLookupByLibrary.simpleMessage(
      "Aucune donnée annuelle disponible",
    ),
    "sellerStats_title": MessageLookupByLibrary.simpleMessage(
      "Analyses du boutique",
    ),
    "sellerStats_totalOrders": MessageLookupByLibrary.simpleMessage(
      "Commandes totales",
    ),
    "sellerStats_yearlyRevenue": MessageLookupByLibrary.simpleMessage(
      "Revenu annuel",
    ),
    "sellerWalletBalance": MessageLookupByLibrary.simpleMessage("Solde actuel"),
    "sellerWalletNoTransactions": MessageLookupByLibrary.simpleMessage(
      "Aucune transaction",
    ),
    "sellerWalletTitle": MessageLookupByLibrary.simpleMessage("Portefeuille"),
    "sellerWalletTransactionCredit": MessageLookupByLibrary.simpleMessage(
      "Crédit",
    ),
    "sellerWalletTransactionDate": MessageLookupByLibrary.simpleMessage("Date"),
    "sellerWalletTransactionDebit": MessageLookupByLibrary.simpleMessage(
      "Débit",
    ),
    "sellerWalletTransactionDescription": MessageLookupByLibrary.simpleMessage(
      "Description",
    ),
    "sellerWalletTransactionReference": MessageLookupByLibrary.simpleMessage(
      "Référence",
    ),
    "sellerWalletTransactionType": MessageLookupByLibrary.simpleMessage("Type"),
    "settingsLabel": MessageLookupByLibrary.simpleMessage("Paramètres"),
    "settings_languageChangeError": MessageLookupByLibrary.simpleMessage(
      "Échec du changement de langue",
    ),
    "settings_languageUpdated": MessageLookupByLibrary.simpleMessage(
      "Langue mise à jour",
    ),
    "settings_noName": MessageLookupByLibrary.simpleMessage("Sans nom"),
    "settings_selectLanguage": MessageLookupByLibrary.simpleMessage(
      "Choisir la langue",
    ),
    "sortByName": MessageLookupByLibrary.simpleMessage("Trier par nom"),
    "sortByPrice": MessageLookupByLibrary.simpleMessage("Trier par prix"),
    "sortByType": MessageLookupByLibrary.simpleMessage("Trier par type"),
    "sortedBy": m9,
    "standardIngredientFree": MessageLookupByLibrary.simpleMessage(
      "Ingrédient standard (gratuit)",
    ),
    "standardIngredientsAreFree": MessageLookupByLibrary.simpleMessage(
      "Les ingrédients standard sont gratuits",
    ),
    "statsLabel": MessageLookupByLibrary.simpleMessage("Statistiques"),
    "statsScreen": MessageLookupByLibrary.simpleMessage("Écran Statistiques"),
    "status": MessageLookupByLibrary.simpleMessage("Statut"),
    "store": MessageLookupByLibrary.simpleMessage("boutique"),
    "storeBioHint": MessageLookupByLibrary.simpleMessage(
      "Décrivez votre boutique",
    ),
    "storeBioLabel": MessageLookupByLibrary.simpleMessage(
      "Bio / Description du boutique",
    ),
    "storeForm_addressNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Adresse non disponible",
    ),
    "storeForm_bioHint": MessageLookupByLibrary.simpleMessage(
      "Décrivez votre boutique",
    ),
    "storeForm_bioLabel": MessageLookupByLibrary.simpleMessage(
      "Bio / Description du boutique",
    ),
    "storeForm_changeImage": MessageLookupByLibrary.simpleMessage(
      "Changer l\'Image",
    ),
    "storeForm_confirmLocation": MessageLookupByLibrary.simpleMessage(
      "Confirmer l\'emplacement",
    ),
    "storeForm_couldNotFetchAddress": MessageLookupByLibrary.simpleMessage(
      "Impossible de récupérer l\'adresse. Veuillez réessayer.",
    ),
    "storeForm_createStore": MessageLookupByLibrary.simpleMessage(
      "Créer un boutique",
    ),
    "storeForm_editStore": MessageLookupByLibrary.simpleMessage(
      "Modifier le boutique",
    ),
    "storeForm_moveTheMapToSelectLocation":
        MessageLookupByLibrary.simpleMessage(
          "Déplacez la carte pour sélectionner un emplacement",
        ),
    "storeForm_nameHint": MessageLookupByLibrary.simpleMessage(
      "Entrez le nom de votre boutique",
    ),
    "storeForm_nameLabel": MessageLookupByLibrary.simpleMessage(
      "Nom du boutique",
    ),
    "storeForm_operationFailed": MessageLookupByLibrary.simpleMessage(
      "L\'opération a échoué",
    ),
    "storeForm_pleaseSelectLocation": MessageLookupByLibrary.simpleMessage(
      "Veuillez sélectionner un emplacement sur la carte.",
    ),
    "storeForm_requiredField": MessageLookupByLibrary.simpleMessage(
      "Ce champ est requis",
    ),
    "storeForm_save": MessageLookupByLibrary.simpleMessage(
      "Enregistrer les Modifications",
    ),
    "storeForm_selectedLocation": MessageLookupByLibrary.simpleMessage(
      "Emplacement Sélectionné",
    ),
    "storeForm_tapToSelectLocation": MessageLookupByLibrary.simpleMessage(
      "Appuyez pour sélectionner un emplacement",
    ),
    "storeForm_uploadImage": MessageLookupByLibrary.simpleMessage(
      "Télécharger une Image",
    ),
    "storeHome_createStore": MessageLookupByLibrary.simpleMessage(
      "Créer une boutique",
    ),
    "storeHome_errorLoadingStore": MessageLookupByLibrary.simpleMessage(
      "Échec du chargement de la boutique. Veuillez réessayer.",
    ),
    "storeHome_loadingStoreInformation": MessageLookupByLibrary.simpleMessage(
      "Chargement des informations de la boutique...",
    ),
    "storeHome_noStoreFound": MessageLookupByLibrary.simpleMessage(
      "Aucune boutique trouvée. Créez-en une !",
    ),
    "storeHome_retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "storeHome_title": MessageLookupByLibrary.simpleMessage("Ma boutique"),
    "storeInformation": MessageLookupByLibrary.simpleMessage(
      "Informations du magasin",
    ),
    "storeLocation": MessageLookupByLibrary.simpleMessage(
      "Emplacement de la boutique",
    ),
    "storeName": MessageLookupByLibrary.simpleMessage("Nom de la boutique"),
    "storeNameHint": MessageLookupByLibrary.simpleMessage(
      "Entrez le nom de votre boutique",
    ),
    "storeNameLabel": MessageLookupByLibrary.simpleMessage("Nom du magasin"),
    "storeNavigation_initializing": MessageLookupByLibrary.simpleMessage(
      "Initialisation...",
    ),
    "storeNavigation_operationFailed": MessageLookupByLibrary.simpleMessage(
      "L\'opération a échoué",
    ),
    "storeNavigation_retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "storeProfile_address": MessageLookupByLibrary.simpleMessage("Adresse"),
    "storeProfile_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
    "storeProfile_coordinates": m10,
    "storeProfile_deleteStore": MessageLookupByLibrary.simpleMessage(
      "Supprimer la boutique",
    ),
    "storeProfile_deleteStoreContent": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir supprimer votre boutique et vous déconnecter ?",
    ),
    "storeProfile_description": MessageLookupByLibrary.simpleMessage(
      "Description",
    ),
    "storeProfile_editStore": MessageLookupByLibrary.simpleMessage(
      "Modifier la boutique",
    ),
    "storeProfile_errorLoadingStore": MessageLookupByLibrary.simpleMessage(
      "Échec du chargement de la boutique. Veuillez réessayer.",
    ),
    "storeProfile_storeName": MessageLookupByLibrary.simpleMessage(
      "Nom de la boutique",
    ),
    "storeVerificationAdminComment": MessageLookupByLibrary.simpleMessage(
      "Commentaire de l\'administrateur",
    ),
    "storeVerificationContinue": MessageLookupByLibrary.simpleMessage(
      "Continuer",
    ),
    "storeVerificationContinueHome": MessageLookupByLibrary.simpleMessage(
      "Continuer vers l\'accueil",
    ),
    "storeVerificationDate": MessageLookupByLibrary.simpleMessage(
      "Date de vérification",
    ),
    "storeVerificationFoodStore": MessageLookupByLibrary.simpleMessage(
      "boutique alimentaire",
    ),
    "storeVerificationNoRequest": MessageLookupByLibrary.simpleMessage(
      "Aucune demande de vérification soumise",
    ),
    "storeVerificationPrompt": MessageLookupByLibrary.simpleMessage(
      "Veuillez fournir les documents nécessaires pour vérifier votre boutique.",
    ),
    "storeVerificationRectify": MessageLookupByLibrary.simpleMessage(
      "Rectifier votre demande",
    ),
    "storeVerificationRequestId": MessageLookupByLibrary.simpleMessage(
      "ID de la demande",
    ),
    "storeVerificationRequest_adminComment":
        MessageLookupByLibrary.simpleMessage(
          "Commentaire de l\'administrateur",
        ),
    "storeVerificationRequest_continueHome":
        MessageLookupByLibrary.simpleMessage("Continuer vers l\'accueil"),
    "storeVerificationRequest_date": MessageLookupByLibrary.simpleMessage(
      "Date de vérification",
    ),
    "storeVerificationRequest_foodStore": MessageLookupByLibrary.simpleMessage(
      "boutique alimentaire",
    ),
    "storeVerificationRequest_logout": MessageLookupByLibrary.simpleMessage(
      "Se déconnecter",
    ),
    "storeVerificationRequest_rectify": MessageLookupByLibrary.simpleMessage(
      "Rectifier votre demande",
    ),
    "storeVerificationRequest_requestId": MessageLookupByLibrary.simpleMessage(
      "ID de la demande",
    ),
    "storeVerificationRequest_retry": MessageLookupByLibrary.simpleMessage(
      "Réessayer",
    ),
    "storeVerificationRequest_start": MessageLookupByLibrary.simpleMessage(
      "Démarrer la Vérification",
    ),
    "storeVerificationRequest_status": MessageLookupByLibrary.simpleMessage(
      "Statut de vérification",
    ),
    "storeVerificationRequest_submittedDoc":
        MessageLookupByLibrary.simpleMessage("Document soumis"),
    "storeVerificationRequest_swipeDown": MessageLookupByLibrary.simpleMessage(
      "Glissez vers le bas pour actualiser",
    ),
    "storeVerificationRequest_verifiedBy": MessageLookupByLibrary.simpleMessage(
      "Vérifié par",
    ),
    "storeVerificationRequest_welcomePrompt": MessageLookupByLibrary.simpleMessage(
      "Rejoignez notre plateforme en soumettant les documents de votre boutique pour un processus de vérification rapide.",
    ),
    "storeVerificationRequest_welcomeTitle":
        MessageLookupByLibrary.simpleMessage("Devenez un Partenaire Cuisinous"),
    "storeVerificationStart": MessageLookupByLibrary.simpleMessage(
      "Démarrer la Vérification",
    ),
    "storeVerificationStatus": MessageLookupByLibrary.simpleMessage(
      "Statut de vérification",
    ),
    "storeVerificationSubmittedDoc": MessageLookupByLibrary.simpleMessage(
      "Document soumis",
    ),
    "storeVerificationSuccess": MessageLookupByLibrary.simpleMessage(
      "Votre boutique a été vérifié et est maintenant actif !",
    ),
    "storeVerificationSwipeDown": MessageLookupByLibrary.simpleMessage(
      "Glissez vers le bas pour actualiser",
    ),
    "storeVerificationVerifiedBy": MessageLookupByLibrary.simpleMessage(
      "Vérifié par",
    ),
    "storeVerificationWelcomePrompt": MessageLookupByLibrary.simpleMessage(
      "Rejoignez notre plateforme en soumettant les documents de votre boutique pour un processus de vérification rapide.",
    ),
    "storeVerificationWelcomeTitle": MessageLookupByLibrary.simpleMessage(
      "Devenez un Partenaire Cuisinous",
    ),
    "stripeError": m11,
    "stripePayoutId": MessageLookupByLibrary.simpleMessage(
      "ID de paiement Stripe",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("Soumettre"),
    "supplementsMustHavePrice": MessageLookupByLibrary.simpleMessage(
      "Les suppléments doivent avoir un prix supérieur à 0",
    ),
    "tapToChangeLocation": MessageLookupByLibrary.simpleMessage(
      "Appuyez pour changer l\'emplacement",
    ),
    "tapToSelectLocation": MessageLookupByLibrary.simpleMessage(
      "Appuyez pour sélectionner un emplacement",
    ),
    "taxLabel": MessageLookupByLibrary.simpleMessage("Taxes"),
    "termsAndConditions": MessageLookupByLibrary.simpleMessage(
      "Conditions générales",
    ),
    "termsAndConditions_conclusion": MessageLookupByLibrary.simpleMessage(""),
    "termsAndConditions_intro": MessageLookupByLibrary.simpleMessage(
      "Dernière mise à jour : 01-01-2026\n\nLes présentes conditions d’utilisation (« Conditions ») régissent votre accès et votre utilisation de l’application mobile Cuisinous et des services connexes (l’« Application »), exploitée par 9534-9072 Québec Inc., faisant affaire sous le nom Cuisinous (« Cuisinous », « nous », « notre »).\n\nEn créant un compte ou en utilisant l’Application, vous confirmez avoir lu, compris et accepté les présentes Conditions. Si vous n’êtes pas d’accord, veuillez ne pas utiliser l’Application.",
    ),
    "termsAndConditions_section10Body": MessageLookupByLibrary.simpleMessage(
      "Tout le contenu de l’Application, l’image de marque, les logiciels et les marques de commerce appartiennent à Cuisinous ou à ses concédants de licence.\nAucun droit n’est accordé sauf ceux expressément prévus aux présentes.",
    ),
    "termsAndConditions_section10Title": MessageLookupByLibrary.simpleMessage(
      "10. PROPRIÉTÉ INTELLECTUELLE",
    ),
    "termsAndConditions_section11Body": MessageLookupByLibrary.simpleMessage(
      "Dans la mesure maximale permise par la loi, Cuisinous n’est pas responsable :\ndes maladies d’origine alimentaire, allergies, blessures ou insatisfactions ;\ndes actes ou manquements des Vendeurs ;\ndes dommages indirects ou consécutifs ;\ndes pertes de profits, de données ou de réputation.\n\nRien ne limite la responsabilité lorsque la loi l’interdit (par exemple, faute lourde).",
    ),
    "termsAndConditions_section11Title": MessageLookupByLibrary.simpleMessage(
      "11. LIMITATION DE RESPONSABILITÉ",
    ),
    "termsAndConditions_section12Body": MessageLookupByLibrary.simpleMessage(
      "Vous acceptez d’indemniser et de dégager Cuisinous de toute responsabilité à l’égard des réclamations découlant :\nde votre utilisation de l’Application ;\ndes aliments vendus ou consommés ;\nde la violation des présentes Conditions ou de la loi ;\ndu contenu que vous fournissez.",
    ),
    "termsAndConditions_section12Title": MessageLookupByLibrary.simpleMessage(
      "12. INDEMNISATION",
    ),
    "termsAndConditions_section13Body": MessageLookupByLibrary.simpleMessage(
      "Cuisinous n’est pas responsable des retards ou défaillances causés par des événements indépendants de sa volonté raisonnable, notamment les catastrophes naturelles, actions gouvernementales, pandémies ou défaillances techniques.",
    ),
    "termsAndConditions_section13Title": MessageLookupByLibrary.simpleMessage(
      "13. FORCE MAJEURE",
    ),
    "termsAndConditions_section14Body": MessageLookupByLibrary.simpleMessage(
      "Nous pouvons modifier ces Conditions à tout moment.\nLa poursuite de l’utilisation de l’Application constitue votre acceptation des Conditions modifiées.",
    ),
    "termsAndConditions_section14Title": MessageLookupByLibrary.simpleMessage(
      "14. MODIFICATIONS DES CONDITIONS",
    ),
    "termsAndConditions_section15Body": MessageLookupByLibrary.simpleMessage(
      "Les présentes Conditions sont régies par les lois de la province de Québec (Canada).",
    ),
    "termsAndConditions_section15Title": MessageLookupByLibrary.simpleMessage(
      "15. DROIT APPLICABLE",
    ),
    "termsAndConditions_section16Body": MessageLookupByLibrary.simpleMessage(
      "Questions ou avis juridiques :\nCourriel : info@cuisinous.ca",
    ),
    "termsAndConditions_section16Title": MessageLookupByLibrary.simpleMessage(
      "16. CONTACT",
    ),
    "termsAndConditions_section1Body": MessageLookupByLibrary.simpleMessage(
      "Cuisinous est une place de marché technologique qui met en relation des Vendeurs indépendants de nourriture avec des Clients.\n\nCuisinous :\nne prépare, cuisine, entrepose, inspecte, emballe, transporte ni livre de nourriture ;\nn’est pas un restaurant, un service de traiteur ou une entreprise alimentaire ;\nne supervise ni ne contrôle les Vendeurs ou leurs cuisines ;\nne garantit pas la qualité, la sécurité, la légalité ou la conformité des aliments ;\nn’est pas l’employeur, l’agent ou le partenaire d’un Vendeur.\n\nToutes les transactions alimentaires ont lieu exclusivement entre le Vendeur et le Client.",
    ),
    "termsAndConditions_section1Title": MessageLookupByLibrary.simpleMessage(
      "1. CE QU’EST CUISINOUS",
    ),
    "termsAndConditions_section2Body": MessageLookupByLibrary.simpleMessage(
      "Pour utiliser l’Application, vous devez :\navoir 18 ans ou plus ;\navoir la capacité légale de conclure un contrat ;\nfournir des informations exactes et à jour.\n\nVous êtes responsable :\nde la confidentialité de vos identifiants de connexion ;\nde toute activité effectuée à partir de votre compte.\n\nVous devez nous aviser immédiatement de tout accès non autorisé suspecté.",
    ),
    "termsAndConditions_section2Title": MessageLookupByLibrary.simpleMessage(
      "2. ADMISSIBILITÉ ET COMPTES",
    ),
    "termsAndConditions_section3Body": MessageLookupByLibrary.simpleMessage(
      "Les Vendeurs sont assujettis à une Convention de vendeur distincte.\nEn cas de conflit entre les présentes Conditions et la Convention de vendeur, la Convention de vendeur prévaut.",
    ),
    "termsAndConditions_section3Title": MessageLookupByLibrary.simpleMessage(
      "3. VENDEURS",
    ),
    "termsAndConditions_section4Body": MessageLookupByLibrary.simpleMessage(
      "Les Vendeurs sont seuls responsables de :\nrespecter toutes les lois et réglementations applicables ;\ndétenir des permis et certifications valides (y compris ceux du MAPAQ) ;\nla salubrité des aliments, l’hygiène, l’étiquetage, les allergènes et l’exactitude des ingrédients ;\nleurs produits alimentaires et méthodes de préparation.\n\nCuisinous ne vérifie ni n’inspecte la conformité des Vendeurs.\n\nLes Clients reconnaissent que :\nles aliments sont préparés par des Vendeurs indépendants ;\nla consommation d’aliments comporte des risques inhérents ;\nCuisinous n’offre aucune garantie quant à la sécurité ou à l’adéquation des aliments.",
    ),
    "termsAndConditions_section4Title": MessageLookupByLibrary.simpleMessage(
      "4. ALIMENTATION ET CONFORMITÉ LÉGALE",
    ),
    "termsAndConditions_section5Body": MessageLookupByLibrary.simpleMessage(
      "Les paiements sont traités par des fournisseurs tiers.\nCuisinous ne conserve pas les informations complètes de paiement.\n\nDes frais de plateforme ou des commissions peuvent s’appliquer et sont affichés avant la confirmation.\nLes frais de plateforme sont non remboursables, sauf lorsque la loi l’exige.\n\nLes Vendeurs sont responsables de toutes les taxes applicables (TPS, TVQ, impôt sur le revenu).",
    ),
    "termsAndConditions_section5Title": MessageLookupByLibrary.simpleMessage(
      "5. COMMANDES, PAIEMENTS ET FRAIS",
    ),
    "termsAndConditions_section6Body": MessageLookupByLibrary.simpleMessage(
      "Les politiques d’annulation et de remboursement sont établies par les Vendeurs et la loi applicable.\nCuisinous peut faciliter la communication, mais n’est pas tenue de résoudre les litiges ni d’émettre des remboursements.",
    ),
    "termsAndConditions_section6Title": MessageLookupByLibrary.simpleMessage(
      "6. ANNULATIONS ET REMBOURSEMENTS",
    ),
    "termsAndConditions_section7Body": MessageLookupByLibrary.simpleMessage(
      "Vous conservez la propriété de votre contenu (photos, menus, avis, textes).\n\nEn publiant du contenu, vous accordez à Cuisinous une licence mondiale, non exclusive et libre de redevances pour l’utiliser aux fins d’exploitation de l’Application, de promotion et d’analyses.\n\nVous confirmez détenir tous les droits nécessaires pour publier votre contenu.",
    ),
    "termsAndConditions_section7Title": MessageLookupByLibrary.simpleMessage(
      "7. CONTENU DES UTILISATEURS",
    ),
    "termsAndConditions_section8Body": MessageLookupByLibrary.simpleMessage(
      "Il est interdit de :\ncontourner l’Application pour effectuer des transactions hors plateforme ;\nfournir des informations fausses ou trompeuses ;\nenfreindre les lois ou les droits de tiers ;\npublier du contenu nuisible, illégal ou trompeur ;\nutiliser l’Application de manière abusive ou nuire à la réputation de Cuisinous.",
    ),
    "termsAndConditions_section8Title": MessageLookupByLibrary.simpleMessage(
      "8. UTILISATION INTERDITE",
    ),
    "termsAndConditions_section9Body": MessageLookupByLibrary.simpleMessage(
      "Cuisinous peut, lorsque la loi le permet :\nsuspendre ou résilier des comptes ;\nretirer des annonces ou du contenu ;\nrestreindre l’accès à l’Application.\n\nAucune indemnité n’est due, sauf lorsque la loi l’exige.",
    ),
    "termsAndConditions_section9Title": MessageLookupByLibrary.simpleMessage(
      "9. SUSPENSION OU RÉSILIATION DU COMPTE",
    ),
    "termsAndConditions_title": MessageLookupByLibrary.simpleMessage(
      "CUISINOUS – CONDITIONS D’UTILISATION (VERSION APPLICATION MOBILE)",
    ),
    "tipAmount": MessageLookupByLibrary.simpleMessage("Pourboire"),
    "tipSuccess": MessageLookupByLibrary.simpleMessage(
      "Pourboire ajouté avec succès ! Merci.",
    ),
    "tipValidationMessage": MessageLookupByLibrary.simpleMessage(
      "Le pourboire doit être 0,00 \$ ou entre 1,00 \$ et 100,00 \$.",
    ),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "transactionDetailsTitle": MessageLookupByLibrary.simpleMessage(
      "Détails de la transaction",
    ),
    "transactionId": MessageLookupByLibrary.simpleMessage("ID de transaction"),
    "transactionStatusCanceled": MessageLookupByLibrary.simpleMessage("Annulé"),
    "transactionStatusCompleted": MessageLookupByLibrary.simpleMessage(
      "Terminé",
    ),
    "transactionStatusFailed": MessageLookupByLibrary.simpleMessage("Échoué"),
    "transactionStatusPending": MessageLookupByLibrary.simpleMessage(
      "En attente",
    ),
    "transactionTypeAdjustment": MessageLookupByLibrary.simpleMessage(
      "Ajustement",
    ),
    "transactionTypeDeposit": MessageLookupByLibrary.simpleMessage("Dépôt"),
    "transactionTypeFee": MessageLookupByLibrary.simpleMessage("Frais"),
    "transactionTypeOrderIncome": MessageLookupByLibrary.simpleMessage(
      "Revenus de commande",
    ),
    "transactionTypeOther": MessageLookupByLibrary.simpleMessage("Autre"),
    "transactionTypePayment": MessageLookupByLibrary.simpleMessage("Paiement"),
    "transactionTypeRefund": MessageLookupByLibrary.simpleMessage(
      "Remboursement",
    ),
    "transactionTypeTipIncome": MessageLookupByLibrary.simpleMessage(
      "Revenus de pourboire",
    ),
    "transactionTypeWithdrawal": MessageLookupByLibrary.simpleMessage(
      "Retrait",
    ),
    "unexpectedError": m12,
    "update": MessageLookupByLibrary.simpleMessage("Mettre à jour"),
    "updateStore": MessageLookupByLibrary.simpleMessage(
      "Mettre à jour la boutique",
    ),
    "uploadImage": MessageLookupByLibrary.simpleMessage(
      "Télécharger une Image",
    ),
    "useCurrentLocation": MessageLookupByLibrary.simpleMessage(
      "Utiliser la position actuelle",
    ),
    "userInfo_bio": MessageLookupByLibrary.simpleMessage("Bio"),
    "userInfo_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
    "userInfo_editProfile": MessageLookupByLibrary.simpleMessage(
      "Modifier le profil",
    ),
    "userInfo_email": MessageLookupByLibrary.simpleMessage("Email"),
    "userInfo_errorUpdatingProfile": MessageLookupByLibrary.simpleMessage(
      "Erreur lors de la mise à jour du profil",
    ),
    "userInfo_firstName": MessageLookupByLibrary.simpleMessage("Prénom"),
    "userInfo_lastName": MessageLookupByLibrary.simpleMessage("Nom de famille"),
    "userInfo_phoneNumber": MessageLookupByLibrary.simpleMessage(
      "Numéro de téléphone",
    ),
    "userInfo_phoneNumberTooLong": MessageLookupByLibrary.simpleMessage(
      "Le numéro de téléphone doit contenir exactement 10 chiffres",
    ),
    "userInfo_profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "userInfo_profileUpdatedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Profil mis à jour avec succès",
    ),
    "userInfo_save": MessageLookupByLibrary.simpleMessage("Enregistrer"),
    "userInfo_username": MessageLookupByLibrary.simpleMessage(
      "Nom d\'utilisateur",
    ),
    "username": MessageLookupByLibrary.simpleMessage("Nom d\'utilisateur"),
    "validationInvalidPrice": MessageLookupByLibrary.simpleMessage(
      "Prix invalide",
    ),
    "validationRequired": MessageLookupByLibrary.simpleMessage("Champ requis"),
    "vendorAgreement_agreeAndContinue": MessageLookupByLibrary.simpleMessage(
      "Accepter et continuer",
    ),
    "vendorAgreement_intro": MessageLookupByLibrary.simpleMessage(
      "Le présent contrat de service (le « Contrat ») est conclu et prend effet à la date et à l’heure de son acceptation électronique par le Vendeur via la plateforme Cuisinous.\n\nENTRE :\n9534-9072 QUÉBEC INC., société légalement constituée en vertu de la Loi sur les sociétés par actions, ayant son siège au 401-5131, place Leblanc, en la ville de Sainte-Catherine, province de Québec, J5C 1G6;\n(Ci-après dénommée « Cuisinous »)\n\nET :\nToute personne physique ou morale ayant créé un compte vendeur sur la plateforme Cuisinous et ayant accepté le présent Contrat par voie électronique, dont l’identité, les coordonnées et les informations pertinentes sont celles fournies lors de la création du compte vendeur;\n(Ci-après dénommé(e) le « Vendeur »)\n\n(Cuisinous et le Vendeur étant ci-après collectivement dénommé(e)s les « Parties »)",
    ),
    "vendorAgreement_preambleBody": MessageLookupByLibrary.simpleMessage(
      "A. En acceptant électroniquement le présent Contrat, le Vendeur reconnaît avoir lu attentivement, compris et accepté sans réserve l’ensemble de ses modalités, ainsi que tout document, politique ou condition y afférent, le cas échéant.\n\nB. Le Vendeur reconnaît que Cuisinous agit uniquement à titre de plateforme technologique de mise en relation, qu’elle n’exerce aucune activité de préparation, de fabrication, de transformation, de conservation, d’inspection ou de livraison d’aliments, et qu’elle n’assume aucune responsabilité relativement aux produits alimentaires offerts par le Vendeur.\n\nC. Le Vendeur reconnaît également agir de façon indépendante, à titre de travailleur autonome, et assumer l’entière responsabilité de ses activités, produits, opérations et obligations légales.\n\nD. L’acceptation électronique du présent Contrat constitue une manifestation de consentement libre et éclairée, ayant la même valeur juridique qu’une signature manuscrite, conformément aux lois applicables au Québec.",
    ),
    "vendorAgreement_preambleTitle": MessageLookupByLibrary.simpleMessage(
      "PRÉAMBULE",
    ),
    "vendorAgreement_section10Body": MessageLookupByLibrary.simpleMessage(
      "10.1. Aux fins du présent Contrat, constituent des « Informations confidentielles » toutes informations, données ou documents, de quelque nature que ce soit, communiqués ou rendus accessibles au Vendeur dans le cadre de l’utilisation de la plateforme, incluant notamment, sans s’y limiter : les renseignements relatifs aux clients, les données transactionnelles, les prix, les modalités commerciales, les fonctionnalités de la plateforme, les procédés, technologies, logiciels, algorithmes, politiques internes et toute information désignée comme confidentielle ou qui, par sa nature, devrait raisonnablement être considérée comme telle.\n\n10.2. Le Vendeur s’engage notamment à :\n\na) préserver la confidentialité des Informations confidentielles;\nb) ne les utiliser qu’aux seules fins de l’exécution du présent Contrat;\nc) ne pas les divulguer à quelque tiers que ce soit sans l’autorisation écrite préalable de Cuisinous;\nd) mettre en place des mesures raisonnables pour empêcher tout accès, utilisation ou divulgation non autorisés.\n\n10.3. Le Vendeur reconnaît que, dans le cadre de ses activités sur la plateforme, il peut avoir accès à des renseignements personnels de clients. Le Vendeur s’engage notamment à :\n\na) traiter ces renseignements personnels conformément aux lois applicables en matière de protection des renseignements personnels, incluant la Loi sur la protection des renseignements personnels dans le secteur privé (RLRQ, c. P-39.1);\nb) utiliser ces renseignements uniquement pour l’exécution des commandes effectuées par l’intermédiaire de la plateforme;\nc) ne pas conserver, reproduire, utiliser ou communiquer ces renseignements à d’autres fins, incluant toute sollicitation directe ou transaction hors plateforme;\nd) aviser sans délai Cuisinous de tout incident de confidentialité, accès non autorisé ou atteinte à la protection des renseignements personnels.\n\n10.4. Tous les renseignements, données et informations relatifs aux clients, aux transactions et à l’utilisation de la plateforme demeurent la propriété exclusive de Cuisinous, sous réserve des droits des personnes concernées prévus par la loi.\n\n10.5. Les obligations prévues au présent article demeurent en vigueur pendant toute la durée du Contrat et survivent à sa résiliation ou à son expiration, pour une période indéterminée ou aussi longtemps que les informations conservent leur caractère confidentiel.\n\n10.6. Le Vendeur reconnaît que toute violation du présent article peut causer un préjudice irréparable à Cuisinous, lequel pourra justifier l’octroi de mesures injonctives, en plus de tout autre recours prévu par la loi ou le présent Contrat.",
    ),
    "vendorAgreement_section10Title": MessageLookupByLibrary.simpleMessage(
      "10. CONFIDENTIALITY ET PROTECTION DES DONNÉES",
    ),
    "vendorAgreement_section11Body": MessageLookupByLibrary.simpleMessage(
      "11.1. Le présent Contrat est régi et interprété conformément aux lois en vigueur dans la province de Québec, sans égard à ses règles de conflit de lois. Les tribunaux du district judiciaire de Québec auront compétence exclusive pour entendre tout litige, recours ou réclamation découlant du présent Contrat ou s’y rapportant.\n\n11.2. Si l’une quelconque des dispositions du présent Contrat est déclarée invalide, illégale ou inapplicable, en tout ou en partie, cette disposition sera réputée dissociable sans affecter la validité, la légalité ou l’applicabilité des autres dispositions, lesquelles demeureront pleinement en vigueur.\n\n11.3. Aucune des Parties ne pourra être tenue responsable d’un manquement ou d’un retard dans l’exécution de ses obligations résultant d’un événement hors de son contrôle raisonnable, incluant notamment, sans limitation; catastrophe naturelle, incendie, inondation, pandémie, acte gouvernemental, grève, panne de réseau, interruption de services technologiques ou défaillance de systèmes informatiques.\n\n11.4. Cuisinous se réserve le droit de modifier, en tout temps et à sa seule discrétion, le présent Contrat, les politiques, règles, modalités ou frais applicables à la plateforme. Toute modification prendra effet dès sa publication ou sa notification au Vendeur par tout moyen raisonnable, incluant par l’intermédiaire de la plateforme. La poursuite de l’utilisation de la plateforme par le Vendeur après l’entrée en vigueur des modifications constitue une acceptation expresse de celles-ci.\n\n11.5. Le fait pour Cuisinous de ne pas exercer ou de retarder l’exercice d’un droit, recours ou privilège prévu au présent Contrat ne constitue en aucun cas une renonciation à ce droit, recours ou privilège.\n\n11.6. Le Vendeur ne peut céder, transférer ou autrement aliéner tout ou partie de ses droits ou obligations en vertu du présent Contrat sans le consentement écrit préalable de Cuisinous. Cuisinous peut céder le présent Contrat sans restriction, notamment dans le cadre d’une réorganisation, d’une fusion, d’une vente d’actifs ou d’un changement de contrôle.\n\n11.7. Le présent Contrat constitue l’intégralité de l’entente intervenue entre les Parties relativement à son objet et remplace toute entente, discussion ou communication antérieure, écrite ou verbale.",
    ),
    "vendorAgreement_section11Title": MessageLookupByLibrary.simpleMessage(
      "11. DISPOSITIONS GÉNÉRALES",
    ),
    "vendorAgreement_section12Body": MessageLookupByLibrary.simpleMessage(
      "12.1. L’acceptation du présent Contrat par le Vendeur, notamment par le biais du bouton « Accepter et continuer », par toute autre action électronique équivalente ou par l’utilisation continue de la plateforme, constitue une acceptation expresse, une signature électronique valide et juridiquement contraignante, ayant la même valeur légale qu’une signature manuscrite, conformément aux lois applicables au Québec, incluant la Loi concernant le cadre juridique des technologies de l’information (RLRQ, ch. C-1.1).\n\n12.2. Le Vendeur reconnaît et déclare que son consentement au présent Contrat est donné de manière libre, éclairée et sans contrainte, après avoir eu l’opportunité de lire attentivement l’ensemble des modalités, politiques et documents connexes accessibles sur la plateforme.\n",
    ),
    "vendorAgreement_section12Title": MessageLookupByLibrary.simpleMessage(
      "12. ACCEPTATION ET CONSENTEMENT ÉLECTRONIQUE",
    ),
    "vendorAgreement_section1Body": MessageLookupByLibrary.simpleMessage(
      "1.1. Cuisinous exploite une plateforme technologique qui permet la mise en relation entre des Vendeurs de produits alimentaires et des Clients.\n\n1.2. Cuisinous n’exerce aucune activité de préparation, de fabrication, de transformation, de conservation, d’inspection ou de livraison d’aliments, et n’est en aucun cas restaurateur, employeur, mandataire ou représentant du Vendeur.\n\n1.3. Le présent Contrat définit les droits et obligations du Vendeur et de Cuisinous pour l’utilisation de la plateforme.",
    ),
    "vendorAgreement_section1Title": MessageLookupByLibrary.simpleMessage(
      "1. OBJET",
    ),
    "vendorAgreement_section2Body": MessageLookupByLibrary.simpleMessage(
      "2.1. Le Vendeur agit à titre de travailleur autonome et exploite son activité de manière indépendante. Rien dans le présent Contrat ne doit être interprété comme créant un lien d’emploi, de mandat, de partenariat, de coentreprise ou de représentation entre le Vendeur et Cuisinous.\n\n2.2. Le Vendeur assume tous les risques et responsabilités liés à son activité, y compris les obligations fiscales, sociales et réglementaires applicables.",
    ),
    "vendorAgreement_section2Title": MessageLookupByLibrary.simpleMessage(
      "2. STATUT DE VENDEUR INDÉPENDANT",
    ),
    "vendorAgreement_section3Body": MessageLookupByLibrary.simpleMessage(
      "3.1. Le Vendeur est exclusivement et entièrement responsable de ce qui suit, sans limitation :\n\na) la sécurité alimentaire, l’hygiène et la sécurité des aliments;\nb) la qualité, l’étiquetage, la composition et la divulgation des allergènes;\nc) ses méthodes de préparation, de stockage et de distribution;\nd) l’obtention et le maintien des permis, licences et certifications requis, incluant ceux délivrés par le ministère de l\'Agriculture, des Pêcheries et de l\'Alimentation du Québec (le « MAPAQ »);\ne) le respect de toutes les lois et réglementations applicables;\nf) la véracité et l’exactitude des informations fournies à Cuisinous;\ng) le respect des droits de propriété intellectuelle et l’interdiction de vendre des produits contrefaits, illégaux ou violant les droits de tiers.\n\n3.2. Cuisinous ne vérifie pas, n’inspecte pas et ne certifie pas les activités, la cuisine, les produits, les opérations, les permis ou l’assurance du Vendeur.\n\n3.3. Le Vendeur s’engage à informer immédiatement Cuisinous de toute modification, suspension ou révocation de ses permis, certifications ou de toute information susceptible d’avoir un impact sur la sécurité alimentaire, la conformité légale ou l’exécution du présent Contrat.",
    ),
    "vendorAgreement_section3Title": MessageLookupByLibrary.simpleMessage(
      "3. OBLIGATIONS DU VENDEUR",
    ),
    "vendorAgreement_section4Body": MessageLookupByLibrary.simpleMessage(
      "4.1. Le Vendeur déclare et garantit notamment qu’il :\n\na) détient tous les permis et certifications requis pour ses activités et qu’ils sont valides et à jour;\nb) respecte toutes les lois, règlements et normes applicables;\nc) assume l’entière responsabilité de ses produits et opérations;\nd) accepte d’indemniser et dégager de toute responsabilité Cuisinous, ses administrateurs, dirigeants et partenaires pour toute réclamation, amende, dommage ou action découlant de la non-conformité du Vendeur;\ne) reconnaît que fournir des informations fausses, trompeuses ou périmées constitue une violation substantielle du Contrat et peut entraîner la suspension ou résiliation immédiate du compte;\nf) détient et maintient, à ses frais, pendant toute la durée du Contrat, une assurance responsabilité civile adéquate couvrant ses activités, ses produits et tout dommage corporel, matériel ou financier pouvant en découler.\n\n4.2. Le Vendeur reconnaît et accepte expressément que Cuisinous ne requiert pas, ne vérifie pas, ne valide pas et ne conserve aucune preuve d’assurance du Vendeur, et que l’absence, l’insuffisance, l’invalidité ou la non-conformité de l’assurance du Vendeur ne saurait en aucun cas engager la responsabilité de Cuisinous. À cet effet, le Vendeur dégage expressément Cuisinous de toute responsabilité, réclamation ou obligation découlant du défaut du Vendeur de détenir ou de maintenir une assurance adéquate.\n\n4.3. Le Vendeur reconnait être entièrement responsable de la sécurité alimentaire, de l’hygiène, de l’exactitude des ingrédients, de la divulgation des allergènes, des risques de contamination croisée et de toute conséquence découlant de la consommation des aliments qu’il vend via Cuisinous.",
    ),
    "vendorAgreement_section4Title": MessageLookupByLibrary.simpleMessage(
      "4. ATTESTATIONS ET GARANTIES DU VENDEUR",
    ),
    "vendorAgreement_section5Body": MessageLookupByLibrary.simpleMessage(
      "5.1. Le Vendeur s’engage à payer tous les frais applicables liés à l’utilisation de la plateforme.\n\n5.2. Le Vendeur s’interdit de contourner la plateforme pour effectuer des transactions directes avec des Clients obtenus par l’intermédiaire de Cuisinous. Toute violation autorise Cuisinous à suspendre ou résilier immédiatement le compte du Vendeur et à réclamer des recours.",
    ),
    "vendorAgreement_section5Title": MessageLookupByLibrary.simpleMessage(
      "5. FRAIS ET INTERDICTION DE CONTOURNEMENT",
    ),
    "vendorAgreement_section6Body": MessageLookupByLibrary.simpleMessage(
      "6.1. Tous les paiements effectués par les Clients ainsi que les versements dus au Vendeur sont traités exclusivement par l’entremise d’un prestataire de services de paiement tiers indépendant, notamment Stripe ou tout autre prestataire équivalent.\n\n6.2. Le Vendeur reconnaît et accepte que Cuisinous n’est pas une institution financière, n’agit pas à titre d’intermédiaire de paiement, d’agent fiduciaire ou de dépositaire de fonds, et ne conserve, ne traite ni ne stocke aucune information bancaire, financière ou de carte de crédit des Clients ou du Vendeur.\n\n6.3. Le Vendeur reconnaît que l’exécution des paiements, leur traitement, leur autorisation, leur compensation et leur versement relèvent exclusivement du prestataire de paiement tiers, conformément aux conditions contractuelles liant le Vendeur audit prestataire.\n\n6.4. Le Vendeur comprend que Cuisinous ne peut en aucun cas être tenu responsable de toute erreur, omission, retard, interruption, défaillance, refus de paiement, retenue de fonds, suspension de compte ou incident de sécurité imputable au prestataire de paiement tiers ou à ses systèmes.",
    ),
    "vendorAgreement_section6Title": MessageLookupByLibrary.simpleMessage(
      "6. MODALITÉS DE PAIEMENT",
    ),
    "vendorAgreement_section7Body": MessageLookupByLibrary.simpleMessage(
      "7.1. Le Vendeur reconnaît et accepte que Cuisinous agit exclusivement à titre de fournisseur de plateforme technologique et d’intermédiaire de mise en relation, et qu’elle n’intervient d’aucune manière dans la préparation, la fabrication, la transformation, la conservation, l’emballage, l’étiquetage, la manipulation, la livraison ou la vente des aliments offerts par le Vendeur.\n\n7.2. Dans toute la mesure permise par la loi, Cuisinous, ses administrateurs, dirigeants, employés, actionnaires et partenaires ne pourront en aucun cas être tenus responsables de tout dommage, préjudice, perte ou réclamation, qu’ils soient directs ou indirects, accessoires, consécutifs, spéciaux ou punitifs, incluant notamment :\n\na) toute maladie, intoxication alimentaire, réaction allergique, blessure corporelle ou décès;\nb) toute perte de revenus, perte d’affaires ou atteinte à la réputation;\nc) toute réclamation, plainte, sanction, amende ou poursuite intentée par un client, un tiers ou une autorité réglementaire;\n\nrésultant directement ou indirectement des aliments, ingrédients, informations, omissions ou activités du Vendeur.\n\n7.3. Cuisinous ne donne aucune garantie, expresse ou implicite, quant à la qualité, la salubrité, la sécurité, la conformité légale, la conformité réglementaire ou l’aptitude à la consommation des produits offerts par le Vendeur, lesquels relèvent de la responsabilité exclusive du Vendeur.\n\n7.4. Le Vendeur renonce expressément à tout recours, réclamation ou poursuite contre Cuisinous relativement à tout dommage découlant des aliments fournis par le Vendeur ou de l’utilisation de la plateforme, sauf en cas de faute lourde ou intentionnelle de Cuisinous.",
    ),
    "vendorAgreement_section7Title": MessageLookupByLibrary.simpleMessage(
      "7. LIMITATION DE RESPONSABILITÉ",
    ),
    "vendorAgreement_section8Body": MessageLookupByLibrary.simpleMessage(
      "8.1. Le Vendeur s’engage à indemniser, défendre et dégager de toute responsabilité Cuisinous, ainsi que ses administrateurs, dirigeants, employés, actionnaires, représentants et partenaires, à l’égard de toute réclamation, demande, plainte, poursuite, action, enquête, sanction, amende, pénalité, dommage, perte, responsabilité, coût ou dépense (incluant notamment les frais judiciaires, honoraires d’avocats et frais d’experts, sur une base avocat-client) découlant directement ou indirectement :\n\na) des aliments, ingrédients, produits ou services offerts, préparés, vendus ou fournis par le Vendeur par l’intermédiaire de la plateforme;\nb) de toute maladie, intoxication alimentaire, réaction allergique, blessure corporelle, décès ou atteinte à la santé;\nc) du non-respect par le Vendeur de toute loi, réglementation, norme ou exigence applicable, incluant celles du MAPAQ;\nd) de toute information fausse, trompeuse, incomplète ou périmée fournie par le Vendeur;\ne) de toute violation du présent Contrat, des politiques ou documents connexes;\nf) de toute atteinte réelle ou alléguée aux droits d’un client, d’un tiers ou d’une autorité gouvernementale.\n\n8.2. À la demande de Cuisinous, le Vendeur assumera la défense complète et diligente de toute réclamation visée au présent article, à ses frais, avec un procureur jugé raisonnablement acceptable par Cuisinous. Cuisinous conserve en tout temps le droit de participer à cette défense à ses propres frais, sans renonciation à ses droits.\n\n8.3. Les obligations d’indemnisation prévues au présent article survivent à la résiliation ou à l’expiration du présent Contrat, pour quelque cause que ce soit.",
    ),
    "vendorAgreement_section8Title": MessageLookupByLibrary.simpleMessage(
      "8. INDEMNISATION",
    ),
    "vendorAgreement_section9Body": MessageLookupByLibrary.simpleMessage(
      "9.1. Cuisinous se réserve le droit, à sa seule et entière discrétion, de suspendre, limiter, retirer des produits, désactiver l’accès à la plateforme ou résilier le compte du Vendeur, en tout temps, avec ou sans préavis, notamment dans les cas suivants :\n\na) toute violation du présent Contrat, des politiques, lignes directrices ou documents connexes;\nb) la fourniture d’informations fausses, trompeuses, incomplètes, périmées ou inexactes;\nc) le non-respect de toute loi, réglementation ou norme applicable, incluant celles relatives à la sécurité alimentaire et au MAPAQ;\nd) tout risque réel ou potentiel pour la santé, la sécurité ou le bien-être des clients ou du public;\ne) toute plainte, enquête, avis, mesure administrative ou procédure intentée ou envisagée par une autorité gouvernementale;\nf) tout comportement, contenu ou activité susceptible de porter atteinte à la réputation, à l’image ou aux intérêts commerciaux de Cuisinous;\ng) toute suspicion raisonnable de fraude, de manquement grave ou de conduite fautive.\n\n9.2. La suspension ou la résiliation du compte du Vendeur ne donne droit à aucune indemnité, compensation ou remboursement, quels qu’en soient le motif ou la durée.\n\n9.3. La résiliation ou l’expiration du présent Contrat, pour quelque cause que ce soit, n’affecte pas les obligations du Vendeur qui, par leur nature, doivent survivre, incluant notamment les obligations relatives aux paiements, à la confidentialité, à l’indemnisation, à la responsabilité, aux limitations de responsabilité et aux lois applicables.",
    ),
    "vendorAgreement_section9Title": MessageLookupByLibrary.simpleMessage(
      "9. SUSPENSION ET RÉSILIATION",
    ),
    "vendorAgreement_title": MessageLookupByLibrary.simpleMessage(
      "CONTRAT DE SERVICE V.1",
    ),
    "verifyYourNumberInProfile": MessageLookupByLibrary.simpleMessage(
      "Vérifiez votre numéro dans votre profil",
    ),
    "withdrawAmount": MessageLookupByLibrary.simpleMessage(
      "Montant du retrait",
    ),
    "withdrawAmountExceeded": MessageLookupByLibrary.simpleMessage(
      "Le montant ne peut pas dépasser votre solde actuel",
    ),
    "withdrawButton": MessageLookupByLibrary.simpleMessage("Retirer"),
    "withdrawConfirm": MessageLookupByLibrary.simpleMessage(
      "Confirmer le retrait",
    ),
    "withdrawCurrentBalance": MessageLookupByLibrary.simpleMessage(
      "Solde actuel",
    ),
    "withdrawCustomAmount": MessageLookupByLibrary.simpleMessage(
      "Montant personnalisé",
    ),
    "withdrawError": MessageLookupByLibrary.simpleMessage(
      "Échec du retrait. Veuillez réessayer.",
    ),
    "withdrawFee": MessageLookupByLibrary.simpleMessage("Frais de retrait"),
    "withdrawFeeNotice": MessageLookupByLibrary.simpleMessage(
      "Ce retrait instantané vous coûtera 4\$. Veuillez confirmer avant de continuer.",
    ),
    "withdrawInvalidAmount": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer un montant valide",
    ),
    "withdrawProcessing": MessageLookupByLibrary.simpleMessage(
      "Traitement du retrait...",
    ),
    "withdrawQuickAmounts": MessageLookupByLibrary.simpleMessage(
      "Montants rapides",
    ),
    "withdrawSuccess": MessageLookupByLibrary.simpleMessage("Retrait réussi !"),
    "withdrawTitle": MessageLookupByLibrary.simpleMessage("Retirer des fonds"),
    "withdrawTotal": MessageLookupByLibrary.simpleMessage("Montant total"),
    "writeReview_clickToUpload": MessageLookupByLibrary.simpleMessage(
      "Cliquez ici pour télécharger",
    ),
    "writeReview_commentHint": MessageLookupByLibrary.simpleMessage(
      "Partagez votre expérience avec ce plat...",
    ),
    "writeReview_commentLabel": MessageLookupByLibrary.simpleMessage(
      "Commentaire (Facultatif)",
    ),
    "writeReview_rateDish": MessageLookupByLibrary.simpleMessage(
      "Évaluer le plat",
    ),
    "writeReview_submit": MessageLookupByLibrary.simpleMessage(
      "Soumettre l\'avis",
    ),
  };
}

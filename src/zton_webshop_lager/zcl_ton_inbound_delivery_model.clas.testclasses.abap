*"* use this source file for your ABAP unit test classes
CLASS ltc_idm_warehouse_employee DEFINITION FOR TESTING
RISK LEVEL HARMLESS
DURATION SHORT.


  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: m_cut                       TYPE REF TO zcl_ton_inbound_delivery_model,
          lt_order_data               TYPE TABLE OF zton_db_wh_ma,
          l_exception_occured         TYPE abap_bool,
          inbound_delivery_cntrl TYPE REF TO zcl_ton_inbound_delivery_cntrl,
          webshop_log                 TYPE REF TO zcl_ton_webshop_log.
    CONSTANTS: lc_logobject          TYPE bal_s_log-object VALUE 'ZWEB',
               lc_subobjec           TYPE bal_s_log-subobject VALUE 'ZWEB',
               lc_warehouse_number_1 TYPE zton_lgnum_de VALUE 'WU01',
               lc_warehouse_number_2 TYPE zton_lgnum_de VALUE 'WU02',
               lc_user_number_1      TYPE char10 VALUE '01',
               lc_user_number_2      TYPE char10 VALUE '02',
               lc_password_1         TYPE string VALUE 'test',
               lc_password_2         TYPE string VALUE 'test2'.

    CLASS-DATA: m_environment TYPE REF TO if_osql_test_environment.
    CLASS-METHODS class_setup.
    METHODS setup.
    METHODS check_wrong_password FOR TESTING.
    METHODS user_dont_exist FOR TESTING.
    METHODS user_and_password_true FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltc_idm_warehouse_employee IMPLEMENTATION.

  METHOD class_setup.

    m_environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'zton_db_lager_ma' ) ) ).

  ENDMETHOD.

  METHOD setup.
    "given
    lt_order_data = VALUE #( ( warehouse_number = lc_warehouse_number_1 userid = lc_user_number_1 password = lc_password_1 )
                             ( warehouse_number = lc_warehouse_number_2 userid = lc_user_number_2 password = lc_password_2 ) ).

    m_environment->clear_doubles( ).
    webshop_log = NEW zcl_ton_webshop_log( iv_object = lc_logobject iv_suobj = lc_subobjec ).
    inbound_delivery_cntrl = NEW zcl_ton_inbound_delivery_cntrl( io_log = webshop_log ).
    m_cut = NEW zcl_ton_inbound_delivery_model( io_cntrl = inbound_delivery_cntrl io_log = webshop_log ).

    m_environment->insert_test_data( EXPORTING i_data = lt_order_data ).

    l_exception_occured = abap_false.

  ENDMETHOD.


  METHOD check_wrong_password.
    "given
    DATA: lv_password TYPE string VALUE 'falsches_passwort'.
    "when
    TRY.
        m_cut->check_user_and_password( iv_password = lv_password iv_userid = lc_user_number_1 iv_warehousenum = lc_warehouse_number_1 ).
      CATCH zcx_ton_webshop_exception_new.
        l_exception_occured = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( act = l_exception_occured
                                      msg = 'Die Methode check_user_and_password funktioniert noch nicht richtig. Das Passwort ist falsch, deswegen sollte eine Exception geworfen werden.').

  ENDMETHOD.

  "toDo:
  METHOD user_dont_exist.
    "given
    DATA: lv_user TYPE zton_user_id VALUE 'Wrong_User'.
    "when
    TRY.
        m_cut->check_user_and_password( iv_warehousenum = lc_warehouse_number_1
                                        iv_userid       = lv_user
                                        iv_password     = lc_password_1 ).

      CATCH zcx_ton_webshop_exception_new.
        l_exception_occured = abap_true.
    ENDTRY.
    "then

    cl_abap_unit_assert=>assert_true( act = l_exception_occured
                                      msg = 'Der User ist nicht vorhanden es sollte eine Exception geworfen werden.').

  ENDMETHOD.

  METHOD user_and_password_true.

    "when
    TRY.
        m_cut->check_user_and_password( iv_warehousenum = lc_warehouse_number_1
                                        iv_userid       = lc_user_number_1
                                        iv_password     = lc_password_1 ).
      CATCH zcx_ton_webshop_exception_new.
        l_exception_occured = abap_true.
    ENDTRY.
    "then
    cl_abap_unit_assert=>assert_true( act = l_exception_occured
                                      msg = 'Der User ist nicht vorhanden es sollte eine Exception geworfen werden.').

  ENDMETHOD.

ENDCLASS.


CLASS ltc_idm_warehouse DEFINITION DEFERRED.
CLASS zcl_ton_inbound_delivery_model DEFINITION LOCAL FRIENDS ltc_idm_warehouse.
CLASS ltc_idm_warehouse DEFINITION FOR TESTING RISK LEVEL HARMLESS.
  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: m_cut                       TYPE REF TO zcl_ton_inbound_delivery_model,
          lt_order_data               TYPE TABLE OF zton_db_lager,
          l_exception_occured         TYPE abap_bool,
          inbound_delivery_cntrl TYPE REF TO zcl_ton_inbound_delivery_cntrl,
          webshop_log                 TYPE REF TO zcl_ton_webshop_log.
    CONSTANTS: lc_logobject          TYPE bal_s_log-object VALUE 'ZSBT',
               lc_subobjec           TYPE bal_s_log-subobject VALUE 'ZUBT',
               lc_storage_area_1     TYPE zton_lgber_de VALUE 'bereich1',
               lc_storage_area_2     TYPE zton_lgber_de VALUE 'bereich2',
               lc_storage_place_1    TYPE zton_lgplatzton_de VALUE 'platz1',
               lc_storage_place_2    TYPE zton_lgplatzton_de VALUE 'platz2',
               lc_warehouse_number_1 TYPE zton_lgnum_de VALUE 'wu01',
               lc_warehouse_number_2 TYPE zton_lgnum_de VALUE 'wu02',
               lc_product_1          TYPE zton_artikelnummer_de  VALUE '1234',
               lc_product_2          TYPE zton_artikelnummer_de  VALUE '12345',
               lc_stock_1            TYPE zton_zton_menge_de VALUE '10',
               lc_stock_2            TYPE zton_zton_menge_de VALUE '20',
               lc_unit               TYPE zton_meins_de VALUE 'ST'.


    CLASS-DATA:           m_environment TYPE REF TO if_osql_test_environment.
    CLASS-METHODS class_setup.
    METHODS setup.
    METHODS update_product_not_exist FOR TESTING.
    METHODS update_product_exist FOR TESTING.
ENDCLASS.

CLASS ltc_idm_warehouse IMPLEMENTATION.

  METHOD class_setup.
    m_environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'zton_db_wh' ) ) ).

  ENDMETHOD.

  METHOD setup.
    "given
    lt_order_data = VALUE #( ( lagerbereich = lc_storage_area_1 lagerplatz = lc_storage_place_1 lagernummer = lc_warehouse_number_1  produkt = lc_product_1 bestand = lc_stock_1 mengeneinheit = lc_unit )
                           ).

    m_environment->clear_doubles( ).
    webshop_log = NEW zcl_ton_webshop_log( iv_object = lc_logobject iv_suobj = lc_subobjec ).
    inbound_delivery_cntrl = NEW zcl_ton_inbound_delivery_cntrl( io_log = webshop_log ).
    m_cut = NEW zcl_ton_inbound_delivery_model( io_cntrl = inbound_delivery_cntrl io_log = webshop_log ).

    m_cut->mv_storage_area = lc_storage_area_2.
    m_cut->mv_storage_place = lc_storage_place_2.
    m_cut->mv_warehousenumber = lc_warehouse_number_2.
    m_cut->mv_article_number = lc_product_2.
    m_cut->mv_quantity = lc_stock_2.
    m_cut->mv_meins = lc_unit.

    m_environment->insert_test_data( EXPORTING i_data = lt_order_data ).

    l_exception_occured = abap_false.

  ENDMETHOD.

  METHOD update_product_not_exist.
    TRY.
        "when
        m_cut->update_product_on_warehouse(  ).

      CATCH zcx_ton_sbt_web_shop_exception.
        l_exception_occured = abap_true.
    ENDTRY.
    "then
    cl_abap_unit_assert=>assert_true( act = l_exception_occured
                                      msg = 'Die Methode update_product_on_warehouse wirft keine Exception falls kein passendes Produkt zum updaten in der Datenbank existiert.').

  ENDMETHOD.

  METHOD update_product_exist.
    TRY.
        m_cut->mv_storage_area = lc_storage_area_1.
        m_cut->mv_storage_place = lc_storage_place_1.
        "when
        m_cut->update_product_on_warehouse(  ).

        SELECT SINGLE produkt
         FROM zton_db_lager
         INTO @DATA(lv_product)
         WHERE produkt = @lc_product_2.


        "then
        cl_abap_unit_assert=>assert_equals( EXPORTING act = lv_product
                                                      exp =  lc_product_2 ).
      CATCH zcx_ton_sbt_web_shop_exception.

    ENDTRY.
  ENDMETHOD.

  "toDo:
  "Prüfen ob Prudukt geupdatet wird, wenn nicht alle Daten vorhanden sind

ENDCLASS.






CLASS ltc_idm_article DEFINITION DEFERRED.
CLASS zcl_ton_inbound_delivery_model DEFINITION LOCAL FRIENDS ltc_idm_article.
CLASS ltc_idm_article DEFINITION FOR TESTING RISK LEVEL HARMLESS.
  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: m_cut                       TYPE REF TO zcl_ton_inbound_delivery_model,
          lt_article_data             TYPE TABLE OF zton_artikel,
          l_exception_occured         TYPE abap_bool,
          inbound_delivery_cntrl TYPE REF TO zcl_ton_inbound_delivery_cntrl,
          webshop_log                 TYPE REF TO zcl_ton_webshop_log.


    CLASS-DATA: m_environment TYPE REF TO if_osql_test_environment.
    CLASS-METHODS class_setup.
    METHODS setup.
    METHODS check_article_exist_true FOR TESTING.


    CONSTANTS: lc_logobject        TYPE bal_s_log-object VALUE 'ZSBT',
               lc_subobjec         TYPE bal_s_log-subobject VALUE 'ZUBT',
               lc_customer         TYPE zton_customernumber_de VALUE '1',
               lc_article_number_1 TYPE zton_artikelnummer_de VALUE '1',
               lc_article_number_2 TYPE zton_artikelnummer_de VALUE '2',
               lc_article_number_3 TYPE zton_artikelnummer_de VALUE '3',
               lc_description_1    TYPE zton_beschreibung_de VALUE 'Bildschirm',
               lc_description_2    TYPE zton_beschreibung_de VALUE 'Tastatur',
               lc_currency         TYPE zton_waehrung_de VALUE 'Euro',
               mc_text_expception  TYPE string VALUE 'Es wurde eine Exception in der aufgerufnen Methode ausgelöst'.



ENDCLASS.

CLASS ltc_idm_article IMPLEMENTATION.

  METHOD setup.
    "given
    lt_article_data = VALUE #( ( artikelnummer = lc_article_number_1 bezeichnung = lc_description_1 preis = 200 waehrung = lc_currency )
                               ( artikelnummer = lc_article_number_2 bezeichnung = lc_description_2 preis = 70 waehrung = lc_currency ) ).


    m_environment->clear_doubles( ).
    webshop_log = NEW zcl_ton_webshop_log( iv_object = lc_logobject iv_suobj = lc_subobjec ).
    inbound_delivery_cntrl = NEW zcl_ton_inbound_delivery_cntrl( io_log = webshop_log ).
    m_cut = NEW zcl_ton_inbound_delivery_model( io_cntrl = inbound_delivery_cntrl io_log = webshop_log ).

    m_environment->insert_test_data( EXPORTING i_data = lt_article_data ).
  ENDMETHOD.

  METHOD class_setup.
    m_environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'zton_artikel' ) ) ).
  ENDMETHOD.

  METHOD check_article_exist_true.
    DATA: lv_exist TYPE abap_bool.
    "when
    TRY.
        lv_exist = m_cut->check_article_exist( iv_article_number = lc_article_number_1 ).
        "then
      CATCH zcx_ton_webshop_exception_new.
        cl_abap_unit_assert=>fail( msg = mc_text_expception ).
    ENDTRY.
    cl_abap_unit_assert=>assert_true( act = lv_exist
                                      msg = 'Die Methode check_article_exist_true gibt abap_false zurück, obwohl der Artikel existiert.').

  ENDMETHOD.

  "Prüfen was passiert wenn kein Artikel vorhanden ist->abap_false
  "search_free_warehouse_position -> schauen ob im richtig fall eine neue Position gesucht wird, bzw. die alte vorgeschlagen wird und exception handling
  "search_product_in_wh schauen wenn ein Produkt im Lager existiert ein neuer vorgeschlagen wird, exception handling und neuer falls kein Produkt vorhanden ist

ENDCLASS.

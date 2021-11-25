*"* use this source file for your ABAP unit test classes
CLASS ltc_homescreen_model_orders DEFINITION DEFERRED.
CLASS zcl_ton_homescreen_model DEFINITION LOCAL FRIENDS ltc_homescreen_model_orders.
CLASS ltc_homescreen_model_orders DEFINITION FOR TESTING RISK LEVEL HARMLESS.
  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: m_cut                 TYPE REF TO zcl_ton_homescreen_model,
          lt_order_data         TYPE TABLE OF zton_order,
          l_exception_occured   TYPE abap_bool,
          homescreen_cntrl TYPE REF TO zcl_ton_homescreen_cntrl,
          login_cntrl      TYPE REF TO zcl_ton_customer_login_cntrl,
          mo_log                TYPE REF TO zcl_ton_webshop_log.

    CONSTANTS: mc_customer_number    TYPE zton_customer_number VALUE '1',
               mc_order_number_1     TYPE zton_order_number VALUE  '1',
               mc_order_number_2     TYPE zton_order_number VALUE  '2',
               mc_position_number_1  TYPE zton_position_number VALUE '1',
               mc_position_number_2  TYPE zton_position_number VALUE '2',
               mc_order_amount_1     TYPE zton_order_amount VALUE 01,
               mc_order_amount_2     TYPE zton_order_amount VALUE 02,
               mc_order_status       TYPE zton_status VALUE 'BE',
               mc_order_value        TYPE zton_order_amount VALUE '100',
               mc_status_in_progress TYPE zton_status VALUE 'IB',
               mc_status_completet   TYPE zton_status VALUE 'AB'.


    CLASS-DATA: m_environment TYPE REF TO if_osql_test_environment.
    CLASS-METHODS class_setup.
    METHODS setup.

    METHODS:
      "!Test method for add_to_cart_method
      check_add_to_cart FOR TESTING.

    METHODS:
      "!Test methods for delete_position_method
      check_delete_position FOR TESTING,
      delete_position_exc_exist FOR TESTING,
      delete_pos_status_exc_exist FOR TESTING.

    METHODS:
      "!Test methods for edit_quantity_of_position method
      check_edit_quantity_of_pos FOR TESTING,
      edit_quantity_of_pos_exc_exist FOR TESTING.

    METHODS:
      "! Test methods for get_all_orders_from_customer method
      check_all_orders_from_customer FOR TESTING,
      all_orders_customer_exc_exist FOR TESTING.

    METHODS:
      "!Test method for get_all_orders_from_customer method
      check_get_done_order FOR TESTING.

    METHODS:
      "!Test method for get_all_orders_from_customer method
      check_get_open_order FOR TESTING.

    METHODS:
      "! Test methods for check_if_order_exist method
      check_if_order_exist_true FOR TESTING,
      check_if_order_exist_false FOR TESTING.

ENDCLASS.

CLASS ltc_homescreen_model_orders IMPLEMENTATION.

  METHOD class_setup.
    m_environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'zton_order' ) ) ).
  ENDMETHOD.

  METHOD setup.

    "given
    lt_order_data = VALUE #( ( order_number = mc_order_number_1 position_number = mc_position_number_1 order_amount = mc_order_amount_1 status = mc_order_status customer_number = mc_customer_number )
                             ( order_number = mc_order_number_1 position_number = mc_position_number_2 order_amount = mc_order_amount_1 status = mc_order_status customer_number = mc_customer_number )
                             ( order_number = mc_order_number_2 position_number = mc_position_number_1 order_amount = mc_order_amount_1 status = mc_status_completet customer_number = mc_customer_number ) ).
    login_cntrl = NEW zcl_ton_customer_login_cntrl( io_log = mo_log  ).
    mo_log = NEW zcl_ton_webshop_log( iv_object = 'ZWEB' iv_suobj = 'ZWEB' ).
    homescreen_cntrl = NEW zcl_ton_homescreen_cntrl( io_login_cntrl = login_cntrl iv_customer_number =  mc_customer_number iv_email =  'test@web.de' io_log = mo_log ).

    m_environment->clear_doubles( ).

    m_cut = NEW zcl_ton_homescreen_model( io_home_screen_cntrl = homescreen_cntrl iv_customer_number = mc_customer_number io_log = mo_log ).

    m_environment->insert_test_data( EXPORTING i_data = lt_order_data ).

    l_exception_occured = abap_false.

  ENDMETHOD.

  METHOD check_add_to_cart.
    "given
    DATA: lv_article            TYPE zton_article,
          lv_number_of_articles TYPE zton_order_amount.

    lv_article = VALUE #( article_number = 1 designation = 'Bildschirm' ).
    lv_number_of_articles = 2.

    "when
    TRY.
        m_cut->add_to_cart( is_article = lv_article iv_number_of_articles = lv_number_of_articles ).

        "then
        cl_abap_unit_assert=>assert_equals( EXPORTING act =  m_cut->mt_cart[ 1 ]-article_designation
                                                     exp =  lv_article-designation ).
      CATCH zcx_ton_webshop_exception_new INTO DATA(e_text).
        cl_abap_unit_assert=>fail( EXPORTING msg = 'Beim hinzufügen ist ein Fehler aufgetreten' ).
    ENDTRY.
  ENDMETHOD.

  METHOD check_delete_position.
    "when
    TRY.
        m_cut->delete_position( is_position = VALUE #( order_number = mc_order_number_1
                                                       position_number = mc_position_number_1
                                                       status = mc_order_status ) ).
      CATCH zcx_ton_webshop_exception_new .
        cl_abap_unit_assert=>fail( EXPORTING msg = 'Beim löschen ist ein Fehler aufgetreten' ).
    ENDTRY.
    "then
    SELECT *
      FROM zton_order
      INTO TABLE @DATA(lt_data)
      WHERE order_number = @mc_order_number_1.


    IF sy-subrc <> 0.
      cl_abap_unit_assert=>fail( EXPORTING msg = 'Es wurden zu viele Datensätze gelöscht' ).
    ELSE.

      IF line_exists( lt_data[ position_number = 1 ] ).
        cl_abap_unit_assert=>fail( EXPORTING msg = 'Position wurde nicht gelöscht'  ).
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD delete_position_exc_exist.
    TRY.
        "given
        m_environment->clear_doubles( ).

        m_cut->delete_position( is_position = VALUE #( order_number = mc_order_number_1
                                                   position_number = mc_position_number_1
                                                   status = mc_order_status ) ).
      CATCH zcx_ton_webshop_exception_new.
        l_exception_occured = abap_true.
    ENDTRY.
    "then
    cl_abap_unit_assert=>assert_true( act = l_exception_occured
                                      msg = 'Es wurde keine Exception geworfen' ).

  ENDMETHOD.

  METHOD delete_pos_status_exc_exist.
    TRY.
        "when
        m_cut->delete_position( is_position = VALUE #( order_number = mc_order_number_1
                                                       position_number = mc_position_number_1
                                                       status = mc_status_in_progress ) ).

      CATCH zcx_ton_webshop_exception_new.
        l_exception_occured = abap_true.
    ENDTRY.
    "then
    cl_abap_unit_assert=>assert_true( act = l_exception_occured
                                      msg = 'wenn der Status AB oder IB ist wird keine Exception geworfen!' ).

  ENDMETHOD.

  METHOD check_edit_quantity_of_pos.
    TRY.
        "when
        m_cut->edit_quantity_of_position( is_position = VALUE #( order_number = mc_order_number_1
                                                       position_number = mc_position_number_1
                                                       status = mc_order_status ) iv_quantity = 5 ).
      CATCH zcx_ton_webshop_exception_new .
        cl_abap_unit_assert=>fail( EXPORTING msg = 'Beim anpassen der Menge ist ein Fehler aufgetreten' ).
    ENDTRY.
    "then
    SELECT *
      FROM zton_order
      INTO TABLE @DATA(lt_data)
      WHERE order_amount = 5 .

    IF sy-subrc <> 0.
      cl_abap_unit_assert=>fail( EXPORTING msg = 'Bestellmenge wurde nicht geändert!'  ).
    ENDIF.

  ENDMETHOD.

  METHOD edit_quantity_of_pos_exc_exist.

    TRY.
        "given
        m_environment->clear_doubles( ).
        "when
        m_cut->edit_quantity_of_position( is_position = VALUE #( order_number = mc_order_number_1
                                                       position_number = mc_position_number_1
                                                       status = mc_order_status ) iv_quantity = 5 ).
      CATCH zcx_ton_webshop_exception_new.
        l_exception_occured = abap_true.
    ENDTRY.
    "then
    cl_abap_unit_assert=>assert_true(
      act = l_exception_occured
      msg = 'Im Fehlerfall wird keine Exception geworfen'
    ).
  ENDMETHOD.



  METHOD check_all_orders_from_customer.
    DATA: mt_orders TYPE zton_tt_order.
    TRY.
        "when
        m_cut->get_all_orders_from_customer(  ).
        mt_orders = m_cut->mt_order.
      CATCH zcx_ton_webshop_exception_new .
        cl_abap_unit_assert=>fail( EXPORTING msg = 'Beim Aufruf ist ein Fehler aufgetreten' ).
    ENDTRY.
    "then
    IF m_cut->mt_order IS INITIAL.
      cl_abap_unit_assert=>fail( EXPORTING msg = 'Es wurden keine Daten gelesen!').
    ELSE.
      "In Tabelle zton_order werden einzelne Bestellpositionen auch als einzelne  Bestellung gespeichert
      cl_abap_unit_assert=>assert_equals( EXPORTING act =  mt_orders[ 1 ]-order_number
                                                    exp =  mc_order_number_1 ).
      cl_abap_unit_assert=>assert_equals( EXPORTING act =  mt_orders[ 2 ]-order_number
                                                    exp =  mc_order_number_1 ).
      cl_abap_unit_assert=>assert_equals( EXPORTING act =  mt_orders[ 3 ]-order_number
                                                    exp =  mc_order_number_2 ).
    ENDIF.
  ENDMETHOD.

  METHOD all_orders_customer_exc_exist.
    DATA: mt_orders TYPE zton_tt_order.

    TRY.
        "given
        m_environment->clear_doubles( ).
        "when
        m_cut->get_all_orders_from_customer( ).
        mt_orders = m_cut->mt_order.
        "then
      CATCH zcx_ton_webshop_exception_new.
        l_exception_occured = abap_true.
    ENDTRY.
    "then
    cl_abap_unit_assert=>assert_true(
      act = l_exception_occured
      msg = 'Es wird keine Exception geworfen, falls ein Fehler auftritt!'
    ).
  ENDMETHOD.

  METHOD check_get_done_order.
    DATA: lv_done_orders TYPE zton_tt_order.
    TRY.
        "when
        m_cut->get_all_orders_from_customer(  ).
      CATCH zcx_ton_webshop_exception_new .
        cl_abap_unit_assert=>fail( EXPORTING msg = 'Beim Aufruf ist ein Fehler aufgetreten' ).
    ENDTRY.
    IF m_cut->mt_order IS INITIAL.
      cl_abap_unit_assert=>fail( EXPORTING msg = 'Es wurden keine Daten gelesen. Erst wenn die Methode get_all_orders_from_customer funktioniert, kann dieser Test positiv werden.').
    ELSE.
      lv_done_orders = m_cut->get_done_order_from_mt_order(  ).

      "then
      cl_abap_unit_assert=>assert_equals( EXPORTING act =  lv_done_orders[ 1 ]-order_number
                                                    exp =  lt_order_data[ 3 ]-order_number ).
    ENDIF.
  ENDMETHOD.

  METHOD check_get_open_order.
    DATA: lv_done_orders TYPE zton_tt_order.
    TRY.
        "when
        m_cut->get_all_orders_from_customer(  ).
      CATCH zcx_ton_webshop_exception_new .
        cl_abap_unit_assert=>fail( EXPORTING msg = 'Es wurden keine Daten gelesen. Erst wenn die Methode get_all_orders_from_customer funktioniert, kann dieser Test positiv werden.' ).
    ENDTRY.
    IF m_cut->mt_order IS INITIAL.
      cl_abap_unit_assert=>fail( EXPORTING msg = 'Es wurden keine Daten gelesen. Erst wenn die Methode get_all_orders_from_customer funktioniert, kann dieser Test positiv werden.').
    ELSE.
      lv_done_orders = m_cut->get_open_order_from_mt_order(  ).

      "then
      cl_abap_unit_assert=>assert_equals( EXPORTING act =  lv_done_orders[ 1 ]-order_number
                                                      exp =  lt_order_data[ 1 ]-order_number ).
    ENDIF.
  ENDMETHOD.

  METHOD check_if_order_exist_true.
    DATA: lv_exist          TYPE boolean,
          ls_order_to_check TYPE zton_order.
    "given
    m_cut->mo_home_screen_cntrl->mt_order_to_show = VALUE #( ( order_number = 1 article = 'Bildschirm' )
                                                                  ( order_number = 2 article = 'Bildschirm' ) ).

    ls_order_to_check = VALUE #( order_number = 1 article = 'Bildschirm'  ).

    "when
    lv_exist = m_cut->check_if_order_exist( is_selected_row = ls_order_to_check ).

    "then
    cl_abap_unit_assert=>assert_true(
     act = lv_exist
     msg = 'Die Methode check_if_order_exist gibt false zurück, obwohl die Bestellnummer 1 existiert!'
   ).

  ENDMETHOD.

  METHOD check_if_order_exist_false.
    DATA: lv_exist          TYPE boolean,
          ls_order_to_check TYPE zton_order.
    "given
    m_cut->mo_home_screen_cntrl->mt_order_to_show = VALUE #( ( order_number = 1 article = 'Bildschirm' )
                                                                  ( order_number = 2 article = 'Bildschirm' ) ).

    ls_order_to_check = VALUE #( order_number = 3 article = 'Bildschirm' ).

    "when
    lv_exist = m_cut->check_if_order_exist( is_selected_row = ls_order_to_check ).

    "then
    cl_abap_unit_assert=>assert_false(
     act = lv_exist
     msg = 'Die Methode check_if_order_exist gibt true zurück, obwohl die Bestellnummer 3 nicht existiert!'
   ).

  ENDMETHOD.

ENDCLASS.


CLASS ltc_homescreen_model_artikel DEFINITION DEFERRED.
CLASS zcl_ton_homescreen_model DEFINITION LOCAL FRIENDS ltc_homescreen_model_artikel.
CLASS ltc_homescreen_model_artikel DEFINITION FOR TESTING RISK LEVEL HARMLESS.
  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: m_cut                 TYPE REF TO zcl_ton_homescreen_model,
          lt_article_data       TYPE TABLE OF zton_article,
          l_exception_occured   TYPE abap_bool,
          homescreen_cntrl TYPE REF TO zcl_ton_homescreen_cntrl,
          login_cntrl      TYPE REF TO zcl_ton_customer_login_cntrl,
          mo_log                TYPE REF TO zcl_ton_webshop_log.


    CLASS-DATA: m_environment TYPE REF TO if_osql_test_environment.
    CLASS-METHODS class_setup.
    METHODS setup.
    METHODS:
      "!Test method for select_articles
      check_select_articles FOR TESTING.
    METHODS:
      "! Test method for remove_item_from_cart
      check_remove_item_from_card FOR TESTING.

    CONSTANTS: mc_customer         TYPE zton_customer_number VALUE '1',
               mc_article_number_1 TYPE zton_article_number VALUE '1',
               mc_article_number_2 TYPE zton_article_number VALUE '2',
               mc_article_number_3 TYPE zton_article_number VALUE '3',
               mc_description_1    TYPE zton_description VALUE 'Bildschirm',
               mc_description_2    TYPE zton_description VALUE 'Tastatur',
               mc_description_3    TYPE zton_description VALUE 'Maus',
               mc_currency         TYPE zton_currency VALUE 'Euro'.



ENDCLASS.

CLASS ltc_homescreen_model_artikel IMPLEMENTATION.

  METHOD setup.
    "given
    lt_article_data = VALUE #( ( article_number = mc_article_number_1 designation = mc_description_1 price = 200 currency = mc_currency )
                               ( article_number = mc_article_number_2 designation = mc_description_2 price = 70 currency = mc_currency )
                               ( article_number = mc_article_number_3 designation = mc_description_3 price = 30 currency = mc_currency ) ).

    mo_log = NEW zcl_ton_webshop_log( iv_object = 'ZWEB' iv_suobj = 'ZWEB' ).
    login_cntrl = NEW zcl_ton_customer_login_cntrl( io_log = mo_log  ).
    homescreen_cntrl = NEW zcl_ton_homescreen_cntrl( io_login_cntrl = login_cntrl iv_customer_number =  mc_customer iv_email =  'test@web.de' io_log = mo_log ).

    m_environment->clear_doubles( ).

    m_cut = NEW zcl_ton_homescreen_model( io_home_screen_cntrl = homescreen_cntrl iv_customer_number = mc_customer io_log = mo_log ).
    m_environment->insert_test_data( EXPORTING i_data = lt_article_data ).
  ENDMETHOD.

  METHOD class_setup.
    m_environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'zton_article' ) ) ).
  ENDMETHOD.

  METHOD check_select_articles.
    DATA: lt_articles TYPE TABLE OF zton_article.

    "when
    m_cut->select_articles(  ).
    .
    lt_articles = m_cut->mt_articles.

    IF lt_articles IS INITIAL.
      cl_abap_unit_assert=>fail( EXPORTING msg = 'In der Methode select_articles wurde nichts ausgelesen!').
    ELSE.

      "then
      cl_abap_unit_assert=>assert_equals( EXPORTING act =  lt_articles[ 1 ]-article_number
                                                    exp =  lt_article_data[ 1 ]-article_number ).
      cl_abap_unit_assert=>assert_equals( EXPORTING act =  lt_articles[ 2 ]-article_number
                                                    exp =  lt_article_data[ 2 ]-article_number ).
      cl_abap_unit_assert=>assert_equals( EXPORTING act =  lt_articles[ 3 ]-article_number
                                                exp =  lt_article_data[ 3 ]-article_number ).
    ENDIF.
  ENDMETHOD.

  METHOD check_remove_item_from_card.
    "given
    m_cut->mt_cart  = VALUE #( ( article_number = mc_article_number_1 article_description = mc_description_1  price = 200 currency = mc_currency )
                            ( article_number = mc_article_number_2 article_description = mc_description_2  price = 70 currency = mc_currency )
                            ( article_number = mc_article_number_3 article_description = mc_description_3  price = 30 currency = mc_currency )    ).

    "when
    m_cut->remove_item_from_cart( iv_article_number = mc_article_number_2 ).

    "then
    cl_abap_unit_assert=>assert_equals( EXPORTING act =  m_cut->mt_cart[ 1 ]-article_number
                                                exp = mc_article_number_1 ).
    cl_abap_unit_assert=>assert_equals( EXPORTING act =  m_cut->mt_cart[ 2 ]-article_number
                                                  exp =  mc_article_number_3 ).

  ENDMETHOD.
ENDCLASS.


CLASS ltc_homescreen_model_adress DEFINITION DEFERRED.
CLASS zcl_ton_homescreen_model DEFINITION LOCAL FRIENDS ltc_homescreen_model_adress.
CLASS ltc_homescreen_model_adress DEFINITION FOR TESTING RISK LEVEL HARMLESS.
  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: m_cut                 TYPE REF TO zcl_ton_homescreen_model,
          lt_adress_data        TYPE TABLE OF zton_order_ad,
          l_exception_occured   TYPE abap_bool,
          homescreen_cntrl TYPE REF TO zcl_ton_homescreen_cntrl,
          login_cntrl      TYPE REF TO zcl_ton_customer_login_cntrl,
          mo_log                TYPE REF TO zcl_ton_webshop_log.

    CONSTANTS: mc_customer_number TYPE zton_customer_number VALUE '1',
               mc_order_number_1  TYPE numc10 VALUE 1,
               mc_order_number_2  TYPE numc10 VALUE 2,
               mc_street_1        TYPE zton_street VALUE 'Schlossallee',
               mc_street_2        TYPE zton_street VALUE 'Parkstrasse',
               mc_zip_code        TYPE zton_postalcode VALUE 97070,
               mc_city            TYPE zton_city VALUE 'Würzburg'.



    CLASS-DATA: m_environment TYPE REF TO if_osql_test_environment.
    CLASS-METHODS class_setup.
    METHODS setup.
    METHODS:
      "!Test method for insert_address_of_order
      check_insert_address_of_order FOR TESTING.





ENDCLASS.

CLASS ltc_homescreen_model_adress IMPLEMENTATION.

  METHOD setup.
    "given
    lt_adress_data = VALUE #( ( order_number = mc_order_number_1 street = mc_street_1 house_number = 1 zip_code = mc_zip_code city = mc_city ) ).

    mo_log = NEW zcl_ton_webshop_log( iv_object = 'ZWEB' iv_suobj = 'ZWEB' ).
    login_cntrl = NEW zcl_ton_customer_login_cntrl( io_log = mo_log ).
    homescreen_cntrl = NEW zcl_ton_homescreen_cntrl( io_login_cntrl = login_cntrl iv_customer_number =  mc_customer_number iv_email =  'test@web.de' io_log = mo_log ).

    m_environment->clear_doubles( ).

    m_cut = NEW zcl_ton_homescreen_model( io_home_screen_cntrl = homescreen_cntrl iv_customer_number = mc_customer_number io_log = mo_log ).
    m_environment->insert_test_data( EXPORTING i_data = lt_adress_data ).
  ENDMETHOD.

  METHOD class_setup.
    m_environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'zton_order_ad' ) ) ).
  ENDMETHOD.

  METHOD check_insert_address_of_order.
    DATA: lt_adress TYPE TABLE OF zton_order_ad.

    "given
    m_cut->ms_order_address = VALUE #( street = mc_street_2 houese_number = 2 zip_code = mc_zip_code city = mc_city ).

    "when
    m_cut->insert_address_of_order( iv_order_number = mc_order_number_2 ).

    "then
    SELECT SINGLE street
        FROM zton_order_ad INTO @DATA(ls_adress)
        WHERE street = @mc_street_2.

    IF sy-subrc <> 0.
      cl_abap_unit_assert=>fail( EXPORTING msg = 'Adresse wurde nicht eingefügt').
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS ltc_homescreen_model_customer DEFINITION DEFERRED.
CLASS zcl_ton_homescreen_model DEFINITION LOCAL FRIENDS ltc_homescreen_model_customer.
CLASS ltc_homescreen_model_customer DEFINITION FOR TESTING RISK LEVEL HARMLESS.
  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: m_cut                 TYPE REF TO zcl_ton_homescreen_model,
          lt_adress_data        TYPE TABLE OF zton_customer,
          l_exception_occured   TYPE abap_bool,
          homescreen_cntrl TYPE REF TO zcl_ton_homescreen_cntrl,
          login_cntrl      TYPE REF TO zcl_ton_customer_login_cntrl,
          mo_log                TYPE REF TO zcl_ton_webshop_log.

    CONSTANTS: mc_customer_number_1 TYPE zton_customer_number VALUE '1',
               mc_customer_number_2 TYPE zton_customer_number VALUE '2',
               mc_name_1            TYPE zton_name VALUE 'Meyer',
               mc_name_2            TYPE zton_name VALUE 'Müller',
               mc_street_1          TYPE zton_street VALUE 'Schlossallee',
               mc_street_2          TYPE zton_street VALUE 'Parkstrasse',
               mc_house_number      TYPE zton_house_nr VALUE 1,
               mc_zip_code          TYPE zton_postalcode VALUE 97070,
               mc_city              TYPE zton_city VALUE 'Würzburg'.



    CLASS-DATA: m_environment TYPE REF TO if_osql_test_environment.
    CLASS-METHODS class_setup.
    METHODS setup.
    METHODS:
      "! Test method for get_address_of_customer
      check_get_adress_of_customer FOR TESTING,
      get_adress_of_custom_exc_exist FOR TESTING.

ENDCLASS.

CLASS ltc_homescreen_model_customer IMPLEMENTATION.

  METHOD setup.
    "given
    lt_adress_data = VALUE #( ( customer_number = mc_customer_number_1 name = mc_name_1 street = mc_street_1 house_number = mc_house_number zip_code = mc_zip_code city = mc_city )
                              ( customer_number = mc_customer_number_2 name = mc_name_2 street = mc_street_2 house_number = mc_house_number zip_code = mc_zip_code city = mc_city ) ).

    mo_log = NEW zcl_ton_webshop_log( iv_object = 'ZWEB' iv_suobj = 'ZWEB' ).
    login_cntrl = NEW zcl_ton_customer_login_cntrl( io_log = mo_log ).
    homescreen_cntrl = NEW zcl_ton_homescreen_cntrl( io_login_cntrl = login_cntrl iv_customer_number =  mc_customer_number_2 iv_email =  'test@web.de' io_log = mo_log ).

    m_environment->clear_doubles( ).

    m_cut = NEW zcl_ton_homescreen_model( io_home_screen_cntrl = homescreen_cntrl iv_customer_number = mc_customer_number_2 io_log = mo_log ).
    m_environment->insert_test_data( EXPORTING i_data = lt_adress_data ).
  ENDMETHOD.

  METHOD class_setup.
    m_environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'zton_customer' ) ) ).
  ENDMETHOD.

  METHOD check_get_adress_of_customer.

    DATA: ls_order_adress TYPE zton_s_adress.
    TRY.
        "when
        m_cut->get_address_of_customer(  ).
      CATCH zcx_ton_webshop_exception_new .
        cl_abap_unit_assert=>fail( EXPORTING msg = 'Beim Aufruf der Methode get_address_of_customer ist ein Fehler aufgetreten' ).
    ENDTRY.
    ls_order_adress = m_cut->ms_order_address.

    "then
    cl_abap_unit_assert=>assert_equals( EXPORTING act =  ls_order_adress-street
                                                  exp =  lt_adress_data[ 2 ]-street ).

  ENDMETHOD.

  METHOD get_adress_of_custom_exc_exist.
    DATA: ls_order_adress TYPE zton_s_adress.

    TRY.
        "given
        m_environment->clear_doubles( ).
        "when
        m_cut->get_address_of_customer(  ).
        ls_order_adress = m_cut->ms_order_address.

      CATCH zcx_ton_webshop_exception_new.
        l_exception_occured = abap_true.
    ENDTRY.
    "then
    cl_abap_unit_assert=>assert_true(
      act = l_exception_occured
      msg = 'In der Methode get_address_of_customer wird keine Exception geworfen wenn ein Fehler auftritt.'
    ).

  ENDMETHOD.

ENDCLASS.

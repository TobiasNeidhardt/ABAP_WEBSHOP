*"* use this source file for your ABAP unit test classes

CLASS ltc_customer_model DEFINITION FOR TESTING RISK LEVEL HARMLESS.
  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: m_cut               TYPE REF TO zcl_ton_customer_login_model,
          lt_adress_data      TYPE TABLE OF zton_customer,
          l_exception_occured TYPE abap_bool,
          login_cntrl    TYPE REF TO zcl_ton_customer_login_cntrl,
          mo_log        TYPE REF TO zcl_ton_webshop_log.

    CONSTANTS: lc_customer_number_1 TYPE zton_customer_number VALUE '1',
               lc_customer_number_2 TYPE zton_customer_number VALUE '2',
               lc_name_1            TYPE zton_name VALUE 'Meyer',
               lc_name_2            TYPE zton_name VALUE 'Müller',
               lc_mail_1            TYPE zton_email VALUE 'test@test.de',
               lc_mail_2            TYPE zton_email VALUE 'unit-test@test.de',
               lc_password_1        TYPE zton_password VALUE '1234',
               lc_password_2        TYPE zton_password VALUE 'ABCD'.



    CLASS-DATA: m_environment TYPE REF TO if_osql_test_environment.
    CLASS-METHODS class_setup.
    METHODS setup.
    METHODS: check_email_is_available_true FOR TESTING,
      check_email_is_available_false FOR TESTING RAISING cx_static_check,
      check_passwort_no_account_exc FOR TESTING,
      check_passwort_false FOR TESTING,
      check_get_customer_number FOR TESTING,
      get_customer_number_exc_exist FOR TESTING,
      check_pw_and_account_pass FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltc_customer_model IMPLEMENTATION.
  METHOD setup.
    "given
    lt_adress_data = VALUE #( ( customer_number = lc_customer_number_1 name = lc_name_1 email = lc_mail_1 password = lc_password_1 )
                              ( customer_number = lc_customer_number_2 name = lc_name_2 email = lc_mail_2 password = lc_password_2 ) ).

    mo_log = new zcl_ton_webshop_log( iv_object = 'ZWEB' iv_suobj = 'ZWEB' ).
    login_cntrl = NEW zcl_ton_customer_login_cntrl( io_log =  mo_log ).

    m_environment->clear_doubles( ).

    m_cut = NEW zcl_ton_customer_login_model( io_cntrl = login_cntrl io_log = mo_log ).
    m_environment->insert_test_data( EXPORTING i_data = lt_adress_data ).
    l_exception_occured = abap_false.

  ENDMETHOD.

  METHOD class_setup.
    m_environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'zton_customer' ) ) ).
  ENDMETHOD.

  METHOD check_email_is_available_true.

    "given
    DATA: lv_mail TYPE zton_email VALUE 'new@test.de'.
    TRY.
        "when
        m_cut->check_if_email_is_available( iv_email = lv_mail ).

      CATCH zcx_ton_webshop_exception_new.
        l_exception_occured = abap_true.
    ENDTRY.
    "then
    cl_abap_unit_assert=>assert_false(
      act = l_exception_occured
      msg = 'Email noch nicht vorhanden deswegen darf sie verwendet werden!'
    ).
  ENDMETHOD.

  METHOD check_email_is_available_false.
    "given
    DATA: lv_mail TYPE zton_email VALUE 'test@test.de'.
    TRY.
        "when
        m_cut->check_if_email_is_available( iv_email = lv_mail ).

      CATCH zcx_ton_webshop_exception_new.
        l_exception_occured = abap_true.
    ENDTRY.
    "then
    cl_abap_unit_assert=>assert_true(
      act = l_exception_occured
      msg = 'Es wird keine Exception geworfen'
    ).

  ENDMETHOD.

  METHOD check_passwort_no_account_exc.
    "given
    DATA: lv_password TYPE zton_password VALUE '1234',
          lv_mail     TYPE zton_email VALUE 'Test2@test.de'.

    TRY.
        m_cut->check_if_password_is_correct( iv_email = lv_mail iv_password = lv_password ).
      CATCH zcx_ton_webshop_exception_new.
        l_exception_occured = abap_true.
    ENDTRY.

    "then
    cl_abap_unit_assert=>assert_true(
      act = l_exception_occured
      msg = 'Die Methode check_if_password_is_correct wirft keine Exception, falls sie keinen Account findet!'
    ).
  ENDMETHOD.


  METHOD check_passwort_false.
    "given
    DATA: lv_password TYPE zton_password VALUE '4321',
          lv_mail     TYPE zton_email VALUE 'Test@test.de'.

    TRY.
        m_cut->check_if_password_is_correct( iv_email = lv_mail iv_password = lv_password ).
      CATCH zcx_ton_webshop_exception_new INTO DATA(e_text).
        l_exception_occured = abap_true.
    ENDTRY.

    "then
    cl_abap_unit_assert=>assert_true(
      act = l_exception_occured
      msg = 'Die Methode check_if_password_is_correct wirft keine Exception, falls das Passwort faslsch ist!'
    ).
  ENDMETHOD.


  METHOD check_pw_and_account_pass.

    "given
    DATA: lv_password TYPE zton_password VALUE lc_password_1,
          lv_mail     TYPE zton_email VALUE lc_mail_1.

    TRY.
        m_cut->check_if_password_is_correct( iv_email = lv_mail iv_password = lv_password ).
      CATCH zcx_ton_webshop_exception_new INTO DATA(e_text).
        l_exception_occured = abap_true.
    ENDTRY.

    "then
    cl_abap_unit_assert=>assert_false(
      act = l_exception_occured
      msg = 'Es wird eine Exception geworfen obwohl Passwort und Email übereinstimmen'
    ).

  ENDMETHOD.

  METHOD check_get_customer_number.
    "given
    DATA: lv_customer_number TYPE zton_customer_number,
          lv_mail            TYPE zton_email VALUE 'test@test.de'.

    TRY.
        "when
        lv_customer_number = m_cut->get_customer_number( iv_email = lv_mail ).
        "then
        cl_abap_unit_assert=>assert_equals( EXPORTING act =  lv_customer_number
                                                       exp =  lc_customer_number_1 ).
      CATCH zcx_ton_webshop_exception_new.
        cl_abap_unit_assert=>fail( EXPORTING msg = 'Es wird eine Exception geworfen!' ).
    ENDTRY.

  ENDMETHOD.

  METHOD get_customer_number_exc_exist.
    "given
    DATA: lv_customer_number TYPE zton_customer_number,
          lv_mail            TYPE zton_email VALUE 'nicht-vorhanden@test.de'.

    TRY.
        "when
        lv_customer_number = m_cut->get_customer_number( iv_email = lv_mail ).

      CATCH zcx_ton_webshop_exception_new.
        l_exception_occured = abap_true.

    ENDTRY.
    "then
    cl_abap_unit_assert=>assert_true(
      act = l_exception_occured
      msg = 'Die Methode get_customer_number_exc_exist wirft keine Exception, falls ein Fehler aufgetreten ist!'
    ).
  ENDMETHOD.

ENDCLASS.

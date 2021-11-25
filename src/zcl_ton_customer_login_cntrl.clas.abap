CLASS zcl_ton_customer_login_cntrl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS:
      constructor
      IMPORTING
      !io_log TYPE REF TO zcl_ton_webshop_log,
      on_back ,
      on_confirm_login
        IMPORTING
                  !iv_email    TYPE zton_email
                  !iv_password TYPE zton_password
        RAISING   zcx_ton_webshop_exception_new,
      on_register ,
      start ,
      on_leave ,
      on_confirm_registration
        IMPORTING
          !is_register_data TYPE zton_s_register ,
      encrypt_password
        IMPORTING
          !iv_password               TYPE zton_password
        RETURNING
          VALUE(rv_password_as_hash) TYPE zton_password ,
      on_pbo_login_screen
        RAISING zcx_ton_webshop_exception_new .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: mv_customer_email         TYPE zton_email,
          mo_customer_login_view    TYPE REF TO zcl_ton_customer_login_view,
          mo_customer_login_model   TYPE REF TO zcl_ton_customer_login_model,
          mo_customer_register_view TYPE REF TO zcl_ton_customer_register_view,
          mo_home_screen_cntrl TYPE REF TO zcl_ton_homescreen_cntrl,
          mo_log                    TYPE REF TO zcl_ton_webshop_log.
ENDCLASS.



CLASS ZCL_TON_CUSTOMER_LOGIN_CNTRL IMPLEMENTATION.


  METHOD constructor.
    me->mo_log = io_log.
  ENDMETHOD.


  METHOD encrypt_password.
    TRY.
        cl_abap_message_digest=>calculate_hash_for_char( EXPORTING if_data       = iv_password
                                                         IMPORTING ef_hashstring = rv_password_as_hash ).

      CATCH cx_abap_message_digest  INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.

    ENDTRY.
  ENDMETHOD.


  METHOD on_back.
    LEAVE TO SCREEN 0.
  ENDMETHOD.


  METHOD on_confirm_login.

    "Call model to select password to email and check if the input password is right.
    IF iv_email IS INITIAL OR iv_password IS INITIAL.
      MESSAGE i040(zton_web_shop) INTO DATA(ls_msg).
      me->mo_log->add_msg_from_sys( ).
      me->mo_log->safe_log( ).
      RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
    ENDIF.
    TRY.
        me->mo_customer_login_model->check_if_password_is_correct( EXPORTING iv_password = me->encrypt_password( iv_password = iv_password )
                                                                             iv_email    = iv_email ).



        me->mo_home_screen_cntrl = NEW zcl_ton_homescreen_cntrl( io_login_cntrl = me
                                                                            iv_customer_number  = me->mo_customer_login_model->get_customer_number( iv_email = iv_email )
                                                                            iv_email = iv_email
                                                                            io_log = mo_log ).

        me->mo_home_screen_cntrl->start( ).
      CATCH zcx_ton_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.

  ENDMETHOD.


  METHOD on_confirm_registration.

    CONSTANTS: lc_text_password        TYPE char90 VALUE   'Die eingegebenen Passwörter stimmen nicht überein!',
               lc_text_successful_save TYPE char90 VALUE   'Ihr Kundenkonto wurde erfolgreich angelegt',
               lc_text_field           TYPE char90 VALUE   'Bitte Füllen Sie alle Pflichtfelder aus!',
               lc_kind                 TYPE char4  VALUE   'ERRO',
               lc_button               TYPE char15 VALUE   'Okay'.

    DATA: lv_button TYPE i.
    "Check if all fields except the telefon number are filled
    "Compare both password fields
    "If everything is fine call the modelclass to save the user

    TRY.
        IF is_register_data-city            IS INITIAL OR
         is_register_data-email           IS INITIAL OR
         is_register_data-house_number    IS INITIAL OR
         is_register_data-password        IS INITIAL OR
         is_register_data-password_repeat IS INITIAL OR
         is_register_data-street          IS INITIAL OR
         is_register_data-firstname       IS INITIAL OR
         is_register_data-name            IS INITIAL OR
         is_register_data-salutation      IS INITIAL OR
         is_register_data-zip_code        IS INITIAL.

          "show pop-up with an error message that all fields must be filled
          lv_button =  /auk/cl_msgbox=>show_msgbox( im_text    = lc_text_field
                                                       im_kind    = lc_kind
                                                       im_button1 = lc_button ).

        ELSEIF is_register_data-password <> is_register_data-password_repeat.
          "Passwords are not the same
          lv_button =  /auk/cl_msgbox=>show_msgbox( im_text = lc_text_password
                                                       im_kind    = lc_kind
                                                       im_button1 = lc_button ).

        ELSE.
          TRY.
              "Check if emailadress already exists and if the adress have the right format
              me->mo_customer_login_model->check_if_email_is_available( iv_email = is_register_data-email ).
              "save customer
              me->mo_customer_login_model->save_registration_customer( is_register_data = is_register_data ).
              "If saving customer is successful output info for customer
              DATA(lv_button_pop_up_success) =  /auk/cl_msgbox=>show_msgbox( im_text    = lc_text_successful_save
                                                                             im_button1 = lc_button ).
            CATCH zcx_ton_webshop_exception_new INTO DATA(e_text).
              MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
          ENDTRY.
        ENDIF.
      CATCH /auk/cx_vc  INTO DATA(auk_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.

    FREE me->mo_customer_register_view.
    me->on_back( ).

  ENDMETHOD.


  METHOD on_leave.
    LEAVE PROGRAM.
  ENDMETHOD.


  METHOD on_pbo_login_screen.

    IF me->mo_home_screen_cntrl IS BOUND.
      MESSAGE i056(zton_web_shop) INTO DATA(ls_msg).
      me->mo_log->add_msg_from_sys( ).
      me->mo_log->safe_log( ).
      RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
    ENDIF.

  ENDMETHOD.


  METHOD on_register.
    IF me->mo_customer_register_view IS NOT BOUND.
      me->mo_customer_register_view = NEW zcl_ton_customer_register_view( io_login_cntrl = me ).
      me->mo_customer_register_view->call_register_screen( ).
    ENDIF.
  ENDMETHOD.


  METHOD start.

    "Create an instance of the login view and of the model
    IF me->mo_customer_login_view IS NOT BOUND.
      mo_customer_login_view = NEW zcl_ton_customer_login_view( io_customer_login_cntrl = me ).
    ENDIF.

    IF me->mo_customer_login_model IS NOT BOUND.
      mo_customer_login_model = NEW zcl_ton_customer_login_model( io_cntrl = me io_log = mo_log ).
    ENDIF.
    TRY.
        "Call the login screen
        me->mo_customer_login_view->call_login_screen( ).
      CATCH zcx_ton_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

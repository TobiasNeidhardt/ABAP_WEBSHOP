CLASS zcl_ton_customer_register_view DEFINITION
PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS: call_register_screen
      RAISING
        zcx_ton_webshop_exception_new ,
      register_screen_pai
        IMPORTING
          !is_register_data TYPE zton_s_register ,
      constructor
        IMPORTING
          !io_login_cntrl TYPE REF TO zcl_ton_customer_login_cntrl
        EXCEPTIONS
          io_cntrl .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mo_login_cntrl TYPE REF TO zcl_ton_customer_login_cntrl .
ENDCLASS.



CLASS zcl_ton_customer_register_view IMPLEMENTATION.


  METHOD call_register_screen.
    TRY.
        CALL FUNCTION 'ZTON_CUSTOMER_REGISTER'
          EXPORTING
            io_customer_register_view = me.
      CATCH cx_root .
        RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new.
    ENDTRY.
  ENDMETHOD.


  METHOD constructor.

    mo_login_cntrl = io_login_cntrl.

  ENDMETHOD.


  METHOD register_screen_pai.

    CASE sy-ucomm.

      WHEN 'BACK'.
        me->mo_login_cntrl->on_back( ).

      WHEN 'LEAVE'.
        me->mo_login_cntrl->on_leave( ).

      WHEN 'CONFIRM'.
        me->mo_login_cntrl->on_confirm_registration( is_register_data = is_register_data ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.

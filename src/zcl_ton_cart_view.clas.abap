CLASS zcl_ton_cart_view DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS: call_screen_cart,
      screen_for_cart_pai ,
      screen_for_cart_pbo ,
      constructor
        IMPORTING
          !io_cntrl TYPE REF TO zcl_ton_homescreen_cntrl .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mo_home_screen_cntrl TYPE REF TO zcl_ton_homescreen_cntrl .
ENDCLASS.



CLASS zcl_ton_cart_view IMPLEMENTATION.


  METHOD call_screen_cart.

    CALL FUNCTION 'ZTON_CART'
      EXPORTING
        io_cart_view = me.

  ENDMETHOD.


  METHOD constructor.

    me->mo_home_screen_cntrl = io_cntrl.

  ENDMETHOD.


  METHOD screen_for_cart_pai.
    TRY.
        CASE sy-ucomm.

          WHEN 'BACK'.
            me->mo_home_screen_cntrl->on_back( ).

          WHEN 'LEAVE'.
            me->mo_home_screen_cntrl->on_leave( ).

          WHEN 'ORDER'.
            me->mo_home_screen_cntrl->on_order( ).

          WHEN 'EDIT'.
            me->mo_home_screen_cntrl->on_edit_quantity( ).

          WHEN 'REMOVE'.
            me->mo_home_screen_cntrl->on_remove_item_from_cart( ).


        ENDCASE.
      CATCH zcx_ton_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.


  METHOD screen_for_cart_pbo.

    me->mo_home_screen_cntrl->on_pbo_cart( ).

  ENDMETHOD.
ENDCLASS.

CLASS zcl_ton_homescreen_view DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS: constructor
      IMPORTING
        !io_home_screen_cntrl TYPE REF TO zcl_ton_homescreen_cntrl ,
      call_home_screen
        RAISING zcx_ton_webshop_exception_new ,
      home_screen_pai
        IMPORTING
          !iv_search_string TYPE string ,
      home_screen_pbo .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: mo_home_screen_cntrl   TYPE REF TO zcl_ton_homescreen_cntrl,
          mo_picture_logo_home_screen TYPE REF TO cl_gui_picture.
ENDCLASS.



CLASS zcl_ton_homescreen_view IMPLEMENTATION.


  METHOD call_home_screen.
    TRY.
        CALL FUNCTION 'ZTON_ITEM_SELECTION'
          EXPORTING
            io_home_screen_view = me.
      CATCH cx_root .
        RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new.
    ENDTRY.
  ENDMETHOD.


  METHOD constructor.

    me->mo_home_screen_cntrl = io_home_screen_cntrl.

  ENDMETHOD.


  METHOD home_screen_pai.

    CASE sy-ucomm.

      WHEN 'LEAVE'.
        me->mo_home_screen_cntrl->on_leave( ).

      WHEN 'BACK'.
        me->mo_home_screen_cntrl->on_back_to_login( ).

      WHEN 'ADD'.
        me->mo_home_screen_cntrl->on_add_product_to_cart( ).

      WHEN 'SHOW'.
        me->mo_home_screen_cntrl->on_show_cart( ).

      WHEN 'SEARCH'.
        me->mo_home_screen_cntrl->on_search_entries_in_table( iv_search_string = iv_search_string ).

      WHEN 'RESET'.
        me->mo_home_screen_cntrl->on_reset_search( ).

      WHEN 'OVERVIEW'.
        me->mo_home_screen_cntrl->on_overview( ).

    ENDCASE.

  ENDMETHOD.


  METHOD home_screen_pbo.

    me->mo_home_screen_cntrl->on_pbo_home_screen( ).

  ENDMETHOD.
ENDCLASS.

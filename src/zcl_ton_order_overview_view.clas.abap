CLASS zcl_ton_order_overview_view DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    DATA: mo_cntrl          TYPE REF TO zcl_ton_order_overview_cntrl,
          mo_grid_order_overview TYPE REF TO cl_gui_alv_grid,
          mo_log                 TYPE REF TO zcl_ton_webshop_log.

    METHODS: call_popup_edit_status
      RAISING
        zcx_ton_webshop_exception_new ,
      call_popup_edit_amount
        RAISING
          zcx_ton_webshop_exception_new ,
      order_overview_pbo ,
      constructor
        IMPORTING
          !io_cntrl TYPE REF TO zcl_ton_order_overview_cntrl OPTIONAL ,
      call_order_overview ,
      order_overview_pai
        RAISING
          zcx_ton_webshop_exception_new ,
      position_overview_pbo ,
      position_overview_pai
        RAISING
          zcx_ton_webshop_exception_new ,
      call_position_overview
        RAISING
          zcx_ton_webshop_exception_new,
      popup_edit_amount_pai
        IMPORTING
          !iv_amount TYPE any .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TON_ORDER_OVERVIEW_VIEW IMPLEMENTATION.


  METHOD call_order_overview.
    CALL FUNCTION 'ZTON_ORDER_VIEW'
      EXPORTING
        im_web_shop = me.
  ENDMETHOD.


  METHOD call_popup_edit_amount.
    TRY.
        CALL FUNCTION 'ZTON_ORDER_EDIT_QUANT'
          EXPORTING
            im_web_shop = me.
      CATCH cx_root .
        RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new.
    ENDTRY.
  ENDMETHOD.


  METHOD call_popup_edit_status.
    TRY.
        CALL FUNCTION 'ZTON_STATUS_POPUP'
          EXPORTING
            im_web_shop = me.
      CATCH cx_root .
        RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new.
    ENDTRY.
  ENDMETHOD.


  METHOD call_position_overview.
    TRY.
        CALL FUNCTION 'ZTON_POSITIONS_OVERVIEW'
          EXPORTING
            im_web_shop = me.
      CATCH cx_root .
        RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new.
    ENDTRY.
  ENDMETHOD.


  METHOD constructor.
    me->mo_cntrl = io_cntrl.

  ENDMETHOD.


  METHOD order_overview_pai.

    TRY.

        CASE sy-ucomm.
          WHEN 'BACK'.
            "passende Methode des Controllers"
            me->mo_cntrl->on_back( ).
          WHEN 'LEAVE'.
            "passende Methode des Controllers
            me->mo_cntrl->on_leave( ).
          WHEN 'SUCHEN'. "Button Suchen des Dynpros (Funktionscode 1000 in Elementliste)
            " Markierte Zeile lesen mit Button
            me->mo_cntrl->on_position( ).
          WHEN 'REFRESH'. "Button Refresh
            me->mo_cntrl->on_refresh( ).
          WHEN 'DELETE'. "Button Bestellung Löschen
            me->mo_cntrl->on_delete( ).
          WHEN OTHERS.
            MESSAGE  i023(zton_shop) INTO DATA(ls_msg).
            me->mo_log->add_msg_from_sys( ).
            me->mo_log->safe_log( ).
            RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
        ENDCASE.
      CATCH zcx_ton_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
      CATCH /auk/cx_vc INTO DATA(auk_text).
        MESSAGE auk_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.


  METHOD order_overview_pbo.
    TRY.
        me->mo_cntrl->on_order_overview_pbo( ).
      CATCH zcx_ton_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.


  METHOD popup_edit_amount_pai.
    TRY.
        CASE sy-ucomm.

          WHEN 'CONFIRM'.
            "Übergabe Daten an an Controller
            me->mo_cntrl->on_edit( iv_wert = iv_amount ).
          WHEN 'BACK'.
            LEAVE TO SCREEN 0.

          WHEN OTHERS.
            "Übergabe Daten an an Controller
            me->mo_cntrl->on_edit( iv_wert = iv_amount ).
        ENDCASE.
      CATCH zcx_ton_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.


  METHOD position_overview_pai.

    TRY.
        CASE sy-ucomm.
          WHEN 'BACK'.
            me->mo_cntrl->on_back( ).
          WHEN 'LEAVE'.
            me->mo_cntrl->on_leave( ).
          WHEN 'DELETE_POSITION'.
            "Löschen einer Position
            me->mo_cntrl->on_delete_position( ).
          WHEN 'EDIT_MENGE'.
            "Ändern einer Bestellmenge
            me->mo_cntrl->on_edit_menge( ).
          WHEN 'EDIT_STATUS'.
            "Ändern des Bestellstatus
            me->mo_cntrl->on_edit_status( ).
          WHEN OTHERS.
            MESSAGE  e023(zton_shop) INTO DATA(ls_msg).
            RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
        ENDCASE.
      CATCH zcx_ton_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.

  ENDMETHOD.


  METHOD position_overview_pbo.
    TRY.
        me->mo_cntrl->on_positions_overview_pbo( ).
      CATCH zcx_ton_webshop_exception_new INTO DATA(e_text).
        MESSAGE e_text->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

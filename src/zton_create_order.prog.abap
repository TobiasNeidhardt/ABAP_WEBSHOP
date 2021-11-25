*&---------------------------------------------------------------------*
*& Report ZTON_CREATE_ORDER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zton_create_order.

PARAMETERS: p_artnum TYPE zton_article_number MATCHCODE OBJECT zton_sh_article OBLIGATORY,
            p_kundid TYPE zton_kd_numr_de MATCHCODE OBJECT zton_sh_customer OBLIGATORY,
            p_amount TYPE zton_order_amount  OBLIGATORY,
            p_bmeins TYPE zton_unit  OBLIGATORY.

CONSTANTS: lc_range_nr       TYPE  nrnr  VALUE '01',
           lc_status_ordered TYPE string VALUE 'BESTELLT',
           lc_status_cart    TYPE string VALUE 'Im Warenkorb'.

DATA: lo_alv          TYPE REF TO   cl_salv_table
      ,ls_order       TYPE          zton_order
      ,lv_bnumber_int TYPE          i
      ,lv_bnumber_chr TYPE          zton_order_number
      ,lt_cart   TYPE TABLE OF zton_order
      ,lo_columns     TYPE REF TO cl_salv_columns_table
      ,lo_column      TYPE REF TO cl_salv_column.


SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (33) FOR FIELD p_amount.

SELECTION-SCREEN END OF LINE.

FIELD-SYMBOLS <fs_cart> TYPE zton_order.

SELECTION-SCREEN:
PUSHBUTTON /2(20) button1 USER-COMMAND add_to_cart , "Zum Warenkorb hinzufügen"
PUSHBUTTON /2(20) button2 USER-COMMAND order, "Bestellung aufgeben"
PUSHBUTTON /2(20) button3 USER-COMMAND show. "Bestellung anzeigen"


INITIALIZATION.
  button1 = TEXT-b01.
  button2 = TEXT-b02.
  button3 = TEXT-b03.

AT SELECTION-SCREEN.
 CASE sy-ucomm.
        WHEN 'ADD_TO_CART'.
      CLEAR ls_order.

      ls_order-unit = p_bmeins.
      ls_order-status = lc_status_cart.
      ls_order-article = p_artnum.
      ls_order-order_amount = p_amount.
      ls_order-customer_number = p_kundid.


      INSERT ls_order INTO TABLE lt_cart.
      IF sy-subrc EQ 0.

        MESSAGE i014(zton_web_shop) WITH p_artnum.

      ELSE.

        MESSAGE e012(zton_web_shop).
      ENDIF.

    WHEN 'ORDER'.
      IF lt_cart IS INITIAL.
        MESSAGE e011(zton_web_shop).
      ELSE.
        CALL FUNCTION 'NUMBER_GET_NEXT'
          EXPORTING
            nr_range_nr = lc_range_nr
            object      = 'ZTON_ORDER'
          IMPORTING
            number      = lv_bnumber_int
          EXCEPTIONS
            OTHERS      = 1.

        IF sy-subrc <> 0.
          MESSAGE e013(zton_web_shop).
        ENDIF.
        lv_bnumber_chr = lv_bnumber_int.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_bnumber_chr
          IMPORTING
            output = lv_bnumber_chr.


        LOOP AT lt_cart ASSIGNING <fs_cart>.
          <fs_cart>-position_number = sy-tabix.

          <fs_cart>-order_number = lv_bnumber_chr.
          <fs_cart>-status = lc_status_ordered.
        ENDLOOP.

        INSERT zton_order FROM TABLE lt_cart.
        IF sy-subrc <> 0.
          MESSAGE e009(zton_web_shop).
        ELSE.
          MESSAGE i010(zton_web_shop).
        ENDIF.

        COMMIT WORK.

        CLEAR:  lt_cart.
      ENDIF.
    WHEN 'SHOW'.
      cl_salv_table=>factory(
      IMPORTING
        r_salv_table   = lo_alv
      CHANGING
        t_table        = lt_cart ).


      DATA(lo_functions) = lo_alv->get_functions( ).
      lo_functions->set_all( abap_false ).
      lo_columns = lo_alv->get_columns( ).
      lo_columns->set_optimize( abap_true ).


      TRY.
          lo_column  = lo_columns->get_column( columnname = 'MANDT'  ).
          lo_column->set_visible( abap_false ).
          lo_column  = lo_columns->get_column( columnname = 'BESTELLNUMMER'  ).
          lo_column->set_visible( abap_false ).
          lo_column  = lo_columns->get_column( columnname = 'POSITIONSNUMMER'  ).
          lo_column->set_visible( abap_false ).


        CATCH cx_salv_not_found.
      ENDTRY.
      lo_alv->display( ).

  ENDCASE.

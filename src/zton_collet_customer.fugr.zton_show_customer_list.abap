FUNCTION ZTON_SHOW_CUSTOMER_LIST.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------
DATA: lt_customer TYPE TABLE OF zton_customer,
      lo_alv        TYPE REF TO   cl_salv_table.

SELECT *
  FROM zton_customer
  INTO TABLE lt_customer.

IF sy-subrc EQ 0.
  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table   = lo_alv
        CHANGING
          t_table        = lt_customer
      ).

      lo_alv->display( ).
    CATCH cx_salv_msg.
  ENDTRY.
  ENDIF.

ENDFUNCTION.

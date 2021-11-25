FUNCTION ZTON_ADD_CUSTOMER.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IS_CUSTOMER) TYPE  ZTON_CUSTOMER
*"----------------------------------------------------------------------

INSERT zton_customer FROM is_customer.
IF sy-subrc EQ 0.
  COMMIT WORK.
  " Neuer Kunde &1 &2 mit Kundennummer &3 angelegt
  MESSAGE i002(zton_web_shop) WITH is_customer-first_name is_customer-name is_customer-customer_number.
ELSE.
  ROLLBACK WORK.
  " fehler ....
  MESSAGE e003(zton_web_shop).
ENDIF.

ENDFUNCTION.

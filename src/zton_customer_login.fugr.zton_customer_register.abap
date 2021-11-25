FUNCTION ZTON_CUSTOMER_REGISTER.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IO_CUSTOMER_REGISTER_VIEW) TYPE REF TO
*"        ZCL_TON_CUSTOMER_REGISTER_VIEW
*"----------------------------------------------------------------------

go_customer_register_view = io_customer_register_view.

CALL SCREEN 9001.

ENDFUNCTION.

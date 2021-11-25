FUNCTION ZTON_ORDER_OVERVIEW.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IO_OVERVIEW_VIEW) TYPE REF TO
*"        ZCL_TON_HOMESCREEN_ORDER_VIEW
*"----------------------------------------------------------------------

 go_order_overview_view = io_overview_view.
 CALL SCREEN 9003.

ENDFUNCTION.

FUNCTION ZTON_EDIT_QUANT .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IM_WEB_SHOP) TYPE REF TO  ZCL_TON_ORDER_OVERVIEW_VIEW
*"----------------------------------------------------------------------

CLEAR go_web_shop.
  go_web_shop = im_web_shop.

CALL SCREEN 9003 STARTING AT 20 10.


ENDFUNCTION.

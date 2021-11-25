FUNCTION ZTON_POSITIONS_OVERVIEW.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IM_WEB_SHOP) TYPE REF TO  ZCL_TON_ORDER_OVERVIEW_VIEW
*"----------------------------------------------------------------------



CLEAR go_web_shop.

go_web_shop = im_web_shop.

call screen 9002.

ENDFUNCTION.

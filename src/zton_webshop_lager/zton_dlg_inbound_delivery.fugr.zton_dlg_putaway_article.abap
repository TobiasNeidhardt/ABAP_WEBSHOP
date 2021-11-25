FUNCTION ZTON_DLG_PUTAWAY_ARTICLE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IO_VIEW) TYPE REF TO  ZCL_TON_INBOUND_DELIVERY_VIEW
*"----------------------------------------------------------------------

  go_putaway_article_view = io_view.

  CALL SCREEN 9001.



ENDFUNCTION.

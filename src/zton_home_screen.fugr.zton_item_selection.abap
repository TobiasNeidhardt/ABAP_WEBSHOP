FUNCTION ZTON_ITEM_SELECTION.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IO_HOME_SCREEN_VIEW) TYPE REF TO  ZCL_TON_HOMESCREEN_VIEW
*"----------------------------------------------------------------------
go_home_screen_view = IO_HOME_SCREEN_VIEW.
CALL SCREEN 9000.

ENDFUNCTION.

*----------------------------------------------------------------------*
***INCLUDE LZTON_DLG_INBOUND_DELIVERYI03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9002 INPUT.
  go_login_view->pai_storage_place( iv_storage_place = gv_lagerplatz ).
ENDMODULE.

*----------------------------------------------------------------------*
***INCLUDE LZTON_ORDER_OVERVIEWI03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9003  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9003 INPUT.
  "Wenn User eine kleinere Bestellmenge als 0 eingibt
  IF p_ein < 0.
    MESSAGE i037(zton_web_shop) INTO DATA(ls_msg).
    RAISE EXCEPTION TYPE zcx_ton_webshop_exception_new USING MESSAGE.
  ELSE.
    go_web_shop->popup_edit_amount_pai( iv_amount = p_ein ).
  ENDIF.
ENDMODULE.

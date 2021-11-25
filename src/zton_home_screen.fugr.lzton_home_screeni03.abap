*----------------------------------------------------------------------*
***INCLUDE LZTON_HOME_SCREENI03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9002 INPUT.

  DATA(ls_order_address) = Value zton_s_adress(  street        = p_street
                                                  houese_number = p_house_number
                                                  zip_code      = p_zip_code
                                                  city          = p_address_city ).

  go_address_view->alternative_address_pai( is_order_address = ls_order_address ).

ENDMODULE.

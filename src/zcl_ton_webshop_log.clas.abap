CLASS zcl_ton_webshop_log DEFINITION
   PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS: constructor
      IMPORTING
        !iv_object TYPE balobj_d
        !iv_suobj  TYPE balsubobj ,
      add_msg
        IMPORTING
          !is_message TYPE bal_s_msg ,
      safe_log ,
      display_log_as_popup,
      add_msg_from_sys.
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: mv_log_handle TYPE balloghndl,
          mt_log_handle TYPE bal_t_logh.

ENDCLASS.



CLASS ZCL_TON_WEBSHOP_LOG IMPLEMENTATION.


  METHOD add_msg.

  ENDMETHOD.


  METHOD add_msg_from_sys.

  ENDMETHOD.


  METHOD constructor.

  ENDMETHOD.


  METHOD display_log_as_popup.

  ENDMETHOD.


  METHOD safe_log.

  ENDMETHOD.
ENDCLASS.

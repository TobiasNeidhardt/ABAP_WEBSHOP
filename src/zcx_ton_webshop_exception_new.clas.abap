CLASS zcx_ton_webshop_exception_new DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES:
      if_t100_dyn_msg ,
      if_t100_message .

    CONSTANTS:
      BEGIN OF object_not_found,
        msgid TYPE symsgid VALUE 'zton_WEB_SHOP',
        msgno TYPE symsgno VALUE '029',
        attr1 TYPE scx_attrname VALUE 'T100_MSGV1',
        attr2 TYPE scx_attrname VALUE 'T100_MSGV2',
        attr3 TYPE scx_attrname VALUE 'T100_MSGV3',
        attr4 TYPE scx_attrname VALUE 'T100_MSGV4',
      END OF object_not_found .
    CONSTANTS:
      BEGIN OF alv_not_able_to_create,
        msgid TYPE symsgid VALUE 'zton_WEB_SHOP',
        msgno TYPE symsgno VALUE '022',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF alv_not_able_to_create .
    CONSTANTS:
      BEGIN OF order_not_found,
        msgid TYPE symsgid VALUE 'zton_WEB_SHOP',
        msgno TYPE symsgno VALUE '025',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF order_not_found .
    CONSTANTS:
      BEGIN OF positions_not_found,
        msgid TYPE symsgid VALUE 'zton_WEB_SHOP',
        msgno TYPE symsgno VALUE '030',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF positions_not_found .

    METHODS: constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous OPTIONAL ,
      get_message
        RETURNING
          VALUE(rs_msg) TYPE bal_s_msg .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_ton_webshop_exception_new IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.


  METHOD get_message.
    rs_msg = VALUE #( msgty = sy-msgty
                  msgid = sy-msgid
                  msgno = sy-msgno
                  msgv1 = sy-msgv1
                  msgv2 = sy-msgv2
                  msgv3 = sy-msgv3
                  msgv4 = sy-msgv4 ).
  ENDMETHOD.
ENDCLASS.

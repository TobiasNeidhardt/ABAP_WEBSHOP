FUNCTION ZTON_SHOW_ARTICLE_LIST.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------
DATA: lt_article         TYPE TABLE OF  zton_article,
      lo_alv            TYPE REF TO    cl_salv_table.

SELECT *
  FROM zton_article
  INTO TABLE lt_article.

IF sy-subrc EQ 0.
  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table   = lo_alv
        CHANGING
          t_table        = lt_article
      ).

      lo_alv->display( ).
    CATCH cx_salv_msg.
  ENDTRY.

ELSEIF sy-subrc <> 0.
  " nachrichtnetext
  MESSAGE e004(zton_web_shop).
ENDIF.
ENDFUNCTION.

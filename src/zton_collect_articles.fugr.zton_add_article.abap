FUNCTION ZTON_ADD_ARTICLE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IS_ARTICLE) TYPE  ZTON_ARTICLE
*"----------------------------------------------------------------------
INSERT zton_article FROM is_article.

IF sy-subrc EQ 0.
  COMMIT WORK.
  " Neuer Artikel &1 &2 mit Artikelnummer &3 angelegt
  MESSAGE i006(zton_web_shop) WITH is_article-designation is_article-price is_article-article_number.
ELSE.
  ROLLBACK WORK.
  " fehler ....
  MESSAGE e005(zton_web_shop).
ENDIF.
ENDFUNCTION.

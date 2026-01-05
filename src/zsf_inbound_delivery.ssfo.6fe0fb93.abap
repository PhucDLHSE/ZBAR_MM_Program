DATA: lv_matnr TYPE matnr,
      lv_mat_desc TYPE makt-maktx.

lv_matnr = ls_lips-matnr.
CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
  EXPORTING
    input  = lv_matnr
  IMPORTING
    output = lv_matnr.

SELECT SINGLE maktx
  INTO lv_mat_desc
  FROM makt
 WHERE matnr = lv_matnr
   AND spras = 'E'.   " E = English language

IF sy-subrc <> 0.
  lv_mat_desc = ls_lips-arktx. " fallback nếu không có tiếng Anh
ENDIF.

gv_mat_desc = lv_mat_desc.
























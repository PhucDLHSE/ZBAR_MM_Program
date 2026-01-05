*---------------------------------------------------------------------*
* Include ZG21_RES_INPUT_PPPLSEL
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_rsnum FOR resb-rsnum,         " Reservation Number
  s_matnr FOR resb-matnr,         " Material
  s_werks FOR resb-werks,         " Plant
  s_bdter FOR resb-bdter,         " Requirement Date
  s_kdauf FOR resb-kdauf.         " Sales Order
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN SKIP.

  SELECTION-SCREEN BEGIN OF BLOCK printmode WITH FRAME TITLE TEXT-003.
    PARAMETERS: p_prev RADIOBUTTON GROUP pm DEFAULT 'X',
                p_prnt RADIOBUTTON GROUP pm.
  SELECTION-SCREEN END OF BLOCK printmode.

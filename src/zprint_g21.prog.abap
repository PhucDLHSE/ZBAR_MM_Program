*&---------------------------------------------------------------------*
*& Report ZPRINT_G21
*&---------------------------------------------------------------------*
REPORT zprint_g21.

DATA: lv_program TYPE sy-repid.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: r_ib RADIOBUTTON GROUP rg1 DEFAULT 'X',
              r_od RADIOBUTTON GROUP rg1,
              r_pi RADIOBUTTON GROUP rg1,
              r_rs RADIOBUTTON GROUP rg1.
SELECTION-SCREEN END OF BLOCK blk1.

AT SELECTION-SCREEN.


  IF r_ib = 'X'.
    lv_program = 'ZSF_IN_178'.
  ELSEIF r_od = 'X'.
    lv_program = 'ZSF_OD_PROGRAM_181'.
  ELSEIF r_pi = 'X'.
    lv_program = 'ZSF_PI_181'.
  ELSEIF r_rs = 'X'.
    lv_program = 'ZSF_RS_PROGRAM_181'.
  ELSE.
    MESSAGE 'Vui lòng chọn một loại form để in!' TYPE 'E'.
  ENDIF.

  IF lv_program IS NOT INITIAL.
    SUBMIT (lv_program) VIA SELECTION-SCREEN AND RETURN.
  ENDIF.

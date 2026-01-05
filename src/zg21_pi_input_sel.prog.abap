*&---------------------------------------------------------------------*
*& Include ZG21_PI_INPUT_SEL - Selection Screen (Physical Inventory)
*&---------------------------------------------------------------------*

* A. Selection Screen

INITIALIZATION.
* Không cần mặc định giá trị

  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
    SELECT-OPTIONS:
      rg_iblnr FOR ikpf-iblnr,          "Physical Inventory Document
      rg_gjahr FOR ikpf-gjahr,          "Fiscal Year
      rg_werks FOR ikpf-werks,          "Plant
      rg_lgort FOR ikpf-lgort.          "Storage Location
  SELECTION-SCREEN END OF BLOCK b1.

  SELECTION-SCREEN SKIP.

  SELECTION-SCREEN BEGIN OF BLOCK printmode WITH FRAME TITLE TEXT-003.
    PARAMETERS: p_prev RADIOBUTTON GROUP pm DEFAULT 'X',
                p_prnt RADIOBUTTON GROUP pm.
  SELECTION-SCREEN END OF BLOCK printmode.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR rg_iblnr-low.
  PERFORM f4_iblnr.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR rg_iblnr-high.
  PERFORM f4_iblnr.

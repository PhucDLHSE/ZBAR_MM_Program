*&---------------------------------------------------------------------*
*& Include          ZSF_OD_SS_181
*&---------------------------------------------------------------------*

TABLES: likp.
*----------------------------------------------------------*
* Selection screen
*----------------------------------------------------------*
*SELECT-OPTIONS: s_vbeln FOR ls_likp-vbeln.

SELECTION-SCREEN BEGIN OF BLOCK delivery WITH FRAME TITLE TEXT-002.
  SELECT-OPTIONS:
* Outbound Delivery (LIKP-VBELN)
    rg_vbeln FOR likp-vbeln,
* Customer (LIKP-KUNNR)
    rg_kunnr FOR likp-kunnr,
* Delivery Date (LIKP-LFDAT)
    rg_erdat FOR likp-erdat,
* Shipping Point / Receiving Plant (LIKP-VSTEL)
    rg_vstel FOR likp-vstel.
SELECTION-SCREEN END OF BLOCK delivery.

SELECTION-SCREEN SKIP. " tang khoang cach giua 2 selection screen

SELECTION-SCREEN BEGIN OF BLOCK b_print WITH FRAME TITLE TEXT-900.
  PARAMETERS:
    p_prev RADIOBUTTON GROUP g1 DEFAULT 'X' USER-COMMAND mode, " Print Preview
    p_prnt RADIOBUTTON GROUP g1.                             " Print thật
SELECTION-SCREEN END OF BLOCK b_print.

AT SELECTION-SCREEN.

  PERFORM validate_inputs.
  " Kiểm tra nếu tất cả đều trống


AT SELECTION-SCREEN ON VALUE-REQUEST FOR rg_vbeln-low.
  PERFORM f4_vbeln.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR rg_vbeln-high.
  PERFORM f4_vbeln.

*&---------------------------------------------------------------------*
*& Include ZG21_INB_INPUT_TOP - Global Data Declaration (ĐÃ CẬP NHẬT)
*&---------------------------------------------------------------------*

* dictionary (tables / structures )
TABLES: likp.

DATA: BEGIN OF lt_likp OCCURS 100, " occurs de define lt_likp la internal table
        vbeln LIKE likp-vbeln,
        vstel LIKE likp-vstel,
        lifnr LIKE likp-lifnr,
        lfdat LIKE likp-lfdat,
        lifex LIKE likp-lifex,
      END OF lt_likp.

DATA: BEGIN OF lt_lips OCCURS 100,
        vbeln LIKE lips-vbeln,
        werks LIKE lips-werks,
        lgort LIKE lips-lgort,
      END OF lt_lips.

* Các biến mới cho việc SUBMIT Smartform
DATA: lt_submit_params TYPE STANDARD TABLE OF rsparams,
      lt_vbeln         TYPE STANDARD TABLE OF likp-vbeln, " Danh sách VBELN duy nhất
      lv_vbeln         TYPE likp-vbeln.

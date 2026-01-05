*&---------------------------------------------------------------------*
*& Include ZG21_OUTB_INPUT_TOP - Global Data Declaration (Outbound - FINAL)
*&---------------------------------------------------------------------*

* dictionary (tables / structures )
TABLES: likp.

DATA: BEGIN OF lt_likp OCCURS 100,
        vbeln LIKE likp-vbeln, " delivery
        vstel LIKE likp-vstel, " shipping point
        kunnr LIKE likp-kunnr, " ship to party
        lfdat LIKE likp-lfdat, " delivery date
      END OF lt_likp.

DATA: BEGIN OF lt_lips OCCURS 100,
        vbeln LIKE lips-vbeln,
        werks LIKE lips-werks,
        lgort LIKE lips-lgort,
      END OF lt_lips.

* Các biến cho việc SUBMIT Smartform
DATA: lt_submit_params TYPE STANDARD TABLE OF rsparams,
      lt_vbeln         TYPE STANDARD TABLE OF likp-vbeln, " Danh sách VBELN duy nhất
      lv_vbeln         TYPE likp-vbeln.

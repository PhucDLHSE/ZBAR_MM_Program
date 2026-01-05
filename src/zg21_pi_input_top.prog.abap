*&---------------------------------------------------------------------*
*& Include ZG21_PI_INPUT_TOP - Global Data Declaration (Physical Inventory)
*&---------------------------------------------------------------------*

CONSTANTS: actvt(2) VALUE '04',
           true     VALUE 'X',
           false    VALUE ' '.

* Dictionary tables
TABLES: ikpf.

* Internal tables
DATA: BEGIN OF it_ikpf OCCURS 100,
        iblnr LIKE ikpf-iblnr,  " Physical Inventory Document
        gjahr LIKE ikpf-gjahr,  " Fiscal Year
        werks LIKE ikpf-werks,  " Plant
        lgort LIKE ikpf-lgort,  " Storage Location
      END OF it_ikpf.

* Fields
DATA: repid LIKE sy-repid,
      tabix TYPE i.

* Các biến cho việc SUBMIT Smartform
DATA: lt_submit_params TYPE STANDARD TABLE OF rsparams,
      lt_IBLNR         TYPE STANDARD TABLE OF ikpf-iblnr,
      lv_IBLNR         TYPE ikpf-iblnr.

*&---------------------------------------------------------------------*
*& Include          ZBAR_MM_G21_T01
*&---------------------------------------------------------------------*
" data for GR
DATA: gv_select         TYPE i,
      gv_matdoc         TYPE mblnr,
      gv_matyear        TYPE mjahr,
      gv_matdoc_rev     TYPE mblnr,
      gv_matyear_rev    TYPE mjahr,
      gv_matdoc_posted  TYPE mblnr,
      gv_matyear_posted TYPE mjahr,
      gv_matdoc_issue   TYPE mblnr,
      gv_matyear_issue  TYPE mjahr,
      ok_code           TYPE sy-ucomm.

DATA: gv_pono     TYPE ekko-ebeln.


DATA: lv_field TYPE fieldname, " chi dinh field name và field value cho event click vao matdoc rev và posted
      lv_value TYPE string.

DATA: gv_disp_qty TYPE char20.
DATA gv_valid_po TYPE abap_bool.
DATA: gv_valid_werks TYPE abap_bool VALUE abap_true.
DATA: gv_valid_inbound TYPE abap_bool VALUE abap_true.

DATA: gv_flag_reverse TYPE xfeld.


TYPES: BEGIN OF ty_ekpo,
         ebeln TYPE ekpo-ebeln,
         ebelp TYPE ekpo-ebelp,
         matnr TYPE ekpo-matnr,
         menge TYPE ekpo-menge,
         meins TYPE ekpo-meins,
       END OF ty_ekpo.

TYPES: BEGIN OF ty_inbound,
         sel              TYPE ce_mark,
         vbeln            TYPE lips-vbeln,    " Inbound Delivery number posnr, matnr
         posnr            TYPE lips-posnr,
         matnr            TYPE lips-matnr,
         lfimg            TYPE lips-lfimg,    " Delivery quantity
         vrkme            TYPE lips-vrkme,
         lgmng            TYPE lips-lgmng,
         meins            TYPE lips-meins,    " UOM
         lfimg_flo        TYPE lips-lfimg_flo,
         lgmng_flo        TYPE lips-lgmng_flo,
         umvkz            TYPE lips-umvkz,
         umvkn            TYPE lips-umvkn,
         umrev            TYPE lips-umrev,
         werks            TYPE lips-werks,
         charg            TYPE lips-charg,
         lgort            TYPE lips-lgort,    " Storage location
         vgbel            TYPE lips-vgbel,
         vgpos            TYPE lips-vgpos,
         wbsta            TYPE lips-wbsta, " goods movement status
         charg_ip         TYPE lips-charg,
         sernr_ip         TYPE equi-sernr,
         sernr            TYPE equi-sernr,
         pikmg            TYPE lipsd-pikmg, "putaway quantity
         matdoc_posted    TYPE mblnr,   "New Matdoc
         matyear_posted   TYPE mjahr,
         matyear_disp     TYPE char4,
       END OF ty_inbound.

TYPES: BEGIN OF ty_vbkok,
         vbeln_vl TYPE vbkok-vbeln_vl,
       END OF ty_vbkok.

TYPES: BEGIN OF ty_vbpok,
         vbeln_vl  TYPE vbpok-vbeln_vl,    " Inbound Delivery number posnr, matnr
         posnr_vl  TYPE vbpok-posnr_vl,
         matnr     TYPE vbpok-matnr,
         lfimg     TYPE vbpok-lfimg,    " Delivery quantity
         vrkme     TYPE vbpok-vrkme,    " UOM
         lgmng     TYPE vbpok-lgmng,
         meins     TYPE vbpok-meins,
         lfimg_flo TYPE vbpok-lfimg_flo,
         lgmng_flo TYPE vbpok-lgmng_flo,
         umvkz     TYPE vbpok-umvkz,
         umvkn     TYPE vbpok-umvkn,
         umrev     TYPE vbpok-umrev,
         werks     TYPE vbpok-werks,
         charg     TYPE vbpok-charg,
         charg_ip  TYPE vbpok-charg,
         lgort     TYPE vbpok-lgort,    " Storage location
         vbtyp_n   TYPE vbpok-vbtyp_n,
         ebumg_bme TYPE vbpok-ebumg_bme,
         sernr     TYPE equi-sernr,
         pikmg     TYPE vbpok-pikmg,
       END OF ty_vbpok.


DATA:
      lt_ekpo    TYPE TABLE OF ty_ekpo,
      ls_ekpo    TYPE ty_ekpo,
      lt_inbound TYPE TABLE OF ty_inbound,
      ls_inbound TYPE ty_inbound,
      lt_vbkok   TYPE TABLE OF ty_vbkok,
      ls_vbkok   TYPE ty_vbkok,
      lt_vbpok   TYPE TABLE OF ty_vbpok,
      ls_vbpok   TYPE ty_vbpok.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TCTR_INBOU_DL21' ITSELF
CONTROLS: tctr_inbou_dl21 TYPE TABLEVIEW USING SCREEN 2011.

*&SPWIZARD: LINES OF TABLECONTROL 'TCTR_INBOU_DL21'
DATA:     g_tctr_inbou_dl21_lines  LIKE sy-loopc.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TCTR_INBOU_SG21' ITSELF
CONTROLS: tctr_inbou_sg21 TYPE TABLEVIEW USING SCREEN 2021.

*&SPWIZARD: LINES OF TABLECONTROL 'TCTR_INBOU_SG21'
DATA:     g_tctr_inbou_sg21_lines  LIKE sy-loopc.

"========================================================================
" GLOBAL DATA FOR PI PROCESS

DATA: gv_iblnr    TYPE iblnr,
      gv_zeili    TYPE dzeile,
      gv_matnr    TYPE char18,
      gv_werks_pi TYPE werks_d,
      gv_lgort_pi TYPE lgort_d,
      gv_menge    TYPE menge_d,
*      gv_menge    TYPE i_erfmg,
      gv_xnull    TYPE xnull,
      gv_sernr_pi TYPE gernr.

DATA: gv_valid_iblnr TYPE abap_bool,
      gv_has_item    TYPE abap_bool. " get item có recount = '' if no item thì show message ngay screen input

TYPES: BEGIN OF ty_ikpf,
         iblnr TYPE ikpf-iblnr,
       END OF ty_ikpf.

TYPES: BEGIN OF ty_iseg,
         sel        TYPE ce_mark,
         iblnr      TYPE iseg-iblnr,    " Inbound Delivery number posnr, matnr
         gjahr      TYPE iseg-gjahr,
         zeili      TYPE iseg-zeili,
         matnr      TYPE iseg-matnr,    " Delivery quantity
         werks      TYPE iseg-werks,
         lgort      TYPE iseg-lgort,
         charg      TYPE iseg-charg,    " UOM
         sernr      TYPE gernr,
         bstar      TYPE iseg-bstar,
         sobkz      TYPE iseg-sobkz,
         menge      TYPE iseg-menge,
         menge_disp TYPE char10,
         diff_quan  TYPE menge_d,
         diff_disp  TYPE char10,
         meins      TYPE iseg-meins,
         xnull      TYPE iseg-xnull,
         xzael      TYPE iseg-xzael,
         xnzae      TYPE iseg-xnzae,
         nblnr      TYPE iseg-nblnr,
         buchm      TYPE iseg-buchm,
         xdiff      TYPE iseg-xdiff,
       END OF ty_iseg.

DATA: lt_ikpf TYPE TABLE OF ty_ikpf,
      lt_iseg TYPE TABLE OF ty_iseg,
      ls_iseg TYPE ty_iseg.

"========================================================================
"=== GLOBAL DATA FOR RESERVATION PROCESS ===
DATA gv_valid_reser TYPE abap_bool.
" data for GI
DATA: gv_vbeln  TYPE vbak-vbeln, "SO Number (Header)
      gv_matnr1 TYPE vbap-matnr, "Material Number (Item Data)
      gv_charg  TYPE vbap-charg, "Batch
      gv_kwmeng TYPE vbap-kwmeng, "Quantity
      gv_meins  TYPE vbap-meins,
      gv_werks  TYPE vbap-werks, "Plant
      gv_lgort  TYPE vbap-lgort, "Storage Location
      gv_sernr  TYPE equi-sernr, "Serial Number

      gv_rsnum  TYPE rkpf-rsnum, "Reservation Number
      gv_rsnum_rep    TYPE char10.

" Header Reservation
TYPES: BEGIN OF ty_rkpf,
         rsnum TYPE rkpf-rsnum,
       END OF ty_rkpf.

" Reservation Item
TYPES: BEGIN OF ty_resb,
         sel          TYPE c LENGTH 1,
         rsnum        TYPE resb-rsnum,
         rspos        TYPE resb-rspos,
         matnr        TYPE resb-matnr,
         werks        TYPE resb-werks,
         lgort        TYPE resb-lgort,
         erfmg        TYPE resb-erfmg,
         erfme        TYPE resb-erfme,
         charg        TYPE resb-charg,
         sernr        TYPE equi-sernr,
         matdoc       TYPE mblnr,
         matyear      TYPE mjahr,
         matyear_disp TYPE char4,
         kzear        TYPE kzear,
       END OF ty_resb.

DATA: gt_resb TYPE STANDARD TABLE OF ty_resb,
      gs_resb TYPE ty_resb,
      gt_rkpf TYPE STANDARD TABLE OF ty_rkpf,
      gs_rkpf TYPE ty_rkpf.


"========================================================================
"=== GLOBAL DATA FOR GOOD ISSUE-OUTBOUND DELIVERY PROCESS ===
DATA: gv_sono     TYPE vbak-vbeln,
      gv_sono_rep TYPE vbak-vbeln,
      gv_vbeln_re TYPE likp-vbeln.

DATA gv_valid_sono TYPE abap_bool.
DATA: gv_valid_outbound TYPE abap_bool VALUE abap_true.

TYPES: BEGIN OF ty_vbak,
         vbeln TYPE vbak-vbeln,
       END OF ty_vbak.

TYPES: BEGIN OF ty_vbap,
         vbeln  TYPE vbap-vbeln,
         posnr  TYPE vbap-posnr,
         matnr  TYPE vbap-matnr,
         kwmeng TYPE vbap-kwmeng,
         vrkme  TYPE vbap-vrkme,
       END OF ty_vbap.

TYPES: BEGIN OF ty_outbound,
         sel            TYPE char1,
         vbeln          TYPE lips-vbeln,    " Outbound Delivery number posnr, matnr
         posnr          TYPE lips-posnr,
         matnr          TYPE lips-matnr,
         lfimg          TYPE lips-lfimg,    " Delivery quantity
         vrkme          TYPE lips-vrkme,
         lgmng          TYPE lips-lgmng,
         meins          TYPE lips-meins,    " UOM
         lfimg_flo      TYPE lips-lfimg_flo,
         lgmng_flo      TYPE lips-lgmng_flo,
         umvkz          TYPE lips-umvkz,
         umvkn          TYPE lips-umvkn,
         umrev          TYPE lips-umrev,
         werks          TYPE lips-werks,
         charg          TYPE lips-charg,
         lgort          TYPE lips-lgort,    " Storage location
         vgbel          TYPE lips-vgbel,
         vgpos          TYPE lips-vgpos,
         wbsta          TYPE lips-wbsta,    " goods movement status
         charg_ip       TYPE lips-charg,
         sernr_ip       TYPE equi-sernr,
         sernr          TYPE equi-sernr,
         pikmg          TYPE lipsd-pikmg, "putaway quantity
*         pstyv          TYPE lips-pstyv,
         matdoc_posted  TYPE mblnr,   "New Matdoc
         matyear_posted TYPE mjahr,
         matyear_disp   TYPE char4,
       END OF ty_outbound.

TYPES: BEGIN OF ty_vbkok_outbound,
         vbeln_vl  TYPE vbkok-vbeln_vl,
         wadat_ist TYPE vbkok-wadat_ist, " Ngày thực tế Post GI
         wause     TYPE c LENGTH 1,
       END OF ty_vbkok_outbound.

TYPES: BEGIN OF ty_vbpok_outbound,
         vbeln_vl  TYPE vbpok-vbeln_vl,    " Outbound Delivery number posnr, matnr
         posnr_vl  TYPE vbpok-posnr_vl,
         matnr     TYPE vbpok-matnr,
         lfimg     TYPE vbpok-lfimg,    " Delivery quantity
         vrkme     TYPE vbpok-vrkme,    " UOM
         lgmng     TYPE vbpok-lgmng,
         meins     TYPE vbpok-meins,
         lfimg_flo TYPE vbpok-lfimg_flo,
         lgmng_flo TYPE vbpok-lgmng_flo,
         umvkz     TYPE vbpok-umvkz,
         umvkn     TYPE vbpok-umvkn,
         umrev     TYPE vbpok-umrev,
         werks     TYPE vbpok-werks,
         charg     TYPE vbpok-charg,
         charg_ip  TYPE vbpok-charg,
         lgort     TYPE vbpok-lgort,    " Storage location
         vbtyp_n   TYPE vbpok-vbtyp_n,
         ebumg_bme TYPE vbpok-ebumg_bme,
         sernr     TYPE equi-sernr,
         pikmg     TYPE vbpok-pikmg,

       END OF ty_vbpok_outbound.


DATA: lt_vbak           TYPE TABLE OF ty_vbak,
      ls_vbak           TYPE ty_vbak,
      lt_vbap           TYPE TABLE OF ty_vbap,
      ls_vbap           TYPE ty_vbap,
      lt_outbound       TYPE TABLE OF ty_outbound,
      ls_outbound       TYPE ty_outbound,
      lt_vbkok_outbound TYPE TABLE OF ty_vbkok_outbound,
      ls_vbkok_outbound TYPE ty_vbkok_outbound,
      lt_vbpok_outbound TYPE TABLE OF ty_vbpok_outbound,
      ls_vbpok_outbound TYPE ty_vbpok_outbound.


"=== TABLE CONTROL ===

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_RESERVATION' ITSELF
CONTROLS: tc_reservation TYPE TABLEVIEW USING SCREEN 3021.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_RESERVATION'
DATA:     g_tc_reservation_lines  LIKE sy-loopc.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_OUT_DL21' ITSELF
CONTROLS: tc_out_dl21 TYPE TABLEVIEW USING SCREEN 3011.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_OUT_DL21'
DATA:     g_tc_out_dl21_lines  LIKE sy-loopc.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_OUT_SG21' ITSELF
CONTROLS: tc_out_sg21 TYPE TABLEVIEW USING SCREEN 3013.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_OUT_SG21'
DATA:     g_tc_out_sg21_lines  LIKE sy-loopc.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_PI_RECNT' ITSELF
CONTROLS: tc_pi_recnt TYPE TABLEVIEW USING SCREEN 0404.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_PI_RECNT'
DATA:     g_tc_pi_recnt_lines  LIKE sy-loopc.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_COUNT_PI' ITSELF
CONTROLS: tc_count_pi TYPE TABLEVIEW USING SCREEN 0402.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_COUNT_PI'
DATA:     g_tc_count_pi_lines  LIKE sy-loopc.

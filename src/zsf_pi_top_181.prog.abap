*&---------------------------------------------------------------------*
*& Include          ZSF_OD_TOP_181
*&---------------------------------------------------------------------*

*----------------------------------------------------------*
* Type declarations
*----------------------------------------------------------*
* Items
TYPES: BEGIN OF ty_ikpf,
         iblnr TYPE ikpf-iblnr,
         lgort TYPE ikpf-lgort,
         gjahr TYPE ikpf-gjahr,
         werks TYPE ikpf-werks,
       END OF ty_ikpf.

* Header
TYPES: BEGIN OF ty_iseg,
         iblnr TYPE iseg-iblnr,
         gjahr TYPE iseg-gjahr,
         matnr TYPE iseg-matnr,
         menge TYPE iseg-menge,
         charg TYPE iseg-charg,
         werks TYPE iseg-werks,
         lgort TYPE iseg-lgort,
         xzael TYPE iseg-xzael,
         disp_menge TYPE char20,
       END OF ty_iseg.

TYPES: BEGIN OF ty_header,
         iblnr TYPE ikpf-iblnr,
         lgort TYPE ikpf-lgort,
         gjahr TYPE ikpf-gjahr,
         werks TYPE ikpf-werks,
         matnr TYPE iseg-matnr,
       END OF ty_header.

TYPES: BEGIN OF ty_item,
         iblnr TYPE iseg-iblnr,
         gjahr TYPE iseg-gjahr,
         matnr TYPE iseg-matnr,
         menge TYPE iseg-menge,
         charg TYPE iseg-charg,
         werks TYPE iseg-werks,
         lgort TYPE iseg-lgort,
         xzael TYPE iseg-xzael,
         disp_menge TYPE char20,
         sernr TYPE equi-sernr,
       END OF ty_item.

*----------------------------------------------------------*
* Data declarations
*----------------------------------------------------------*
DATA: lv_fname              TYPE rs38l_fnam,
      ls_control_parameters TYPE ssfctrlop,
      ls_output_options     TYPE ssfcompop,
      ls_job_output_info    TYPE ssfcrescl,
      lt_ikpf               TYPE TABLE OF ty_ikpf,
      ls_ikpf               TYPE ty_ikpf,
      lt_iseg               TYPE TABLE OF ty_iseg,
      ls_iseg               TYPE ty_iseg,
      lt_header             TYPE TABLE OF ty_header,
      ls_header             TYPE ty_header,
      lt_item               TYPE TABLE OF ty_item,
      ls_item               TYPE ty_item,
      gv_form_count         TYPE i VALUE 0.

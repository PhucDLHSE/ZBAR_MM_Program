*&---------------------------------------------------------------------*
*& Include          ZSF_OD_TOP_181
*&---------------------------------------------------------------------*

*----------------------------------------------------------*
* Type declarations
*----------------------------------------------------------*
* Items
TYPES: BEGIN OF ty_lips,
         vbeln TYPE lips-vbeln,
         posnr TYPE lips-posnr,
         matnr TYPE lips-matnr,
         arktx TYPE lips-arktx,
         lfimg TYPE lips-lfimg,
         meins TYPE lips-meins,
         charg TYPE lips-charg,
         werks TYPE lips-werks,
         lgort TYPE lips-lgort,
       END OF ty_lips.

* Header
TYPES: BEGIN OF ty_likp,
         vbeln TYPE likp-vbeln,  "Số chứng từ giao hàng
         kunnr TYPE likp-kunnr,  "Mã khách hàng
         erdat TYPE likp-erdat,  "Ngày tạo
       END OF ty_likp.

TYPES: BEGIN OF ty_header,
         vbeln TYPE likp-vbeln,  "Số chứng từ giao hàng
         kunnr TYPE likp-kunnr,  "Mã khách hàng
         erdat TYPE likp-erdat,  "Ngày tạo
         werks TYPE lips-werks,
       END OF ty_header.

TYPES: BEGIN OF ty_item,
         vbeln TYPE lips-vbeln,
         posnr TYPE lips-posnr,
         matnr TYPE lips-matnr,
         arktx TYPE lips-arktx,
         lfimg TYPE lips-lfimg,
         meins TYPE lips-meins,
         charg TYPE lips-charg,
         werks TYPE lips-werks,
         lgort TYPE lips-lgort,
       END OF ty_item.

*----------------------------------------------------------*
* Data declarations
*----------------------------------------------------------*
DATA: lv_fname              TYPE rs38l_fnam,
      ls_control_parameters TYPE ssfctrlop,
      ls_output_options     TYPE ssfcompop,
      ls_job_output_info    TYPE ssfcrescl,
      lt_likp               TYPE TABLE OF ty_likp,
      ls_likp               TYPE ty_likp,
      lt_lips               TYPE TABLE OF ty_lips,
      ls_lips               TYPE ty_lips,
      lt_header             TYPE TABLE OF ty_header,
      ls_header             TYPE ty_header,
      lt_item               TYPE TABLE OF ty_item,
      ls_item               TYPE ty_item,
      gv_form_count         TYPE i VALUE 0.

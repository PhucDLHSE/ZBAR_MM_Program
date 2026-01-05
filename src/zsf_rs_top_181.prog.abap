*&---------------------------------------------------------------------*
*& Include          ZSF_RS_TOP_181
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_rkpf,
         rsnum TYPE rkpf-rsnum,
         bwart TYPE rkpf-bwart,
         rsdat TYPE rkpf-rsdat,
         usnam TYPE rkpf-usnam,
       END OF ty_rkpf.


TYPES: BEGIN OF ty_resb,
         rsnum TYPE resb-rsnum,
         rspos TYPE resb-rspos,
         matnr TYPE resb-matnr,
         werks TYPE resb-werks,
         lgort TYPE resb-lgort,
         charg TYPE resb-charg,
         bdmng TYPE resb-bdmng,
         meins TYPE resb-meins,
       END OF ty_resb.

TYPES: BEGIN OF ty_makt,
         matnr TYPE makt-matnr,
         maktx TYPE makt-maktx,
       END OF ty_makt.

TYPES: BEGIN OF ty_header,
         rsnum TYPE rkpf-rsnum,
         bwart TYPE rkpf-bwart,
         rsdat TYPE rkpf-rsdat,
         usnam TYPE rkpf-usnam,
         werks TYPE resb-werks,
       END OF ty_header.

TYPES: BEGIN OF ty_item,
         rsnum TYPE resb-rsnum,
         matnr TYPE resb-matnr,
         maktx TYPE makt-maktx,
         werks TYPE resb-werks,
         lgort TYPE resb-lgort,
         charg TYPE resb-charg,
         bdmng TYPE resb-bdmng,
         meins TYPE resb-meins,
       END OF ty_item.

*----------------------------------------------------------*
* Data declarations
*----------------------------------------------------------*
DATA: lv_fname              TYPE rs38l_fnam,
      ls_control_parameters TYPE ssfctrlop,
      ls_output_options     TYPE ssfcompop,
      ls_job_output_info    TYPE ssfcrescl,
      lt_rkpf               TYPE TABLE OF ty_rkpf,
      ls_rkpf               TYPE ty_rkpf,
      lt_resb               TYPE TABLE OF ty_resb,
      ls_resb               TYPE ty_resb,
      lt_makt               TYPE TABLE OF ty_makt,
      ls_makt               TYPE ty_makt,
      lt_header             TYPE TABLE OF ty_header,
      ls_header             TYPE ty_header,
      lt_item               TYPE TABLE OF ty_item,
      ls_item               TYPE ty_item,
      gv_form_count         TYPE i VALUE 0.

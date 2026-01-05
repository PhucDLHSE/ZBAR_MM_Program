*&---------------------------------------------------------------------*
*& Include          ZBAR_MM_G21_F01
*&---------------------------------------------------------------------*
FORM main_chosen.
  CASE gv_select.
    WHEN 1.
      CLEAR gv_select.
      CALL SCREEN 0200. " FOR GR
    WHEN 2.
      CLEAR gv_select.
      CALL SCREEN 0300. " FOR GI
    WHEN 3.
      CLEAR gv_select.
      CALL SCREEN 0400. " FOR PI
    WHEN OTHERS.
*      MESSAGE 'Please enter 1, 2, or 3 only!' TYPE 'S' DISPLAY LIKE 'E'.
      MESSAGE s035(zms_mm_g21) DISPLAY LIKE 'E'.
      SET CURSOR FIELD 'GV_SELECT'.
      EXIT.
  ENDCASE.

  CLEAR gv_select.
ENDFORM.

FORM gr_chosen.
  CASE gv_select.
    WHEN 1.
      CLEAR gv_select.
      CALL SCREEN 0201. " RECEIVING PLANT
    WHEN 2.
      CLEAR gv_select.
      CALL SCREEN 0202. " REVERSE GR
    WHEN OTHERS.
*      MESSAGE 'Please entere 1,2 only!' TYPE 'S' DISPLAY LIKE 'E'.
      MESSAGE s001(zms_mm_g21) DISPLAY LIKE 'E'.
      SET CURSOR FIELD 'GV_SELECT'.
      EXIT.
  ENDCASE.
  CLEAR gv_select.
ENDFORM.

FORM gr201_chosen.
  CASE gv_select.
    WHEN 1.
      CLEAR gv_select.
      CALL SCREEN 2010. " PLANT DL21
    WHEN 2.
      CLEAR gv_select.
      CALL SCREEN 2020. " PLANT SG21
    WHEN OTHERS.
*      MESSAGE 'Please entere 1,2 only!' TYPE 'S' DISPLAY LIKE 'E'.
      MESSAGE s001(zms_mm_g21) DISPLAY LIKE 'E'.
      SET CURSOR FIELD 'GV_SELECT'.
      EXIT.
  ENDCASE.
  CLEAR gv_select.
ENDFORM.

FORM gr300_chosen .
  CASE gv_select.
    WHEN 1.
      CLEAR gv_select.
      CALL SCREEN 301. " POST GI FOR SO
    WHEN 2.
      CLEAR gv_select.
      CALL SCREEN 302. " POST GI FOR RESER
    WHEN 3.
      CLEAR gv_select.
      CALL SCREEN 303. " RESERVE OUTBOUND
    WHEN 4.
      CLEAR gv_select.
      CALL SCREEN 304. " RESERVE RESER
    WHEN OTHERS.
      MESSAGE 'Please enter 1,2,3,4 only!' TYPE 'E'.
  ENDCASE.
ENDFORM.

FORM gr301_chosen.
  CASE gv_select.
    WHEN 1.
      CLEAR gv_select.
      CALL SCREEN 3010. " PLANT DL21
    WHEN 2.
      CLEAR gv_select.
      CALL SCREEN 3012. " PLANT SG21
    WHEN OTHERS.
*      MESSAGE 'Please entere 1,2 only!' TYPE 'S' DISPLAY LIKE 'E'.
      MESSAGE s001(zms_mm_g21) DISPLAY LIKE 'E'.
      SET CURSOR FIELD 'GV_SELECT'.
      EXIT.
  ENDCASE.
  CLEAR gv_select.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form pi_chosen
*&---------------------------------------------------------------------*
FORM pi_chosen .
  CASE gv_select.
    WHEN 1.
      CLEAR gv_select.
      CALL SCREEN 0401. " enter count inven record
    WHEN 2.
      CLEAR gv_select.
      CALL SCREEN 0403. " recount inven record
*    WHEN 3.
*      CLEAR gv_select.
*      CALL SCREEN 0405. " post diff
    WHEN OTHERS.
*     MESSAGE 'Please entere 1,2 only!' TYPE 'S' DISPLAY LIKE 'E'.
      MESSAGE s001(zms_mm_g21) DISPLAY LIKE 'E'.
      SET CURSOR FIELD 'GV_SELECT'.
      EXIT.
  ENDCASE.
  CLEAR gv_select.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form frm_check_po_item
*&---------------------------------------------------------------------*

FORM frm_check_po_item .
  gv_valid_po = abap_true.

  IF gv_pono IS INITIAL.
    MESSAGE s032(zms_mm_g21) DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_PONO'.
    gv_valid_po = abap_false.
    EXIT.
  ENDIF.

  SELECT COUNT( * )
    FROM ekko
    WHERE ebeln = @gv_pono.
  IF sy-subrc <> 0.
    MESSAGE s033(zms_mm_g21) WITH gv_pono DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_PONO'.
    gv_valid_po = abap_false.
    EXIT.
  ENDIF.
ENDFORM.


" form get inbound delivery base on PO number
FORM frm_get_inbound_delivery .

  gv_valid_inbound = abap_true.

  "Lấy inbound delivery theo PO
  SELECT a~vbeln, a~posnr, a~matnr, a~lfimg, a~vrkme, a~lgmng, a~meins, a~werks,
         a~lfimg_flo, a~lgmng_flo, a~umvkz, a~umvkn, a~umrev, a~charg, a~lgort, a~vgbel, a~vgpos, a~wbsta
    FROM lips AS a
    INNER JOIN likp AS b ON a~vbeln = b~vbeln
    INTO CORRESPONDING FIELDS OF TABLE @lt_inbound
    WHERE a~vgbel = @gv_pono.

  IF lt_inbound IS INITIAL.
    MESSAGE s034(zms_mm_g21) DISPLAY LIKE 'E'.
    gv_valid_inbound = abap_false.
    EXIT.
  ENDIF.

  SORT lt_inbound BY posnr ASCENDING.

ENDFORM.


FORM frm_post_gr.

  DATA: lv_message        TYPE string,
        lt_return         TYPE TABLE OF bapiret2,
        ls_return         TYPE bapiret2,
        lt_prot           TYPE TABLE OF prott,
        ls_vbkok_wa       TYPE vbkok,
        ls_header_data    TYPE bapiibdlvhdrchg,
        ls_header_control TYPE bapiibdlvhdrctrlchg,
        lt_item_data      TYPE TABLE OF bapiibdlvitemchg,
        lt_item_control   TYPE TABLE OF bapiibdlvitemctrlchg,
        ls_item_data      TYPE bapiibdlvitemchg,
        ls_item_control   TYPE bapiibdlvitemctrlchg,
        lt_vbpok_tab      TYPE TABLE OF vbpok,
        ls_vbpok_tab      TYPE vbpok,
        lv_error_any      TYPE xfeld,
        lv_matdoc         TYPE mblnr,
        lv_matyear        TYPE mjahr,
        lv_sernr_check    TYPE equi-sernr,
        lv_charg_check    TYPE lips-charg,
        lt_sernr_tab      TYPE TABLE OF vlser,
        ls_sernr_tab      TYPE vlser,
        lt_sernr_change   TYPE TABLE OF bapidlvitmserno,
        ls_sernr_change   TYPE bapidlvitmserno.


  FIELD-SYMBOLS <fs_inbound> TYPE ty_inbound.
  FIELD-SYMBOLS <fs_upd> TYPE ty_inbound.

  LOOP AT lt_inbound ASSIGNING <fs_inbound> WHERE sel = 'X'.

    " === BATCH ===
    CONDENSE <fs_inbound>-charg_ip NO-GAPS.

    IF <fs_inbound>-charg_ip IS INITIAL.
      MESSAGE s011(zms_mm_g21) DISPLAY LIKE 'E'.
      SET CURSOR FIELD 'LS_INBOUND-CHARG_IP'.
      RETURN.
    ENDIF.

    <fs_inbound>-charg = <fs_inbound>-charg_ip.

    " === SERIAL ===
    CONDENSE <fs_inbound>-sernr_ip NO-GAPS.
    TRANSLATE <fs_inbound>-sernr_ip TO UPPER CASE.

    IF <fs_inbound>-sernr_ip IS INITIAL.
      MESSAGE s013(zms_mm_g21) DISPLAY LIKE 'E'.
      SET CURSOR FIELD 'LS_INBOUND-SERNR_IP'.
      RETURN.
    ENDIF.

    <fs_inbound>-sernr = <fs_inbound>-sernr_ip.

    lt_vbpok_tab = VALUE #( BASE lt_vbpok_tab (
    vbeln_vl  = <fs_inbound>-vbeln
    posnr_vl  = <fs_inbound>-posnr
    matnr     = <fs_inbound>-matnr
    lfimg     = <fs_inbound>-lfimg
    vrkme     = <fs_inbound>-vrkme
    lgmng     = <fs_inbound>-lgmng
    charg     = <fs_inbound>-charg
    lfimg_flo = <fs_inbound>-lfimg_flo
    lgmng_flo = <fs_inbound>-lgmng_flo
    umvkz     = <fs_inbound>-umvkz
    umvkn     = <fs_inbound>-umvkn
    umrev     = <fs_inbound>-umrev
    werks     = <fs_inbound>-werks
    lgort     = <fs_inbound>-lgort
    vbtyp_n   = 'J'
    pikmg     = <fs_inbound>-pikmg
    ebumg_bme = <fs_inbound>-lfimg ) ).

    CLEAR ls_sernr_tab.
    ls_sernr_tab-posnr = <fs_inbound>-posnr.  " item number
    ls_sernr_tab-sernr = <fs_inbound>-sernr. " serial user input
    APPEND ls_sernr_tab TO lt_sernr_tab.

    " Build item_data for BAPI_INB_DELIVERY_CHANGE
    lt_item_data = VALUE #( BASE lt_item_data (
    deliv_numb = <fs_inbound>-vbeln
    deliv_item = <fs_inbound>-posnr
    dlv_qty = <fs_inbound>-lfimg
    dlv_qty_imunit = <fs_inbound>-lgmng
    del_qty_flo = <fs_inbound>-lfimg_flo
    dlv_qty_st_flo = <fs_inbound>-lgmng_flo
    fact_unit_nom = <fs_inbound>-umvkz
    fact_unit_denom = <fs_inbound>-umvkn
    conv_fact = <fs_inbound>-umrev
    base_uom = <fs_inbound>-vrkme
    material = <fs_inbound>-matnr
    batch = <fs_inbound>-charg ) ).

    CLEAR ls_sernr_change.
    ls_sernr_change-deliv_numb = <fs_inbound>-vbeln.
    ls_sernr_change-itm_number = <fs_inbound>-posnr.
    ls_sernr_change-serialno   = <fs_inbound>-sernr.
    APPEND ls_sernr_change TO lt_sernr_change.

    CLEAR ls_item_control.
    ls_item_control-deliv_numb = <fs_inbound>-vbeln.
    ls_item_control-deliv_item = <fs_inbound>-posnr.
    ls_item_control-chg_delqty = 'X'.
    APPEND ls_item_control TO lt_item_control.

    IF ls_header_data IS INITIAL.
      ls_header_data-deliv_numb = <fs_inbound>-vbeln.
      ls_header_control-deliv_numb = <fs_inbound>-vbeln.
    ENDIF.

  ENDLOOP.

  IF lt_inbound IS INITIAL.
*    MESSAGE 'Vui lòng chọn line item để post GR!' TYPE 'S' DISPLAY LIKE 'E'.
    MESSAGE s015(zms_mm_g21) DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'ls_inbound-vbeln'.
    EXIT.
  ENDIF.

  CALL FUNCTION 'BAPI_INB_DELIVERY_CHANGE'
    EXPORTING
      header_data    = ls_header_data
      header_control = ls_header_control
      delivery       = CONV vbeln_vl( ls_header_data-deliv_numb )
    TABLES
      item_data      = lt_item_data
      item_control   = lt_item_control
      item_serial_no = lt_sernr_change
      return         = lt_return.
  " check errors like before
  LOOP AT lt_return INTO DATA(ls_return_line).
    IF ls_return_line-type = 'E' OR ls_return_line-type = 'A'.
      IF ls_return_line-message IS NOT INITIAL.
        MESSAGE s039(zms_mm_g21)
        WITH ls_return_line-message DISPLAY LIKE ls_return_line-type.
      ENDIF.
      MESSAGE ID ls_return_line-id
      TYPE 'S' NUMBER ls_return_line-number
      WITH ls_return_line-message_v1 ls_return_line-message_v2 ls_return_line-message_v3 ls_return_line-message_v4 DISPLAY LIKE ls_return_line-type.

      RETURN.
    ENDIF.
  ENDLOOP.

  " update batch, serialno
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

  " Prepare VBKOK and call WS_DELIVERY_UPDATE_2 using lt_vbpok_tab
  CLEAR ls_vbkok_wa.
  ls_vbkok_wa-vbeln_vl   = ls_header_data-deliv_numb.
  ls_vbkok_wa-wabuc      = 'X'.
  ls_vbkok_wa-spe_auto_gr = 'X'.
  ls_vbkok_wa-kzebu = 'X'.
  ls_vbkok_wa-komue = 'X'.

  CALL FUNCTION 'WS_DELIVERY_UPDATE_2'
    EXPORTING
      vbkok_wa               = ls_vbkok_wa
      synchron               = 'X'
      delivery               = ls_header_data-deliv_numb
      if_error_messages_send = 'X'
      if_database_update_1   = '1'
    IMPORTING
      ef_error_any           = lv_error_any
    TABLES
      vbpok_tab              = lt_vbpok_tab
      prot                   = lt_prot
      sernr_tab              = lt_sernr_tab
    EXCEPTIONS
      error_message          = 1
      OTHERS                 = 2.

  DATA(lv_has_error) = abap_false.

  LOOP AT lt_prot INTO DATA(ls_prot).
    IF ls_prot-msgty = 'E' OR ls_prot-msgty = 'A'.
      lv_has_error = abap_true.
      " message
      MESSAGE |Item { ls_prot-vbeln }/{ ls_prot-posnr }: { ls_prot-msgty } { ls_prot-msgno } - { ls_prot-msgv1 } { ls_prot-msgv2 } { ls_prot-msgv3 } { ls_prot-msgv4 }| TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
  ENDLOOP.

  IF lv_error_any IS INITIAL AND lv_has_error IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    " get matdoc posted
    SELECT SINGLE m~mblnr, m~mjahr
    FROM mseg AS m
    INNER JOIN mkpf AS k
    ON m~mblnr = k~mblnr
    AND m~mjahr = k~mjahr
      INNER JOIN @lt_inbound AS a
      ON m~vbeln_im = a~vbeln
      AND m~vbelp_im = a~posnr
      AND a~sel = 'X'
      WHERE  m~shkzg   = 'S'
      AND m~mblnr NOT IN (
            SELECT smbln FROM mseg WHERE shkzg = 'H' AND smbln IS NOT NULL
          )
    INTO ( @lv_matdoc, @lv_matyear ).

    MESSAGE s017(zms_mm_g21) WITH lv_matdoc lv_matyear.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.

  "Refresh inbound sau POST
  PERFORM frm_get_inbound_delivery.

  CLEAR ok_code.
  sy-ucomm = ''.
  READ TABLE lt_inbound INTO DATA(ls_inbound) INDEX 1.
  IF ls_inbound-werks = 'DL21'.
    LEAVE TO SCREEN 2011.
  ELSEIF ls_inbound-werks = 'SG21'.
    LEAVE TO SCREEN 2021.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form frm_auto_fill_year
*&---------------------------------------------------------------------*
FORM frm_auto_fill_year.
  IF NOT gv_matdoc IS INITIAL.
    SELECT SINGLE mjahr
      FROM mkpf
      INTO @gv_matyear
      WHERE mblnr = @gv_matdoc.
    IF sy-subrc <> 0.
      CLEAR gv_matyear.
*      MESSAGE |Không tìm thấy Material document { gv_matdoc }!| TYPE 'E'.
      MESSAGE s002(zms_mm_g21) WITH gv_matdoc.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form frm_display_migo
*&---------------------------------------------------------------------*
FORM frm_display_migo  USING    p_gv_matdoc
                                p_gv_matyear.

  DATA: lv_zeile TYPE mseg-zeile.

  IF p_gv_matdoc IS INITIAL.
*    MESSAGE 'Không có Material Document để hiển thị!' TYPE 'I'.
    MESSAGE s002(zms_mm_g21) WITH gv_matdoc.
    EXIT.
  ENDIF.

  "--- Lấy ZEILE từ MSEG cho item đầu tiên của MBLNR
  SELECT SINGLE zeile
    INTO lv_zeile
    FROM mseg
   WHERE mblnr = p_gv_matdoc
     AND mjahr = p_gv_matyear.

  IF sy-subrc <> 0.
    lv_zeile = '000001'.
  ENDIF.

  CALL FUNCTION 'MIGO_DIALOG'
    EXPORTING
      i_action            = 'A04'
      i_refdoc            = 'R02'
      i_notree            = 'X'
      i_skip_first_screen = 'X'
      i_deadend           = 'X'
      i_no_auth_check     = ''
      i_okcode            = 'OK_GO'
      i_mblnr             = p_gv_matdoc
      i_mjahr             = p_gv_matyear
      i_zeile             = lv_zeile
    EXCEPTIONS
      illegal_combination = 1
      OTHERS              = 2.

  IF sy-subrc <> 0.
    MESSAGE 'Không thể mở MIGO_DISPLAY!' TYPE 'E'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form frm_check_werks
*&---------------------------------------------------------------------*
FORM frm_check_werks  USING    pv_werks.

  gv_valid_werks = abap_true.

  "--- Lấy toàn bộ Plant trong PO
  SELECT COUNT( * )
    FROM ekpo
    WHERE ebeln = @gv_pono
    AND werks = @pv_werks.

  IF sy-subrc <> 0.
    MESSAGE s039(zms_mm_g21) WITH 'PO NO' gv_pono 'is not belong to' pv_werks
       DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_PONO'.
    gv_valid_werks = abap_false.
    EXIT.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form frm_get_reservation_data
*&---------------------------------------------------------------------*
*& Lấy danh sách item từ Reservation Number
*&---------------------------------------------------------------------*
FORM frm_get_reservation_data.
  gv_valid_reser = abap_true.
*  CLEAR: gt_resb, gs_resb.

  IF gv_rsnum_rep IS INITIAL.
    MESSAGE s036(zms_mm_g21) DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_RSNUM'.
    gv_valid_reser = abap_false.
    EXIT.
  ENDIF.

  gv_rsnum = gv_rsnum_rep.

  "=== Check reservation exist ===
  SELECT rsnum
    FROM rkpf
    INTO TABLE @gt_rkpf
    WHERE rsnum = @gv_rsnum.

  IF sy-subrc <> 0.
    MESSAGE s005(zms_mm_g21) WITH gv_rsnum DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_RSNUM'.
    gv_valid_reser = abap_false.
    EXIT.
  ENDIF.

  "=== Lấy item của reservation ===
  SELECT rsnum, rspos, a~matnr, werks, lgort, erfmg, erfme, charg, b~sernr, kzear
    FROM resb AS a
    INNER JOIN equi AS b
    ON a~matnr = b~matnr
    AND a~charg = b~charge
    INTO CORRESPONDING FIELDS OF TABLE @gt_resb
    WHERE rsnum = @gv_rsnum.

  IF gt_resb IS INITIAL.
    MESSAGE |Reservation { gv_rsnum } does not have item !| TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_RSNUM'.
    gv_valid_reser = abap_false.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_post_gi_reservation
*&---------------------------------------------------------------------*
*& Post Goods Issue for Reservation: BAPI_GOODSMVT_CREATE
*&---------------------------------------------------------------------*
FORM frm_post_gi_reservation.

  DATA: lv_index     TYPE i VALUE 0,
        ls_header    TYPE bapi2017_gm_head_01,
        ls_headerret TYPE bapi2017_gm_head_ret,
        lt_item      TYPE TABLE OF bapi2017_gm_item_create,
        ls_item      TYPE bapi2017_gm_item_create,
        lt_return    TYPE TABLE OF bapiret2,
        ls_return    TYPE bapiret2,
        lv_matdoc    TYPE bapi2017_gm_head_ret-mat_doc,
        lv_matyear   TYPE bapi2017_gm_head_ret-doc_year,
        ls_code      TYPE bapi2017_gm_code,
        lt_sernr     TYPE TABLE OF bapi2017_gm_serialnumber,
        ls_sernr     TYPE bapi2017_gm_serialnumber.

  CLEAR: lt_item, lt_return.

  "====  HEADER cho BAPI ====
  ls_header-pstng_date = sy-datum.
  ls_header-doc_date   = sy-datum.
  ls_header-pr_uname   = sy-uname.
  ls_header-header_txt = |GI for Reservation { gv_rsnum }|.
  ls_header-ref_doc_no = gv_rsnum.
  ls_code-gm_code = '03'. " Goods Issue

  " Loại movement 201 = Goods Issue cho Reservation
  DATA(lv_movetype) = '201'.

*  "==== Build item from gt_resb ====
  LOOP AT gt_resb INTO gs_resb WHERE sel = 'X'.

    lv_index += 1.
    CLEAR ls_item.
    ls_item-material  = gs_resb-matnr.
    ls_item-plant     = gs_resb-werks.
    ls_item-stge_loc  = gs_resb-lgort.
    ls_item-move_type = lv_movetype.
    ls_item-entry_qnt = gs_resb-erfmg.
    ls_item-entry_uom = gs_resb-erfme.
    ls_item-reserv_no = gs_resb-rsnum.
    ls_item-res_item  = gs_resb-rspos.

    IF gs_resb-charg IS NOT INITIAL.
      ls_item-batch = gs_resb-charg.
    ENDIF.

    APPEND ls_item TO lt_item.

    ls_sernr-matdoc_itm = lv_index.

    ls_sernr-serialno = gs_resb-sernr.
    APPEND ls_sernr TO lt_sernr.
    CLEAR: ls_sernr.
  ENDLOOP.

  IF lt_item IS INITIAL.
*    MESSAGE 'Chưa chọn item nào để Post GI!' TYPE 'S' DISPLAY LIKE 'E'.
    MESSAGE s015(zms_mm_g21) DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "==== CALL BAPI ====
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header       = ls_header
      goodsmvt_code         = ls_code
    IMPORTING
      goodsmvt_headret      = ls_headerret
    TABLES
      goodsmvt_item         = lt_item
      goodsmvt_serialnumber = lt_sernr
      return                = lt_return.

  "==== Kiểm tra lỗi ====
  READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
  IF sy-subrc = 0.
    LOOP AT lt_return INTO ls_return.
      MESSAGE ls_return-message TYPE 'S' DISPLAY LIKE 'E'.
    ENDLOOP.
    EXIT.
  ENDIF.

  "==== Commit nếu OK ====
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = abap_true.
  LOOP AT gt_resb INTO gs_resb WHERE sel = 'X'.
    gs_resb-matdoc = ls_headerret-mat_doc.
    gs_resb-matyear = ls_headerret-doc_year.
    MODIFY gt_resb FROM gs_resb.
  ENDLOOP.
  lv_matdoc = ls_headerret-mat_doc.
  lv_matyear = ls_headerret-doc_year.
  gv_matdoc  = ls_headerret-mat_doc.
  gv_matyear = ls_headerret-doc_year.

  MESSAGE s018(zms_mm_g21) WITH lv_matdoc lv_matyear.
  PERFORM frm_get_reservation_data.
  CLEAR: ok_code.
  sy-ucomm = ''.
  LEAVE TO SCREEN 3021.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_reverse_gi_reservation
*&---------------------------------------------------------------------*
*& Reverse Reservation bằng BAPI_GOODSMVT_CANCEL
*&---------------------------------------------------------------------*
FORM frm_reverse_gi_reservation USING p_gv_matdoc
                                      p_gv_matyear.

  DATA: ls_headerret TYPE bapi2017_gm_head_ret,
        lt_return    TYPE TABLE OF bapiret2,
        ls_return    TYPE bapiret2.

  "==== Gọi BAPI_GOODSMVT_CANCEL ====
  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      materialdocument    = p_gv_matdoc
      matdocumentyear     = p_gv_matyear
      goodsmvt_pstng_date = sy-datum
      goodsmvt_pr_uname   = sy-uname
    IMPORTING
      goodsmvt_headret    = ls_headerret
    TABLES
      return              = lt_return.

  READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    MESSAGE |Reverse Reservation failed for Material Document { p_gv_matdoc }: { ls_return-message }| TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'p_gv_matdoc'.
    EXIT.
  ENDIF.

  "==== Commit transaction ====
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

  "--- Message
*  MESSAGE |Reverse Reservation thành công, Material Document sau khi reverse { ls_headerret-mat_doc }!| TYPE 'S'.
  MESSAGE s021(zms_mm_g21) WITH ls_headerret-mat_doc ls_headerret-doc_year.
  "==== Gán kết quả Reverse ====
  gv_matdoc_rev = ls_headerret-mat_doc.
  gv_matyear    = ls_headerret-doc_year.

  " clear batch
  IF gv_matdoc_rev IS NOT INITIAL.
    TYPES: BEGIN OF ty_mseg,
             mblnr TYPE mblnr,
             rsnum TYPE rsnum,
             rspos TYPE rspos,
           END OF ty_mseg.

    DATA: lt_mseg TYPE TABLE OF ty_mseg,
          ls_mseg TYPE ty_mseg.

    SELECT mblnr, rsnum, rspos
      FROM mseg
      INTO CORRESPONDING FIELDS OF TABLE @lt_mseg
      WHERE mblnr = @gv_matdoc_rev.


    DATA: lt_return_res                TYPE TABLE OF bapiret2,
          ls_return_res                TYPE bapiret2,
          lt_reservationitems_changed  TYPE TABLE OF bapi2093_res_item_change,
          lt_reservationitems_changedx TYPE TABLE OF bapi2093_res_item_changex,
          ls_reservationitems_changed  TYPE bapi2093_res_item_change,
          ls_reservationitems_changedx TYPE bapi2093_res_item_changex.

    FIELD-SYMBOLS <fs_res_rev> TYPE ty_resb.
    FIELD-SYMBOLS <fs_upd_rev> TYPE ty_resb.

    "==========================================================
    "  SORT lt_inbound trước khi dùng READ TABLE + BINARY SEARCH
    "==========================================================
*          SORT lt_inbound BY vbeln posnr.

    LOOP AT lt_mseg INTO ls_mseg.

      " --- Convert VBELN_IM ---
      DATA lv_rsnum TYPE rsnum.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_mseg-rsnum
        IMPORTING
          output = lv_rsnum.

      "==========================================================
      " READ TABLE với BINARY SEARCH
      "==========================================================
      READ TABLE gt_resb ASSIGNING <fs_res_rev> WITH KEY
                 rsnum = lv_rsnum
                 rspos = ls_mseg-rspos.
*              BINARY SEARCH.

      IF sy-subrc <> 0.
        MESSAGE 'Can not get Reservation' TYPE 'E'.
        EXIT.
      ENDIF.

      CLEAR: <fs_res_rev>-sernr. " delete sernr to update new

      " --- Chuẩn bị delivery number ---
      DATA(lv_rsnum_int) = <fs_res_rev>-rsnum.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_res_rev>-rsnum
        IMPORTING
          output = lv_rsnum_int.

      DATA(lv_matnr) = <fs_res_rev>-matnr.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          input  = <fs_res_rev>-matnr
        IMPORTING
          output = lv_matnr.

      DATA(lv_uom) = <fs_res_rev>-erfme.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input          = <fs_res_rev>-erfme
          language       = sy-langu
        IMPORTING
          output         = lv_uom
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

      " --- Build BAPI item data ---
      CLEAR ls_reservationitems_changed.
      ls_reservationitems_changed-res_item    = <fs_res_rev>-rspos.
      ls_reservationitems_changed-stge_loc    = <fs_res_rev>-lgort.
      ls_reservationitems_changed-batch       = <fs_res_rev>-charg.
      ls_reservationitems_changed-entry_qnt   = <fs_res_rev>-erfmg.
      APPEND ls_reservationitems_changed TO lt_reservationitems_changed.

      " --- Control ---
      CLEAR ls_reservationitems_changedx.
      ls_reservationitems_changedx-res_item = <fs_res_rev>-rspos.
      ls_reservationitems_changedx-stge_loc = 'X'.
      ls_reservationitems_changedx-batch = 'X'.
      ls_reservationitems_changedx-entry_qnt = 'X'.
      APPEND ls_reservationitems_changedx TO lt_reservationitems_changedx.
    ENDLOOP.

    " header for BAPI
    READ TABLE gt_resb INTO DATA(ls_first_rev) INDEX 1.
    IF sy-subrc <> 0.
      MESSAGE 'Can not get Reservation.' TYPE 'E'.
      EXIT.
    ENDIF.

    DATA(lv_first_rsnum) = ls_first_rev-rsnum.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_first_rev-rsnum " dùng convert de ko bi tro ve dang co 0 phia trc khi check error batch, serial
      IMPORTING
        output = lv_first_rsnum.

    CALL FUNCTION 'BAPI_RESERVATION_CHANGE'
      EXPORTING
        reservation               = lv_first_rsnum
*       TESTRUN                   =
*       ATPCHECK                  =
      TABLES
        reservationitems_changed  = lt_reservationitems_changed
        reservationitems_changedx = lt_reservationitems_changedx
*       RESERVATIONITEMS_NEW      =
        return                    = lt_return_res.
*       EXTENSIONIN               =
    .

    " check errors like before
    LOOP AT lt_return_res INTO DATA(ls_return_line).
      IF ls_return_line-type = 'E' OR ls_return_line-type = 'A'.
        MESSAGE |BAPI_INB_DELIVERY_CHANGE errror: { ls_return_line-id } { ls_return_line-number } - { ls_return_line-message } { ls_return_line-message_v1 } { ls_return_line-message_v2 } { ls_return_line-message_v3 } { ls_return_line-message_v4 }|
                    TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.
    ENDLOOP.

    " cap nhat thay doi update batch, serialno
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form frm_check_so_item
*&---------------------------------------------------------------------*
*& Kiêm tra Sale Orders
*&---------------------------------------------------------------------*
FORM frm_check_so_item .
  gv_valid_sono = abap_true.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = gv_sono
    IMPORTING
      output = gv_sono_rep.

  IF gv_sono IS INITIAL.
*    MESSAGE 'Vui lòng nhập Sales Order!' TYPE 'S' DISPLAY LIKE 'E'.
    MESSAGE s037(zms_mm_g21) DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_SONO'.
    gv_valid_sono = abap_false.
    EXIT.
  ENDIF.

  "Check Exist
  SELECT vbeln
    FROM vbak
    INTO TABLE @lt_vbak
    WHERE vbeln = @gv_sono_rep.

  IF lt_vbak IS INITIAL.
*    MESSAGE |Sale Order { gv_sono } không tồn tại!| TYPE 'S' DISPLAY LIKE 'E'.
    MESSAGE s004(zms_mm_g21) WITH gv_sono DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_SONO'.
    gv_valid_sono = abap_false.
    EXIT.
  ENDIF.

  "Get item from SO Number
  SELECT vbeln, posnr, matnr, kwmeng, vrkme
    FROM vbap
    INTO TABLE @lt_vbap
    WHERE vbeln = @gv_sono_rep.

  IF lt_vbap IS INITIAL.
    MESSAGE |Sale Order { gv_sono } does not have item!| TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_SONO'.
    gv_valid_sono = abap_false.
    EXIT.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form frm_check_werk_outbound
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_SONO
*&---------------------------------------------------------------------*
FORM frm_check_werk_dl21  USING    p_gv_sono.
  DATA: lt_werks TYPE TABLE OF vbap-werks,
        lv_werks TYPE vbap-werks.

  gv_valid_werks = abap_true.

  "Get Plant
  SELECT DISTINCT werks
    INTO TABLE @lt_werks
    FROM vbap
    WHERE vbeln = @gv_sono_rep.

  IF lt_werks IS INITIAL.
    MESSAGE |Can not found item in Sale Order { p_gv_sono }!|
            TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_SONO'.
    gv_valid_werks = abap_false.
    EXIT.
  ENDIF.
  "Check Plant valid
  LOOP AT lt_werks INTO lv_werks.
    IF lv_werks <> 'DL21'.
      MESSAGE |Sale Order { p_gv_sono } has item belonging Plant { lv_werks } - Please enter others SO Number !|
              TYPE 'S' DISPLAY LIKE 'E'.
      SET CURSOR FIELD 'GV_SONO'.
      gv_valid_werks = abap_false.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form frm_check_werk_outbound (SG21)
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_SONO
*&---------------------------------------------------------------------*
FORM frm_check_werk_sg21  USING    p_gv_sono.
  DATA: lt_werks TYPE TABLE OF vbap-werks,
        lv_werks TYPE vbap-werks.

  gv_valid_werks = abap_true.
  "Get Plant
  SELECT DISTINCT werks
    INTO TABLE @lt_werks
    FROM vbap
    WHERE vbeln = @gv_sono_rep.

  IF lt_werks IS INITIAL.
    MESSAGE |Can not found item in Sales Order { p_gv_sono }!|
            TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_SONO'.
    gv_valid_werks = abap_false.
    EXIT.
  ENDIF.

  "Check Plant
  LOOP AT lt_werks INTO lv_werks.
    IF lv_werks <> 'SG21'.
      MESSAGE |Sale Order { p_gv_sono } has item belonging Plant { lv_werks } - Please enter others SO Number !|
              TYPE 'S' DISPLAY LIKE 'E'.
      SET CURSOR FIELD 'GV_SONO'.
      gv_valid_werks = abap_false.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_get_outbound_delivery
*&---------------------------------------------------------------------*
FORM frm_get_outbound_delivery .
*  CLEAR: lt_inbound, ls_inbound, lt_vbkok, lt_vbpok.

  gv_valid_outbound = abap_true.
  "Lấy outbound delivery theo SO (tất cả line items)
  SELECT a~vbeln, a~posnr, a~matnr, a~lfimg, a~vrkme, a~lgmng, a~meins, a~werks, "a~pstyv,
         a~lfimg_flo, a~lgmng_flo, a~umvkz, a~umvkn, a~umrev, a~charg, a~lgort, a~vgbel, a~vgpos, a~wbsta
    FROM lips AS a
    INNER JOIN likp AS b ON a~vbeln = b~vbeln
    INTO CORRESPONDING FIELDS OF TABLE @lt_outbound
    WHERE a~vgbel = @gv_sono_rep.

  IF lt_outbound IS INITIAL.
    MESSAGE 'Can not found Outbound Delivery for this Sale Order !' TYPE 'I'.
    gv_valid_outbound = abap_false.
    EXIT.
  ENDIF.

  SORT lt_outbound BY posnr ASCENDING.

  " convert quantity
  LOOP AT lt_outbound INTO ls_outbound.

    " Convert inbound delivery number
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_outbound-vbeln
      IMPORTING
        output = ls_outbound-vbeln.

    " Convert material number
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_outbound-matnr
      IMPORTING
        output = ls_outbound-matnr.

    "UOM
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
      EXPORTING
        input          = ls_outbound-vrkme
        language       = sy-langu
      IMPORTING
        output         = ls_outbound-vrkme
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.

    MODIFY lt_outbound FROM ls_outbound.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FRM_POST_GI_OUTBOUND_DELIVERY
*&---------------------------------------------------------------------*
* Post Goods Issue (PGI) cho Outbound Delivery
* Sử dụng BAPI 'WS_DELIVERY_UPDATE'
*----------------------------------------------------------------------*
FORM frm_post_gi_outbound_delivery.

  DATA: lv_message        TYPE string,
        lt_prot           TYPE TABLE OF prott,
        ls_vbkok_wa       TYPE vbkok,
        lt_vbpok_tab      TYPE TABLE OF vbpok,
        ls_vbpok_tab      TYPE vbpok,
        lv_error_any      TYPE xfeld,
        lv_matdoc         TYPE mblnr,
        lv_matyear        TYPE mjahr,
        lv_vrkme_internal TYPE lips-vrkme,
        lv_sernr_check    TYPE equi-sernr,
        lv_charg_check    TYPE lips-charg,
        lt_sernr_tab      TYPE TABLE OF vlser,
        ls_sernr_tab      TYPE vlser,
        lt_return         TYPE TABLE OF bapiret2,
        ls_return         TYPE bapiret2,
        lt_sernr_change   TYPE TABLE OF bapidlvitmserno,
        ls_sernr_change   TYPE bapidlvitmserno,
        ls_header_data    TYPE bapiobdlvhdrchg,
        ls_header_control TYPE bapiobdlvhdrctrlchg,
        lt_item_data      TYPE TABLE OF bapiobdlvitemchg,
        lt_item_control   TYPE TABLE OF bapiobdlvitemctrlchg,
        ls_item_data      TYPE bapiobdlvitemchg,
        ls_item_control   TYPE bapiobdlvitemctrlchg.

  DATA: lt_vbpok_sel TYPE TABLE OF ty_vbpok_outbound,
        ls_vbpok_sel TYPE ty_vbpok_outbound.

  FIELD-SYMBOLS <fs_outbound> TYPE ty_outbound.
  FIELD-SYMBOLS <fs_upd> TYPE ty_outbound.

  "LOOP ITEM
  LOOP AT lt_outbound ASSIGNING <fs_outbound>.
    DATA(lv_vbeln_int) = <fs_outbound>-vbeln.
    DATA(lv_posnr_int) = <fs_outbound>-posnr.
    DATA(lv_matnr_int) = <fs_outbound>-matnr.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_vbeln_int
      IMPORTING
        output = lv_vbeln_int.

    " Convert Material Number -> Internal
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = <fs_outbound>-matnr
      IMPORTING
        output = lv_matnr_int.

    DATA: lv_charg_input TYPE lips-charg,
          lv_sernr_input TYPE equi-sernr.

    CONDENSE <fs_outbound>-charg_ip NO-GAPS.

    lv_charg_input = <fs_outbound>-charg_ip.
    " -------- A. Check batch --------
    IF lv_charg_input IS INITIAL.
*      MESSAGE |Dòng { <fs_outbound>-posnr }: Chưa nhập Batch Number!| TYPE 'S' DISPLAY LIKE 'E'.
      MESSAGE s011(zms_mm_g21) DISPLAY LIKE 'E'.
      SET CURSOR FIELD 'LS_OUTBOUND-CHARG_IP'.
      RETURN.
    ENDIF.

    <fs_outbound>-charg = lv_charg_input.

    " -------- B. Check serial --------
    CONDENSE <fs_outbound>-sernr_ip NO-GAPS.
    lv_sernr_input = <fs_outbound>-sernr_ip.
    TRANSLATE lv_sernr_input TO UPPER CASE.

    IF lv_sernr_input IS INITIAL.
*      MESSAGE |Dòng { <fs_outbound>-posnr }: Chưa nhập Serial Number!| TYPE 'S' DISPLAY LIKE 'E'.
      MESSAGE s013(zms_mm_g21) DISPLAY LIKE 'E'.
      SET CURSOR FIELD 'LS_OUTBOUND-SERNR_IP'.
      RETURN.
    ENDIF.

    <fs_outbound>-sernr = lv_sernr_input.

    " UOM
    lv_vrkme_internal = <fs_outbound>-vrkme.

    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input          = lv_vrkme_internal
        language       = sy-langu
      IMPORTING
        output         = lv_vrkme_internal
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.

    IF sy-subrc <> 0.
      MESSAGE |Lỗi chuyển đổi UOM { <fs_outbound>-vrkme } (Item { <fs_outbound>-posnr })!| TYPE 'E'.
      RETURN.
    ENDIF.

    " ------ 2. Build VBPOK for BAPI WS_DELIVERY_UPDATE_2 ------
    CLEAR ls_vbpok_sel.
    ls_vbpok_sel-vbeln_vl   = lv_vbeln_int.
    ls_vbpok_sel-posnr_vl   = <fs_outbound>-posnr.
    ls_vbpok_sel-matnr      = lv_matnr_int.
    ls_vbpok_sel-lfimg      = <fs_outbound>-lfimg.
    ls_vbpok_sel-vrkme      = lv_vrkme_internal.
    ls_vbpok_sel-lgmng      = <fs_outbound>-lgmng.
    ls_vbpok_sel-charg      = <fs_outbound>-charg.
    ls_vbpok_sel-sernr      = <fs_outbound>-sernr.
    ls_vbpok_sel-lgort      = <fs_outbound>-lgort.
    ls_vbpok_sel-werks      = <fs_outbound>-werks.
    ls_vbpok_sel-pikmg      = <fs_outbound>-lfimg.
    ls_vbpok_sel-umrev      = <fs_outbound>-umrev.
    ls_vbpok_sel-lfimg_flo  = <fs_outbound>-lfimg_flo.
    ls_vbpok_sel-lgmng_flo  = <fs_outbound>-lgmng_flo.
    ls_vbpok_sel-umvkz      = <fs_outbound>-umvkz.
    ls_vbpok_sel-umvkn      = <fs_outbound>-umvkn.
    ls_vbpok_sel-ebumg_bme  = <fs_outbound>-lfimg.

    APPEND ls_vbpok_sel TO lt_vbpok_sel.

    CLEAR ls_sernr_change.
    ls_sernr_change-deliv_numb = ls_vbpok_sel-vbeln_vl.
    ls_sernr_change-itm_number = ls_vbpok_sel-posnr_vl.
    ls_sernr_change-serialno   = ls_vbpok_sel-sernr.
    APPEND ls_sernr_change TO lt_sernr_change.

    CLEAR ls_item_data.
    ls_item_data-deliv_numb = ls_vbpok_sel-vbeln_vl.
    ls_item_data-deliv_item = ls_vbpok_sel-posnr_vl.
    ls_item_data-dlv_qty = ls_vbpok_sel-lfimg.
    ls_item_data-dlv_qty_imunit = ls_vbpok_sel-lgmng.
    ls_item_data-del_qty_flo = ls_vbpok_sel-lfimg_flo.
    ls_item_data-dlv_qty_st_flo = ls_vbpok_sel-lgmng_flo.
    ls_item_data-fact_unit_nom = ls_vbpok_sel-umvkz.
    ls_item_data-fact_unit_denom = ls_vbpok_sel-umvkn.
    ls_item_data-conv_fact = ls_vbpok_sel-umrev.
    ls_item_data-base_uom = ls_vbpok_sel-vrkme.
    ls_item_data-material = ls_vbpok_sel-matnr.
    ls_item_data-batch = ls_vbpok_sel-charg.
    APPEND ls_item_data TO lt_item_data.

    CLEAR ls_item_control.
    ls_item_control-deliv_numb = ls_vbpok_sel-vbeln_vl.
    ls_item_control-deliv_item = ls_vbpok_sel-posnr_vl.
    ls_item_control-chg_delqty = 'X'.
    APPEND ls_item_control TO lt_item_control.

    CLEAR ls_sernr_tab.
    ls_sernr_tab-posnr = ls_vbpok_sel-posnr_vl.
    ls_sernr_tab-sernr = ls_vbpok_sel-sernr.
    APPEND ls_sernr_tab TO lt_sernr_tab.

  ENDLOOP.

  IF lt_vbpok_sel IS INITIAL.
*    MESSAGE 'Vui lòng chọn line item để Post Goods Issue!' TYPE 'S' DISPLAY LIKE 'E'.
    MESSAGE s015(zms_mm_g21) DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'LS_OUTBOUND-VBELN'.
    EXIT.
  ENDIF.

  " 3. Build Item for BAPI
  CLEAR lt_vbpok_tab.

  LOOP AT lt_vbpok_sel INTO ls_vbpok_sel.
    CLEAR ls_vbpok_tab.
    MOVE-CORRESPONDING ls_vbpok_sel TO ls_vbpok_tab.

    APPEND ls_vbpok_tab TO lt_vbpok_tab.
  ENDLOOP.


  " Prepare VBKOK (Header data for Post GI)
  READ TABLE lt_vbpok_sel INTO DATA(ls_first) INDEX 1.
  IF sy-subrc <> 0.
    MESSAGE 'Can not get Outbound Delivery header.' TYPE 'E'.
    EXIT.
  ENDIF.

  ls_header_data-deliv_numb = ls_first-vbeln_vl.
  ls_header_control-deliv_numb = ls_first-vbeln_vl.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CHANGE'
    EXPORTING
      header_data    = ls_header_data
      header_control = ls_header_control
      delivery       = ls_first-vbeln_vl
    TABLES
      item_data      = lt_item_data
      item_control   = lt_item_control
      item_serial_no = lt_sernr_change
      return         = lt_return.

  LOOP AT lt_return INTO DATA(ls_return_line).

    IF ls_return_line-type = 'E' OR ls_return_line-type = 'A'.
      " Message
      IF ls_return_line-message IS NOT INITIAL.
        MESSAGE s039(zms_mm_g21)
        WITH ls_return_line-message DISPLAY LIKE ls_return_line-type.
      ENDIF.
      MESSAGE ID ls_return_line-id
      TYPE 'S' NUMBER ls_return_line-number
      WITH ls_return_line-message_v1 ls_return_line-message_v2 ls_return_line-message_v3 ls_return_line-message_v4 DISPLAY LIKE ls_return_line-type.

      RETURN.
    ENDIF.
  ENDLOOP.
  .
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

  CLEAR ls_vbkok_wa.
  ls_vbkok_wa-vbeln_vl    = ls_first-vbeln_vl.
  ls_vbkok_wa-wadat_ist   = sy-datum.
  ls_vbkok_wa-wabuc       = 'X'.
  ls_vbkok_wa-komue       = 'X'.
  ls_vbkok_wa-wadat       = sy-datum.


  " 4. WS_DELIVERY_UPDATE_2
  CALL FUNCTION 'WS_DELIVERY_UPDATE_2'
    EXPORTING
      vbkok_wa               = ls_vbkok_wa
      synchron               = 'X'
      delivery               = ls_first-vbeln_vl
      if_error_messages_send = 'X'
      if_database_update_1   = '1'
    IMPORTING
      ef_error_any           = lv_error_any
    TABLES
      vbpok_tab              = lt_vbpok_tab
      prot                   = lt_prot
      sernr_tab              = lt_sernr_tab
    EXCEPTIONS
      error_message          = 1
      OTHERS                 = 2.

  DATA(lv_has_error) = abap_false.

  LOOP AT lt_prot INTO DATA(ls_prot).
    IF ls_prot-msgty = 'E' OR ls_prot-msgty = 'A'.
      lv_has_error = abap_true.
      MESSAGE |Item { ls_prot-vbeln }/{ ls_prot-posnr }: { ls_prot-msgty } { ls_prot-msgno } - { ls_prot-msgv1 } { ls_prot-msgv2 } { ls_prot-msgv3 } { ls_prot-msgv4 }| TYPE 'E'.
    ENDIF.
  ENDLOOP.

  IF lv_error_any IS INITIAL AND lv_has_error IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.

  " Get Material Doc sau khi Post GI
  SELECT SINGLE m~mblnr, m~mjahr
  FROM mseg AS m
  INNER JOIN mkpf AS k
  ON m~mblnr = k~mblnr
  AND m~mjahr = k~mjahr
  WHERE m~vbeln_im = @ls_first-vbeln_vl
    AND m~vbelp_im = @ls_first-posnr_vl
    AND m~shkzg  = 'H'
    AND m~mblnr NOT IN (
        SELECT smbln FROM mseg WHERE shkzg = 'S' AND smbln IS NOT NULL
    )
  INTO (@lv_matdoc, @lv_matyear).

  IF lv_matdoc IS NOT INITIAL.

    LOOP AT lt_vbpok_sel INTO ls_vbpok_sel.

      READ TABLE lt_outbound ASSIGNING <fs_upd>
        WITH KEY vbeln = ls_vbpok_sel-vbeln_vl
                 posnr = ls_vbpok_sel-posnr_vl.

      IF sy-subrc = 0.
        <fs_upd>-matdoc_posted  = lv_matdoc.
        <fs_upd>-matyear_posted = lv_matyear.
        <fs_upd>-sel            = ''.
      ENDIF.
    ENDLOOP.
*    MESSAGE |Post GI thành công! Material Doc: { lv_matdoc }/{ lv_matyear }| TYPE 'S'.
    MESSAGE s018(zms_mm_g21) WITH lv_matdoc lv_matyear.
  ENDIF.
*
  " Refresh data sau Post
  PERFORM frm_get_outbound_delivery.

  CLEAR ok_code.
  sy-ucomm = ''.

  READ TABLE lt_vbpok_sel INTO ls_vbpok_sel INDEX 1.
  IF ls_vbpok_sel-werks = 'DL21'.
    LEAVE TO SCREEN 3011.
  ELSEIF ls_vbpok_sel-werks = 'SG21'.
    LEAVE TO SCREEN 3013.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form frm_reverse_gi
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form frm_reverse_gi_outbound_delivery
*&---------------------------------------------------------------------*
FORM frm_reverse_gi_outbound USING p_gv_vbeln.

  "==============================================================
  " Data declarations
  "==============================================================
  DATA: lv_matdoc      TYPE mblnr,
        lv_matyear     TYPE mjahr,
        lv_wbstk       TYPE wbstk,
        lt_mesg        TYPE TABLE OF mesg,
        ls_mesg        TYPE mesg,
        lv_exist_vbeln TYPE likp-vbeln,
        ls_outbound    LIKE LINE OF lt_outbound.

  DATA lv_vbeln_1 TYPE likp-vbeln.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_gv_vbeln
    IMPORTING
      output = lv_vbeln_1.
  "==============================================================
  " Check input user
  "==============================================================
  IF p_gv_vbeln IS INITIAL.
*    MESSAGE 'Vui lòng nhập Outbound Delivery trước khi thực hiện Reverse!' TYPE 'S' DISPLAY LIKE 'E'.
    MESSAGE s038(zms_mm_g21) DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.



  "==============================================================
  " Check Delivery exist
  "==============================================================
  DATA: ls_vbeln TYPE likp.

  SELECT SINGLE vbeln, vbtyp
    FROM likp
    INTO (@ls_vbeln-vbeln, @ls_vbeln-vbtyp)
    WHERE vbeln = @lv_vbeln_1.

*  IF SY-SUBRC = 0.
*    " dùng ls_vbeln-vbeln / ls_vbeln-vbtyp
*  ENDIF.

  IF sy-subrc <> 0.
*    MESSAGE |Outbound Delivery { p_gv_vbeln } không tồn tại!| TYPE 'S' DISPLAY LIKE 'E'.
    MESSAGE s022(zms_mm_g21) WITH p_gv_vbeln DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "==============================================================
  " Get Material Document form MSEG with Outbound Delivery
  "==============================================================
  CLEAR: lv_matdoc, lv_matyear.

  SELECT SINGLE m~mblnr, m~mjahr
  FROM mseg AS m
  INNER JOIN mkpf AS k
  ON m~mblnr = k~mblnr
  AND m~mjahr = k~mjahr
  WHERE m~vbeln_im = @ls_vbeln-vbeln
    AND m~shkzg  = 'H'
    AND m~mblnr NOT IN (
        SELECT smbln FROM mseg WHERE shkzg = 'S' AND smbln IS NOT NULL
    )
  INTO (@lv_matdoc, @lv_matyear).

  IF lv_matdoc IS INITIAL.
    MESSAGE |Can not found Material Document in MSEG for Delivery { p_gv_vbeln }. Please enter again !.|
    TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.
  "==============================================================
  " Call BAPI WS_REVERSE_GOODS_ISSUE for Reverse
  "==============================================================
  CLEAR lt_mesg.

  CALL FUNCTION 'WS_REVERSE_GOODS_ISSUE'
    EXPORTING
      i_vbeln                   = lv_vbeln_1
      i_budat                   = sy-datum
      i_tcode                   = 'VL09'
      i_vbtyp                   = ls_vbeln-vbtyp
    TABLES
      t_mesg                    = lt_mesg
    EXCEPTIONS
      error_reverse_goods_issue = 1
      error_message             = 2
      OTHERS                    = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ELSE.


    "==============================================================
    " RETURN
    "==============================================================
    READ TABLE lt_mesg INTO ls_mesg WITH KEY msgty = 'E'.
    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      MESSAGE |Reverse Good Issue failed for Material Document { lv_matdoc }: { ls_mesg-text }| TYPE 'S' DISPLAY LIKE 'E'.
      SET CURSOR FIELD 'p_gv_vbeln'.
      EXIT.
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    DATA: lv_mat_reverse  TYPE mblnr,
          lv_year_reverse TYPE mjahr.

    SELECT SINGLE m~mblnr, m~mjahr
    FROM mseg AS m
    INNER JOIN mkpf AS k
    ON m~mblnr = k~mblnr
    AND m~mjahr = k~mjahr
    WHERE m~vbeln_im = @ls_vbeln-vbeln
      AND m~shkzg  = 'S'
      AND smbln = @lv_matdoc
*    AND m~mblnr NOT IN (
*        SELECT smbln FROM mseg WHERE shkzg = 'H' AND smbln IS NOT NULL
*    )
    INTO (@gv_matdoc_rev, @lv_year_reverse).

    "==============================================================
    " Success
    "==============================================================
*    MESSAGE |Reverse GI thành công! Material Document { gv_matdoc_rev }/{ lv_year_reverse } mới.| TYPE 'S'.
    MESSAGE s021(zms_mm_g21) WITH gv_matdoc_rev lv_year_reverse.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                         p_table_name
                         p_mark_name
                CHANGING p_ok      LIKE sy-ucomm.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA: l_ok     TYPE sy-ucomm,
        l_offset TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH p_ok FOR p_tc_name.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  l_offset = strlen( p_tc_name ) + 1.
  l_ok = p_ok+l_offset.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE l_ok.
    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM compute_scrolling_in_tc USING p_tc_name
                                            l_ok.
      CLEAR p_ok.

    WHEN 'MARK'.                      "mark all filled lines
      PERFORM fcode_tc_mark_lines USING p_tc_name
                                        p_table_name
                                        p_mark_name   .
      CLEAR p_ok.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM fcode_tc_demark_lines USING p_tc_name
                                          p_table_name
                                          p_mark_name .
      CLEAR p_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC


*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM compute_scrolling_in_tc USING    p_tc_name
                                      p_ok.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_tc_new_top_line     TYPE i.
  DATA l_tc_name             LIKE feld-name.
  DATA l_tc_lines_name       LIKE feld-name.
  DATA l_tc_field_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <lines>      TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.
*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
  ASSIGN (l_tc_lines_name) TO <lines>.


*&SPWIZARD: is no line filled?                                         *
  IF <tc>-lines = 0.
*&SPWIZARD: yes, ...                                                   *
    l_tc_new_top_line = 1.
  ELSE.
*&SPWIZARD: no, ...                                                    *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        entry_act      = <tc>-top_line
        entry_from     = 1
        entry_to       = <tc>-lines
        last_page_full = 'X'
        loops          = <lines>
        ok_code        = p_ok
        overlapping    = 'X'
      IMPORTING
        entry_new      = l_tc_new_top_line
      EXCEPTIONS
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO    = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
        OTHERS         = 0.
  ENDIF.

*&SPWIZARD: get actual tc and column                                   *
  GET CURSOR FIELD l_tc_field_name
             AREA  l_tc_name.

  IF syst-subrc = 0.
    IF l_tc_name = p_tc_name.
*&SPWIZARD: et actual column                                           *
      SET CURSOR FIELD l_tc_field_name LINE 1.
    ENDIF.
  ENDIF.

*&SPWIZARD: set the new top line                                       *
  <tc>-top_line = l_tc_new_top_line.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_mark_lines USING p_tc_name
                               p_table_name
                               p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_demark_lines USING p_tc_name
                                 p_table_name
                                 p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = space.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*& Form frm_sort_matdoc_sg21
*&---------------------------------------------------------------------*
FORM frm_sort_matdoc_up.

  DATA: lt_posted   TYPE TABLE OF ty_inbound,
        lt_unposted TYPE TABLE OF ty_inbound,
        ls_line     TYPE ty_inbound.
  "1. ĐÃ POST và CHƯA POST
  LOOP AT lt_inbound INTO ls_line.
    IF ls_line-matdoc_posted IS INITIAL.
      APPEND ls_line TO lt_unposted.
    ELSE.
      APPEND ls_line TO lt_posted.
    ENDIF.
  ENDLOOP.
  "2. Sort nhóm đã post theo MATDOC tăng dần
  SORT lt_posted BY matdoc_posted ASCENDING.
  "3. Sort nhóm chưa post theo SEQNO để giữ nguyên thứ tự ban đầu
  SORT lt_unposted BY posnr ASCENDING.
  "4. Ghép lại: posted trước – unposted sau
  CLEAR lt_inbound.
  APPEND LINES OF lt_posted TO lt_inbound.
  APPEND LINES OF lt_unposted TO lt_inbound.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_inven_doc
*&---------------------------------------------------------------------*

FORM check_inven_doc.

  gv_valid_iblnr = abap_true.

  " check input
  PERFORM check_pi_input_valid.

  IF gv_valid_iblnr = abap_false.
    EXIT.
  ENDIF.

  IF gv_iblnr IS INITIAL.
    MESSAGE 'Please enter Inventory Document !' TYPE 'S' DISPLAY LIKE 'E'.

    SET CURSOR FIELD 'GV_IBLNR'.
    gv_valid_iblnr = abap_false.
    EXIT.
  ENDIF.

  SELECT a~iblnr, b~gjahr, b~zeili, b~matnr, b~werks, b~lgort, b~charg, b~menge, b~meins, b~bstar, b~sobkz, b~xnull, b~xzael
  FROM ikpf AS a
  INNER JOIN iseg AS b
    ON a~iblnr = b~iblnr
  INTO CORRESPONDING FIELDS OF TABLE @lt_iseg
  WHERE a~iblnr = @gv_iblnr
    AND b~zeili = @gv_zeili
  ORDER BY b~zeili.

  IF lt_iseg IS INITIAL.
    MESSAGE |Inventory Document { gv_iblnr } does not have item. Please enter again !| TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_IBLNR'.
    gv_valid_iblnr = abap_false.
    EXIT.
  ENDIF.

  LOOP AT lt_iseg ASSIGNING FIELD-SYMBOL(<fs_iseg>).

    <fs_iseg>-sernr = gv_sernr_pi.
    <fs_iseg>-menge = gv_menge.
    <fs_iseg>-menge_disp = <fs_iseg>-menge.
    <fs_iseg>-xnull = gv_xnull.
    IF <fs_iseg>-xnull = 'X'.
      CLEAR <fs_iseg>-sernr.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_sort_matdoc_down
*&---------------------------------------------------------------------*
FORM frm_sort_matdoc_down .

  DATA: lt_posted   TYPE TABLE OF ty_inbound,
        lt_unposted TYPE TABLE OF ty_inbound,
        ls_line     TYPE ty_inbound.
  "1. Chia 2 nhóm: ĐÃ POST và CHƯA POST
  LOOP AT lt_inbound INTO ls_line.
    IF ls_line-matdoc_posted IS INITIAL.
      APPEND ls_line TO lt_unposted.
    ELSE.
      APPEND ls_line TO lt_posted.
    ENDIF.
  ENDLOOP.
  "2. Sort nhóm đã post theo MATDOC tăng dần
  SORT lt_posted BY matdoc_posted DESCENDING.
  "3. Sort nhóm chưa post theo SEQNO để giữ nguyên thứ tự ban đầu
  SORT lt_unposted BY posnr DESCENDING.
  "4. Ghép lại: posted trước – unposted sau
  CLEAR lt_inbound.
  APPEND LINES OF lt_posted TO lt_inbound.
  APPEND LINES OF lt_unposted TO lt_inbound.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_pi_input_valid
*&---------------------------------------------------------------------*

FORM check_pi_input_valid.

*  DATA(lv_iblnr) = gv_iblnr.
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT' "convert sang leading zero de search iseg
*    EXPORTING
*      input  = gv_iblnr
*    IMPORTING
*      output = lv_iblnr.

  " check inven document
  IF gv_iblnr IS INITIAL.
    MESSAGE 'Please enter Inventory Document !' TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_IBLNR'.
    gv_valid_iblnr = abap_false.
    EXIT.
  ENDIF.

  SELECT SINGLE iblnr
  FROM iseg
  INTO @DATA(lv_iseg_iblnr)
  WHERE iblnr = @gv_iblnr.

  IF sy-subrc <> 0.
    MESSAGE |Inventory Document { gv_iblnr } không tồn tại!|
          TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_IBLNR'.
    gv_valid_iblnr = abap_false.
    EXIT.
  ENDIF.

  " check inven item
  IF gv_zeili IS INITIAL.
    MESSAGE 'Inventory Item is required. Please enter Inventory Item !' TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_ZEILI'.
    gv_valid_iblnr = abap_false.
    EXIT.
  ENDIF.

  SELECT SINGLE zeili
  FROM iseg
  INTO @DATA(lv_zeili_data)
  WHERE iblnr = @gv_iblnr
    AND zeili = @gv_zeili.
  IF lv_zeili_data IS INITIAL.
    MESSAGE |Item { gv_zeili } does not exist Inventory Document { gv_iblnr }!|
          TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_ZEILI'.
    gv_valid_iblnr = abap_false.
    EXIT.
  ELSEIF gv_zeili <> lv_zeili_data.
    MESSAGE |Item { gv_zeili } incorrect with Item in Inventory Document { gv_iblnr }!|
          TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_ZEILI'.
    gv_valid_iblnr = abap_false.
    EXIT.
  ENDIF.

  SELECT SINGLE matnr
  FROM iseg
  INTO @gv_matnr
  WHERE iblnr = @gv_iblnr
    AND zeili = @lv_zeili_data.

*  DATA(lv_matnr) = gv_matnr.
*  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
*    EXPORTING
*      input  = lv_matnr
*    IMPORTING
*      output = gv_matnr.

  SELECT SINGLE werks
  FROM iseg
  INTO @gv_werks_pi
  WHERE iblnr = @gv_iblnr
    AND zeili = @lv_zeili_data
    AND matnr = @gv_matnr.

  SELECT SINGLE lgort
  FROM iseg
  INTO @gv_lgort_pi
  WHERE iblnr = @gv_iblnr
    AND zeili = @lv_zeili_data
    AND matnr = @gv_matnr
    AND werks = @gv_werks_pi.

  IF gv_xnull = 'X'.
    gv_menge = 0.
  ELSE.
    IF gv_menge IS INITIAL.
      MESSAGE 'Please enter Counted Quantity!' TYPE 'S' DISPLAY LIKE 'E'.
      SET CURSOR FIELD 'GV_MENGE'.
      gv_valid_iblnr = abap_false.
      EXIT.
    ENDIF.
  ENDIF.

  SELECT SINGLE charg
    FROM iseg
    INTO @DATA(lv_charg)
    WHERE iblnr = @gv_iblnr
    AND zeili = @gv_zeili
    AND matnr = @gv_matnr
    AND werks = @gv_werks_pi
    AND lgort = @gv_lgort_pi.

  IF lv_charg IS INITIAL.
    MESSAGE 'Serial Number can not found (Item without Batch) !' TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_SERNR_PI'.
    gv_valid_iblnr = abap_false.
    EXIT.
  ENDIF.

  IF gv_sernr_pi IS INITIAL.
    MESSAGE 'Please input Serial Number!' TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_SERNR_PI'.
    gv_valid_iblnr = abap_false.
    EXIT.
  ENDIF.

  DATA: lv_sernr TYPE gernr.

  SELECT SINGLE sernr
    INTO @lv_sernr
    FROM equi
    WHERE matnr = @gv_matnr
    AND charge = @lv_charg.

  IF lv_sernr IS INITIAL.
    MESSAGE |Material { gv_matnr } Batch { lv_charg } does not have Serial Number!|
          TYPE 'S' DISPLAY LIKE 'E'.
    gv_valid_iblnr = abap_false.
    SET CURSOR FIELD 'GV_SERNR_PI'.
    EXIT.
  ELSEIF gv_sernr_pi <> lv_sernr.
    MESSAGE |Serial { gv_sernr_pi } incorrect for Material { gv_matnr } Batch { lv_charg }!|
         TYPE 'S' DISPLAY LIKE 'E'.
    gv_valid_iblnr = abap_false.
    SET CURSOR FIELD 'GV_SERNR_PI'.
    EXIT.
  ENDIF.

  SELECT SINGLE xzael
    FROM iseg
    INTO @DATA(lv_xzael)
    WHERE iblnr = @gv_iblnr
    AND zeili = @gv_zeili.

  IF lv_xzael = 'X' .
    MESSAGE | Item { gv_zeili } counted! | TYPE 'S' DISPLAY LIKE 'E'.
    gv_valid_iblnr = abap_false.
    SET CURSOR FIELD 'gv_iblnr'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form post_count_quantity
*&---------------------------------------------------------------------*
FORM post_count_quantity.

  DATA: lt_bapi_items  TYPE TABLE OF bapi_physinv_count_items,
        ls_bapi_item   TYPE bapi_physinv_count_items,
        lt_bapi_serial TYPE TABLE OF bapi_physinv_serialnumbers,
        ls_bapi_serial TYPE bapi_physinv_serialnumbers,
        lt_return      TYPE TABLE OF bapiret2,
        ls_return      TYPE bapiret2.

  READ TABLE lt_iseg ASSIGNING FIELD-SYMBOL(<fs_head>) INDEX 1.
  IF sy-subrc <> 0.
    MESSAGE 'No Item in table to count!' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  LOOP AT lt_iseg ASSIGNING FIELD-SYMBOL(<fs_iseg>).

    CLEAR ls_bapi_item.

    " ITEM: pad thành 3 ký tự numc
    ls_bapi_item-item = <fs_iseg>-zeili.
    ls_bapi_item-material = <fs_iseg>-matnr.
    ls_bapi_item-batch = <fs_iseg>-charg.
    ls_bapi_item-entry_qnt = <fs_iseg>-menge.
    ls_bapi_item-entry_uom = <fs_iseg>-meins.
    ls_bapi_item-zero_count = <fs_iseg>-xnull.

    APPEND ls_bapi_item TO lt_bapi_items.

    " SERIALS: nếu cần
    IF <fs_iseg>-sernr IS NOT INITIAL.
      CLEAR ls_bapi_serial.
      ls_bapi_serial-item = <fs_iseg>-zeili.
      ls_bapi_serial-serialno = <fs_iseg>-sernr.
      APPEND ls_bapi_serial TO lt_bapi_serial.
    ENDIF.

  ENDLOOP.

  IF lt_bapi_items IS INITIAL.
    MESSAGE 'Không có item nào để count.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  CALL FUNCTION 'BAPI_MATPHYSINV_COUNT'
    EXPORTING
      physinventory = <fs_head>-iblnr
      fiscalyear    = <fs_head>-gjahr
    TABLES
      items         = lt_bapi_items
      serialnumbers = lt_bapi_serial
      return        = lt_return.

  DATA(lv_has_error) = abap_false.
  DATA lv_msg_all TYPE string.

  LOOP AT lt_return INTO ls_return.
    " Aggregate all messages (error, warning, info)
    CONCATENATE lv_msg_all ls_return-message cl_abap_char_utilities=>newline INTO lv_msg_all.

    " detect error
    IF ls_return-type = 'E' OR ls_return-type = 'A'.
      lv_has_error = abap_true.
    ENDIF.
  ENDLOOP.

  " Nếu có lỗi → show TẤT CẢ message error/warning/info ra popup
  IF lv_has_error = abap_true.
    MESSAGE lv_msg_all TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " Không lỗi → commit
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

  " THÀNH CÔNG → thông báo
  MESSAGE 'Count saved successfully.' TYPE 'S'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_inven_doc
*&---------------------------------------------------------------------*
FORM get_inven_doc .
  gv_valid_iblnr = abap_true.  " mặc định hợp lệ

  " check inven document
  IF gv_iblnr IS INITIAL.
    MESSAGE 'Vui lòng nhập Inventory Document!' TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_IBLNR'.
    gv_valid_iblnr = abap_false.
    EXIT.
  ENDIF.

  SELECT SINGLE iblnr
  FROM iseg
  INTO @DATA(lv_iseg_iblnr)
  WHERE iblnr = @gv_iblnr.

  IF sy-subrc <> 0.
    MESSAGE |Inventory Document { gv_iblnr } does not exist !|
          TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_IBLNR'.
    gv_valid_iblnr = abap_false.
    EXIT.
  ENDIF.

  SELECT a~iblnr, b~gjahr, b~zeili, b~matnr, b~werks, b~lgort, b~charg, b~menge, b~meins, b~bstar, b~sobkz, b~xnull, b~xzael,
          b~xdiff, b~buchm, xnzae, nblnr
  FROM ikpf AS a
  INNER JOIN iseg AS b
    ON a~iblnr = b~iblnr
  INTO CORRESPONDING FIELDS OF TABLE @lt_iseg
  WHERE a~iblnr = @lv_iseg_iblnr
    AND b~xzael = 'X'
    AND b~xnzae <> 'X'
    AND b~xdiff <> 'X'
  ORDER BY b~zeili.

  IF lt_iseg IS INITIAL.
    MESSAGE | Items in Inventory Document { gv_iblnr } recounted or not counted!| TYPE 'S' DISPLAY LIKE 'E'.
    SET CURSOR FIELD 'GV_IBLNR'.
    gv_valid_iblnr = abap_false.
    EXIT.
  ENDIF.

  LOOP AT lt_iseg ASSIGNING FIELD-SYMBOL(<fs_iseg>).

    <fs_iseg>-diff_quan = <fs_iseg>-menge - <fs_iseg>-buchm.
    <fs_iseg>-diff_disp = <fs_iseg>-diff_quan. " type quan ko get sô âm nên display bang type char
    IF <fs_iseg>-diff_disp IS INITIAL.
      MESSAGE | Check difference quantity { <fs_iseg>-diff_quan } again! | TYPE 'S' DISPLAY LIKE 'E'.
      SET CURSOR FIELD '<fs_iseg>-diff_disp'.
      gv_valid_iblnr = abap_false.
      EXIT.
    ENDIF.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_rec_inven_doc
*&---------------------------------------------------------------------*
FORM create_rec_inven_doc.
  DATA:
    lv_s_eikpf       TYPE eikpf,
    ls_iikpf         TYPE iikpf,
    lt_t_eiseg       TYPE STANDARD TABLE OF eiseg,
    lv_error_message TYPE eiseg,
    lv_et_ikpf       TYPE ty_t_ikpf,
    lt_t_item        TYPE STANDARD TABLE OF iseg_sel,
    lv_et_iseg       TYPE ty_t_iseg,
    lt_t_dm07i       TYPE STANDARD TABLE OF dm07i.

  CLEAR: lt_t_eiseg,
  lv_s_eikpf,
  lt_t_item,
  lt_t_dm07i.

  "------------------------------------------------------------
  " Build header cho recount document
  "------------------------------------------------------------
  READ TABLE lt_iseg INTO DATA(ls_first) INDEX 1.
  IF sy-subrc <> 0.
    MESSAGE 'Can not get inbound header.' TYPE 'E'.
    EXIT.
  ENDIF.

  CLEAR ls_iikpf.
  ls_iikpf-iblnr = ls_first-iblnr.
  ls_iikpf-werks = ls_first-werks.
  ls_iikpf-lgort = ls_first-lgort.
  ls_iikpf-zldat = sy-datum.
  ls_iikpf-ibltxt = ls_iikpf-iblnr.

  LOOP AT lt_iseg INTO ls_iseg WHERE sel = 'X'.

    lt_t_eiseg = VALUE #( BASE lt_t_eiseg
       ( iblnr = ls_first-iblnr
        gjahr = ls_iseg-gjahr
        zeili = ls_iseg-zeili
        matnr = ls_iseg-matnr
        werks = ls_iseg-werks
        lgort = ls_iseg-lgort
        charg = ls_iseg-charg
        meins = ls_iseg-meins
        menge = ls_iseg-menge
     ) ).

    " BAPI will know and get Item user selected
    DATA(ls_item) = VALUE iseg_sel(
    iblnr = ls_iseg-iblnr
    gjahr = ls_iseg-gjahr
    zeili = ls_iseg-zeili
  ).
    APPEND ls_item TO lt_t_item.

  ENDLOOP.

  "------------------------------------------------------------
  " Call BAPI MB_CREATE_RECOUNT
  "------------------------------------------------------------
  CALL FUNCTION 'MB_CREATE_RECOUNT'
    EXPORTING
      s_iikpf       = ls_iikpf
    IMPORTING
      s_eikpf       = lv_s_eikpf
      et_ikpf       = lv_et_ikpf
      et_iseg       = lv_et_iseg
    TABLES
      t_eiseg       = lt_t_eiseg
      t_dm07i       = lt_t_dm07i
      t_item        = lt_t_item
    EXCEPTIONS
      error_message = 1
      OTHERS        = 2.

  IF lv_s_eikpf-msgty = 'E'.

    MESSAGE ID lv_s_eikpf-msgid
     TYPE 'S' NUMBER lv_s_eikpf-msgno WITH lv_s_eikpf-msgv1 lv_s_eikpf-msgv3 lv_s_eikpf-msgv3 lv_s_eikpf-msgv4 DISPLAY LIKE 'E'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    LOOP AT lv_et_ikpf ASSIGNING FIELD-SYMBOL(<lfs_ikpf>).
      IF lv_s_eikpf-iblnr IS INITIAL.
        lv_s_eikpf-iblnr = <lfs_ikpf>-iblnr.
      ELSE.
        lv_s_eikpf-iblnr = |{ lv_s_eikpf-iblnr }/ { <lfs_ikpf>-iblnr }|.
      ENDIF.
    ENDLOOP.
    MESSAGE |Recount document { lv_s_eikpf-iblnr } created sucessfully !| TYPE 'S'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form update_clear_serial
*&---------------------------------------------------------------------*
FORM clear_batch_serial .

  DATA:
    lt_return_rev         TYPE TABLE OF bapiret2,
    ls_return_rev         TYPE bapiret2,
    ls_header_data_rev    TYPE bapiibdlvhdrchg,
    ls_header_control_rev TYPE bapiibdlvhdrctrlchg,
    lt_item_data_rev      TYPE TABLE OF bapiibdlvitemchg,
    lt_item_control_rev   TYPE TABLE OF bapiibdlvitemctrlchg,
    ls_item_data_rev      TYPE bapiibdlvitemchg,
    ls_item_control_rev   TYPE bapiibdlvitemctrlchg,
    lt_sernr_change_rev   TYPE TABLE OF bapidlvitmserno,
    ls_sernr_change_rev   TYPE bapidlvitmserno.

  SELECT mblnr,
    a~vbeln, a~posnr, a~matnr, a~lfimg, a~vrkme, a~lgmng, a~meins, a~werks,
         a~lfimg_flo, a~lgmng_flo, a~umvkz, a~umvkn, a~umrev, a~charg, a~lgort, a~vgbel, a~vgpos, a~wbsta
    FROM lips AS a
    INNER JOIN likp AS b ON a~vbeln = b~vbeln
    INNER JOIN mseg ON vbeln_im = a~vbeln
      AND vbelp_im = a~posnr
    INTO TABLE @DATA(lt_mseg)
    WHERE mblnr = @gv_matdoc_rev.

  IF sy-subrc <> 0.
    MESSAGE 'Can not get Inbound Delivery' TYPE 'E'.
    EXIT.
  ENDIF.


  LOOP AT lt_mseg INTO DATA(ls_mseg).

    " --- Build BAPI item data ---
    CLEAR ls_item_data_rev.
    ls_item_data_rev-deliv_numb       = ls_mseg-vbeln.
    ls_item_data_rev-deliv_item       = ls_mseg-posnr.
    ls_item_data_rev-dlv_qty          = ls_mseg-lfimg.
    ls_item_data_rev-dlv_qty_imunit   = ls_mseg-lgmng.
    ls_item_data_rev-del_qty_flo      = ls_mseg-lfimg_flo.
    ls_item_data_rev-dlv_qty_st_flo   = ls_mseg-lgmng_flo.
    ls_item_data_rev-fact_unit_nom    = ls_mseg-umvkz.
    ls_item_data_rev-fact_unit_denom  = ls_mseg-umvkn.
    ls_item_data_rev-conv_fact        = ls_mseg-umrev.
    ls_item_data_rev-base_uom         = ls_mseg-vrkme.
    ls_item_data_rev-material         = ls_mseg-matnr.
    ls_item_data_rev-batch            = ls_mseg-charg.
    APPEND ls_item_data_rev TO lt_item_data_rev.

    " --- Serial ---
    CLEAR ls_sernr_change_rev.
    ls_sernr_change_rev-deliv_numb = ls_mseg-vbeln.
    ls_sernr_change_rev-itm_number = ls_mseg-posnr.
    ls_sernr_change_rev-serialno   = ''.
    APPEND ls_sernr_change_rev TO lt_sernr_change_rev.

    " --- Control ---
    CLEAR ls_item_control_rev.
    ls_item_control_rev-deliv_numb = ls_mseg-vbeln.
    ls_item_control_rev-deliv_item = ls_mseg-posnr.
    ls_item_control_rev-chg_delqty = 'X'.
    APPEND ls_item_control_rev TO lt_item_control_rev.

    IF ls_header_data_rev IS INITIAL.
      ls_header_data_rev-deliv_numb = ls_mseg-vbeln.
      ls_header_control_rev-deliv_numb = ls_mseg-vbeln.
    ENDIF.

  ENDLOOP.


  CALL FUNCTION 'BAPI_INB_DELIVERY_CHANGE'
    EXPORTING
      header_data    = ls_header_data_rev
      header_control = ls_header_control_rev
      delivery       = CONV vbeln_vl( ls_mseg-vbeln )
    TABLES
      item_data      = lt_item_data_rev
      item_control   = lt_item_control_rev
      item_serial_no = lt_sernr_change_rev
      return         = lt_return_rev.
  " check errors like before
  LOOP AT lt_return_rev INTO DATA(ls_return_line).
    " chỉ lấy lỗi Error hoặc Abort

    IF ls_return_line-type = 'E' OR ls_return_line-type = 'A'.
      " Hiển thị message chi tiết ngay lập tức
      IF ls_return_line-message IS NOT INITIAL.
        MESSAGE s039(zms_mm_g21)
        WITH ls_return_line-message DISPLAY LIKE ls_return_line-type.
      ENDIF.
      MESSAGE ID ls_return_line-id
      TYPE 'S' NUMBER ls_return_line-number
      WITH ls_return_line-message_v1 ls_return_line-message_v2 ls_return_line-message_v3 ls_return_line-message_v4 DISPLAY LIKE ls_return_line-type.

      RETURN.
    ENDIF.
  ENDLOOP.

  " cap nhat thay doi update batch, serialno
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form clear_batch_serial_ob
*&---------------------------------------------------------------------*
FORM clear_batch_serial_ob .

  DATA:
    lt_return_rev         TYPE TABLE OF bapiret2,
    ls_return_rev         TYPE bapiret2,
    ls_header_data_rev    TYPE bapiobdlvhdrchg,
    ls_header_control_rev TYPE bapiobdlvhdrctrlchg,
    lt_item_data_rev      TYPE TABLE OF bapiobdlvitemchg,
    lt_item_control_rev   TYPE TABLE OF bapiobdlvitemctrlchg,
    ls_item_data_rev      TYPE bapiobdlvitemchg,
    ls_item_control_rev   TYPE bapiobdlvitemctrlchg,
    lt_sernr_change_rev   TYPE TABLE OF bapidlvitmserno,
    ls_sernr_change_rev   TYPE bapidlvitmserno.

  SELECT mblnr,
  a~vbeln, a~posnr, a~matnr, a~lfimg, a~vrkme, a~lgmng, a~meins, a~werks,
       a~lfimg_flo, a~lgmng_flo, a~umvkz, a~umvkn, a~umrev, a~charg, a~lgort, a~vgbel, a~vgpos, a~wbsta
  FROM lips AS a
  INNER JOIN likp AS b ON a~vbeln = b~vbeln
  INNER JOIN mseg ON vbeln_im = a~vbeln
    AND vbelp_im = a~posnr
  INTO TABLE @DATA(lt_mseg)
  WHERE mblnr = @gv_matdoc_rev.

  IF sy-subrc <> 0.
    MESSAGE 'Can not get Outbound' TYPE 'E'.
    EXIT.
  ENDIF.

  LOOP AT lt_mseg INTO DATA(ls_mseg).
    " --- Chuẩn bị delivery number ---
    DATA(lv_vbeln_int) = ls_mseg-vbeln.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_mseg-vbeln
      IMPORTING
        output = lv_vbeln_int.

    DATA(lv_matnr) = ls_mseg-matnr.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = ls_mseg-matnr
      IMPORTING
        output = lv_matnr.

    DATA(lv_uom) = ls_mseg-vrkme.
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input          = ls_mseg-vrkme
        language       = sy-langu
      IMPORTING
        output         = lv_uom
      EXCEPTIONS
        unit_not_found = 1
        OTHERS         = 2.

    " --- Build BAPI item data ---
    CLEAR ls_item_data_rev.
    ls_item_data_rev-deliv_numb       = lv_vbeln_int.
    ls_item_data_rev-deliv_item       = ls_mseg-posnr.
    ls_item_data_rev-dlv_qty          = ls_mseg-lfimg.
    ls_item_data_rev-dlv_qty_imunit   = ls_mseg-lgmng.
    ls_item_data_rev-del_qty_flo      = ls_mseg-lfimg_flo.
    ls_item_data_rev-dlv_qty_st_flo   = ls_mseg-lgmng_flo.
    ls_item_data_rev-fact_unit_nom    = ls_mseg-umvkz.
    ls_item_data_rev-fact_unit_denom  = ls_mseg-umvkn.
    ls_item_data_rev-conv_fact        = ls_mseg-umrev.
    ls_item_data_rev-base_uom         = lv_uom.
    ls_item_data_rev-material         = lv_matnr.
    ls_item_data_rev-batch            = ls_mseg-charg.
    APPEND ls_item_data_rev TO lt_item_data_rev.

    " --- Serial ---
    CLEAR ls_sernr_change_rev.
    ls_sernr_change_rev-deliv_numb = lv_vbeln_int.
    ls_sernr_change_rev-itm_number = ls_mseg-posnr.
    ls_sernr_change_rev-serialno   = ''.
    APPEND ls_sernr_change_rev TO lt_sernr_change_rev.

    " --- Control ---
    CLEAR ls_item_control_rev.
    ls_item_control_rev-deliv_numb = lv_vbeln_int.
    ls_item_control_rev-deliv_item = ls_mseg-posnr.
    ls_item_control_rev-chg_delqty = 'X'.
    APPEND ls_item_control_rev TO lt_item_control_rev.

    IF ls_header_data_rev IS INITIAL.
      ls_header_data_rev-deliv_numb = ls_mseg-vbeln.
      ls_header_control_rev-deliv_numb = ls_mseg-vbeln.
    ENDIF.

  ENDLOOP.

  CALL FUNCTION 'BAPI_OUTB_DELIVERY_CHANGE'
    EXPORTING
      header_data    = ls_header_data_rev
      header_control = ls_header_control_rev
      delivery       = CONV vbeln_vl( ls_mseg-vbeln )
    TABLES
      item_data      = lt_item_data_rev
      item_control   = lt_item_control_rev
      item_serial_no = lt_sernr_change_rev
      return         = lt_return_rev.
  " check errors like before
  LOOP AT lt_return_rev INTO DATA(ls_return_line).
    " chỉ lấy lỗi Error hoặc Abort
    IF ls_return_line-type = 'E' OR ls_return_line-type = 'A'.
      " Hiển thị message chi tiết ngay lập tức
      IF ls_return_line-message IS NOT INITIAL.
        MESSAGE s039(zms_mm_g21)
        WITH ls_return_line-message DISPLAY LIKE ls_return_line-type.
      ENDIF.
      MESSAGE ID ls_return_line-id
      TYPE 'S' NUMBER ls_return_line-number
      WITH ls_return_line-message_v1 ls_return_line-message_v2 ls_return_line-message_v3 ls_return_line-message_v4 DISPLAY LIKE ls_return_line-type.

      RETURN.
    ENDIF.
  ENDLOOP.

  " cap nhat thay doi update batch, serialno
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

ENDFORM.


FORM frm_sort_matdoc_up_generic
    USING    iv_field_matdoc TYPE string
             iv_field_item   TYPE string

    CHANGING ct_data         TYPE ANY TABLE.

  FIELD-SYMBOLS:
    <lt_data>     TYPE STANDARD TABLE,
    <ls_line>     TYPE any,
    <lv_matdoc>   TYPE any,
    <lv_item>     TYPE any,
    <lt_posted>   TYPE STANDARD TABLE,
    <lt_unposted> TYPE STANDARD TABLE.

  ASSIGN ct_data TO <lt_data>.

  DATA: lr_posted   TYPE REF TO data,
        lr_unposted TYPE REF TO data.

  CREATE DATA lr_posted   LIKE ct_data.
  CREATE DATA lr_unposted LIKE ct_data.


  ASSIGN lr_posted->*   TO <lt_posted>.
  ASSIGN lr_unposted->* TO <lt_unposted>.

  LOOP AT <lt_data> ASSIGNING <ls_line>.
    ASSIGN COMPONENT iv_field_matdoc OF STRUCTURE <ls_line> TO <lv_matdoc>.
    ASSIGN COMPONENT iv_field_item   OF STRUCTURE <ls_line> TO <lv_item>.

*    IF sy-subrc <> 0.
*      CONTINUE.
*    ENDIF.

    IF <lv_matdoc> IS INITIAL.
      APPEND <ls_line> TO <lt_unposted>.
    ELSE.
      APPEND <ls_line> TO <lt_posted>.
    ENDIF.
  ENDLOOP.

  SORT <lt_posted>   BY (iv_field_matdoc).
  SORT <lt_unposted> BY (iv_field_item).

  CLEAR <lt_data>.
  APPEND LINES OF <lt_posted>   TO <lt_data>.
  APPEND LINES OF <lt_unposted> TO <lt_data>.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_sort_matdoc_down_generic

*&      <-- LT_INBOUND
*&---------------------------------------------------------------------*
FORM frm_sort_matdoc_down_generic USING    iv_field_matdoc TYPE string
                                           iv_field_item   TYPE string

                                  CHANGING ct_data         TYPE ANY TABLE.

  FIELD-SYMBOLS:
    <lt_data>     TYPE STANDARD TABLE,
    <ls_line>     TYPE any,
    <lv_matdoc>   TYPE any,
    <lv_item>     TYPE any,
    <lt_posted>   TYPE STANDARD TABLE,
    <lt_unposted> TYPE STANDARD TABLE.

  ASSIGN ct_data TO <lt_data>.

  DATA: lr_posted   TYPE REF TO data,
        lr_unposted TYPE REF TO data.

  CREATE DATA lr_posted   LIKE ct_data. " lr_posted là type cua lt_posted
  CREATE DATA lr_unposted LIKE ct_data.


  ASSIGN lr_posted->* TO <lt_posted>. " de thuc hien viec append ben duoi APPEND <ls_line> TO <lt_unposted>. thi phai gan type cho lt_posted
  ASSIGN lr_unposted->* TO <lt_unposted>.

  LOOP AT <lt_data> ASSIGNING <ls_line>.
    ASSIGN COMPONENT iv_field_matdoc OF STRUCTURE <ls_line> TO <lv_matdoc>.
    ASSIGN COMPONENT iv_field_item   OF STRUCTURE <ls_line> TO <lv_item>.

    IF <lv_matdoc> IS INITIAL.
      APPEND <ls_line> TO <lt_unposted>.
    ELSE.
      APPEND <ls_line> TO <lt_posted>.
    ENDIF.
  ENDLOOP.

  SORT <lt_posted>   BY (iv_field_matdoc) DESCENDING.
  SORT <lt_unposted> BY (iv_field_item) DESCENDING.

  CLEAR <lt_data>.
  APPEND LINES OF <lt_posted>   TO <lt_data>.
  APPEND LINES OF <lt_unposted> TO <lt_data>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATE_SELECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validate_select .
  IF gv_select IS INITIAL.
    MESSAGE 'Please enter number.' TYPE 'E'.
    SET CURSOR FIELD 'GV_SELECT'.
  ELSEIF gv_select <> 1 AND gv_select <> 2 AND gv_select <> 3.
    MESSAGE 'Please enter 1,2,3 only.' TYPE 'E'.
    SET CURSOR FIELD 'GV_SELECT'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Include          ZSF_RS_SS_181
*&---------------------------------------------------------------------*
TABLES: rkpf, resb.
*SELECT-OPTIONS: s_rsnum FOR ls_rkpf-rsnum.
SELECTION-SCREEN BEGIN OF BLOCK reservation WITH FRAME TITLE TEXT-002.
  SELECT-OPTIONS:
    rg_rsnum FOR rkpf-rsnum,
    rg_matnr FOR resb-matnr,
    rg_werks FOR resb-werks,
    rg_rsdat FOR rkpf-rsdat.
SELECTION-SCREEN END OF BLOCK reservation.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK printmode WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_prev RADIOBUTTON GROUP pm DEFAULT 'X',
              p_prnt RADIOBUTTON GROUP pm.
SELECTION-SCREEN END OF BLOCK printmode.


AT SELECTION-SCREEN.
  " Kiểm tra nếu tất cả đều trống
  IF sy-ucomm = 'ONLI'.
    IF rg_rsnum[] IS INITIAL
    AND rg_matnr[] IS INITIAL
    AND rg_werks[] IS INITIAL
    AND rg_rsdat[] IS INITIAL.
      MESSAGE 'Vui lòng chọn ít nhất 1 tiêu chí tìm kiếm!' TYPE 'E'.
    ENDIF.

    IF rg_rsnum[] IS NOT INITIAL.
      SELECT SINGLE rsnum
        FROM rkpf
        INTO @DATA(iv_rsnum)
        WHERE rsnum IN @rg_rsnum.
      IF sy-subrc <> 0.
        MESSAGE 'Reservation number không tồn tại!' TYPE 'E'.
      ENDIF.
    ENDIF.

    " 3. Check Ship-to-party
    IF rg_matnr[] IS NOT INITIAL.
      SELECT SINGLE matnr
        FROM resb
        INTO @DATA(iv_matnr)
        WHERE matnr IN @rg_matnr.
      IF sy-subrc <> 0.
        MESSAGE 'Material không tồn tại!' TYPE 'E'.
      ENDIF.
    ENDIF.

    " 4. Check Delivery date
    IF rg_werks[] IS NOT INITIAL.
      SELECT SINGLE werks
        FROM resb
        INTO @DATA(iv_werks)
        WHERE werks IN @rg_werks.
      IF sy-subrc <> 0.
        MESSAGE 'Plant không tồn tại!' TYPE 'E'.
      ENDIF.
    ENDIF.

    " 5. Check Shipping point
    IF rg_rsdat[] IS NOT INITIAL.
      SELECT SINGLE rsdat
        FROM rkpf
        INTO @DATA(iv_rsdat)
        WHERE rsdat IN @rg_rsdat.
      IF sy-subrc <> 0.
        MESSAGE 'Requirement Date không tồn tại!' TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR rg_rsnum-low.
  PERFORM f4_rsnum.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR rg_rsnum-high.
  PERFORM f4_rsnum.

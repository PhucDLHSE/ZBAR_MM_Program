gv_index = 0.

*DATA: lv_date TYPE d,
*      lv_time TYPE t,
*      lv_secs TYPE i,
*      lv_hour TYPE i,
*      lv_min  TYPE i,
*      lv_sec  TYPE i,
*      lv_hour_c(2),
*      lv_min_c(2),
*      lv_sec_c(2).
*
*lv_date = sy-datum.
*lv_time = sy-uzeit.  " Giờ hệ thống (UTC)
*lv_secs = lv_time DIV 1.  " Chuyển TIME sang giây
*
*" Cộng thêm 6 tiếng (ví dụ múi giờ Việt Nam +7)
*lv_secs = lv_secs + 21600.
*
*" Nếu vượt 24h thì trừ đi 86400 và tăng ngày lên 1
*IF lv_secs >= 86400.
*  lv_secs = lv_secs - 86400.
*  lv_date = lv_date + 1.  " <-- tăng ngày
*ENDIF.
*
*" Chuyển lại TIME
*lv_time = lv_secs.
*
*" Lưu lại để in ra
*gv_correct_date = lv_date.
*gv_correct_time = lv_time.
*
*" Tách giờ, phút, giây
*lv_hour = lv_time DIV 3600.
*lv_min  = ( lv_time MOD 3600 ) DIV 60.
*lv_sec  = lv_time MOD 60.
*
*IF lv_hour < 10.
*  lv_hour_c = |0{ lv_hour }|.
*ELSE.
*  lv_hour_c = lv_hour.
*ENDIF.
*
*IF lv_min < 10.
*  lv_min_c = |0{ lv_min }|.
*ELSE.
*  lv_min_c = lv_min.
*ENDIF.
*
*IF lv_sec < 10.
*  lv_sec_c = |0{ lv_sec }|.
*ELSE.
*  lv_sec_c = lv_sec.
*ENDIF.
*
*CONCATENATE lv_hour_c ':' lv_min_c ':' lv_sec_c INTO gv_correct_time_txt.
*CONDENSE gv_correct_time_txt NO-GAPS.
DATA: lv_date TYPE d,
      lv_time TYPE t,
      lv_secs TYPE i,
      lv_hour TYPE i,
      lv_min  TYPE i,
      lv_sec  TYPE i,
      lv_hour_c(2),
      lv_min_c(2),
      lv_sec_c(2).

lv_date = sy-datum.
lv_time = sy-uzeit.  " Giờ hệ thống (UTC)
lv_secs = lv_time DIV 1.  " Chuyển TIME sang giây

" Cộng thêm 6 tiếng (ví dụ múi giờ Việt Nam +7)
lv_secs = lv_secs + 21600.

" Nếu vượt 24h thì trừ đi 86400 và tăng ngày lên 1
IF lv_secs >= 86400.
  lv_secs = lv_secs - 86400.
  lv_date = lv_date + 1.  " <-- tăng ngày
ENDIF.

" Chuyển lại TIME
lv_time = lv_secs.

" Lưu lại để in ra
gv_correct_date = lv_date.
gv_correct_time = lv_time.

"=== Format ngày (DD/MM/YYYY)
DATA(lv_year)  = lv_date(4).
DATA(lv_month) = lv_date+4(2).
DATA(lv_day)   = lv_date+6(2).

CONCATENATE lv_day '/' lv_month '/' lv_year INTO gv_correct_date_txt.
CONDENSE gv_correct_date_txt NO-GAPS.

"=== Tách giờ phút giây
lv_hour = lv_time DIV 3600.
lv_min  = ( lv_time MOD 3600 ) DIV 60.
lv_sec  = lv_time MOD 60.

IF lv_hour < 10.
  lv_hour_c = |0{ lv_hour }|.
ELSE.
  lv_hour_c = lv_hour.
ENDIF.

IF lv_min < 10.
  lv_min_c = |0{ lv_min }|.
ELSE.
  lv_min_c = lv_min.
ENDIF.

IF lv_sec < 10.
  lv_sec_c = |0{ lv_sec }|.
ELSE.
  lv_sec_c = lv_sec.
ENDIF.

CONCATENATE lv_hour_c ':' lv_min_c ':' lv_sec_c INTO gv_correct_time_txt.
CONDENSE gv_correct_time_txt NO-GAPS.

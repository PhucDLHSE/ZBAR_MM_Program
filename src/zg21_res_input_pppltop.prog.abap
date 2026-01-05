*---------------------------------------------------------------------*
* Include ZG21_RES_INPUT_PPPLTOP - ĐÃ CẬP NHẬT
*---------------------------------------------------------------------*

TABLES: resb, rkpf.

* Bảng nội bộ để lưu trữ danh sách các Reservation Number duy nhất tìm được
DATA: lt_rsnum TYPE STANDARD TABLE OF resb-rsnum.
DATA: lv_rsnum TYPE resb-rsnum.

* Bảng nội bộ để chứa Selection Options cho việc truyền qua SUBMIT
DATA: lt_submit_params TYPE STANDARD TABLE OF rsparams.

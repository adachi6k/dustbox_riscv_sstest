.section .text
.global _start

_start:
    li t0, 0x00000000  # 無効なアドレスをロード（例：アドレス0）
    # mtvec に next_targetを設定
    la t1, next_target
    csrw mtvec, t1    
    jr t0              # t0のアドレスにジャンプ
next_target:
    nop                # この命令には到達しない

    .section .text
    .globl _start

    .align 12  # ページサイズ（4KB、12ビット）にアライン

_start:
    # 1. 例外ハンドラの設定（マシンモード用）
    la t1, machine_exception_handler
    csrw mtvec, t1

    # 2. スーパーバイザモードの例外ハンドラの設定
    la t1, supervisor_exception_handler
    csrw stvec, t1

    # 3. スーパーバイザモードへの切り替え
    li t0, (1 << 11)  # MSTATUSのMPPフィールドに値1（スーパーバイザモード）を設定
    csrs mstatus, t0

    # 4. スーパーバイザモードでのプログラム開始アドレスを設定
    la t0, supervisor_start
    csrw mepc, t0

    # 
    csrw satp, zero


    # 5. MRET命令でスーパーバイザモードに切り替え
    mret

# 以下はスーパーバイザモードで実行されるコード
supervisor_start:
    # 1. 仮想メモリの例外ハンドラを設定
    la t1, supervisor_exception_handler
    csrw stvec, t1

    # 2. ページテーブルの設定
    # ページテーブルのベースアドレスを取得
    la t0, page_table_root
    # 物理ページ番号（PPN）を取得するために12ビット右シフト
    srli t0, t0, 12
    # satpレジスタのMODEフィールド（Sv39の場合は8）を設定
    li t1, (8 << 60)  # MODE=8（Sv39）
    or t0, t0, t1

    # 3. 仮想メモリの有効化
    csrw satp, t0
    sfence.vma

    # 4. 次の命令フェッチで命令ページフォルトが発生

    # ここで命令ページフォルトが発生するため、以下のコードには到達しない
    j infinite_loop  # この命令がフェッチされるときにページフォルト

infinite_loop:
    j infinite_loop  # 無限ループ

# スーパーバイザモードの例外ハンドラ
supervisor_exception_handler:
    # 例外の種類を確認（scauseレジスタ）
    csrr t0, scause
    # scauseや他のレジスタをデバッグ用に保存・表示するなどの処理を行う
    j supervisor_exception_handler  # 無限ループで停止

# マシンモードの例外ハンドラ
machine_exception_handler:
    csrr t0, mcause
    j machine_exception_handler  # 無限ループで停止

# ページテーブルの設定
    .align 12
page_table_root:
    # レベル2ページテーブルエントリ（VPN[2]）
    .quad 0  # 無効なエントリ（コードセクションを未マッピングにする）

    # 必要に応じて他のエントリを追加

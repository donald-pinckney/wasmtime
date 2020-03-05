(module
    ;; Import the required fd_write WASI function which will write the given io vectors to stdout
    ;; The function signature for fd_write is:
    ;; (File Descriptor, *iovs, iovs_len, nwritten) -> Returns number of bytes written
    ;; (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))


    ;; (global $_after_kapture (mut i64) (i64.const 0)) ;; continuation_id

    (func $add1 (param i64) (result i64)
        (i64.add (i64.const 1) (local.get 0))
    )

    (func $handler (param i64 i64) ;; k , arg
        (restore (continuation_copy (local.get 0)) (i64.const 987))
    )

    (func $main_handler (param i64 i64)
        (restore (local.get 0) (call $add1 (control $handler (i64.const 1234))))
    )

    (func $the_main (export "the_main") (result i64)
        (control $main_handler (i64.const 1234))
    )

)
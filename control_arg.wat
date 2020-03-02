(module
    ;; Import the required fd_write WASI function which will write the given io vectors to stdout
    ;; The function signature for fd_write is:
    ;; (File Descriptor, *iovs, iovs_len, nwritten) -> Returns number of bytes written
    ;; (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))


    ;; (global $_after_kapture (mut i64) (i64.const 0)) ;; continuation_id

    (global $x (mut i64) (i64.const 0))


    (func $handler (param i64 i64) ;; k, v

        (global.set $x (local.get 1))
        (restore (local.get 0) (i64.const 1234))

        ;; (global.set $_after_kapture (local.get 0))

        ;; global.get $_to_capture_arg1
        ;; global.get $_to_capture_arg2
        ;; global.get $_to_capture_arg3
        ;; global.get $_to_capture ;; we HAVE to put these onto the stack BEFORE doing control!!!

        ;; (control $_save_k_restore (i64.const 1337))
        ;; drop
        ;; call_indirect (type $proc)
    )



    (func $the_main (export "the_main") (result i64)
        (control $handler (i64.const 1337))
        drop
        
        (global.get $x)
    )

)
(module
    ;; Import the required fd_write WASI function which will write the given io vectors to stdout
    ;; The function signature for fd_write is:
    ;; (File Descriptor, *iovs, iovs_len, nwritten) -> Returns number of bytes written
    ;; (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))


    ;; (global $_after_kapture (mut i64) (i64.const 0)) ;; continuation_id

    (global $i (mut i64) (i64.const 0))
    (global $k (mut i64) (i64.const 90872340))


    (func $handler (param i64 i64) ;; k, v
        (global.set $k (continuation_copy (local.get 0)))
        (restore (local.get 0) (i64.const 1234))
    )



    (func $the_main (export "the_main") (result i64)
        (control $handler (i64.const 1337))
        drop
        ;; (global.set $i)

        (if (i64.lt_u (global.get $i) (i64.const 10))
            (then
                (global.set $i (i64.add (global.get $i) (i64.const 1)))
                (restore (global.get $k) (i64.const 9782342))
            )
            (else

            )
        )

        ;; unreachable


        (global.get $i)
    )

)
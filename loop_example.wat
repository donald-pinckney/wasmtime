(module
    (global $i (mut i64) (i64.const 0))
    (global $k (mut i64) (i64.const 90872340))


    (func $tee_restore (param i64 i64)
        (global.set $k (continuation_copy (local.get 0)))
        (restore (local.get 0) (local.get 1))
    )

    (func $handler (param i64 i64) ;; k, v
        (call $tee_restore (local.get 0) (i64.const 1234))
    )



    (func $the_main_handler (param i64 i64)
        (control $handler (i64.const 1337))
        drop

        (if (i64.lt_u (global.get $i) (i64.const 10))
            (then
                (global.set $i (i64.add (global.get $i) (i64.const 1)))
                (call $tee_restore (global.get $k) (i64.const 9782342))
            )
            (else

            )
        )

        (restore (local.get 0) (global.get $i))
    )

    (func $the_main (export "the_main") (result i64)
        (control $the_main_handler (i64.const 0))
    )

)
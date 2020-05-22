(module
    
    ;; (import "spectest" "print" (func $print) (param i32)))
    ;; (import "spectest" "print_i32" (func $print_i32 (param i32)))

    (func $drop_i32 (param i32)
        ;; (call $print_i32 (local.get 0))
    )



    (func $the_main (export "the_main")
        (i64.store (i32.const 8) (i64.const -1))

        i32.const 1035
        call $drop_i32

        (block
            (prompt
                br 1
            )
        ) ;; branch to
        i32.const 1061
        call $drop_i32
    )

    (memory (;0;) 1)

)
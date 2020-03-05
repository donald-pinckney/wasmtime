(module
    (type $gen_t (func (param i64)))

    (global $_after_kapture (mut i64) (i64.const 0)) ;; continuation_id
    (global $_to_capture (mut i32) (i32.const 0)) ;; func ptr

    (func $_save_k_restore (param i64 i64)
        (restore (global.get $_after_kapture) (local.get 0))
    )

    (func $_kapture_handler (param i64 i64) (local $tmp i32)
        (global.set $_after_kapture (local.get 0))

        (local.set $tmp (global.get $_to_capture)) ;; we HAVE to put this onto the stack BEFORE doing control!!!
        (control $_save_k_restore (i64.const 1337))
        local.get $tmp
        call_indirect (type $gen_t)
    )

    (func $kapture (param $f i32) (result i64)
        (global.set $_to_capture (local.get $f))
        (control $_kapture_handler (i64.const 1337))
    )


    (memory 1)
    (global $_env_alloc_ptr (mut i32) (i32.const 0))
    (func $alloc_env (result i64)
        global.get $_env_alloc_ptr
        (global.set $_env_alloc_ptr (i32.add (i32.const 24) (global.get $_env_alloc_ptr)))
        i64.extend_i32_u
    )

    (func $env_addr (param $env i64) (param $offset i64) (result i32)
        (i32.wrap_i64 
            (i64.add 
                (local.get $env) 
                (i64.mul 
                    (i64.const 8) 
                    (local.get $offset))))
    )

    (func $read_env (param $env i64) (param $offset i64) (result i64)
        (i64.load (call $env_addr (local.get $env) (local.get $offset)))
    )

    (func $write_env (param $env i64) (param $offset i64) (param $x i64)
        (i64.store 
            (call $env_addr (local.get $env) (local.get $offset)) 
            (local.get $x)
        )
    )

    



    (func $yield_handler (param $rest i64) (param $env i64)
        (call $write_env (local.get $env) (i64.const 1) (local.get $rest))
        (restore
            (call $read_env (local.get $env) (i64.const 0))
            (call $read_env (local.get $env) (i64.const 2))
        )
    )

    (func $gen_yield (param $v i64) (param $env i64)
        (call $write_env (local.get $env) (i64.const 2) (local.get $v))
        (control $yield_handler (local.get $env))
        drop
    )

    (func $next_handler (param $k i64) (param $env i64)
        (call $write_env (local.get $env) (i64.const 0) (local.get $k))
        (restore 
            (call $read_env (local.get $env) (i64.const 1)) 
            (local.get $env)
        )
    )

    (func $gen_next (param $env i64) (result i64)
        (control $next_handler (local.get $env))
    )

    (func $makeGenerator (param $generator i32) (result i64) (local $env i64)
        (local.set $env (call $alloc_env))
        (call $write_env (local.get $env) (i64.const 0) (i64.const 0))
        (call $write_env (local.get $env) (i64.const 1) (call $kapture (local.get $generator)))
        local.get $env
    )





    (table funcref
        (elem
            $exampleGenerator
        )
    )

    (func $exampleGenerator (param $env i64) (local $i i64)
        (local.set $i (i64.const 0))
        (loop
            (call $gen_yield (local.get $i) (local.get $env))
            (local.set $i (i64.add (local.get $i) (i64.const 1)))
            br 0
        )
    )

    (func $the_main (export "the_main") (result i64) (local $n i64) (local $sum i64) (local $gen_env i64)
        (local.set $n (i64.const 0))
        (local.set $sum (i64.const 0))
        (local.set $gen_env (call $makeGenerator (i32.const 0)))

        (loop
            (local.set $sum 
                (i64.add 
                    (local.get $sum) 
                    (call $gen_next (local.get $gen_env))))
            
            (local.set $n (i64.add (local.get $n) (i64.const 1)))
            (br_if 0 (i64.ne (local.get $n) (i64.const 10)))
        )

        (local.get $sum)
    )

)
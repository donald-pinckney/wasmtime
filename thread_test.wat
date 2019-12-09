(module
    ;; Import the required fd_write WASI function which will write the given io vectors to stdout
    ;; The function signature for fd_write is:
    ;; (File Descriptor, *iovs, iovs_len, nwritten) -> Returns number of bytes written
    (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

    (memory 1)
    (export "memory" (memory 0))

    (type $proc (func))

    (table funcref
        (elem
            $loopA $loopB $printA $printB
        )
    )


    (global $_kapture_result (mut i64) (i64.const 0)) ;; continuation_id
    (global $_after_kapture (mut i64) (i64.const 0)) ;; continuation_id
    (global $_to_capture (mut i32) (i32.const 0)) ;; kthread_func_t


    (func $_save_k_restore (param i64 i64)
        (global.set $_kapture_result (get_local 0))
        global.get $_after_kapture
        i64.const 0 ;; value doesn't matter
        restore
    )

    (func $_kapture_handler (param i64 i64)
        (global.set $_after_kapture (get_local 0))

        global.get $_to_capture
        (control $_save_k_restore)
        drop
        call_indirect (type $proc)
    )

    (func $kapture (param i32) (result i64)
        (global.set $_to_capture (get_local 0))
        (control $_kapture_handler)
        drop
        global.get $_kapture_result
    )



    ;; Write 'hello world\n' to memory at an offset of 8 bytes
    ;; Note the trailing newline which is required for the text to appear
    (data (i32.const 16) "A\n")

    (func $print_ascii (param i32)
        (i32.store8 (i32.const 16) (get_local 0))
        (call $fd_write
            (i32.const 1) ;; file_descriptor - 1 for stdout
            (i32.const 0) ;; *iovs - The pointer to the iov array, which is stored at memory location 0
            (i32.const 1) ;; iovs_len - We're printing 1 string stored in an iov - so one.
            (i32.const 20) ;; nwritten - A place in memory to store the number of bytes writen
        )
        drop
    )

    (func $print_d (param i64)
        (call $print_ascii (i32.wrap/i64 (i64.add (i64.const 48) (get_local 0))))
    )

    (func $printA
        (call $print_ascii (i32.const 65))
    )
    (func $printB
        (call $print_ascii (i32.const 66))
    )


    (func $loopA
        (loop
            call $printA
            call $kthread_yield
            br 0
        )

        call $kthread_exit
    )

    (func $loopB
        (loop
            call $printB
            call $kthread_yield
            br 0
        )

        call $kthread_exit
    )


    (func $restore7 (param i64 i64)
        get_local 0 ;; First param is the continuation ID
        i64.const 7
        restore
    )




    (global $queue_head (mut i32) (i32.const 40))
    (global $queue_tail (mut i32) (i32.const 40))
    (global $queue_len (mut i32) (i32.const 0))

    ;; The actual queue starts at memory index 40

    (func $enqueue (param i64)
        global.get $queue_head
        get_local 0
        i64.store

        (global.set $queue_head (i32.add (global.get $queue_head) (i32.const 8)))     
        (global.set $queue_len (i32.add (global.get $queue_len) (i32.const 1)))
    )

    (func $dequeue (result i64)
        (if (result i64) (global.get $queue_len)
            (then
                (i64.load (global.get $queue_tail))
                (global.set $queue_tail (i32.add (global.get $queue_tail) (i32.const 8) ))
                (global.set $queue_len (i32.sub (global.get $queue_len) (i32.const 1)))
            )
            (else
                unreachable ;; actuall it is reachable: don't do it
            )
        )
    )

    (func $kthread_init
        ;; call $queue_init
    )

    (func $kthread_create (param i32) ;; function ptr
        (call $enqueue (call $kapture (get_local 0)))
    )

    (func $kthread_start
        call $dequeue
        i64.const 7
        restore
    )

    (func $_kthread_switcher (param i64 i64)
        (call $enqueue (get_local 0))
        call $dequeue
        i64.const 7 ;; value doesn't matter
        restore
    )

    (func $kthread_yield
        control $_kthread_switcher
        drop
    )

    (func $kthread_exit
        (if (global.get $queue_len)
            (then
                call $dequeue
                i64.const 7 ;; value doesn't matter
                restore
            )
            (else
                unreachable ;; would like to do exit(0)
            )
        )
    )


    ;; (func $kthread)

    ;; (func $kthread_create)

    (func $main (export "_start")
        ;; (control $restore7)
        
        
    
        ;; Creating a new io vector within linear memory
        (i32.store (i32.const 0) (i32.const 16))  ;; iov.iov_base - This is a pointer to the start of the 'hello world\n' string
        (i32.store (i32.const 4) (i32.const 2))  ;; iov.iov_len - The length of the 'hello world\n' string


        ;; (call $enqueue (i64.const 3))
        ;; (call $enqueue (i64.const 1))
        ;; (call $enqueue (i64.const 3))
        ;; (call $enqueue (i64.const 7))
        ;; (call $print_d (call $dequeue))
        ;; (call $enqueue (i64.const 8))
        ;; (call $print_d (call $dequeue))
        ;; (call $enqueue (i64.const 2))
        ;; (call $print_d (call $dequeue))
        ;; (call $print_d (call $dequeue))
        ;; (call $print_d (call $dequeue))
        ;; (call $print_d (call $dequeue))


        ;; (call $print_d (i64.const 0))


        ;; (call $kapture (i32.const 2))
        ;; (call $kapture (i32.const 3))
        ;; drop
        ;; i64.const 7
        ;; restore


        call $kthread_init
        (call $kthread_create (i32.const 0)) ;; 0 = $loopA
        (call $kthread_create (i32.const 1)) ;; 2 = $loopB
        call $kthread_start



        ;; (call $kapture (i32.const 2))
        
        ;; call $print_d
        ;; drop

        ;; drop
        ;; i64.const 7
        ;; restore

        ;; (call_indirect (i32.const 3))

        ;; call $loopA
        ;; call $loopA
        ;; ;; ;; (i32.const 1294967296)
        ;; (setjmp (i32.const 32))
        ;; ;; ;; (i32.const 0)
        ;; drop



        ;; ;; (longjmp (i32.const 56) (i64.const 59))

        ;; (control)



        ;; (i32.store (i32.const 9) (i32.add 
        ;; 							(i32.const 65) 
        ;; 							(i32.wrap/i64 (i64.add (i64.const 3) (control $restore7))  )   ;; (setjmp (i32.const 0))
        ;; 						)) ;; 65
        ;; (call $do_print)


        ;; (control $restore7)
        ;; drop
    )
)
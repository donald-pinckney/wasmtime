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


    (global $_after_kapture (mut i64) (i64.const 0)) ;; continuation_id
    (global $_to_capture (mut i32) (i32.const 0)) ;; kthread_func_t

    (func $_save_k_restore (param i64 i64)
        (restore (global.get $_after_kapture) (local.get 0))
    )

    (func $_kapture_handler (param i64 i64)
        (global.set $_after_kapture (local.get 0))

        global.get $_to_capture ;; we HAVE to put this onto the stack BEFORE doing control!!!
        control $_save_k_restore
        drop
        call_indirect (type $proc)
    )

    (func $kapture (param i32) (result i64)
        (global.set $_to_capture (local.get 0))
        control $_kapture_handler
    )



    ;; Write 'hello world\n' to memory at an offset of 8 bytes
    ;; Note the trailing newline which is required for the text to appear
    (data (i32.const 16) "A\n")

    (func $print_ascii (param i32)
        (i32.store8 (i32.const 16) (local.get 0))
        (call $fd_write
            (i32.const 1) ;; file_descriptor - 1 for stdout
            (i32.const 0) ;; *iovs - The pointer to the iov array, which is stored at memory location 0
            (i32.const 1) ;; iovs_len - We're printing 1 string stored in an iov - so one.
            (i32.const 20) ;; nwritten - A place in memory to store the number of bytes writen
        )
        drop
    )

    (func $print_d64 (param i64)
        (call $print_d32 (i32.wrap_i64 (local.get 0)))
    )

    (func $print_d32 (param i32)
        (call $print_ascii (i32.add (i32.const 48) (local.get 0)))
    )

    (func $printA
        (call $print_ascii (i32.const 65))
    )
    (func $printB
        (call $print_ascii (i32.const 66))
    )
    (func $printC
        (call $print_ascii (i32.const 67))
    )




    (global $queue_head (mut i32) (i32.const 40))
    (global $queue_tail (mut i32) (i32.const 40))
    (global $queue_len (mut i32) (i32.const 0))

    (global $after_cont (mut i64) (i64.const 0))


    ;; The actual queue starts at memory index 40

    (func $enqueue (param i64)
        global.get $queue_head
        local.get 0
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
                unreachable ;; actuall it is reachable: but don't do it
            )
        )
    )

    (func $kthread_init
        ;; nothing to do here, the queue is initialized by the init values of the globals
        ;; call $queue_init
    )

    (func $kthread_create (param i32) ;; function ptr, entry in the table
        (call $enqueue (call $kapture (local.get 0)))
    )

    (func $_kthread_start_handler (param i64 i64)
        (global.set $after_cont (local.get 0))
        (restore (call $dequeue) (i64.const 7)) ;; value doesn't matter, not used in threads
    )

    (func $kthread_start
        control $_kthread_start_handler
        drop
        ;; (restore (call $dequeue) (i64.const 7)) ;; value doesn't matter, not used in threads
    )

    (func $_kthread_yield_handler (param i64 i64)
        (call $enqueue (local.get 0))
        (restore (call $dequeue) (i64.const 7)) ;; value doesn't matter, not used in threads
    )

    (func $kthread_yield
        control $_kthread_yield_handler
        drop
    )

    (func $kthread_exit
        (if (global.get $queue_len)
            (then
                (restore (call $dequeue) (i64.const 7)) ;; value doesn't matter, not used in threads
            )
            (else
                (restore (global.get $after_cont) (i64.const 7)) ;; value doesn't matter, not used in threads
                ;; unreachable ;; would like to do exit(0)
            )
        )
    )



    (func $loopA (local $i i32)
        (local.set $i (i32.const 0))

        (block
            (loop
                call $printA
                (call $print_d32 (local.get $i))
                call $kthread_yield

                (local.set $i (i32.add (local.get $i) (i32.const 1)))
                (br_if 1 (i32.eq (local.get $i) (i32.const 10)))
                br 0
            )
        )

        call $kthread_exit
    )

    (func $loopB (local $i i32)
        (local.set $i (i32.const 0))

        (block
            (loop
                call $printB
                (call $print_d32 (local.get $i))
                call $kthread_yield
                
                (local.set $i (i32.add (local.get $i) (i32.const 1)))
                (br_if 1 (i32.eq (local.get $i) (i32.const 10)))
                br 0
            )
        )

        call $kthread_exit
    )



    (func $main (export "_start")    
        ;; Creating a new io vector within linear memory
        ;; We just need to initialize this memory so printing will work.
        (i32.store (i32.const 0) (i32.const 16))  ;; iov.iov_base - This is a pointer to the start of the 'hello world\n' string
        (i32.store (i32.const 4) (i32.const 2))  ;; iov.iov_len - The length of the 'hello world\n' string


        call $kthread_init
        (call $kthread_create (i32.const 0)) ;; 0 = $loopA
        (call $kthread_create (i32.const 1)) ;; 1 = $loopB
        call $kthread_start

        call $printC
    )
)
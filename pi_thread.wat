(module
    ;; Import the required fd_write WASI function which will write the given io vectors to stdout
    ;; The function signature for fd_write is:
    ;; (File Descriptor, *iovs, iovs_len, nwritten) -> Returns number of bytes written
    (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

    (memory 1)
    (export "memory" (memory 0))

    (type $proc (func (param i64 i64 i64)))

    (table funcref
        (elem
            $terms
        )
    )


    (global $_after_kapture (mut i64) (i64.const 0)) ;; continuation_id
    (global $_to_capture (mut i32) (i32.const 0)) ;; kthread_func_t
    (global $_to_capture_arg1 (mut i64) (i64.const 0)) ;; arbitrary argument
    (global $_to_capture_arg2 (mut i64) (i64.const 0)) ;; arbitrary argument
    (global $_to_capture_arg3 (mut i64) (i64.const 0)) ;; arbitrary argument

    (func $_save_k_restore (param i64 i64)
        (restore (global.get $_after_kapture) (local.get 0))
    )

    (func $_kapture_handler (param i64 i64)
        (global.set $_after_kapture (local.get 0))

        global.get $_to_capture_arg1
        global.get $_to_capture_arg2
        global.get $_to_capture_arg3
        global.get $_to_capture ;; we HAVE to put these onto the stack BEFORE doing control!!!

        control $_save_k_restore
        drop
        call_indirect (type $proc)
    )

    (func $kapture (param i32 i64 i64 i64) (result i64)
        (global.set $_to_capture (local.get 0))
        (global.set $_to_capture_arg1 (local.get 1))
        (global.set $_to_capture_arg2 (local.get 2))
        (global.set $_to_capture_arg3 (local.get 3))
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


    ;; (global $queue_start_addr i32 (i32.const 40))

    (global $queue_head (mut i32) (i32.const 40))
    (global $queue_tail (mut i32) (i32.const 40))
    (global $queue_len (mut i32) (i32.const 0))

    ;; The actual queue starts at memory index 40

    (func $set_thread_queue_start_addr (param i32)
        (global.set $queue_head (local.get 0))
        (global.set $queue_tail (local.get 0))
    )

    (func $enqueue (param i64)
        (i64.store (global.get $queue_head) (local.get 0))

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

    (global $after_cont (mut i64) (i64.const 0))

    (func $kthread_init
        ;; nothing to do here, the queue is initialized by the init values of the globals
        ;; call $queue_init
    )

    (func $kthread_create (param i32 i64 i64 i64) ;; function ptr, entry in the table
        (call $enqueue (call $kapture (local.get 0) (local.get 1) (local.get 2) (local.get 3)))
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


    (func $term (param f64) (result f64) (local i64)
		i64.const 0
		local.get 0
		i64.trunc_f64_s
		i64.const 1
		i64.and
		i64.sub
		i64.const 1
		i64.shl
		i64.const 1
		i64.add
		local.tee 1
		i64.const 2
		i64.shl
		f64.convert_i64_s
		local.get 0
		local.get 0
		f64.add
		f64.const 1
		f64.add
		f64.div
	)

    (func $terms (param $thread_addr i64) (param $from i64) (param $to i64) (local $f f64) (local $k i64)
        (local.set $f (f64.const 0))
        (local.set $k (local.get $from))

        (block
            (loop
                ;; (call $print_ascii (i32.wrap_i64 (local.get $char)))

                (local.set $f (f64.add (local.get $f) (call $term (f64.convert_i64_s (local.get $k)))))
                ;; (call $term (f64.convert_i64_s (local.get $k)))
                ;; (local.set $f (f64.add (local.get $f) (f64.const 4)))

                ;; (call $print_ascii (i32.wrap_i64 (local.get $thread_addr)))
    
                ;; (call $print_d32 (local.get $i))
                call $kthread_yield

                (local.set $k (i64.add (local.get $k) (i64.const 1)))
                (br_if 1 (i64.gt_s (local.get $k) (local.get $to)))
                br 0
            )
        )

        (f64.store (i32.wrap_i64 (local.get $thread_addr)) (local.get $f))

        call $kthread_exit
    )



    (global $numThreads i64 (i64.const 4))
    (global $numTerms i64 (i64.const 40))


    (func $the_main (export "the_main") (result f64) (local $numTerms i64) (local $k i64) (local $termsPerThread i64) (local $sum f64)
        ;; Creating a new io vector within linear memory
        ;; We just need to initialize this memory so printing will work.
        (i32.store (i32.const 0) (i32.const 16))  ;; iov.iov_base - This is a pointer to the start of the 'hello world\n' string
        (i32.store (i32.const 4) (i32.const 2))  ;; iov.iov_len - The length of the 'hello world\n' string

        ;; (local.set $numThreads (i64.const 2))
        ;; (local.set $numTerms (i64.const 10))

        (local.set $termsPerThread (i64.div_s (global.get $numTerms) (global.get $numThreads)))
        (local.set $k (i64.const 0))

        (call $set_thread_queue_start_addr (i32.wrap_i64 (i64.add (i64.mul (i64.const 8) (global.get $numThreads)) (i64.const 40))))

        call $kthread_init


        (block
            (loop
                (call $kthread_create (i32.const 0) 
                    (i64.add (i64.mul (local.get $k) (i64.const 8)) (i64.const 40)) 
                    (i64.mul (local.get $k) (local.get $termsPerThread))
                    (i64.sub (i64.add (local.get $termsPerThread) (i64.mul (local.get $k) (local.get $termsPerThread))) (i64.const 1))
                ) ;; 0 = $thread_print_loop, 65 = 'A'


                (local.set $k (i64.add (local.get $k) (i64.const 1)))
                (br_if 1 (i64.eq (local.get $k) (global.get $numThreads)))
                br 0
            )
        )

        call $kthread_start


        (local.set $sum (f64.const 0))
        (local.set $k (i64.const 0))

        (block
            (loop
                (local.set $sum 
                    (f64.add 
                        (local.get $sum) 
                        (f64.load 
                            (i32.wrap_i64 (i64.add (i64.mul (local.get $k) (i64.const 8)) (i64.const 40)))
                        )
                    )
                )


                (local.set $k (i64.add (local.get $k) (i64.const 1)))
                (br_if 1 (i64.eq (local.get $k) (global.get $numThreads)))
                br 0
            )
        )

        (local.get $sum)
    )

    (func $main (export "_start") 

    )
)
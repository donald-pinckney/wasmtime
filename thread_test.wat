(module
    ;; Import the required fd_write WASI function which will write the given io vectors to stdout
    ;; The function signature for fd_write is:
    ;; (File Descriptor, *iovs, iovs_len, nwritten) -> Returns number of bytes written
    (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

    (memory 1)
    (export "memory" (memory 0))

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
            br 0
        )
    )

    (func $loopB
        (loop
            call $printB
            br 0
        )
    )


    (func $restore7 (param i64 i64)
        get_local 0 ;; First param is the continuation ID
        i64.const 7
        restore
    )


    ;; At memory index 32 is stored the next head pointer (where to store the next enqueued value)
    ;; At memory index 36 is stored the current tail pointer (where to dequeue from)
    ;; The actual queue starts at memory index 40
    (func $queue_init
        (i32.store (i32.const 32) (i32.const 40))
        (i32.store (i32.const 36) (i32.const 40)) ;; dequeue index starts off of the queue, sketch but works for now
    )

    (func $enqueue (param i64)
        (i32.load (i32.const 32))
        get_local 0
        i64.store

        
        (i32.store (i32.const 32) (i32.add (i32.load (i32.const 32)) (i32.const 8)))
    )

    (func $dequeue (result i64)
        (i64.load (i32.load (i32.const 36)))
        (i32.store (i32.const 36) (i32.add (i32.load (i32.const 36)) (i32.const 8) ))
    )

    ;; (func $kthread_init
    
    ;; )

    ;; (func $kthread_create)

    (func $main (export "_start")
        ;; (control $restore7)
        
        
    
        ;; Creating a new io vector within linear memory
        (i32.store (i32.const 0) (i32.const 16))  ;; iov.iov_base - This is a pointer to the start of the 'hello world\n' string
        (i32.store (i32.const 4) (i32.const 2))  ;; iov.iov_len - The length of the 'hello world\n' string

        call $queue_init

        (call $enqueue (i64.const 3))
        (call $enqueue (i64.const 1))
        (call $enqueue (i64.const 3))
        (call $enqueue (i64.const 7))
        (call $print_d (call $dequeue))
        (call $enqueue (i64.const 8))
        (call $print_d (call $dequeue))
        (call $enqueue (i64.const 2))
        (call $print_d (call $dequeue))
        (call $print_d (call $dequeue))
        (call $print_d (call $dequeue))
        (call $print_d (call $dequeue))


        (call $print_d (i64.const 0))
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
(module
    ;; Import the required fd_write WASI function which will write the given io vectors to stdout
    ;; The function signature for fd_write is:
    ;; (File Descriptor, *iovs, iovs_len, nwritten) -> Returns number of bytes written
    (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

    (memory 1)
    (export "memory" (memory 0))

    ;; Write 'hello world\n' to memory at an offset of 8 bytes
    ;; Note the trailing newline which is required for the text to appear
    (data (i32.const 8) "hello world\n")

    (func $do_print
        (call $fd_write
            (i32.const 1) ;; file_descriptor - 1 for stdout
            (i32.const 0) ;; *iovs - The pointer to the iov array, which is stored at memory location 0
            (i32.const 1) ;; iovs_len - We're printing 1 string stored in an iov - so one.
            (i32.const 20) ;; nwritten - A place in memory to store the number of bytes writen
        )
        drop
    )

    (func $max (param i64 i64) (result i64)
        block
            get_local 0
            get_local 1
            i64.sub
            i64.const 0
            i64.le_s
            br_if 0
            get_local 0
            return
        end
        get_local 1
    )

    (func $otherRestore7 (param i64)
        get_local 0
        i64.const 7
        restore
    )

;;     (func $restore42 (param i64 i64)
;;         (call $do_print)
;; ;;
;;         get_local 0
;;         ;; (call $otherRestore7)
;;         ;; i64.const 7
;;         ;; restore
;;     )


    (func $restore42 (param i64 i64)
        get_local 0 ;; First param is the continuation ID
        i64.const 42
        restore
    )

    (func $main (export "_start")
        (control $restore7)
        
        
    
        ;; Creating a new io vector within linear memory
        (i32.store (i32.const 0) (i32.const 8))  ;; iov.iov_base - This is a pointer to the start of the 'hello world\n' string
        (i32.store (i32.const 4) (i32.const 12))  ;; iov.iov_len - The length of the 'hello world\n' string

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


        (control $restore7)
        drop

        ;; vs.

        ;; (call $do_print)



        ;; (longjmp (i32.const 32) (i64.const 6))

        ;; ;; (setjmp (i32.const 0))
        ;; drop ;; Discard the number of bytes written from the top the stack

        ;; (longjmp (i32.const 32) (i64.const 5))
    )
)
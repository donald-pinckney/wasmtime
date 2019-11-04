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

    (func $main (export "_start")
        ;; Creating a new io vector within linear memory
        (i32.store (i32.const 0) (i32.const 8))  ;; iov.iov_base - This is a pointer to the start of the 'hello world\n' string
        (i32.store (i32.const 4) (i32.const 12))  ;; iov.iov_len - The length of the 'hello world\n' string

        ;; ;; ;; (i32.const 1294967296)
        ;; (setjmp (i32.const 32))
        ;; ;; ;; (i32.const 0)
        ;; drop



        ;; ;; (longjmp (i32.const 56) (i64.const 59))

        (i32.store (i32.const 9) (i32.add 
        							(i32.const 65) 
        							(i32.wrap/i64 (setjmp (i32.const 32))  )   ;; (setjmp (i32.const 0))
        						)) ;; 65

        (call $fd_write
            (i32.const 1) ;; file_descriptor - 1 for stdout
            (i32.const 0) ;; *iovs - The pointer to the iov array, which is stored at memory location 0
            (i32.const 1) ;; iovs_len - We're printing 1 string stored in an iov - so one.
            (i32.const 20) ;; nwritten - A place in memory to store the number of bytes writen
        )
        drop

        (longjmp (i32.const 32) (i64.const 6))

        ;; ;; (setjmp (i32.const 0))
        ;; drop ;; Discard the number of bytes written from the top the stack

        ;; (longjmp (i32.const 32) (i64.const 5))
    )
)
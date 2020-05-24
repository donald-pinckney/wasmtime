use std::process::Command;
use std::env;
use std::fs::File;

fn main() {
    println!("cargo:rerun-if-changed=signalhandlers/SignalHandlers.cpp");
    println!("cargo:rerun-if-changed=signalhandlers/SignalHandlers.hpp");
    println!("cargo:rerun-if-changed=signalhandlers/Trampolines.cpp");
    let target = std::env::var("TARGET").unwrap();
    let mut build = cc::Build::new();
    build
        .cpp(true)
        .warnings(false)
        .file("signalhandlers/SignalHandlers.cpp")
        .file("signalhandlers/Trampolines.cpp");
    if !target.contains("windows") {
        build
            .flag("-std=c++11")
            .flag("-fno-exceptions")
            .flag("-fno-rtti");
    }

    build.compile("signalhandlers");


    println!("cargo:rerun-if-changed=conts/conts.c");
    let mut build = cc::Build::new();
    build
        .warnings(true)
        .file("conts/conts.c")
        .opt_level(3)
        .debug(false);
        // .file("conts/conts.s");
    
    build.compile("conts");


    println!("cargo:rerun-if-changed=src/continuations.s");
    let out_dir = env::var("OUT_DIR").unwrap();
    let asm_dep_file = &(out_dir.clone() + "/continuations_machine_dep.s");

    #[cfg(target_os = "macos")]
    // copy continuations.s to machine-dependent place
    Command::new("cp").args(&["src/continuations.s", asm_dep_file]).status().unwrap().success();
    #[cfg(target_os = "linux")]
    {
        //sed 's/_control/control/g' src/continuations.s
        let replace_cmd = "s/_control/control/g; s/_restore/restore/g; s/_current_stack_top/current_stack_top/g; s/_current_prompt_depth/current_prompt_depth/g; s/_cont_table/cont_table/g; s/_alloc_cont_id/alloc_cont_id/g; s/_alloc_stack/alloc_stack/g; s/_dealloc_cont_id/dealloc_cont_id/g; s/_dealloc_stack/dealloc_stack/g";
        let out_f = File::create(asm_dep_file).unwrap();
        Command::new("sed").stdout(out_f).args(&[replace_cmd, "src/continuations.s"]).status().unwrap().success();
    }

    if !(Command::new("clang").args(&["-o", &(out_dir.clone() + "/continuations.o"),
                                   "-x", "assembler",
                                   "-integrated-as",
                                   "-c",
                                   asm_dep_file])
                           .status().unwrap().success() &&
         Command::new("ar").args(&["-crus",
                                   &(out_dir.clone() + "/libcontinuations.a"),
                                   &(out_dir.clone() + "/continuations.o")])
                            .status().unwrap().success()) {
      panic!("failed");
    }
    println!("cargo:rustc-link-search=native={}", out_dir);
    println!("cargo:rustc-link-lib=static=continuations");
}

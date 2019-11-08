use std::process::Command;
use std::env;

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
        .file("conts/conts.c");
        // .file("conts/conts.s");
    
    build.compile("conts");


    println!("cargo:rerun-if-changed=src/continuations.s");
    let out_dir = env::var("OUT_DIR").unwrap();
    if !(Command::new("as").args(&["-o", &(out_dir.clone() + "/continuations.o"),
                                   "src/continuations.s"])
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

#![warn(clippy::all)]
#![warn(clippy::pedantic)]
#![warn(clippy::undocumented_unsafe_blocks)]
#![allow(clippy::cast_possible_truncation)]
#![allow(unknown_lints)]
#![warn(missing_copy_implementations)]
#![warn(missing_debug_implementations)]
#![warn(missing_docs)]
#![warn(rust_2018_idioms)]
#![warn(trivial_casts, trivial_numeric_casts)]
#![warn(unsafe_op_in_unsafe_fn)]
#![warn(unused_qualifications)]
#![warn(variant_size_differences)]

//! A minimal CLI for invoking [`minify_html`].
//!
//! This tool replaces [`@minify-html/node`] as part of the hyperbola-static
//! build process. The npm package includes pre-built binaries and does not
//! include an aarch64-macos-darwin binary.
//!
//! This tool does not expose any command line options or flags. It hardcodes
//! the configuration previously used in `build.mjs`.
//!
//! The tool accepts an arbitrary number of paths as positional arguments and
//! will minify these paths in place.
//!
//! [`@minify-html/node`]: https://www.npmjs.com/package/@minify-html/node

use std::env;
use std::fs::File;
use std::io::{self, Read, Write};
use std::path::Path;
use std::process;
use std::sync::{Mutex, PoisonError};

use rayon::prelude::*;

use minify_html::{minify, Cfg};

macro_rules! io_expect {
    ($path:expr, $expr:expr, $tx:expr $(,)?) => {
        match $expr {
            Ok(r) => r,
            Err(e) => {
                let mut errors = $tx.lock().unwrap_or_else(PoisonError::into_inner);
                errors.push(($path.to_owned(), e));
                return;
            }
        }
    };
}

fn main() {
    if let Some(workspace_root) = env::var_os("BUILD_WORKSPACE_DIRECTORY") {
        if let Err(e) = env::set_current_dir(&workspace_root) {
            let _ignore = writeln!(
                io::stderr(),
                "Failed to change directory to bazel workspace root '{}': {}",
                Path::new(&workspace_root).display(),
                e,
            );
            process::exit(1);
        }
    }

    let cfg = Cfg {
        do_not_minify_doctype: true,
        ensure_spec_compliant_unquoted_attribute_values: true,
        keep_closing_tags: true,
        keep_comments: false,
        keep_html_and_head_opening_tags: true,
        keep_spaces_between_attributes: true,
        minify_css: true,
        minify_js: true,
        remove_bangs: false,
        remove_processing_instructions: false,
    };

    let sources = env::args_os().skip(1).collect::<Vec<_>>();

    let errors = Mutex::new(Vec::with_capacity(sources.len()));

    // Loop over all provided sources and execute the following to reformat in
    // place:
    //
    // - Open the file.
    // - Read the file as as bytes.
    // - Minify the source code with `minify_html::minify`.
    // - Reopen the file in create mode to truncate it.
    // - Write the entire minified contents back into the file.
    // - Print success.
    sources.par_iter().for_each(|input| {
        let path = Path::new(input);

        let mut src_file = io_expect!(path, File::open(input), errors);

        let mut src_code = Vec::<u8>::new();
        io_expect!(path, src_file.read_to_end(&mut src_code), errors);

        let out_code = minify(&src_code, &cfg);

        let mut out_file = io_expect!(path, File::create(input), errors);
        io_expect!(path, out_file.write_all(&out_code), errors);
    });

    let errors = errors.into_inner().unwrap_or_else(PoisonError::into_inner);
    if !errors.is_empty() {
        for (path, e) in errors {
            let _ignore = writeln!(io::stderr(), "KO {}: Failed to minify: {e}", path.display());
        }
        process::exit(1);
    }

    let _ignore = writeln!(io::stdout(), "OK: minified {} HTML sources", sources.len());
}

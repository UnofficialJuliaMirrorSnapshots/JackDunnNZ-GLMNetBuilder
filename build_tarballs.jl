# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "GLMNet"
version = v"5.0.0"

# Collection of sources required to build GLMNet
sources = [
    "https://github.com/JuliaStats/GLMNet.jl.git" =>
    "3030d4f6e034dca06f25b1343a33b9c799cda7f7",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/GLMNet.jl/deps/

flags="-fdefault-real-8 -ffixed-form -shared -O3"
if [[ ${target} != *mingw* ]]; then
     flags="${flags} -fPIC"
fi
if [[ ${target} != aarch64* ]] && [[ ${target} != arm* ]]; then
     flags="${flags} -m${nbits}"
fi

libdir=$prefix/lib
if [[ ${target} == *mingw* ]]; then
     libdir=$prefix/bin
fi

${FC} ${LDFLAGS} ${flags} glmnet5.f90 -o libglmnet.${dlext}

mkdir -p $libdir
mv libglmnet.${dlext} $libdir/

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    Linux(:aarch64, libc=:glibc),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    Linux(:powerpc64le, libc=:glibc),
    Linux(:i686, libc=:musl),
    Linux(:x86_64, libc=:musl),
    Linux(:aarch64, libc=:musl),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf),
    MacOS(:x86_64),
    FreeBSD(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]
platforms = expand_gcc_versions(platforms)

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libglmnet", :libglmnet)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)


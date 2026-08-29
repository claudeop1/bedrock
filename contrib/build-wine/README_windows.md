# Running Bedrock from source on Windows (development version)

## Prerequisites

- [python3](https://www.python.org/)
- [git](https://gitforwindows.org/)

## Main steps

### 1. Check out the code from GitHub:
```
> git clone https://github.com/spesmilo/bedrock.git
> cd bedrock
> git submodule update --init
```

Run install (this should install most dependencies):
```
> python3 -m pip install --user -e ".[gui,crypto]"
```

### 2. Install `libsecp256k1`

[comment]: # (technically the dll should be put into site-packages/bedrock_ecc/,
but putting it into bedrock/ also works because of the `os.add_dll_directory` call in
bedrock/__init__.py)

[libsecp256k1](https://github.com/bitcoin-core/secp256k1) is a required dependency.
This is a C library, which you need to compile yourself.
Bedrock needs a dll, named `libsecp256k1-0.dll` (or newer `libsecp256k1-*.dll`),
placed into the inner `bedrock/` folder.

For Unix-like systems, the (`contrib/make_libsecp256k1.sh`) script does this for you,
however it does not work on Windows.
If you have access to a Linux machine (e.g. VM) or perhaps even using
WSL (Windows Subsystem for Linux), you can cross-compile from there to Windows,
and build this dll:
```
$ GCC_TRIPLET_HOST="x86_64-w64-mingw32" ./contrib/make_libsecp256k1.sh
```

Alternatively, MSYS2 and MinGW-w64 can be used directly on Windows, as follows.

- download and install [MSYS2](https://www.msys2.org/)
- run MSYS2
- inside the MSYS2 shell:
  ```
  $ pacman -Syu
  $ pacman -S --needed git base-devel mingw-w64-x86_64-toolchain mingw-w64-x86_64-autotools
  $ export PATH="$PATH:/mingw64/bin"
  ```
  `cd` into the git clone, e.g. `C:\wspace\bedrock` (auto-mounted at `/c/wspace/bedrock`)
  ```
  $ cd /c/wspace/bedrock
  $ GCC_TRIPLET_HOST="x86_64-w64-mingw32" ./contrib/make_libsecp256k1.sh
  ```

(note: this is a bit cumbersome, see [issue #5976](https://github.com/spesmilo/bedrock/issues/5976)
for discussion)

### 3. Run bedrock:

```
> python3 ./run_bedrock
```


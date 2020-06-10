# Scripts to test the QEMU Arm xPack

The binaries can be available from one of the pre-releases:

https://github.com/xpack-dev-tools/pre-releases/releases

## Download the repo

The test script is part of the QEMU Arm xPack:

```console
$ curl -L https://github.com/xpack-dev-tools/qemu-arm-xpack/raw/xpack/scripts/git-clone.sh | bash

To use the development branch, issue the following:

```bash
rm -rf ~/Downloads/qemu-arm-xpack.git
git clone --recurse-submodules -b xpack-develop \
  https://github.com/xpack-dev-tools/qemu-arm-xpack.git  \
  ~/Downloads/qemu-arm-xpack.git
```

## Start a local test

To check if QEMU Arm starts on the current platform, run a native test:

```bash
bash ~/Downloads/qemu-arm-xpack.git/tests/scripts/native-test.sh \
  https://github.com/xpack-dev-tools/pre-releases/releases/download/test/
```

The script stores the downloaded archive in a local cache, and
does not download it again if available locally.

To force a new download, remove the local archive:

```console
rm ~/Work/cache/xpack-qemu-arm-*
```

## Start the Travis test

The multi-platform test runs on Travis CI; it is configured to not fire on
git actions, but only via a manual POST to the Travis API.

```bash
bash ~/Downloads/qemu-arm-xpack.git/tests/scripts/travis-trigger-stable.sh
bash ~/Downloads/qemu-arm-xpack.git/tests/scripts/travis-trigger-latest.sh
```

For convenience, on macOS this can be invoked from Finder, using
the `travis-trigger-stable.mac.command` and
`travis-trigger-latest.mac.command` shortcuts.

The test results are available at
[Travis](https://travis-ci.org/github/xpack-dev-tools/qemu-arm-xpack/builds/).

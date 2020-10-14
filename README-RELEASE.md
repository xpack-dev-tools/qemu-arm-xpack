# How to make a new release

## Prepare the build

Before starting the build, perform some checks and tweaks.

### Check Git

- switch to the `xpack-develop` branch
- if needed, merge the `xpack` branch

### Increase the version

- open the `VERSION` file
- increase the numbers

### Fix possible open issues

Check GitHub issues and pull requests:

- https://github.com/xpack-dev-tools/qemu-arm-xpack/issues
- https://github.com/xpack-dev-tools/qemu/issues

and fix them; do not close them yet.

### Update the `CHANGELOG.md` file

- open the `CHANGELOG.md` file
- check if all previous fixed issues are in
- add a new entry like _v2.8.0-10 prepared_

Note: if you missed to update the `CHANGELOG.md` before starting the build,
edit the file and rerun the build, it should take only a few minutes to
recreate the archives with the correct file.

### Update the version specific code

- open the `common-versions-source.sh` file
- add a new `if` with the new version before the existing code
- update the QEMU_GIT_COMMIT

## Push the build script

In this Git repo:

- push the `xpack-develop` branch to GitHub
- possibly push the helper project too

## Build

### Clean the destination folder

Clear the folder where the binaries from all build machines will be collected.

```console
$ rm -f ~/Downloads/xpack-binaries/qemu/*
```

### Pre-run the build scripts

Before the real build, run a test build on the development machine:

```console
$ sudo rm -rf ~/Work/qemu-arm-*
$ caffeinate bash ~/Downloads/qemu-arm-xpack.git/scripts/build.sh --develop --without-pdf --linux64 --win64 --linux32 --win32
```

### Run the build scripts

Move to the three production machines.

On the macOS build machine, create three new terminals.

Connect to the Intel Linux:

```console
$ caffeinate ssh xbbi
```

Connect to the Arm Linux:

```console
$ caffeinate ssh xbba
```

On all machines, clone the `xpack-develop` branch:

```console
$ rm -rf ~/Downloads/qemu-arm-xpack.git; \
  git clone --recurse-submodules --branch xpack-develop \
  https://github.com/xpack-dev-tools/qemu-arm-xpack.git \
  ~/Downloads/qemu-arm-xpack.git
```

Remove any previous build:

```console
$ sudo rm -rf ~/Work/qemu-arm-*
```

On the Linux machines:

```console
$ bash ~/Downloads/qemu-arm-xpack.git/scripts/build.sh --all
```

On the macOS machine:

```console
$ caffeinate bash ~/Downloads/qemu-arm-xpack.git/scripts/build.sh --osx
```

Copy the binaries to the development machine.

On all three machines:

```console
$ (cd ~/Work/qemu-arm-*/deploy; scp * ilg@wks:Downloads/xpack-binaries/qemu)
```

## Test

Install the binaries on all supported platforms and check if they are
functional, using the Eclipse STM32F4DISCOVERY blinky test.

The QEMU tests are available in a separate repo:

```
$ cd Downloads
$ git clone https://github.com/xpack-dev-tools/qemu-eclipse-test-projects.git qemu-eclipse-test-projects.git
```

## Create a new GitHub pre-release

- commit and push the `xpack-develop` branch
- go to the [GitHub Releases](https://github.com/xpack-dev-tools/qemu-arm-xpack/releases) page
- click **Draft a new release**
- name the tag like **v2.8.0-10** (mind the dashes in the middle!)
- select the `xpack-develop` branch
- name the release like **xPack QEMU Arm v2.8.0-10**
(mind the dashes)
- as description
  - add a downloads badge like `![Github Releases (by Release)](https://img.shields.io/github/downloads/xpack-dev-tools/qemu-arm-xpack/v2.8.0-10/total.svg)`
  - draft a short paragraph explaining what are the main changes
- **attach binaries** and SHA (drag and drop from the archives folder will do it)
- **enable** the **pre-release** button
- click the **Publish Release** button

Note: at this moment the system should send a notification to all clients watching this project.

## Run the Travis tests

Using the scripts in `tests/scripts/`, start:

- trigger-travis-quick.mac.command (optional)
- trigger-travis-stable.mac.command
- trigger-travis-latest.mac.command

The test results are available from:

- https://travis-ci.org/github/xpack-dev-tools/qemu-arm-xpack

For more details, see `tests/scripts/README.md`.

## Prepare a new blog post

In the `xpack.github.io` web Git:

- select the `xpack-develop` branch
- add a new file to `_posts/qemu-arm/releases`
- name the file like `2020-10-14-qemu-arm-v2-8-0-10-released.md`
- name the post like: **xPack QEMU Arm v2.8.0-10 released**.
- as `download_url` use the tagged URL like `https://github.com/xpack-dev-tools/qemu-arm-xpack/releases/tag/v2.8.0-10/`
- update the `date:` field with the current date
- update the Travis URLs using the actual test pages

If any, close
[build issues](https://github.com/xpack-dev-tools/qemu-arm-xpack/issues)
on the way. Refer to them as:

- **[Issue:\[#1\]\(...\)]**.

Also close
[functional issues](https://github.com/xpack-dev-tools/qemu/issues).

## Update the SHA sums

Copy/paste the build report at the end of the post as:

```console
## Checksums
The SHA-256 hashes for the files are:

856f8970b0a159d9a1bbf56709f3a5f32a26c2448948d51f82b4b3f7d949f7bd  
xpack-qemu-arm-2.8.0-10-darwin-x64.tar.gz

c8c8b3e22f2d508f60440018c48171f11d7cf0b384b5b2131017f1c1f7742a44  
xpack-qemu-arm-2.8.0-10-linux-arm64.tar.gz

8503d11a833e1d13c43d8d444a69984b9416d6cf05663f68ec0e2f01ceab448a  
xpack-qemu-arm-2.8.0-10-linux-arm.tar.gz

ad073b730a2d4366f562fa15b91ad6e02c212fa693d7677921fc343c23cba111  
xpack-qemu-arm-2.8.0-10-linux-x32.tar.gz

ce5979e96c84255a818eac360f83e7739673f3d842c700cad29b70eac8c67ee6  
xpack-qemu-arm-2.8.0-10-linux-x64.tar.gz

5c811889b6b182b1767a89c21793a7cccfa4fdf8914efb616155df2b0e505f4a  
xpack-qemu-arm-2.8.0-10-win32-x32.zip

3bc5ec953227112b45c36713083e1dbba4d3a6d3d917eb617694217e8cfc8b00  
xpack-qemu-arm-2.8.0-10-win32-x64.zip
```

If you missed this, `cat` the content of the `.sha` files:

```console
$ ~Downloads/xpack-binaries/qemu
$ cat *.sha
```

## Update the Web

- commit the `develop` branch of `xpack.github.io` web Git; use a message
  like **xPack QEMU Arm v2.8.0-10 released**
- wait for the GitHub Pages build to complete
- the preview web is https://xpack.github.io/web-preview/

## Publish on the npmjs server

- select the `xpack-develop` branch
- open the `package.json` file
- open [GitHub Releases](https://github.com/xpack-dev-tools/qemu-arm-xpack/releases)
  and select the latest release
- update the `baseUrl:` with the file URLs (including the tag/version)
- from the release, copy the SHA & file names
- commit all changes, use a message like
`package.json: update urls for 2.8.0-10 release` (without `v`)
- check the latest commits `npm run git-log`
- update `CHANGELOG.md`; commit with a message like
  _CHANGELOG: prepare npm v2.8.0-10.1_
- `npm version 2.8.0-10.1`; the first 4 numbers are the same as the
  GitHub release; the fifth number is the npm specific version
- `npm pack` and check the content of the archive, which should list
only the `package.json`, the `README.md`, `LICENSE` and `CHANGELOG.md`
- push all changes to GitHub
- `npm publish --tag next` (use `--access public` when publishing
for the first time)

## Test if the npm binaries can be installed with xpm

Run the `tests/scripts/trigger-travis-xpm-install.sh` file, this
will install the package on Intel Linux 64-bit, macOS and Windows 64-bit.

For 32-bit Windows, 32-bit Intel GNU/Linux and 32-bit Arm, install manually.

```console
$ xpm install --global @xpack-dev-tools/openocd@next
```

## Test the npm binaries

Install the binaries on all platforms:

```console
$ xpm install --global @xpack-dev-tools/qemu-arm@next
```

On platforms where Eclipse is available, use the
`arm-f4b-fs-debug-qemu` debug luncher available in the `arm-f4b-fs` Eclipse
project available in the `xpack-dev-tools/arm-none-eabi-gcc-xpack` GitHub
project.

On Arm 32-bit, where Eclipse is not available, run the
tests by manually starting the
blinky test on the emulated STM32F4DISCOVERY board.

```
~/opt/xPacks/@xpack-dev-tools/qemu-arm/2.8.0-10.1/.content/bin/qemu-system-gnuarmeclipse --version

mkdir -p ~/Downloads
(cd ~/Downloads; curl -L --fail -o f407-disc-blink-tutorial.elf \
https://github.com/xpack-dev-tools/qemu-eclipse-test-projects/raw/master/f407-disc-blink-tutorial/Debug/f407-disc-blink-tutorial.elf)

~/opt/xPacks/@xpack-dev-tools/qemu-arm/2.8.0-10.1/.content/bin/qemu-system-gnuarmeclipse \
--board STM32F4-Discovery \
-d unimp,guest_errors \
--nographic \
--image ~/Downloads/f407-disc-blink-tutorial.elf \
--semihosting-config enable=on,target=native \
--semihosting-cmdline test 6

DISPLAY=:1.0 ~/opt/xPacks/@xpack-dev-tools/qemu-arm/2.8.0-10.1/.content/bin/qemu-system-gnuarmeclipse \
--board STM32F4-Discovery \
-d unimp,guest_errors \
--image ~/Downloads/f407-disc-blink-tutorial.elf \
--semihosting-config enable=on,target=native \
--semihosting-cmdline test 6

```

## Update the repo

- merge `xpack-develop` into `xpack`
- push

## Promote next to latest

Promote the release as `latest`:

- `npm dist-tag ls @xpack-dev-tools/qemu-arm`
- `npm dist-tag add @xpack-dev-tools/qemu-arm@2.8.0-10.1 latest`
- `npm dist-tag ls @xpack-dev-tools/qemu-arm`

## Update the Web

- in the `master` branch, merge the `develop` branch
- wait for the GitHub Pages build to complete
- the result is in https://xpack.github.io/news/
- remember the post URL, since it must be updated in the release page

## Create the final GitHub release

- go to the [GitHub Releases](https://github.com/xpack-dev-tools/qemu-arm-xpack/releases) page
- check the download counter, it should match the number of tests
- add a link to the Web page `[Continue reading »]()`; use an same blog URL
- **disable** the **pre-release** button
- click the **Update Release** button

## Share on Twitter

- in a separate browser windows, open [TweetDeck](https://tweetdeck.twitter.com/)
- using the `@xpack_project` account
- paste the release name like **xPack QEMU Arm v2.8.0-10 released**
- paste the link to the blog release URL
- click the **Tweet** button

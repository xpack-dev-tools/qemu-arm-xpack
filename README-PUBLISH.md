# How to publish the xPack QEMU Arm?

## Build

Before starting the build, perform some checks.

### Check possible open issues

Check GitHub [issues](https://github.com/xpack-dev-tools/qemu-arm-xpack/issues)
and fix them; do not close them yet.

### Check the `CHANGELOG.md` file

Open the `CHANGELOG.md` file and and check if all
new entries are in.

Note: if you missed to update the `CHANGELOG.md` before starting the build,
edit the file and rerun the build, it should take only a few minutes to
recreate the archives with the correct file.

### Check the version

The `VERSION` file should refer to the actual release.

## Push the build script

In this Git repo:

- if necessary, merge the `xpack-develop` branch into `xpack`.
- push it to GitHub.
- possibly push the helper project too.

### Run the build scripts

When everything is ready, follow the instructions from the
[build](https://github.com/xpack-dev-tools/qemu-arm-xpack/blob/xpack/README-BUILD.md)
page.

## Test

Install the binaries on all supported platforms and check if they are
functional, using the Eclipse STM32F4DISCOVERY blinky test.

The QEMU tests are available in a separate repo:

```
$ cd Downloads
$ git clone https://github.com/xpack-dev-tools/qemu-eclipse-test-projects.git qemu-eclipse-test-projects.git
```

## Create a new GitHub pre-release

- in `CHANGELOG.md`, add release date
- commit and push the repo
- go to the [GitHub Releases](https://github.com/xpack-dev-tools/qemu-arm-xpack/releases) page
- click **Draft a new release**
- name the tag like **v2.8.0-9** (mind the dashes in the middle!)
- select the `xpack` branch
- name the release like **xPack QEMU Arm v2.8.0-9**
(mind the dashes)
- as description
  - add a downloads badge like `![Github Releases (by Release)](https://img.shields.io/github/downloads/xpack-dev-tools/qemu-arm-xpack/v2.8.0-9/total.svg)`
  - draft a short paragraph explaining what are the main changes
- **attach binaries** and SHA (drag and drop from the archives folder will do it)
- **enable** the **pre-release** button
- click the **Publish Release** button

Note: at this moment the system should send a notification to all clients watching this project.

## Run the Travis tests

As URL, use something like

```
base_url="https://github.com/xpack-dev-tools/qemu-arm-xpack/releases/download/v2.8.0-9/"
```

The tests results are available at
[Travis](https://travis-ci.org/github/xpack-dev-tools/qemu-arm-xpack/builds/).

For more details, see `tests/scripts/README.md`.

## Prepare a new blog post

In the `xpack.github.io` web Git:

- add a new file to `_posts/qemu-arm/releases`
- name the file like `020-07-01-qemu-arm-v2-8-0-9-released.md`
- name the post like: **xPack QEMU Arm v2.8.0-9 released**.
- as `download_url` use the tagged URL like `https://github.com/xpack-dev-tools/qemu-arm-xpack/releases/tag/v2.8.0-9/`
- update the `date:` field with the current date

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
xpack-qemu-arm-2.8.0-9-darwin-x64.tar.gz

c8c8b3e22f2d508f60440018c48171f11d7cf0b384b5b2131017f1c1f7742a44  
xpack-qemu-arm-2.8.0-9-linux-arm64.tar.gz

8503d11a833e1d13c43d8d444a69984b9416d6cf05663f68ec0e2f01ceab448a  
xpack-qemu-arm-2.8.0-9-linux-arm.tar.gz

ad073b730a2d4366f562fa15b91ad6e02c212fa693d7677921fc343c23cba111  
xpack-qemu-arm-2.8.0-9-linux-x32.tar.gz

ce5979e96c84255a818eac360f83e7739673f3d842c700cad29b70eac8c67ee6  
xpack-qemu-arm-2.8.0-9-linux-x64.tar.gz

5c811889b6b182b1767a89c21793a7cccfa4fdf8914efb616155df2b0e505f4a  
xpack-qemu-arm-2.8.0-9-win32-x32.zip

3bc5ec953227112b45c36713083e1dbba4d3a6d3d917eb617694217e8cfc8b00  
xpack-qemu-arm-2.8.0-9-win32-x64.zip
```

If you missed this, `cat` the content of the `.sha` files:

```console
$ cd deploy
$ cat *.sha
```

## Update the Web

- commit the `xpack.github.io` web Git; use a message
  like **xPack QEMU Arm v2.8.0-9 released**
- adjust timestamps
- wait for the GitHub Pages build to complete
- remember the post URL, since it must be updated in the release page

## Publish on the npmjs server

- open [GitHub Releases](https://github.com/xpack-dev-tools/qemu-arm-xpack/releases)
  and select the latest release
- update the `baseUrl:` with the file URLs (including the tag/version)
- from the release, copy the SHA & file names
- commit all changes, use a message like `package.json: update urls for 2.8.0-9 release` (without `v`)
- check the latest commits `npm run git-log`
- update `CHANGELOG.md`; commit with a message like
  _CHANGELOG: prepare npm v2.8.0-9.1_
- `npm version 2.8.0-9.1`; the first 4 numbers are the same as the
  GitHub release; the fifth number is the npm specific version
- `npm pack` and check the content of the archive
- push all changes to GitHub
- `npm publish --tag next` (use `--access public` when publishing for the first time)

When the release is considered stable, promote it as `latest`:

- `npm dist-tag ls @xpack-dev-tools/qemu-arm`
- `npm dist-tag add @xpack-dev-tools/qemu-arm@2.8.0-9.1 latest`
- `npm dist-tag ls @xpack-dev-tools/qemu-arm`

## Test npm binaries

Install the binaries on all platforms.

```console
$ xpm install --global @xpack-dev-tools/qemu-arm@next
```

## Create the final GitHub release

- go to the [GitHub Releases](https://github.com/xpack-dev-tools/qemu-arm-xpack/releases) page
- check the download counter, it should match the number of tests
- add a link to the Web page `[Continue reading »]()`; use an same blog URL
- **disable** the **pre-release** button
- click the **Update Release** button

## Share on Twitter

- in a separate browser windows, open [TweetDeck](https://tweetdeck.twitter.com/)
- using the `@xpack_project` account
- paste the release name like **xPack QEMU Arm v2.8.0-9 released**
- paste the link to the blog release URL
- click the **Tweet** button

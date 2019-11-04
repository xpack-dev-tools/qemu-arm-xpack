# How to publish the xPack QEMU Arm?

## Build

Before starting the build, perform some checks.

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

- go to the [GitHub Releases](https://github.com/xpack-dev-tools/qemu-arm-xpack/releases) page
- click **Draft a new release**
- name the tag like **v2.8.0-7** (mind the dashes in the middle!)
- select the `xpack` branch
- name the release like **xPack QEMU Arm v2.8.0-7**
(mind the dashes)
- as description
  - add a downloads badge like `![Github Releases (by Release)](https://img.shields.io/github/downloads/xpack-dev-tools/qemu-arm-xpack/v2.8.0-7/total.svg)`
  - draft a short paragraph explaining what are the main changes
- **attach binaries** and SHA (drag and drop from the archives folder will do it)
- **enable** the **pre-release** button
- click the **Publish Release** button

Note: at this moment the system should send a notification to all clients watching this project.

## Prepare a new blog post

In the `xpack.github.io` web Git:

- add a new file to `_posts/qemu-arm/releases`
- name the file like `2018-07-22-qemu-arm-v2-8-0-7-released.md`
- name the post like: **xPack QEMU Arm v2.8.0-7 released**.
- as `download_url` use the tagged URL like `https://github.com/xpack-dev-tools/qemu-arm-xpack/releases/tag/v2.8.0-7/`
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

956da5f621df33b3c881b50316f197afb0df1edf59a87e295b8632085ccdd6a2
xpack-qemu-arm-2.8.0-7-darwin-x64.tgz

c116a9dcd220e66258d2e9842d672fbe065dedad7ae3e09b1afe4f254bd5ac6e
xpack-qemu-arm-2.8.0-7-linux-x32.tgz

cb1c2b9e9b4256e0d3ae29582e684364ec100bfb5a5bb814842f774855f8f9ac
xpack-qemu-arm-2.8.0-7-linux-x64.tgz

8ae176c652bf281a8868b8fcc69bdd27ea995736b62aa4ffb8762a95e40fd742
xpack-qemu-arm-2.8.0-7-win32-x32.zip

24a68b94b347169428041ec1b09f40774ca9afa7d52caa979efeabece33596b1
xpack-qemu-arm-2.8.0-7-win32-x64.zip
```

If you missed this, `cat` the content of the `.sha` files:

```console
$ cd deploy
$ cat *.sha
```

## Update the Web

- commit the `xpack.github.io` web Git; use a message
  like **xPack QEMU Arm v2.8.0-7 released**
- wait for the GitHub Pages build to complete
- remember the post URL, since it must be updated in the release page

## Publish on the npmjs server

- open [GitHub Releases](https://github.com/xpack-dev-tools/qemu-arm-xpack/releases)
  and select the latest release
- update the `baseUrl:` with the file URLs (including the tag/version)
- from the release, copy the SHA & file names
- commit all changes, use a message like `package.json: update urls for 2.8.0-7 release` (without `v`)
- update `CHANGELOG.md`; commit with a message like
  _CHANGELOG: prepare npm v2.8.0-7.1_
- `npm version 2.8.0-7.1`; the first 4 numbers are the same as the
  GitHub release; the fifth number is the npm specific version
- `npm pack` and check the content of the archive
- push all changes to GitHub
- `npm publish` (use `--access public` when publishing for the first time)

## Test npm binaries

Install the binaries on all platforms.

```console
$ xpm install --global @xpack-dev-tools/qemu-arm@latest
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
- paste the release name like **xPack QEMU Arm v2.8.0-7.1 released**
- paste the link to the blog release URL
- click the **Tweet** button

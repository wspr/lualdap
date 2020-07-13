# Releases

## Version numbers

In the following `${VERSION}` represents the version to be released.  If
it is a release candidate, it ends in `-rc1`, `-rc2`, and so on.
Example: `VERSION=1.2.4-rc1`

Since LuaRocks does not support dashes in the version string, except for
the build number, we replace eventual dashes (`-`) in `${VERSION}` with
dots (`.`).  With LuaRocks, the version number is followed by a dash and
the build number, which is usually one (`1`), except for release candidates,
where we use zero (`0`).  We use `${LUAROCKS_VERSION}` to represent this
version string below.
Example: `LUAROCKS_VERSION=1.2.4.rc1-0`

Since Windows libraries use a four number versioning scheme without the
possibility for non-digit characters, we use the fourth and last number to
distinguish between releases (`0` in the last position) and release
candidates (previous version number in the first three positions, but `99`,
`999` and so on in the last position).  This number is represented by
`${WINDOWS_VERSION}` in the following.
Example: `WINDOWS_VERSION=1.2.3.99`

Note that for Git tags we prefix `${VERSION}` with `v`.  This is explicit
in the instructions below.

## Release checklist

- [ ] Copy `rockspecs/rockspec` to `rockspecs/lualdap/lualdap-${LUAROCKS_VERSION}.rockspec`
- [ ] In `Makefile` and `Makefile.win` adjust `V` to `${VERSION}` 
- [ ] In `src/lualdap.def` adjust `VERSION` to `${WINDOWS_VERSION}`
- [ ] In `README.md` adjust "Current version" to `${VERSION}` under
    "installation"
- [ ] In `NEWS.md`:
    - [ ] Rename "Unreleased" to `${VERSION}`
    - [ ] Adjust the link for `Unreleased` to show the changelog (commit log)
        between the previous version and `v${VERSION}` and rename it to
        `${VERSION}`
    - [ ] Add a new, empty "Unreleased" section
    - [ ] Add a new link for `Unreleased` to show the changelog between
       `v${VERSION}` and `HEAD`
- [ ] Commit these changes with message "Release v${VERSION}"
- [ ] Tag this commit with `v${VERSION}`

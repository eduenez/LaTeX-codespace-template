# DO NOT EDIT THE FILES IN THIS DIRECTORY

The files here are **vendored copies** of files that are written and maintained in the repository
`eduenez/LaTeX-shared-files` (the shared style packages in `_packages/`, the toolkit in `toolkit/`, which is delivered to
`_scripts/` and `_templates/`). Their checksums are recorded in `vendor.lock`; `make vendor-check` reports any file that was edited.

* Do not edit, rename or delete them here: the next `make update-shared` would overwrite your change.
* To fix or improve one, change it in `LaTeX-shared-files` first (tests, commit, push), then run `make update-shared`
  here (add `APPLY=1` to apply). If you are not the maintainer, describe the problem to Eduardo.

(This note is written by the vendoring tool into every vendored directory. It is not part of `LaTeX-shared-files` itself: where that
repository is used as a git submodule, its files may be edited like those of any other repository.)

# D2 Wishlist

[![Build & Release][badge_svg]][build_yml]

[badge_svg]: https://github.com/ThatGerber/d2wishlist/actions/workflows/update-wishlist.yml/badge.svg
[build_yml]: https://github.com/ThatGerber/d2wishlist/actions/workflows/update-wishlist.yml

Combination of multiple DIM lists into one, with additional permutations.

* [Combined Wishlist, includes Voltron.txt][wishlist_txt]
* [Separate list for my rolls][grrbearr_txt]

[wishlist_txt]: https://raw.githubusercontent.com/ThatGerber/d2wishlist/release/wishlist.txt
[grrbearr_txt]: https://raw.githubusercontent.com/ThatGerber/d2wishlist/release/grrbearr.txt

## Docs

* [Filters](/lib/dim/FILTERS.md)
* [Wishlists](/lib/littlelight/README.md)

## Building

The list will be built on each push to main. It will download the latest from source
lists before compiling the full lists.

It is also scheduled to rebuild every 8 hours with any updates from other lists.

To build the lists manualy, `make` will create the wishlists using the `SRC_FILE_PREFIX`
var (defaults to `GrrBearr`).

Replace the files in `src/` with new files with a common prefix (i.e. `MyUser`) and
update the make var `SRC_FILE_PREFIX=MyUser` to create a new file wit those builds named
`build/myuser.txt`.

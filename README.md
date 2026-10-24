# libw2k: Windows 2000 controls in C

Owner-drawn Windows 2000 look (tokens of the `win2000-style` skill) for a plain Win32 or any other host. C99, no dependencies except the backends.
Extracted from the AFVI TOOLS application (`git@github.com:orangepro2001/AFVI_TOOL.git`), which uses it as a git submodule, with no change of look.

| Layer | Files | Contains |
| --- | --- | --- |
| 0 drawing interface | `w2k_gfx.h` | `w2k_gfx`: fill, gradient, text, text width, clip (five function pointers + text height) |
| 1 tokens and primitives | `w2k.h`, `w2k_draw.c` | colours, six bevel recipes, button/check/tab/group/field/progress/scrollbar/caption primitives, `w2k_font_px`, `w2k_px()` |
| 2 controls | `w2k.h`, `w2k_ctl.c` | button, check/radio, combo + drop list, property sheet, menu bar, popup menu, report list, text view, status bar, dialog frame, window caption; hit regions in a `w2k_hotlist` |
| backend Windows | `w2k_gdi.h/.c` | GDI font and `w2k_gfx` on an HDC. The only file that includes `<windows.h>` |
| backend Linux | `w2k_png.h/.c`, `third_party/stb_truetype.h` | software canvas, PNG writer/reader (zlib), tolerant snapshot comparison |

Layers 0 to 2 never include `<windows.h>` (checked by `grep -lE '#include *<windows.h>' *.[ch]`: only `w2k_gdi.*`): that is what lets the same code render on Linux.

## Using it

```c
w2k_gfx g = w2k_gdi_gfx(hdc);                 /* or w2k_png_gfx() on Linux */
w2k_hot_reset(&hot);
w2k_button(&g, &hot, x, y, w, h, L"OK", ACT_OK, 0, W2K_DEFAULT);
...
int i = w2k_hot_at(&hot, mouse_x, mouse_y);   /* on click: hot.v[i].act / .arg */
```

The library keeps no state: the application owns selection, scroll offsets and open menus, and passes them in each paint. Clicks are resolved with the
hit-region list the controls fill while painting (later regions win, so modal layers register last).

## Tests and demo

`tests/run.sh` builds `demo/demo.c` (a gallery of every control, no application code, no Go) and runs the logic checks (hit list, list scrolling, scaling)
plus a snapshot comparison with `tests/snapshots` (14 px, 14 px with menu and drop list open, 18 px). `--update` rewrites the baselines after a deliberate
look change. Needs gcc, zlib headers and `fonts-dejavu-core`. Tahoma is not on Linux, so the images use DejaVu Sans.

## Not extracted (stays in `gui/app.c`)

- Layout and flow of the application's screens, the plan/job dialogs' contents, the Excel entry, all state and `host_t` (native EDIT fields, timers, core calls).
- Keyboard handling and focus order: it is bound to the application's actions; the library only exposes hit regions.
- Text editing (the app uses native EDIT children for IME); a library edit control would need its own caret, selection and IME code.
- Dark theme, DPI scaling beyond `w2k_font_px`, tree, grid editing, date picker: not needed yet .
- Licence: undecided (no LICENSE file yet, so nobody else may reuse it until you choose one); `third_party/stb_truetype.h` is public domain / MIT (Linux backend only).

## Using it from another project

As a git submodule at `libw2k/` (the AFVI TOOLS way), then compile `w2k_draw.c w2k_ctl.c` with your host and one backend (`w2k_gdi.c` on Windows,
`w2k_png.c` + `-lz` on Linux for tests and previews) with `-Ilibw2k`. Keep your application code free of `<windows.h>` behind a host interface so the
Linux backend can run it too (that is how AFVI TOOLS tests its whole UI on Linux).

## Status

Written against one application. API is not frozen; new controls are added when an application needs them, each with a gallery state and a snapshot.

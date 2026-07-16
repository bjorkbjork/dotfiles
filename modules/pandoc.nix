{ pkgs, config, ... }:

{
  # Markdown → PDF via `md2pdf x.md -o x.pdf` (alias in shell.nix).
  # Defaults use typst as the PDF engine with Noto Sans (see fonts.nix).
  home.packages = with pkgs; [
    pandoc
    typst
  ];

  # typst searches system font dirs, not the nix profile — point it there.
  home.sessionVariables.TYPST_FONT_PATHS =
    "${config.home.profileDirectory}/share/fonts";

  # Generated so the include path follows $HOME (portable across machines).
  xdg.dataFile."pandoc/defaults/defaults.yaml".text = ''
    pdf-engine: typst
    include-before-body:
      - ${config.xdg.dataHome}/pandoc/defaults-body.typst
    variables:
      mainfont: "Noto Sans"
      header-includes: |
        #set table(stroke: 0.5pt)
        #show table: it => {
          // Pandoc centers markdown tables, shrinks small ones to content, and
          // turns separator dash counts of wide ones into hard column widths
          // (|---|---|---| -> equal thirds). Renderers like GitHub ignore all of
          // that, so rebuild every table: columns sized to content, last column
          // takes the remaining page width, unspecified cell alignment -> left.
          let cols = (auto,) * (it.columns.len() - 1) + (1fr,)
          let aligns = if type(it.align) == array {
            it.align.map(a => if a == auto { left } else { a })
          } else { it.align }
          if cols == it.columns and aligns == it.align { it } else {
            table(columns: cols, align: aligns, ..it.children)
          }
        }
  '';

  xdg.dataFile."pandoc/defaults-body.typst".source =
    ../files/pandoc/defaults-body.typst;

  # Not wired into defaults — use ad hoc:
  #   pandoc --lua-filter ~/.local/share/pandoc/filters/unicode-table.lua ...
  xdg.dataFile."pandoc/filters/unicode-table.lua".source =
    ../files/pandoc/unicode-table.lua;
}

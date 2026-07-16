# tmux cheat sheet (for this config)

tmux = terminal multiplexer. One terminal window hosts many shells, and they
**survive disconnects** — close the window, reopen, `tmux attach`, everything
is still running. Invaluable on client/cloud machines.

Mental model: **server → sessions → windows (tabs) → panes (splits)**.

All commands start with the **prefix**: `Ctrl-b`, then release, then the key.
(Written as `C-b x` below.)

## Sessions (the outermost thing)

| | |
|---|---|
| `tmux` | new session |
| `tmux new -s work` | new named session |
| `tmux attach` / `tmux a -t work` | reattach |
| `tmux ls` | list sessions |
| `C-b d` | detach (leave everything running) |

## Windows (like browser tabs)

| | |
|---|---|
| `C-b c` | new window |
| `C-b n` / `C-b p` | next / previous window |
| `C-b 1`..`9` | jump to window (this config starts at 1) |
| `C-b ,` | rename window |
| `C-b w` | interactive window picker |

## Panes (splits — customized in this config)

| | |
|---|---|
| `C-b \|` | split vertically (side by side), keeps current dir |
| `C-b -` | split horizontally (stacked), keeps current dir |
| `C-b h/j/k/l` | move between panes, vim-style |
| `C-b z` | zoom pane to full window (again to unzoom) |
| `C-b x` | kill pane (confirm with `y`) |
| Mouse | click to focus, drag borders to resize (mouse is on) |

## Copy mode (scrollback — vi keys are on)

| | |
|---|---|
| `C-b [` or scroll wheel | enter copy mode |
| `h/j/k/l`, `C-u`/`C-d` | move / half-page |
| `/pattern` | search |
| `Space` then `Enter` | start selection, copy it |
| `C-b ]` | paste |
| `q` | quit copy mode |

## A realistic first workflow

```sh
tmux new -s client        # start the day
# C-b |  → editor left, shell right
# C-b c  → new window for logs
# laptop lid closes / ssh drops — no problem:
tmux attach -t client     # everything still there
```

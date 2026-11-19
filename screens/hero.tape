Source common.tape
Output hero.gif
Hide
Type "tmux -L revamped-screens attach -t demo"
Enter
Sleep 1.5s
Show
Sleep 3500ms
Screenshot status.png
Sleep 6s
Hide
Ctrl+]
Type@5ms "prefix M-r, C-c"
Enter
Show
Ctrl+B
Escape
Type@1ms "r"
Sleep 5s
Screenshot popup.png
Sleep 1s
Ctrl+C
Sleep 1500ms
Hide
Ctrl+]
Type@5ms "tmux set -g @ram_revamped_icons nerd"
Enter
Show
Sleep 800ms
Type "tmux set -g @ram_revamped_icons nerd"
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot icons.png
Sleep 1s
Hide
Ctrl+]
Type@5ms "tmux set -g @ram_revamped_icons ascii"
Enter
Show
Sleep 800ms
Type "tmux set -g @ram_revamped_icons ascii"
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1500ms
Hide
Ctrl+]
Type@5ms "tmux set -g status-right #{ram_graph} #{ram_trend} #{ram_text} "
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{ram_graph} #{ram_trend} #{ram_text} '"
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Type@5ms "ram-revamped apply"
Enter
Show
Sleep 800ms
Type "ram-revamped apply"
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 6s
Screenshot graph.png
Sleep 1s
Hide
Ctrl+]
Type@5ms "tmux set -g status-right #{ram_graph} #{ram_percentage} "
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{ram_graph} #{ram_percentage} '"
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Type@5ms "tmux set -g @ram_revamped_render options"
Enter
Show
Sleep 800ms
Type "tmux set -g @ram_revamped_render options"
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Type@5ms "ram-revamped apply"
Enter
Show
Sleep 800ms
Type "ram-revamped apply"
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3s
Hide
Ctrl+]
Type@5ms "tmux show -gv status-right | cut -c1-90"
Enter
Show
Sleep 800ms
Type "tmux show -gv status-right | cut -c1-90"
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3s
Screenshot options.png
Sleep 1s
Sleep 1500ms

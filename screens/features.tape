Source common.tape
Output scratch.gif
Hide
Type "tmux -L revamped-screens attach -t demo"
Enter
Sleep 1.5s
Show
Sleep 3500ms
Hide
Ctrl+]
Type@5ms "ram-revamped card"
Enter
Show
Sleep 800ms
Type "ram-revamped card"
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 4s
Screenshot card.png
Sleep 1s
Hide
Type "clear"
Enter
Sleep 600ms
Show
Hide
Ctrl+]
Type@5ms "tmux set -g status-right #{ram_absolute} #{ram_pressure_fg_color}#{ram_pressure}#[default] #{ram_reclaimable} #{ram_top_process} "
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{ram_absolute} #{ram_pressure_fg_color}#{ram_pressure}#[default] #{ram_reclaimable} #{ram_top_process} '"
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
Sleep 7s
Screenshot details.png
Sleep 1s
Hide
Type "clear"
Enter
Sleep 600ms
Show
Hide
Ctrl+]
Type@5ms "tmux set -g status-right #{ram_breakdown} #{ram_commit} "
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{ram_breakdown} #{ram_commit} '"
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
Sleep 4s
Screenshot breakdown.png
Sleep 1s
Hide
Type "clear"
Enter
Sleep 600ms
Show
Hide
Ctrl+]
Type@5ms "tmux set -g status-right #{ram_percentage} #{ram_available} #{ram_swap} "
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{ram_percentage} #{ram_available} #{ram_swap} '"
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
Type@5ms "tmux set -g @ram_revamped_percentage_format mem %s%%"
Enter
Show
Sleep 800ms
Type "tmux set -g @ram_revamped_percentage_format 'mem %s%%'"
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot format.png
Sleep 1s
Hide
Ctrl+]
Type@5ms "tmux set -g @ram_revamped_fixed_width on"
Enter
Show
Sleep 800ms
Type "tmux set -g @ram_revamped_fixed_width on"
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot fixed.png
Sleep 1s
Hide
Ctrl+]
Type@5ms "tmux set -g @ram_revamped_available_label free"
Enter
Show
Sleep 800ms
Type "tmux set -g @ram_revamped_available_label free"
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Type@5ms "tmux set -g @ram_revamped_swap_label swp"
Enter
Show
Sleep 800ms
Type "tmux set -g @ram_revamped_swap_label swp"
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 3500ms
Screenshot labels.png
Sleep 1s
Hide
Type "clear"
Enter
Sleep 600ms
Show
Hide
Ctrl+]
Type@5ms "tmux set -g @ram_revamped_medium_thresh 30"
Enter
Show
Sleep 800ms
Type "tmux set -g @ram_revamped_medium_thresh 30"
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Type@5ms "tmux set -g @ram_revamped_high_thresh 60"
Enter
Show
Sleep 800ms
Type "tmux set -g @ram_revamped_high_thresh 60"
Hide
Ctrl+]
Type@5ms "Enter"
Enter
Show
Enter
Sleep 1200ms
Hide
Ctrl+]
Type@5ms "tmux set -g status-right #{ram_fg_color}#{ram_icon} #{ram_percentage}#[default] "
Enter
Show
Sleep 800ms
Type "tmux set -g status-right '#{ram_fg_color}#{ram_icon} #{ram_percentage}#[default] '"
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
Screenshot tiers.png
Sleep 1s
Hide
Type "clear"
Enter
Sleep 600ms
Show
Hide
Ctrl+]
Type@5ms "tmux set -g @ram_revamped_popup_key M"
Enter
Show
Sleep 800ms
Type "tmux set -g @ram_revamped_popup_key M"
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
Sleep 2s
Hide
Ctrl+]
Type@5ms "prefix M, C-c"
Enter
Show
Ctrl+B
Type@1ms "M"
Sleep 4s
Screenshot popup-key.png
Sleep 1s
Ctrl+C
Sleep 1500ms

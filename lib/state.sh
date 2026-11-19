#!/bin/sh
# shellcheck disable=SC2034

[ -n "${RAM_REVAMPED_STATE_LOADED:-}" ] && return 0
RAM_REVAMPED_STATE_LOADED=1

RAM_REVAMPED_SETTINGS='popup_key	M-r
popup_width	80%
popup_height	60%
interval	5
detail_interval	60
render	jobs
history_size	30
medium_thresh	50
high_thresh	85
swap_warn_thresh	1
trend_threshold	3
low_icon	▰▱▱
medium_icon	▰▰▱
high_icon	▰▰▰
low_fg_color
medium_fg_color
high_fg_color
low_bg_color
medium_bg_color
high_bg_color
swap_active_icon
swap_active_color
trend_up	↑
trend_down	↓
trend_flat	→
percentage_format	%s%%
available_format	%s%%
swap_format	%s%%
pressure_format	%s%%
breakdown_format	W %sG C %sG I %sG F %sG
absolute_format	%s / %s
commit_format	%s%%
reclaimable_format	%s
top_process_format	%s %s
icons	ascii
fixed_width	off
percentage_label
available_label
swap_label
pressure_label
breakdown_label
absolute_label
commit_label
reclaimable_label
top_process_label
graph_label
trend_label
percentage_width
available_width
swap_width
pressure_width
breakdown_width
absolute_width
commit_width
reclaimable_width
top_process_width
graph_width
trend_width'
RAM_REVAMPED_NAMES='popup_key popup_width popup_height interval detail_interval render history_size medium_thresh high_thresh swap_warn_thresh trend_threshold low_icon medium_icon high_icon low_fg_color medium_fg_color high_fg_color low_bg_color medium_bg_color high_bg_color swap_active_icon swap_active_color trend_up trend_down trend_flat percentage_format available_format swap_format pressure_format breakdown_format absolute_format commit_format reclaimable_format top_process_format icons fixed_width percentage_label available_label swap_label pressure_label breakdown_label absolute_label commit_label reclaimable_label top_process_label graph_label trend_label percentage_width available_width swap_width pressure_width breakdown_width absolute_width commit_width reclaimable_width top_process_width graph_width trend_width'
RAM_REVAMPED_CARRIED='popup_width popup_height interval detail_interval render history_size medium_thresh high_thresh swap_warn_thresh trend_threshold low_icon medium_icon high_icon low_fg_color medium_fg_color high_fg_color low_bg_color medium_bg_color high_bg_color swap_active_icon swap_active_color trend_up trend_down trend_flat percentage_format available_format swap_format pressure_format breakdown_format absolute_format commit_format reclaimable_format top_process_format icons fixed_width percentage_label available_label swap_label pressure_label breakdown_label absolute_label commit_label reclaimable_label top_process_label graph_label trend_label percentage_width available_width swap_width pressure_width breakdown_width absolute_width commit_width reclaimable_width top_process_width graph_width trend_width'
RAM_REVAMPED_LIVE='percent available swap pressure breakdown absolute commit reclaimable top_process history percent_ts percent_lock percent_lock_ts pressure_ts top_process_ts published'
RAM_REVAMPED_S_popup_key='M-r'
RAM_REVAMPED_S_popup_width='80%'
RAM_REVAMPED_S_popup_height='60%'
RAM_REVAMPED_S_interval='5'
RAM_REVAMPED_S_detail_interval='60'
RAM_REVAMPED_S_render='jobs'
RAM_REVAMPED_S_history_size='30'
RAM_REVAMPED_S_medium_thresh='50'
RAM_REVAMPED_S_high_thresh='85'
RAM_REVAMPED_S_swap_warn_thresh='1'
RAM_REVAMPED_S_trend_threshold='3'
RAM_REVAMPED_S_low_icon='▰▱▱'
RAM_REVAMPED_S_medium_icon='▰▰▱'
RAM_REVAMPED_S_high_icon='▰▰▰'
RAM_REVAMPED_S_low_fg_color=''
RAM_REVAMPED_S_medium_fg_color=''
RAM_REVAMPED_S_high_fg_color=''
RAM_REVAMPED_S_low_bg_color=''
RAM_REVAMPED_S_medium_bg_color=''
RAM_REVAMPED_S_high_bg_color=''
RAM_REVAMPED_S_swap_active_icon=''
RAM_REVAMPED_S_swap_active_color=''
RAM_REVAMPED_S_trend_up='↑'
RAM_REVAMPED_S_trend_down='↓'
RAM_REVAMPED_S_trend_flat='→'
RAM_REVAMPED_S_percentage_format='%s%%'
RAM_REVAMPED_S_available_format='%s%%'
RAM_REVAMPED_S_swap_format='%s%%'
RAM_REVAMPED_S_pressure_format='%s%%'
RAM_REVAMPED_S_breakdown_format='W %sG C %sG I %sG F %sG'
RAM_REVAMPED_S_absolute_format='%s / %s'
RAM_REVAMPED_S_commit_format='%s%%'
RAM_REVAMPED_S_reclaimable_format='%s'
RAM_REVAMPED_S_top_process_format='%s %s'
RAM_REVAMPED_S_icons='ascii'
RAM_REVAMPED_S_fixed_width='off'
RAM_REVAMPED_S_percentage_label=''
RAM_REVAMPED_S_available_label=''
RAM_REVAMPED_S_swap_label=''
RAM_REVAMPED_S_pressure_label=''
RAM_REVAMPED_S_breakdown_label=''
RAM_REVAMPED_S_absolute_label=''
RAM_REVAMPED_S_commit_label=''
RAM_REVAMPED_S_reclaimable_label=''
RAM_REVAMPED_S_top_process_label=''
RAM_REVAMPED_S_graph_label=''
RAM_REVAMPED_S_trend_label=''
RAM_REVAMPED_S_percentage_width=''
RAM_REVAMPED_S_available_width=''
RAM_REVAMPED_S_swap_width=''
RAM_REVAMPED_S_pressure_width=''
RAM_REVAMPED_S_breakdown_width=''
RAM_REVAMPED_S_absolute_width=''
RAM_REVAMPED_S_commit_width=''
RAM_REVAMPED_S_reclaimable_width=''
RAM_REVAMPED_S_top_process_width=''
RAM_REVAMPED_S_graph_width=''
RAM_REVAMPED_S_trend_width=''
RAM_REVAMPED_S_percent=''
RAM_REVAMPED_S_available=''
RAM_REVAMPED_S_swap=''
RAM_REVAMPED_S_pressure=''
RAM_REVAMPED_S_breakdown=''
RAM_REVAMPED_S_absolute=''
RAM_REVAMPED_S_commit=''
RAM_REVAMPED_S_reclaimable=''
RAM_REVAMPED_S_top_process=''
RAM_REVAMPED_S_history=''
RAM_REVAMPED_S_percent_ts=''
RAM_REVAMPED_S_percent_lock=''
RAM_REVAMPED_S_percent_lock_ts=''
RAM_REVAMPED_S_pressure_ts=''
RAM_REVAMPED_S_top_process_ts=''
RAM_REVAMPED_S_published=''
RAM_REVAMPED_METRICS='percentage icon fg_color bg_color available swap swap_icon swap_color pressure pressure_fg_color breakdown absolute commit reclaimable top_process graph trend text'
RAM_REVAMPED_LABELLED='percentage available swap pressure breakdown absolute commit reclaimable top_process graph trend'
RAM_REVAMPED_DEFAULT_POPUP_KEY='M-r'
RAM_REVAMPED_DEFAULT_INTERVAL=5
RAM_REVAMPED_DEFAULT_DETAIL=60
RAM_REVAMPED_DEFAULT_HISTORY=30
RAM_REVAMPED_DEFAULT_MEDIUM=50
RAM_REVAMPED_DEFAULT_HIGH=85
RAM_REVAMPED_DEFAULT_SWAP_WARN=1
RAM_REVAMPED_DEFAULT_TREND=3
RAM_REVAMPED_DEFAULT_PAGE=4096
RAM_REVAMPED_PERCENT_NATURAL=4
RAM_REVAMPED_GRAPH_STEPS=8
RAM_REVAMPED_POPUP_SINCE=3.2
RAM_REVAMPED_NOTES_SINCE=3.1
RAM_REVAMPED_EMPTY='ram-revamped-empty-argument'
RAM_REVAMPED_TMUX=''
RAM_REVAMPED_NOTES=0
RAM_REVAMPED_TOOL=''
RAM_REVAMPED_JOB=''
RAM_REVAMPED_KEYS=''
RAM_REVAMPED_SKIPPED=''
RAM_REVAMPED_PLAN=''
RAM_REVAMPED_NOW=0
RAM_REVAMPED_LIMIT=5
RAM_REVAMPED_DETAIL=60
RAM_REVAMPED_MARK='ram-revamped-processes'
RAM_REVAMPED_NUMBER=0
RAM_REVAMPED_DOUBLED=''
RAM_REVAMPED_WANT=''
RAM_REVAMPED_RAW=''
RAM_REVAMPED_PAGE=4096
RAM_REVAMPED_STORED=0
RAM_REVAMPED_TIER='low'
RAM_REVAMPED_OUT=''
RAM_REVAMPED_LABEL=''
RAM_REVAMPED_WIDTH=''
RAM_REVAMPED_GLYPH=''
RAM_REVAMPED_NATURAL=0
RAM_REVAMPED_MONITOR=''
RAM_REVAMPED_CARD=''
RAM_REVAMPED_F_percent=''
RAM_REVAMPED_F_available=''
RAM_REVAMPED_F_swap=''
RAM_REVAMPED_F_pressure=''
RAM_REVAMPED_F_breakdown=''
RAM_REVAMPED_F_absolute=''
RAM_REVAMPED_F_commit=''
RAM_REVAMPED_F_reclaimable=''
RAM_REVAMPED_F_history=''
RAM_REVAMPED_F_top_process=''
REVAMPED_CACHE_PREFIX=ram_revamped
REVAMPED_LOG_NS=ram-revamped
RAM_REVAMPED_KINDS='interval	number
detail_interval	number
history_size	number
medium_thresh	number
high_thresh	number
swap_warn_thresh	number
trend_threshold	number
percentage_width	number
available_width	number
swap_width	number
pressure_width	number
breakdown_width	number
absolute_width	number
commit_width	number
reclaimable_width	number
top_process_width	number
graph_width	number
trend_width	number
render	jobs options
icons	ascii nerd
fixed_width	on off'

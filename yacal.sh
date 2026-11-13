#!/usr/bin/env bash

# Author: Haitham Aouati
# GitHub: https://github.com/haithamaouati
# yacal - Yet Another Calendar: Advanced CLI Calendar for Termux

# --- Dependency Check ---
required_deps=("date" "column" "clear")
for dep in "${required_deps[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
        echo "Error: Required dependency '$dep' is missing." >&2
        echo "Please install it via package manager (e.g., pkg install util-linux coreutils)." >&2
        exit 1
    fi
done

usage() {
    echo "Usage: $0 [OPTIONS] [MONTH] [YEAR]"
    echo "Options:"
    echo "  -3                     Show 3-month view (prev, current, next)"
    echo "  -d                     Show full date and time under the calendar"
    echo "  -c                     Clear screen before showing calendar"
    echo "  -r YYYY-MM-DD          Count days remaining until target date and highlight it (Yellow)"
    echo "  -b DATE1 DATE2         Count days between two dates and highlight both (Green & Red)"
    echo "  -m YYYY-MM-DD          Mark a specific day on the calendar (Purple)"
    echo "  -h                     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                     Show current month calendar"
    echo "  $0 12 2026             Show December 2026 calendar"
    echo "  $0 -3                  Show previous, current, and next month"
    echo "  $0 -d                  Show calendar with full date and time"
    echo "  $0 -c -d               Clear screen and show calendar with date and time"
    echo "  $0 -r 2026-12-31       Count days remaining to target date and highlight it"
    echo "  $0 -b 2026-12-01 2026-12-25  Count days between two dates with green/red highlights"
    echo "  $0 -m 2026-12-25       Mark a specific day on the calendar in purple"
    exit 0
}

render_month() {
    local show_datetime="$1"
    shift
    local m_arg="${1:-$(date +%m)}"
    local y_arg="${2:-$(date +%Y)}"
    
    if ! [[ "$m_arg" =~ ^[0-9]+$ ]] || ! [[ "$y_arg" =~ ^[0-9]+$ ]]; then
        echo "Error: Month and year must be valid numbers." >&2
        return 1
    fi

    local m=$((10#$m_arg))
    local y=$((10#$y_arg))
    shift 2 2>/dev/null || true
    
    local specific_highlights
    specific_highlights=("$@")

    local pad_m=$(printf "%02d" "$m")

    if ! month_name=$(date -d "$y-$pad_m-01" +%B 2>/dev/null); then
        echo "Error: Invalid month ($m) or year ($y)." >&2
        return 1
    fi

    local first_day_dw=$(date -d "$y-$pad_m-01" +%w)
    local days_in_month=$(date -d "$y-$pad_m-01 + 1 month - 1 day" +%d)

    local cur_day=$((10#$(date +%d)))
    local cur_month=$((10#$(date +%m)))
    local cur_year=$(date +%Y)

    # Dynamically center header over 20-character wide grid
    local header_text="$month_name $y"
    local header_len=${#header_text}
    local pad_len=$(( (20 - header_len) / 2 ))
    printf "%*s%s\n" "$pad_len" "" "$header_text"
    echo "Su Mo Tu We Th Fr Sa"

    local week_line=()
    for ((i=0; i<first_day_dw; i++)); do
        week_line+=("  ")
    done

    for ((d=1; d<=days_in_month; d++)); do
        local day_str
        day_str=$(printf "%2d" "$d")

        if [[ $m -eq $cur_month && $y -eq $cur_year && $d -eq $cur_day ]]; then
            day_str="\x1b[7m${day_str}\x1b[0m"
        fi

        for sh in "${specific_highlights[@]}"; do
            local sh_m="${sh%%:*}"
            local rest="${sh#*:}"
            local sh_d="${rest%%:*}"
            local sh_style="${rest##*:}"
            [[ -z "$sh_m" || -z "$sh_d" ]] && continue
            sh_m=$((10#$sh_m))
            sh_d=$((10#$sh_d))

            if [[ $sh_m -eq $m && $d -eq $sh_d ]]; then
                day_str="${sh_style}$(printf "%2d" "$d")\x1b[0m"
            fi
        done

        week_line+=("$day_str")

        if [[ ${#week_line[@]} -eq 7 ]]; then
            (
                IFS=" "
                echo -e "${week_line[*]}"
            )
            week_line=()
        fi
    done

    if [[ ${#week_line[@]} -gt 0 ]]; then
        while [[ ${#week_line[@]} -lt 7 ]]; do
            week_line+=("  ")
        done
        (
            IFS=" "
            echo -e "${week_line[*]}"
        )
    fi
    
    if [[ "$show_datetime" -eq 1 ]]; then
        echo ""
        echo "$(date '+%A, %B %d, %Y - %I:%M:%S %p')"
    fi
    echo ""
}

# --- Manual Argument Parsing ---
MODE="single"
TARGET_DATE=""
DATE1=""
DATE2=""
MARK_DATE=""
SHOW_THREE=0
SHOW_DATE=0
CLEAR_SCREEN=0
MONTH=""
YEAR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -3)
            SHOW_THREE=1
            shift
            ;;
        -d)
            SHOW_DATE=1
            shift
            ;;
        -c)
            CLEAR_SCREEN=1
            shift
            ;;
        -r)
            TARGET_DATE="$2"
            MODE="remaining"
            shift 2
            ;;
        -b)
            DATE1="$2"
            DATE2="$3"
            MODE="between"
            shift 3
            ;;
        -m)
            MARK_DATE="$2"
            MODE="mark"
            shift 2
            ;;
        -h)
            usage
            ;;
        -*)
            echo "Error: Unknown option $1. Use -h for help." >&2
            exit 1
            ;;
        *)
            if [[ -z "$MONTH" ]]; then
                MONTH="$1"
            elif [[ -z "$YEAR" ]]; then
                YEAR="$1"
            else
                echo "Error: Too many arguments provided." >&2
                exit 1
            fi
            shift
            ;;
    esac
done

if [[ "$CLEAR_SCREEN" -eq 1 ]]; then
    clear
fi

# --- Feature Execution ---
case "$MODE" in
    "remaining")
        if [[ -z "$TARGET_DATE" ]]; then
            echo "Error: The -r flag requires a target date (e.g., -r 2026-12-31)." >&2
            exit 1
        fi
        if ! target_epoch=$(date -d "$TARGET_DATE" +%s 2>/dev/null); then
            echo "Error: Invalid target date format '$TARGET_DATE'. Use YYYY-MM-DD." >&2
            exit 1
        fi
        now_epoch=$(date +%s)
        diff_secs=$((target_epoch - now_epoch))
        diff_days=$((diff_secs / 86400))

        t_year=$(date -d "$TARGET_DATE" +%Y)
        t_month=$(date -d "$TARGET_DATE" +%m)
        t_day=$(date -d "$TARGET_DATE" +%d)
        
        render_month "$SHOW_DATE" "$t_month" "$t_year" "$t_month:$t_day:\x1b[43m\x1b[30m"

        if [[ $diff_days -lt 0 ]]; then
            echo "Target date $TARGET_DATE was $(( -diff_days )) days ago."
        else
            echo "Days remaining until $TARGET_DATE: $diff_days days"
        fi
        exit 0
        ;;

    "between")
        if [[ -z "$DATE1" || -z "$DATE2" ]]; then
            echo "Error: The -b flag requires two dates (e.g., -b 2026-12-01 2026-12-25)." >&2
            exit 1
        fi
        if ! d1_epoch=$(date -d "$DATE1" +%s 2>/dev/null) || ! d2_epoch=$(date -d "$DATE2" +%s 2>/dev/null); then
            echo "Error: Invalid date format in '$DATE1' or '$DATE2'. Use YYYY-MM-DD." >&2
            exit 1
        fi
        
        diff_secs=$((d2_epoch - d1_epoch))
        diff_days=$(( diff_secs < 0 ? -diff_secs / 86400 : diff_secs / 86400 ))

        d1_year=$(date -d "$DATE1" +%Y); d1_month=$(date -d "$DATE1" +%m); d1_day=$(date -d "$DATE1" +%d)
        d2_year=$(date -d "$DATE2" +%Y); d2_month=$(date -d "$DATE2" +%m); d2_day=$(date -d "$DATE2" +%d)

        if [[ "$d1_month" == "$d2_month" && "$d1_year" == "$d2_year" ]]; then
            render_month "$SHOW_DATE" "$d1_month" "$d1_year" "$d1_month:$d1_day:\x1b[42m\x1b[30m" "$d2_month:$d2_day:\x1b[41m\x1b[30m"
        else
            render_month "$SHOW_DATE" "$d1_month" "$d1_year" "$d1_month:$d1_day:\x1b[42m\x1b[30m"
            render_month "$SHOW_DATE" "$d2_month" "$d2_year" "$d2_month:$d2_day:\x1b[41m\x1b[30m"
        fi

        echo "Total days between $DATE1 and $DATE2: $diff_days days"
        exit 0
        ;;

    "mark")
        if [[ -z "$MARK_DATE" ]]; then
            echo "Error: The -m flag requires a target date (e.g., -m 2026-12-25)." >&2
            exit 1
        fi
        if ! date -d "$MARK_DATE" &>/dev/null; then
            echo "Error: Invalid date format '$MARK_DATE'. Use YYYY-MM-DD." >&2
            exit 1
        fi

        m_year=$(date -d "$MARK_DATE" +%Y)
        m_month=$(date -d "$MARK_DATE" +%m)
        m_day=$(date -d "$MARK_DATE" +%d)

        # Render calendar with Purple highlight style (\x1b[45m\x1b[30m)
        render_month "$SHOW_DATE" "$m_month" "$m_year" "$m_month:$m_day:\x1b[45m\x1b[30m"

        echo "Marked date: $MARK_DATE"
        exit 0
        ;;

    *)
        if [[ $SHOW_THREE -eq 1 ]]; then
            base_month=${MONTH:-$(date +%m)}
            base_year=${YEAR:-$(date +%Y)}
            
            if ! date -d "$base_year-$base_month-01" &>/dev/null; then
                echo "Error: Invalid month ($base_month) or year ($base_year)." >&2
                exit 1
            fi

            prev_m=$(date -d "$base_year-$base_month-01 - 1 month" +%m)
            prev_y=$(date -d "$base_year-$base_month-01 - 1 month" +%Y)
            next_m=$(date -d "$base_year-$base_month-01 + 1 month" +%m)
            next_y=$(date -d "$base_year-$base_month-01 + 1 month" +%Y)

            render_month "$SHOW_DATE" "$prev_m" "$prev_y"
            render_month "$SHOW_DATE" "$base_month" "$base_year"
            render_month "$SHOW_DATE" "$next_m" "$next_y"
        else
            MONTH=${MONTH:-$(date +%m)}
            YEAR=${YEAR:-$(date +%Y)}
            render_month "$SHOW_DATE" "$MONTH" "$YEAR"
        fi
        ;;
esac

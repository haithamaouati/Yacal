# yacal (Yet Another Calendar)

`yacal` is an enhanced, feature-rich Bash-based CLI calendar designed for Termux and standard Linux environments. It builds upon the traditional `cal` utility by offering ANSI color highlighting, countdown tracking, interval calculations between dates, and customizable display options.

---

## Features

- **Multi-Month View (`-3`)**: Displays previous, current, and next months sequentially.
- **Countdown Calculator (`-r`)**: Calculates remaining days until a target date (`YYYY-MM-DD`) and highlights the target day in yellow.
- **Date Interval Calculator (`-b`)**: Calculates total days between two dates (`YYYY-MM-DD`) and highlights the start date in green and the end date in red.
- **Live Timestamp (`-d`)**: Appends the formatted current date and time directly beneath the calendar output.
- **Screen Control (`-c`)**: Clears the terminal screen before rendering.
- **Dependency Checking**: Verifies system prerequisites on launch and outputs clear warning messages if missing.
- **Clean & Minimalist**: Built without emojis, utilizing standard ANSI color escapes for terminal readability.

---

## Prerequisites

`yacal` relies on standard GNU core utilities. Ensure the following packages are installed on your terminal (e.g., in Termux):

```bash
pkg install util-linux coreutils
```

---

## Installation

1. Clone the repository or download the script:
   ```bash
   git clone https://github.com/your-username/yacal.git
   cd yacal
   ```

2. Make the script executable:
   ```bash
   chmod +x yacal
   ```

3. (Optional) Move to a directory in your `$PATH` or create an alias:
   ```bash
   mv yacal ~/.local/bin/
   # or add to ~/.bashrc:
   # alias yacal="$HOME/path/to/yacal"
   ```

---

## Usage

```text
Usage: yacal [OPTIONS] [MONTH] [YEAR]
```

### Options

| Flag | Description |
| :--- | :--- |
| `-3` | Display 3-month view (previous, current, next) |
| `-d` | Display full date and time under the calendar |
| `-c` | Clear terminal screen before rendering |
| `-r YYYY-MM-DD` | Count remaining days until target date and highlight it (Yellow) |
| `-b DATE1 DATE2` | Count total days between two dates and highlight both (Green & Red) |
| `-h` | Show usage instructions and examples |

---

## Examples

#### Standard Calendar View
```bash
./yacal
```

#### Specific Month and Year
```bash
./yacal 12 2026
```

#### 3-Month Overview
```bash
./yacal -3
```

#### Show Current Timestamp Below Calendar
```bash
./yacal -d
```

#### Clear Screen and Display Calendar with Timestamp
```bash
./yacal -c -d
```

#### Count Days Remaining (Countdown)
```bash
./yacal -r 2026-12-31
```
*Outputs the calendar with December 31st highlighted in yellow, followed by the remaining day count.*

#### Count Days Between Two Dates (Interval)
```bash
./yacal -b 2026-12-01 2026-12-25
```
*Outputs the calendar with December 1st highlighted in green, December 25th in red, and the total interval count.*

---

## License

This project is licensed under the [MIT License](LICENSE).
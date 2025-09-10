# vcf2csv — vCard to CSV converter

A command-line tool that converts vCard files to CSV format.  

## Requirements

- macOS 13 or later
- Swift 6
- Xcode Command Line Tools installed

## Installation

```bash
# Clone the repository
git clone https://github.com/1mash0/vcf2csv.git

cd vcf2csv

# Build & install (installs to /usr/local/bin by default)
make install

# Uninstall
make uninstall
```

> The provided `Makefile` installs the compiled binary as `vcf2csv`.

## Usage

```bash
# `<input>` — Path to the input vCard file.
# `<output>` - Path to the output CSV file.
vcf2csv <input> <output>
```

## Arguments & Options

### Positional Arguments

- `input`:  
  Path to the input vCard file.

- `output`:  
  Path to the output CSV file.

## Examples

```bash
vcf2csv ~/Downloads/contacts.vcf ~/Downloads/contacts.csv
```

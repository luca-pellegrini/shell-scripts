#!/usr/bin/python3
"""rsync-via-ssh.py: Python implementation of the `rsync-via-ssh` script"""

import argparse
# import logging
import os
import re
import sys
import readline
import subprocess
from datetime import datetime
from pathlib import Path


PROGRAM_NAME = "rsync-via-ssh"


def main():
    args = parse_arguments()
    # Set up logger
    if args.log_dir is not None:
        if os.path.isdir(args.log_dir):
            log_dir = Path(args.log_dir)
        else:
            print(f"Warning: arg '--log-dir': {args.log_dir} is not accessible. Using default.", file=sys.stderr)
    else:
        log_dir = Path.home() / ".cache" / PROGRAM_NAME / "log"
    # Current date and time as string in format YYYY.MM.DD-HH.MM.SS
    date_and_time = datetime.now().strftime("%Y.%m.%d-%H.%M.%S")
    log_file = log_dir / f"{date_and_time}.log"
    log_file_dry_run = log_dir / f"DRY-RUN-{date_and_time}.log"
    # logging.basicConfig(
    #     format="%(levelname)s: %(message)s",
    #     level=logging.INFO,
    #     filename=log_file)

    dest_ip_address = None
    port = None

    try:
        src_ip_address = get_source_ip_address()
    except ValueError:
        print("Error: could not get valid IP address for source (this machine).\nCheck your network connection.", file=sys.stderr)
        sys.exit(1)

    if args.interactive:
        print(f"IP address of Source: {src_ip_address}")
        # Get dest_ip_address
        while True:
            n = input(f"IP address of Destination: ")
            if check_ip_address(n):
                dest_ip_address = n
                break
            else:
                print("Invalid IP address. Try again.", file=sys.stderr)
        # Get port number
        while True:
            port = input(f"Port number: ")
            if port.isdecimal() and int(port) <= 65535:
                break
            else:
                print("Invalid port number. Try again.", file=sys.stderr)
    else:  # non-interactive
        if args.dest_ip_address is not None and check_ip_address(args.dest_ip_address):
            dest_ip_address = args.dest_ip_address
        if args.port is not None and args.port.isdecimal() and int(args.port) <= 65535:
            port = args.port
    if dest_ip_address is None:
        print("Error: IP address of Destination is not set.", file=sys.stderr)
        sys.exit(1)

    # Set destination
    DEST = f"{os.environ['USER']}@{dest_ip_address}"
    # Export RSYNC_RSH environment variable
    if port:
        os.environ["RSYNC_RSH"] = f"ssh -p {port}"

    # Display prompt to the user
    reply = input("Do a DRY RUN? [Y/n] ")
    if reply == "" or reply in ("Y", "y", "yes", "S", "s", "si"):
        run_rsync(dest=DEST, dry_run=True, log_file=log_file_dry_run)
        print(f"\nLogs of the dry run saved to:\n{str(log_file_dry_run)}")
        subprocess.run(f"less {str(log_file_dry_run)}")
    while True:
        reply = input("Run rsync now? [y/n] ")
        if reply in ("N", "n", "no"):
            sys.exit()
        elif reply in ("Y", "y", "yes", "S", "s", "si"):
            break
    run_rsync(dest=DEST, dry_run=False, log_file=log_file)
    print(f"\nLogs of the run saved to:\n{str(log_file)}")


def parse_arguments() -> argparse.Namespace:
    """Parse and return command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Sync files and directories between two hosts with rsync via SSH")
    parser.add_argument(
        "-i", "--interactive",
        action="store_true",
        help="Run the script in interactive mode")
    parser.add_argument(
        "-d", "--dest",
        dest="dest_ip_address",
        help="IP address of destination host")
    parser.add_argument(
        "-p", "--port",
        help="SSH port on destination host")
    parser.add_argument(
        "--log-dir",
        help="Set the directory where the log files of this run will be saved")
    return parser.parse_args()


def get_source_ip_address() -> str:
    """Get IP address of current host system (the source machine)."""
    args = ["ip", "route", "get", "8.8.8.8"]
    p = subprocess.run(args, capture_output=True, encoding="UTF-8")
    output = p.stdout.split()
    ip_address = output[output.index("src") + 1]
    if check_ip_address(ip_address):
        return ip_address
    else:
        raise ValueError("Invalid IP address")


def check_ip_address(ip_address: str) -> bool:
    """Check if the provided string is a valid IP address."""
    regex = "[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}"
    if re.fullmatch(regex, ip_address):
        return True
    else:
        return False


def run_rsync(dest: str, dry_run: bool = False, log_file: Path = None) -> None:
    pass


if __name__ == "__main__":
    main()

#!/usr/bin/env python3

from enum import Enum
import functools
import json
import logging
import re
import subprocess
from abc import ABC, abstractmethod
from argparse import ArgumentParser
from pathlib import Path
from re import Match
from subprocess import CalledProcessError
from typing import Callable, List, Optional, cast

logging.basicConfig(
    level=logging.DEBUG
)


def main() -> None:
    exit(MonitOPNsense.run_test())


def run(
    *,
    cmd: List[str],
    cwd: Optional[Path] = None,
) -> str:
    cmd_str = " ".join(cmd)
    logging.info(f"Running command '{cmd_str}'")
    try:
        result = subprocess.run(
            args=cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            check=True,
            cwd=cwd,
            timeout=15, # seconds
        )
        logging.info(result.stdout)
        return result.stdout.strip()
    except CalledProcessError as err:
        logging.exception(f"Failed to run '{cmd_str}'\n{err.stdout}")
        raise


class BeepMelody(Enum):
    LOW = "low"
    HIGH = "high"
    START = "start"
    STOP = "stop"


def beep(melody: BeepMelody) -> None:
    run(cmd=["opnsense-beep", melody.value])


class MonitTest(ABC):
    @staticmethod
    @abstractmethod
    def register_args(subparser: ArgumentParser) -> None:
        pass

    @abstractmethod
    def test(self) -> bool:
        pass


class MonitOPNsense:
    _parser = ArgumentParser(description="OPNsense Monit commands")
    _subparsers = _parser.add_subparsers()
    _parser.set_defaults(run_test=lambda **_: MonitOPNsense._parser.print_usage())

    @staticmethod
    def register(test_cls: type[MonitTest]) -> type[MonitTest]:
        subparser = MonitOPNsense._subparsers.add_parser(
            name=test_cls.__name__.lower(),
            help=test_cls.__doc__ and test_cls.__doc__.strip(),
        )
        test_cls.register_args(subparser)
        subparser.set_defaults(run_test=lambda **kwargs: test_cls(**kwargs).test())
        return test_cls

    @staticmethod
    def get_test() -> Callable[[], bool]:
        args = vars(MonitOPNsense._parser.parse_args())
        run_test = args.pop("run_test")
        return functools.partial(run_test, **args)

    @staticmethod
    def run_test() -> int:
        try:
            run = MonitOPNsense.get_test()
            if run():
                logging.info("Test passed")
                return 0
            else:
                logging.warning("Test failed")
                beep(BeepMelody.LOW)
                return -1
        except Exception:
            logging.exception("Unexpected failure")
            beep(BeepMelody.HIGH)
            return -10


@MonitOPNsense.register
class CpuTemperature(MonitTest):
    """
    Check CPU core temperatures
    """
    def __init__(self, threshold: int) -> None:
        super().__init__()
        self.threshold = threshold

    @property
    def core_count(self) -> int:
        output = run(cmd=[
            "sysctl",
            "-n", "kern.smp.cpus",
        ])
        return int(output)

    @property
    def core_temperatures(self) -> List[float]:
        output_pattern = re.compile(".+:\\s*(?P<temp>[0-9\\.]+)C")
        temps = [
            cast(
                Match[str],
                output_pattern.match(
                    run(cmd=["sysctl", f"dev.cpu.{coreId}.temperature"])
                )
            )
            for coreId in range(self.core_count)
        ]
        return [
            float(temp.groupdict()["temp"])
            for temp in temps
        ]

    @property
    def max_core_temperature(self) -> float:
        return max(self.core_temperatures)

    @staticmethod
    def register_args(subparser: ArgumentParser) -> None:
        subparser.add_argument(
            "--threshold",
            type=int,
            help="Fail test if max temperature is equal or higher than threshold",
            required=False,
            default=60,
        )

    def test(self) -> bool:
        return self.max_core_temperature <= self.threshold


@MonitOPNsense.register
class SmartStatus(MonitTest):
    """
    Check disk S.M.A.R.T. status and disk temperatures
    """
    def __init__(self, device: str, threshold: int) -> None:
        self.device = device
        self.threshold = threshold

    @property
    def status(self) -> dict:
        return json.loads(run(cmd=["smartctl", "-Hiaxc", "--json=c", self.device]))

    @property
    def current_temperature(self) -> float:
        return self.status["temperature"]["current"]

    @property
    def is_ok(self) -> bool:
        return self.status["smart_status"]["passed"]

    @staticmethod
    def register_args(subparser: ArgumentParser) -> None:
        subparser.add_argument(
            "--device",
            type=str,
            help="Device to check",
            required=False,
            default="/dev/nvme0",
        )
        subparser.add_argument(
            "--threshold",
            type=int,
            help="Fail test if max temperature is equal or higher than threshold",
            required=False,
            default=70,
        )

    def test(self) -> bool:
        return self.current_temperature <= self.threshold and self.is_ok


@MonitOPNsense.register
class CrowdSec(MonitTest):
    """
    Check CrowdSec decisions list
    """

    @property
    def decisions(self) -> List[dict]:
        return json.loads(
            run(cmd=[
                "cscli", "decisions", "list",
                "--output", "json",
            ])
        ) or []

    @staticmethod
    def register_args(subparser: ArgumentParser) -> None:
        """
        Not needed
        """
        pass

    def test(self) -> bool:
        return not self.decisions


@MonitOPNsense.register
class ConfigCtl(MonitTest):
    """
    Check service status via `configctl`
    """
    def __init__(self, service_name: str, command: str, valid_output: str) -> None:
        self.service_name: str = service_name
        self.command = command
        self.valid_output = valid_output

    @property
    def status(self) -> str:
        return run(cmd=["/usr/local/sbin/configctl", self.service_name, self.command])

    @staticmethod
    def register_args(subparser: ArgumentParser) -> None:
        subparser.add_argument(
            "--service-name",
            type=str,
            help="Service to check",
            required=True,
        )
        subparser.add_argument(
            "--command",
            type=str,
            help="Command to get status information",
            required=True,
        )
        subparser.add_argument(
            "--valid-output",
            type=str,
            help="Output when service is running",
            required=False,
            default="is running",
        )

    def test(self) -> bool:
        return self.valid_output in self.status


if __name__ == "__main__":
    main()

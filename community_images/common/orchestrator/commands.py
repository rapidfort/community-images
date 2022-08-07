""" Command enum class """
from enum import Enum

class Commands(Enum):
    """Enum for commands"""
    HOURLY_RUN = "hourly_run"
    STUB = "stub"
    STUB_COVERAGE = "stub_coverage"
    HARDEN = "harden"
    HARDEN_COVERAGE = "harden_coverage"
    LATEST_COVERAGE = "latest_coverage"

    def __str__(self):
        return self.value.lower()

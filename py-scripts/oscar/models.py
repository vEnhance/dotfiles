from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class ContestData:
    """All known data about one contest, from any combination of input formats."""

    name: str
    num_problems: int | None = None
    n: int = 0
    problem_names: list[str] = field(default_factory=list)

    # Only from old per-student format
    scores_raw: list[list[int | None]] | None = None

    # problem_dist[p][s] = count of students scoring s on problem p
    problem_dist: list[list[int]] | None = None

    # total_dist[t] = count of students with total score t
    total_dist: list[int] | None = None

    @property
    def max_total(self) -> int | None:
        if self.total_dist is not None:
            return len(self.total_dist) - 1
        if self.num_problems is not None:
            return 7 * self.num_problems
        return None

    @property
    def scores_total(self) -> list[int] | None:
        """Sorted ascending list of all total scores."""
        if self.scores_raw is not None:
            totals = sorted(sum(s or 0 for s in row) for row in self.scores_raw)
            return totals
        if self.total_dist is not None:
            result = []
            for score, count in enumerate(self.total_dist):
                result.extend([score] * count)
            return result
        return None

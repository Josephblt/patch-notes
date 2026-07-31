#!/usr/bin/env python3
import argparse
import csv
from collections import Counter
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt


def read_rows(path: Path) -> list[dict[str, str]]:
    with path.open(newline="") as input_file:
        return list(csv.DictReader(input_file))


def plot_final_combined_frequency(rows: list[dict[str, str]], output_path: Path) -> None:
    behaviors = sorted({row["behavior"] for row in rows})
    series = {
        behavior: Counter(
            int(row["final_combined"])
            for row in rows
            if row["behavior"] == behavior
        )
        for behavior in behaviors
    }
    minimum_score = min(min(counts) for counts in series.values())
    maximum_score = max(max(counts) for counts in series.values())
    scores = list(range(minimum_score, maximum_score + 1))

    plt.figure(figsize=(12, 6.5))

    for behavior in behaviors:
        plt.plot(
            scores,
            [series[behavior].get(score, 0) for score in scores],
            label=behavior,
            linewidth=2.5,
        )

    plt.axvline(0, color="#999999", linestyle="--", linewidth=1)
    plt.title("Patch Notes final combined score frequency")
    plt.xlabel("Final combined raw score (Fun + Money)")
    plt.ylabel("Frequency")
    plt.grid(alpha=0.25)
    plt.legend()
    plt.tight_layout()
    plt.savefig(output_path, dpi=180)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("csv_path", type=Path)
    parser.add_argument("output_path", type=Path)
    args = parser.parse_args()

    plot_final_combined_frequency(read_rows(args.csv_path), args.output_path)
    print(f"Wrote balance plot: {args.output_path}")


if __name__ == "__main__":
    main()

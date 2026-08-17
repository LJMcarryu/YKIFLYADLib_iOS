from __future__ import annotations

import contextlib
import copy
import io
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))
import release_state  # noqa: E402


ARTIFACTS = [
    {"name": "checksums.txt", "contentSha256": "8620ace4643602b6e69459ebf81a6eaa69a611bfdfdd94653bb18280836eb894"},
    {"name": "delivery-manifest.json", "contentSha256": "d9c2bebb0c91a115c753b455732631455578d8440e7eb7e378ca67778694b2b4"},
    {"name": "IFLYADLib.xcframework.zip", "contentSha256": "309c22486980cc283e76ea6d1299255b4f244e6ae4be3ef4f0ed959bd1cc0814"},
    {"name": "YKIFLYADLib-6.2.3.zip", "contentSha256": "c4c821bd97aaa7eaed3f2441476c43a6bed6e34e8deec9b6b26c1decc88ef86b"},
]


class ReleaseStateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.state = json.loads((ROOT / "release-state.json").read_text(encoding="utf-8"))
        self.facts = {
            key: copy.deepcopy(value)
            for key, value in self.state.items()
            if key != "artifactInventory"
        }
        self.facts["artifacts"] = copy.deepcopy(ARTIFACTS)

    def write_facts(self, directory: Path) -> Path:
        path = directory / "facts.json"
        path.write_text(json.dumps(self.facts), encoding="utf-8")
        return path

    def test_current_state_is_rebuilt_exactly_from_content_digests(self) -> None:
        generated = release_state.build_closed_state(self.facts)
        self.assertEqual(generated, self.state)
        self.assertEqual(
            release_state.canonical_json(generated),
            (ROOT / "release-state.json").read_text(encoding="utf-8"),
        )
        self.assertEqual(generated["artifactInventory"], {
            "count": 4,
            "sha256": "24ab111ff2eb1bcf944cf421fe871803e478c5c376fd2de002ceff61f3d95428",
        })

    def test_dry_run_prints_state_without_writing(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target = root / "release-state.json"
            target.write_text("原内容\n", encoding="utf-8")
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                result = release_state.main([str(target), "--facts", str(self.write_facts(root))])
            self.assertEqual(result, 0)
            self.assertEqual(target.read_text(encoding="utf-8"), "原内容\n")
            self.assertEqual(json.loads(output.getvalue()), self.state)

    def test_write_atomically_generates_closed_state(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target = root / "release-state.json"
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                result = release_state.main([
                    str(target), "--facts", str(self.write_facts(root)), "--write",
                    "--expected-channel", "youku",
                    "--expected-repository", "LJMcarryu/YKIFLYADLib_iOS",
                    "--expected-version", "6.2.3",
                ])
            self.assertEqual(result, 0)
            self.assertEqual(target.read_text(encoding="utf-8"),
                             release_state.canonical_json(self.state))

    def test_rejects_extra_facts_fields(self) -> None:
        for mutate in (
            lambda value: value.update({"unexpected": True}),
            lambda value: value["artifacts"][0].update({"size": 1}),
        ):
            value = copy.deepcopy(self.facts)
            mutate(value)
            with self.assertRaises(release_state.ReleaseStateError):
                release_state.build_closed_state(value)

    def test_rejects_non_closed_failure_and_fake_apple_success(self) -> None:
        for mutate in (
            lambda value: value.update({"phase": "VERIFIED"}),
            lambda value: value["publication"].update({"conclusion": "failure"}),
            lambda value: value["appleReview"].update({"statusAtFreeze": "success"}),
            lambda value: value["publication"].update({"releaseId": "370458966"}),
        ):
            value = copy.deepcopy(self.facts)
            mutate(value)
            with self.assertRaises(release_state.ReleaseStateError):
                release_state.build_closed_state(value)

    def test_failed_replace_preserves_original_and_removes_temporary_file(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target = root / "release-state.json"
            target.write_text("不可破坏的原状态\n", encoding="utf-8")
            with mock.patch.object(release_state.os, "replace", side_effect=OSError("失败")):
                with self.assertRaises(OSError):
                    release_state.atomic_write_state(target, self.state)
            self.assertEqual(target.read_text(encoding="utf-8"), "不可破坏的原状态\n")
            self.assertEqual(list(root.glob(".release-state.json.*.tmp")), [])

    def test_freeze_facts_generate_frozen_state_with_null_publication(self) -> None:
        facts = copy.deepcopy(self.facts)
        facts.pop("publication")
        facts["phase"] = "FROZEN"
        frozen = release_state.build_state_from_facts(facts)
        self.assertEqual(frozen["phase"], "FROZEN")
        self.assertIsNone(frozen["publication"])
        self.assertEqual(frozen["artifactInventory"], self.state["artifactInventory"])

        facts["publication"] = None
        with self.assertRaises(release_state.ReleaseStateError):
            release_state.build_frozen_state(facts)

    def test_phase_specific_publication_and_transition_contract(self) -> None:
        frozen = copy.deepcopy(self.state)
        frozen["phase"] = "FROZEN"
        frozen["publication"] = None
        preparing = copy.deepcopy(frozen)
        preparing["phase"] = "PREPARING"
        release_state.validate_state_transition(preparing, frozen)
        release_state.validate_state_transition(frozen, self.state)

        invalid_publication = copy.deepcopy(frozen)
        invalid_publication["publication"] = {}
        with self.assertRaises(release_state.ReleaseStateError):
            release_state.validate_state(invalid_publication)

        next_frozen = copy.deepcopy(frozen)
        next_frozen["version"] = "6.2.4"
        release_state.validate_state_transition(self.state, next_frozen)
        with self.assertRaises(release_state.ReleaseStateError):
            release_state.validate_state_transition(self.state, frozen)

        cross_version_closed = copy.deepcopy(self.state)
        cross_version_closed["version"] = "6.2.4"
        cross_version_closed["publication"]["tagName"] = "6.2.4"
        cross_version_closed["publication"]["releaseUrl"] = (
            "https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/tag/6.2.4"
        )
        with self.assertRaises(release_state.ReleaseStateError):
            release_state.validate_state_transition(self.state, cross_version_closed)


if __name__ == "__main__":
    unittest.main()

#!/usr/bin/env bash

set -euo pipefail

test_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

python3 - "$test_dir/../bin/ai-usage" <<'PY'
import json
import os
from pathlib import Path
import runpy
import subprocess
import sys
import tempfile
import unittest


script = Path(sys.argv.pop()).resolve()
usage = runpy.run_path(str(script))


def token_counts(**values):
    return dict.fromkeys(usage['TOKEN_FIELDS'], 0) | values


class UsagePricingTests(unittest.TestCase):
    def test_sol_and_luna_api_prices(self):
        counts = token_counts(input=1000, cache_read=1000, output=1000)
        for model, expected in (
            ('gpt-6-sol', 0.0122),
            ('gpt-6.1-sol', 0.0121),
            ('gpt-6-luna', 0.00061),
            ('gpt-5.6-sol', 0.0244),
            ('gpt-5.6', 0.0244),
            ('gpt-5.6-terra', 0.0142),
            ('gpt-5.6-luna', 0.00142),
        ):
            with self.subTest(model=model):
                self.assertAlmostEqual(usage['codex_api_cost'](model, counts), expected)

    def test_claude_model_specific_cache_prices(self):
        counts = token_counts(**dict.fromkeys(usage['TOKEN_FIELDS'], 1000))
        for model, expected in (
            ('claude-opus-5-5', 0.0372),
            ('claude-sonnet-5-5', 0.0187),
            ('claude-fable-5-1', 0.09275),
            ('claude-mythos-5-1', 0.09275),
            ('claude-opus-5', 0.04675),
        ):
            with self.subTest(model=model):
                self.assertAlmostEqual(usage['claude_api_cost'](model, counts), expected)

    def test_versions_do_not_inherit_an_older_model_price(self):
        resolve = usage['resolve_from']
        for model in ('claude-opus-5-6', 'claude-opus-5-55', 'claude-fable-5-2'):
            self.assertIsNone(resolve(usage['CLAUDE_API_PRICING'], model), model)
        for suffix in ('20261001', '2026-10-01'):
            self.assertEqual(
                resolve(usage['CODEX_API_PRICING'], 'gpt-6.1-sol-' + suffix),
                (2.0, 0.1, 10.0),
            )
        self.assertIsNone(resolve(usage['CODEX_API_PRICING'], 'gpt-6.1-sol-mini'))

    def test_long_context_threshold_and_cache_writes(self):
        counts = token_counts(input=1000, cache_read=270000, cache_write_5m=1000, output=1000)
        self.assertAlmostEqual(usage['codex_api_cost']('gpt-6.1-sol', counts), 0.0415)
        counts['cache_read'] += 1
        self.assertAlmostEqual(usage['codex_api_cost']('gpt-6.1-sol', counts), 0.0780002)

    def test_credits_use_their_own_rates_and_fast_multiplier(self):
        counts = token_counts(input=1000, cache_read=1000, output=1000)
        for model, expected in (
            ('gpt-6-sol', 0.305),
            ('gpt-6.1-sol', 0.3025),
            ('gpt-6-luna', 0.01525),
            ('gpt-5.6-sol', 0.61),
        ):
            with self.subTest(model=model):
                self.assertEqual(usage['codex_credit_range'](model, counts, 'default'),
                                 (expected, expected, False))
                fast = usage['codex_credit_range'](model, counts, 'fast')
                self.assertAlmostEqual(fast[0], expected * 2)
                self.assertEqual(fast[0], fast[1])
                self.assertFalse(fast[2])
                unknown = usage['codex_credit_range'](model, counts, None)
                self.assertAlmostEqual(unknown[0], expected)
                self.assertAlmostEqual(unknown[1], expected * 2)
                self.assertTrue(unknown[2])
        counts['cache_write_5m'] = 1000
        self.assertEqual(usage['codex_credit_range']('gpt-6.1-sol', counts, 'default'),
                         (0.3025, 0.3025, False))

    def test_cli_prices_model_ids_from_session_logs(self):
        with tempfile.TemporaryDirectory(prefix='ai-usage-test-') as root:
            root = Path(root)
            claude_root = root / 'claude'
            codex_root = root / 'codex'
            claude_root.mkdir()
            (codex_root / 'sessions').mkdir(parents=True)
            timestamp = '2026-10-02T00:00:00Z'
            claude_record = {
                'type': 'assistant', 'timestamp': timestamp,
                'message': {
                    'id': 'opus-message', 'model': 'claude-opus-5-5',
                    'usage': {'input_tokens': 1000, 'output_tokens': 1000,
                              'cache_read_input_tokens': 1000},
                },
            }
            (claude_root / 'session.jsonl').write_text(json.dumps(claude_record) + '\n')
            for model in ('gpt-6-sol', 'gpt-6.1-sol', 'codex-auto-review', 'unknown-model'):
                records = [
                    {'type': 'session_meta', 'payload': {'id': model, 'cwd': '/test'}},
                    {'type': 'turn_context', 'payload': {'model': model}},
                    {'type': 'event_msg', 'payload': {
                        'type': 'thread_settings_applied',
                        'thread_settings': {'service_tier': 'default'},
                    }},
                    {'type': 'event_msg', 'timestamp': timestamp, 'payload': {
                        'type': 'token_count', 'info': {'last_token_usage': {
                            'input_tokens': 2000, 'cached_input_tokens': 1000,
                            'output_tokens': 1000,
                        }},
                    }},
                ]
                (codex_root / 'sessions' / (model + '.jsonl')).write_text(
                    ''.join(json.dumps(record, separators=(',', ':')) + '\n' for record in records)
                )
            environment = dict(os.environ, AI_USAGE_CLAUDE_ROOT=str(claude_root),
                               AI_USAGE_CODEX_ROOT=str(codex_root), AI_USAGE_TIMEZONE='Asia/Shanghai')
            result = subprocess.run(
                [sys.executable, str(script), '--since', '2026-10-01',
                 '--until', '2026-10-03', '--json'],
                env=environment, check=True, capture_output=True, text=True,
            )
            providers = json.loads(result.stdout)['providers']
            self.assertEqual(providers['claude']['unpriced_models'], [])
            self.assertAlmostEqual(providers['claude']['api_equivalent_cost_usd'], 0.0242)
            codex = providers['codex']
            self.assertEqual(codex['unpriced_models'], ['unknown-model'])
            for model, expected in (('gpt-6-sol', 0.0122), ('gpt-6.1-sol', 0.0121),
                                    ('codex-auto-review', 0.00142)):
                self.assertAlmostEqual(codex['models'][model]['api_equivalent_cost_usd'], round(expected, 4))
            self.assertAlmostEqual(codex['api_equivalent_cost_usd'], 0.0257)
            self.assertAlmostEqual(codex['credits_min'], 0.643)
            self.assertEqual(codex['credits_min'], codex['credits_max'])


unittest.main()
PY

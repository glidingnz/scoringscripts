// testbed/run.js
// Usage: node testbed/run.js testbed/fixtures/nz_annex_a_invented.json --runner runner/bin/seeyou_runner.exe --script "New Zealand Annex A scoring 2020.pas"

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

function parseArgs(argv) {
  const args = { _: [] };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--runner') args.runner = argv[++i];
    else if (a === '--script') args.script = argv[++i];
    else args._.push(a);
  }
  return args;
}

function loadJson(p) {
  let text = fs.readFileSync(p, 'utf8');
  if (text.charCodeAt(0) === 0xFEFF) {
    text = text.slice(1);
  }
  return JSON.parse(text);
}

function runCase(runnerPath, scriptPath, testCase) {
  const input = {
    script_path: scriptPath,
    day_tag: testCase.day_tag || '',
    class_id: testCase.class_id,
    task: testCase.task,
    pilots: testCase.pilots,
    options: testCase.options || {}
  };

  const proc = spawnSync(runnerPath, [], {
    input: JSON.stringify(input),
    encoding: 'utf8',
    maxBuffer: 10 * 1024 * 1024
  });

  if (proc.error) {
    return { ok: false, error: proc.error.message };
  }
  if (proc.status !== 0) {
    return { ok: false, error: proc.stderr || `runner exit ${proc.status}` };
  }

  let output;
  try {
    output = JSON.parse(proc.stdout || '{}');
  } catch (e) {
    return { ok: false, error: `invalid JSON from runner: ${e.message}` };
  }

  return { ok: true, output };
}

function comparePoints(testCase, output) {
  const expected = testCase.expected && testCase.expected.points ? testCase.expected.points : {};
  const actualMap = {};
  if (Array.isArray(output.pilots)) {
    for (const p of output.pilots) actualMap[p.comp_id] = p.points;
  }

  const diffs = [];
  for (const compId of Object.keys(expected)) {
    const exp = expected[compId];
    const act = actualMap[compId];
    if (act === undefined) {
      diffs.push(`${compId}: expected ${exp}, missing actual`);
    } else if (act !== exp) {
      diffs.push(`${compId}: expected ${exp}, got ${act}`);
    }
  }

  return diffs;
}

function main() {
  const args = parseArgs(process.argv);
  const fixturePath = args._[0];
  if (!fixturePath) {
    console.error('usage: node testbed/run.js <fixtures.json> --runner <runner.exe> --script <script.pas>');
    process.exit(2);
  }

  const runnerPath = args.runner || path.resolve('runner/bin/seeyou_runner.exe');
  const scriptPath = args.script || path.resolve('New Zealand Annex A scoring 2020.pas');

  const cases = loadJson(fixturePath);
  if (!Array.isArray(cases)) {
    console.error('fixtures file must be a JSON array');
    process.exit(2);
  }

  let failures = 0;
  for (const tc of cases) {
    const label = tc.id || 'case';
    const res = runCase(runnerPath, scriptPath, tc);
    if (!res.ok) {
      console.log(`[FAIL] ${label} - ${res.error}`);
      failures++;
      continue;
    }
    const diffs = comparePoints(tc, res.output);
    if (diffs.length) {
      console.log(`[FAIL] ${label}`);
      for (const d of diffs) console.log(`  ${d}`);
      failures++;
    } else {
      console.log(`[OK] ${label}`);
    }
  }

  process.exit(failures ? 1 : 0);
}

main();

#!/usr/bin/env node
// Deterministic synthetic Instagram export fixture generator.
// Reference files define input shape/counts only; fixture identities are generated.
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { deflateRawSync } from 'node:zlib';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const root = path.dirname(fileURLToPath(import.meta.url));
const epoch = 1736942400;
const json = (x) => `${JSON.stringify(x, null, 2)}\n`;
const pad = (n) => String(n).padStart(4, '0');
const record = (n, timestamp = epoch + n - 1, casing = 'lower') => {
  const user = `synthetic_${pad(n)}`;
  const value = casing === 'upper' ? user.toUpperCase() : user;
  return { title: '', string_list_data: [{ href: `https://www.instagram.com/${value}/`, value, timestamp }] };
};

function crc32(data) {
  let c = 0xffffffff;
  for (const b of data) { c ^= b; for (let k = 0; k < 8; k++) c = (c >>> 1) ^ ((c & 1) ? 0xedb88320 : 0); }
  return (c ^ 0xffffffff) >>> 0;
}
function zip(entries) {
  const locals = [], centrals = [];
  let offset = 0;
  for (const entry of entries) {
    const name = Buffer.from(entry.name), data = Buffer.from(entry.data), compressed = entry.method === 8 ? deflateRawSync(data) : data;
    const crc = crc32(data), flags = 1 << 11 | (entry.encrypted ? 1 : 0), method = entry.method ?? 0;
    const local = Buffer.alloc(30);
    local.writeUInt32LE(0x04034b50, 0); local.writeUInt16LE(20, 4); local.writeUInt16LE(flags, 6); local.writeUInt16LE(method, 8);
    local.writeUInt32LE(crc, 14); local.writeUInt32LE(compressed.length, 18); local.writeUInt32LE(data.length, 22); local.writeUInt16LE(name.length, 26);
    const localBlock = Buffer.concat([local, name, compressed]); locals.push(localBlock);
    const central = Buffer.alloc(46);
    central.writeUInt32LE(0x02014b50, 0); central.writeUInt16LE((3 << 8) | 20, 4); central.writeUInt16LE(20, 6); central.writeUInt16LE(flags, 8); central.writeUInt16LE(method, 10);
    central.writeUInt32LE(crc, 16); central.writeUInt32LE(compressed.length, 20); central.writeUInt32LE(data.length, 24);
    central.writeUInt16LE(name.length, 28); central.writeUInt32LE(entry.externalAttributes ?? ((0o100644 << 16) >>> 0), 38); central.writeUInt32LE(offset, 42);
    centrals.push(Buffer.concat([central, name])); offset += localBlock.length;
  }
  const centralBytes = Buffer.concat(centrals), end = Buffer.alloc(22);
  end.writeUInt32LE(0x06054b50, 0); end.writeUInt16LE(entries.length, 8); end.writeUInt16LE(entries.length, 10);
  end.writeUInt32LE(centralBytes.length, 12); end.writeUInt32LE(offset, 16);
  return Buffer.concat([...locals, centralBytes, end]);
}

const following = Array.from({ length: 810 }, (_, i) => record(i + 1));
const followers = [
  ...Array.from({ length: 747 }, (_, i) => record(i + 1)),
  ...Array.from({ length: 36 }, (_, i) => record(811 + i, epoch + 1000 + i)),
];
const slices = {
  'followers_1.json': followers.slice(0, 400),
  'followers_2.json': followers.slice(400),
  'following.json': { relationships_following: following.map((r) => ({ ...r, media_list_data: [] })) },
  'variants.json': {
    duplicate: [record(1), record(1)],
    caseVariant: [record(1, epoch, 'upper')],
    missingTimestamp: [{ title: '', string_list_data: [{ href: 'https://www.instagram.com/synthetic_missing_time/', value: 'synthetic_missing_time' }] }],
    invalidTimestamp: [{ title: '', string_list_data: [{ href: 'https://www.instagram.com/synthetic_invalid_time/', value: 'synthetic_invalid_time', timestamp: 'not-a-time' }] }],
    malformedExamples: ['{', '[null]'],
  },
};

const normalize = (r) => {
  const item = r.string_list_data[0];
  const display = item.value.trim();
  return { identity: display.toLowerCase(), display, profileUrl: item.href, sourceTimestamp: Number.isInteger(item.timestamp) ? item.timestamp : null };
};
const followingSet = new Set(following.map((r) => normalize(r).identity));
const followersSet = new Set(followers.map((r) => normalize(r).identity));
const categories = {
  mutual: [...followersSet].filter((id) => followingSet.has(id)).sort(),
  followerOnly: [...followersSet].filter((id) => !followingSet.has(id)).sort(),
  followingOnly: [...followingSet].filter((id) => !followersSet.has(id)).sort(),
};
const goldens = {
  schema: 'kinship.synthetic-fixtures.v1',
  provenance: 'Generated synthetic data. Reference export consulted for structure and expected corpus counts only; no reference identities copied.',
  identityNormalization: 'trim then Unicode lowercase; timestamps preserved as integer seconds or null when unavailable',
  expectedCounts: { following: 810, followers: 783, mutual: 747, followerOnly: 36, followingOnly: 63 },
  categories,
  records: Object.fromEntries([
    ['followers', followers], ['following', following],
  ].map(([side, rows]) => [side, rows.map(normalize).sort((a, b) => a.identity.localeCompare(b.identity))])),
};
const friendManifest = {
  ...goldens,
  counts: { following: followingSet.size, followers: followersSet.size, mutual: categories.mutual.length, followerOnly: categories.followerOnly.length, followingOnly: categories.followingOnly.length },
  note: 'Single synthetic snapshot; categories computed by set intersection and differences.',
};

await mkdir(root, { recursive: true });
for (const [name, contents] of Object.entries(slices)) await writeFile(path.join(root, name), json(contents));
await writeFile(path.join(root, 'goldens.json'), json(goldens));
await writeFile(path.join(root, 'manifest.json'), json(friendManifest));

// Portable baseline ZIP; deliberately modest size and fixed entry order/timestamps.
const baselineEntries = [
  { name: 'connections/followers_and_following/followers_1.json', data: json(slices['followers_1.json']) },
  { name: 'connections/followers_and_following/followers_2.json', data: json(slices['followers_2.json']) },
  { name: 'connections/followers_and_following/following.json', data: json(slices['following.json']) },
];
await writeFile(path.join(root, 'baseline.zip'), zip(baselineEntries));

// Hostile archive builders produce isolated test inputs on demand, not committed blobs.
const payload = json([{ title: '', string_list_data: [{ href: 'https://www.instagram.com/synthetic_zip/', value: 'synthetic_zip', timestamp: epoch }] }]);
const jsonOverLimit = Buffer.from(`[${JSON.stringify({ padding: 'x'.repeat(21 * 1024 * 1024) })}]`);
const bomb = Buffer.from(`[${JSON.stringify({ padding: 'x'.repeat(512 * 1024) })}]`);
const hostileCases = {
  traversal: [{ name: '../outside.json', data: payload }],
  casefoldDuplicate: [{ name: 'Followers.json', data: payload }, { name: 'followers.JSON', data: payload }],
  symlink: [{ name: 'link.json', data: payload, externalAttributes: (0o120777 << 16) >>> 0 }],
  encrypted: [{ name: 'encrypted.json', data: payload, encrypted: true }],
  nestedArchive: [{ name: 'outer.zip', data: zip([{ name: 'inner.json', data: payload }]) }],
  ratioLimit: [{ name: 'ratio.json', data: bomb, method: 8 }],
  sizeLimit: [{ name: 'oversize.json', data: jsonOverLimit, method: 8 }],
  metadataDeception: [{ name: 'claimed.json', data: payload }],
};
for (const [name, entries] of Object.entries(hostileCases)) {
  const archive = zip(entries);
  if (name === 'metadataDeception') {
    // Corrupt local-header uncompressed length and CRC while central metadata stays valid.
    const localNameLength = archive.readUInt16LE(26), localExtraLength = archive.readUInt16LE(28);
    const dataOffset = 30 + localNameLength + localExtraLength;
    archive.writeUInt32LE(1, 22); archive.writeUInt32LE(0, 14);
    assert.notEqual(archive.readUInt32LE(22), archive.readUInt32LE(dataOffset - localNameLength - localExtraLength + 20));
  }
  await writeFile(path.join(root, `${name}.zip`), archive);
}

// Recognized relationship JSON with invalid structure must fail closed; unrelated
// valid JSON remains available for adapter skip coverage.
await writeFile(path.join(root, 'malformedRelationship.zip'), zip([
  { name: 'followers.json', data: '{"followers":{}}' },
]));
await writeFile(path.join(root, 'unrelatedJson.zip'), zip([
  { name: 'metadata.json', data: '{"export_version":1}' },
  { name: 'following.json', data: json({ relationships_following: [record(1)] }) },
]));

// Generator self-checks: counts, ordering, synthetic identity namespace, and ZIP signatures.
assert.equal(slices['followers_1.json'].length, 400);
assert.equal(slices['followers_2.json'].length, 383);
assert.equal(followers.length, 783);
assert.equal(following.length, 810);
assert.deepEqual({ mutual: categories.mutual.length, followerOnly: categories.followerOnly.length, followingOnly: categories.followingOnly.length }, { mutual: 747, followerOnly: 36, followingOnly: 63 });
for (const rows of Object.values(goldens.records)) {
  assert.deepEqual(rows.map((r) => r.identity), [...rows.map((r) => r.identity)].sort());
  assert(rows.every((r) => r.identity.startsWith('synthetic_')));
}
assert.equal((await readFile(path.join(root, 'baseline.zip'))).readUInt32LE(0), 0x04034b50);
const parsedFollowers = JSON.parse(await readFile(path.join(root, 'followers_1.json'), 'utf8')).concat(JSON.parse(await readFile(path.join(root, 'followers_2.json'), 'utf8')));
const parsedFollowing = JSON.parse(await readFile(path.join(root, 'following.json'), 'utf8')).relationships_following;
assert.equal(parsedFollowers.length, 783); assert.equal(parsedFollowing.length, 810);
const deceptive = await readFile(path.join(root, 'metadataDeception.zip'));
assert.notEqual(deceptive.readUInt32LE(14), deceptive.readUInt32LE(deceptive.readUInt16LE(26) + 30));
const sizeZip = await readFile(path.join(root, 'sizeLimit.zip'));
assert(sizeZip.readUInt32LE(22) > 20 * 1024 * 1024);
const ratioZip = await readFile(path.join(root, 'ratioLimit.zip'));
assert(ratioZip.readUInt32LE(24) / ratioZip.readUInt32LE(18) > 200);
for (const name of ['baseline', ...Object.keys(hostileCases)]) {
  const archive = await readFile(path.join(root, `${name}.zip`));
  let offset = archive.readUInt32LE(16);
  const count = archive.readUInt16LE(10);
  for (let i = 0; i < count; i++) {
    assert.equal(archive.readUInt32LE(offset), 0x02014b50);
    assert.equal(archive.readUInt16LE(offset + 8), 0x0800 | (name === 'encrypted' ? 1 : 0));
    const externalAttributes = archive.readUInt32LE(offset + 38);
    const filenameLength = archive.readUInt16LE(offset + 28);
    const filename = archive.toString('utf8', offset + 46, offset + 46 + filenameLength);
    assert.equal(externalAttributes, filename === 'link.json' ? (0o120777 << 16) >>> 0 : (0o100644 << 16) >>> 0);
    offset += 46 + filenameLength + archive.readUInt16LE(offset + 30) + archive.readUInt32LE(offset + 20);
  }
}
assert.equal(createHash('sha256').update(json(goldens)).digest('hex').length, 64);
console.log('Generated fixture corpus; assertions passed.');

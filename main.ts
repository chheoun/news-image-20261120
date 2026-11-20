import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

const outputDir = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';
const imagePath = new URL('./entry.png', import.meta.url);
const image = readFileSync(imagePath);

const pngSignature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
if (!image.subarray(0, pngSignature.length).equals(pngSignature)) {
  throw new Error('The bundled news image is not a PNG.');
}
if (image.length < 24 || image.length > 1_048_576) {
  throw new Error('The bundled PNG must be complete and no larger than 1 MiB.');
}

const width = image.readUInt32BE(16);
const height = image.readUInt32BE(20);
if (width < 1 || height < 1 || width > 1024 || height > 1024) {
  throw new Error('The bundled PNG must fit within 1024 by 1024 pixels.');
}

mkdirSync(outputDir, { recursive: true });
writeFileSync(join(outputDir, 'entry.png'), image);

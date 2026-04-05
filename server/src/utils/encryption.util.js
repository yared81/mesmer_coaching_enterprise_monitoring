const crypto = require('crypto');

// In a real production app, this key should be in an environment variable (32 bytes)
// Key must be exactly 32 bytes for AES-256-CBC. Pad or slice to enforce this.
const _rawKey = process.env.ENCRYPTION_KEY || 'mesmer-coaching-encrypt-key-32byt';
const ENCRYPTION_KEY = _rawKey.padEnd(32, '0').slice(0, 32);
const IV_LENGTH = 16; // For AES, this is always 16

function encrypt(text) {
  if (!text) return text;
  try {
    const key = Buffer.from(ENCRYPTION_KEY, 'utf8').slice(0, 32);
    const iv = crypto.randomBytes(IV_LENGTH);
    const cipher = crypto.createCipheriv('aes-256-cbc', key, iv);
    let encrypted = cipher.update(text);
    encrypted = Buffer.concat([encrypted, cipher.final()]);
    return iv.toString('hex') + ':' + encrypted.toString('hex');
  } catch (err) {
    console.error('Encryption error:', err);
    return text;
  }
}

function decrypt(text) {
  if (!text || !text.includes(':')) return text;
  try {
    const key = Buffer.from(ENCRYPTION_KEY, 'utf8').slice(0, 32);
    const textParts = text.split(':');
    const iv = Buffer.from(textParts.shift(), 'hex');
    const encryptedText = Buffer.from(textParts.join(':'), 'hex');
    const decipher = crypto.createDecipheriv('aes-256-cbc', key, iv);
    let decrypted = decipher.update(encryptedText);
    decrypted = Buffer.concat([decrypted, decipher.final()]);
    return decrypted.toString();
  } catch (err) {
    return text;
  }
}

module.exports = { encrypt, decrypt };

import { Logger } from './logger';
const logger = Logger.child({ module: 'environment' });

interface _Options {
  fallback?: string;
  redacted?: boolean;
}

class _Var {
  constructor(private name: string, private options?: _Options) {
    if (process.env[this.name] || this.options?.fallback !== undefined) {
      logger.debug({ key: this.name, value: this.options?.redacted ? '[REDACTED]' : this.read() });
    } else {
      logger.fatal({ key: this.name }, 'Unable to find environment value. Exiting...');
      process.exit(1);
    }
  }

  public read = (): string => process.env[this.name] ?? this.options!.fallback!;
}

// Firebase
export const FIREBASE_PROJECT_ID = new _Var('FIREBASE_PROJECT_ID');
export const FIREBASE_CLIENT_EMAIL = new _Var('FIREBASE_CLIENT_EMAIL', { redacted: true });
export const FIREBASE_DATABASE_URL = new _Var('FIREBASE_DATABASE_URL', { redacted: true });
export const FIREBASE_PRIVATE_KEY = new _Var('FIREBASE_PRIVATE_KEY', { redacted: true });
// API Keys
export const FANART_TV_API_KEY = new _Var('FANART_TV_API_KEY', { redacted: true });
export const THEMOVIEDB_API_KEY = new _Var('THEMOVIEDB_API_KEY', { redacted: true });
// Redis
export const REDIS_HOST = new _Var('REDIS_HOST');
export const REDIS_PORT = new _Var('REDIS_PORT');
export const REDIS_USE_TLS = new _Var('REDIS_USE_TLS', { fallback: 'false' });
export const REDIS_USER = new _Var('REDIS_USER', { fallback: '' });
export const REDIS_PASS = new _Var('REDIS_PASS', { fallback: '', redacted: true });
// Other
export const PORT = new _Var('PORT', { fallback: '9000' });

import { Server } from './server';
import { Firebase, Redis } from './services';

Firebase.initialize();
Redis.initialize();
Server.start();

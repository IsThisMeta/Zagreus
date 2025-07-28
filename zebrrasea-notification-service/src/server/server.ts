import express from 'express';
import { Environment, Logger } from '../utils';
import { router } from '../modules';

const logger = Logger.child({ module: 'express' });
const server = express();

const docs = async (request: express.Request, response: express.Response): Promise<void> => {
  response.redirect(301, 'https://docs.zebrrasea.app/zebrrasea/notifications');
};

const health = async (request: express.Request, response: express.Response): Promise<void> => {
  response.status(200).json({
    status: 'OK',
    version: process.env.npm_package_version,
  });
};

export const initialize = (): void => {
  server.use(express.json());
  server.get('/', docs);
  server.get('/health', health);
  server.use('/v1', router);
};

export const start = (): void => {
  initialize();

  const PORT = Environment.PORT.read();
  server.listen(PORT).on('error', (error: Error) => {
    logger.error(error);
    process.exit(1);
  });
  logger.info({ PORT }, 'Running');
};

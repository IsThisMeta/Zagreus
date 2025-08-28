import { Redis } from '../';
import { Constants } from '../../utils';

const DEVICE_DELIMITER = '|';

const _keyBuilder = (uid: string): string => {
  return `${Constants.REDIS.PREFIX.DEVICES}:${uid}`;
};

export const getDeviceList = async (uid: string): Promise<string[] | undefined> => {
  const key = _keyBuilder(uid);
  const res = await Redis.get(key);
  if (res) return res.split(DEVICE_DELIMITER);
  return undefined;
};

export const setDeviceList = async (uid: string, devices: string[]): Promise<boolean> => {
  const key = _keyBuilder(uid);
  const devicesJoined = devices.join(DEVICE_DELIMITER);
  const res = await Redis.set(key, devicesJoined, Constants.REDIS.EXPIRE.DEVICES);
  if (res) return true;
  return false;
};

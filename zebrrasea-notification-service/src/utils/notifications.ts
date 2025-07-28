import { MulticastMessage } from 'firebase-admin/messaging';

export interface Payload {
  title: string;
  body: string;
  image?: string;
  data?: {
    [key: string]: string;
  };
}

export interface Settings {
  sound: boolean;
  ios: {
    interruptionLevel: iOSInterruptionLevel;
  };
}

export enum iOSInterruptionLevel {
  PASSIVE = 'passive',
  ACTIVE = 'active',
  TIME_SENSITIVE = 'time-sensitive',
}

export const buildMulticastMessage = (
  tokens: string[],
  payload: Payload,
  settings: Settings,
): MulticastMessage => {
  const data: { [key: string]: string } = {};
  for (const key of Object.keys(payload.data ?? {})) {
    data[key] = String((payload.data ?? {})[key]);
  }

  return <MulticastMessage>{
    tokens: tokens,
    notification: {
      title: payload.title,
      body: payload.body,
      imageUrl: payload.image,
    },
    data,
    android: {
      notification: {
        sound: settings.sound ? 'default' : undefined,
      },
      priority: 'high',
      ttl: 2419200,
    },
    apns: {
      payload: {
        aps: {
          mutableContent: payload.image !== undefined,
          sound: settings.sound ? 'default' : undefined,
          contentAvailable: true,
          'interruption-level': settings.ios.interruptionLevel,
        },
      },
    },
  };
};

export const generateTitle = (module: string, profile: string, body: string): string => {
  if (profile && profile !== 'default') return `${module} (${profile}): ${body}`;
  return `${module}: ${body}`;
};

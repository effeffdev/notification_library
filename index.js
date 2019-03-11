
import { NativeModules, NativeEventEmitter, DeviceEventEmitter } from 'react-native';

const { RNNotificationLibrary } = NativeModules;

export const IOSEmitter = new NativeEventEmitter(RNNotificationLibrary);
export const AndroidEmitter = DeviceEventEmitter;

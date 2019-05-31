
import { NativeModules, NativeEventEmitter } from 'react-native';

const { RNNotificationLibrary } = NativeModules;

export default new NativeEventEmitter(RNNotificationLibrary);

import {
    NativeModules,
    DeviceEventEmitter
} from 'react-native';

const AliyunOSS = NativeModules.AliyunOSSModule;

export let initWithAppKey =function(endpoint,accessKeyId,accessKeySecret) {
    AliyunOSS.initWithAppKey(endpoint,accessKeyId,accessKeySecret)
}
export let upload= async function(bucketName, objectKey, uploadFilePath) {
    await AliyunOSS.upload(bucketName, objectKey, uploadFilePath)
}
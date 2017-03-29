## Installation
Installation can be done through ``npm``:

```shell
npm i react-native-imagesplit --save
```

## Usage
用于获取app的唯一标示

```js
import { NativeModules } from 'react-native';
```

```jsx
const imagePathArray = ['','',''];
//纵向拼接图片
NativeModules.RNImageSplit.spliceImageVertical(imagePathArray, (imagePath) => {
  // service code
});
//横向拼接图片
NativeModules.RNImageSplit.spliceImageHorizontal(imagePathArray, (imagePath) => {
  // service code
});
```

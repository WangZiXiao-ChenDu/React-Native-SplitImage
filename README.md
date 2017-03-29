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
const imageArray = ['','',''];
//纵向拼接图片
NativeModules.RNImageSplit.spliceImageVertical(imageArray, (imagePath) => {
  // service code
});
//横向拼接图片
NativeModules.RNImageSplit.spliceImageHorizontal(imageArray, (imagePath) => {
  // service code
});
```

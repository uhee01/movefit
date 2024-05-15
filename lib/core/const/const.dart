const nativeChannel = 'com.example.movefit_app';
const workHistoryBox = 'workHistoryBox';
const workGoalBox = 'workGoalBox';

const pointModel = '/assets/model/PointNet75.tflite';

const List<String> inferenceLabels = [
  'bench_pressing',
  'deadlifting',
  'pull_ups',
  'push_up',
  'situp',
  'squat'
];

const viewLabel = ['벤치프레스', '데드리프트', '풀업', '푸시업', '싯업', '스쿼트'];

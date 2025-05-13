// web/waveform.js

// 오디오 파형 추출 함수 - Flutter에서 JS interop으로 호출
window.generateWaveformFromUrl = async function (url) {
    const response = await fetch(url);
    const arrayBuffer = await response.arrayBuffer();
  
    const audioContext = new (window.AudioContext || window.webkitAudioContext)();
    const audioBuffer = await audioContext.decodeAudioData(arrayBuffer);
  
    const channelData = audioBuffer.getChannelData(0); // 첫 번째 채널 사용
    const samples = 512;
    const blockSize = Math.floor(channelData.length / samples);
    const waveform = [];
  
    for (let i = 0; i < samples; i++) {
      let sum = 0;
      const start = i * blockSize;
      const end = Math.min(start + blockSize, channelData.length);
  
      for (let j = start; j < end; j++) {
        sum += Math.abs(channelData[j]);
      }
  
      const avg = sum / (end - start);
      waveform.push(Math.min(avg, 1.0)); // 정규화
    }
  
    return waveform;
  };
  
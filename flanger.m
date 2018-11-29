% program: flanger.m
% author: Rahul Sharma
% course: CS 827
% date: 2018/11/13
% assignment #3
% description: This program creates the flanging audio effect in MATLAB. It creates a single delay
% with the delay time ocilating from either 0-3 ms or 0-15 ms at 0.1 - 5 Hz. Input for this 
% program is a PCM formatted file generated using audacity export function and saving file in 
% uncompressed, header less, 16bits PCM. Output of this program is a Flanged wave file (out_flanger.wav)
% along withseveral graphs displaying original wave form, flanged wave form, Fourier tranformation of  
% original and flanged signal. Output also consists of the audio wav 'original.wav' generated from  
% raw PCM file and finally generated the 'out_flanger.raw' as a raw file of generated flanged wave.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------  READS A PCM FORMATTED FILE  -----------------------------------------
fs=44100;endianness='l';
infile_raw = 'input.raw';
fid_R = fopen(infile_raw,'r',endianness);
data = fread(fid_R,'int32'); % Raw data of input audio file.
fclose(fid_R);
data=int32(data);
infile = 'original.wav';
audiowrite(infile,data,fs,'BitsPerSample',32); % outputfile is normalized in amplitude


%-------------------------------  IMPLEMENT FLANGING EFFECT  -------------------------------------------
[x, Fs] = audioread(infile);% read the sample waveform
% Define parameters to vary the effect
max_time_delay = 0.015; % max delay in seconds
sweep_freq = 0.5; %sweep_freq of flange in Hz
index = 1:length(x);
amp = 0.7; % suggested coefficient
sin_ref = (sin(2 * pi * index * (sweep_freq / Fs)))';% sin reference to create oscillating delay
max_samp_delay = round(max_time_delay * Fs); %convert delay in ms to max delay in samples
y = zeros(length(x), 1); % create empty out vector
y(1:max_samp_delay) = x(1:max_samp_delay); % to avoid referencing of negative samples

% for each sample
for i = (max_samp_delay + 1):length(x)
    cur_sin = abs(sin_ref(i)); %abs of current sin val 0-1
    cur_delay = ceil(cur_sin * max_samp_delay); % generate delay from 1-max_samp_delay, ensure whole no.
    y(i) = (amp * x(i)) + amp * (x(i - cur_delay)); % add delayed sample
end

%-------------------------------  PLOTTING GRAPHS  ----------------------------------------------------
figure(1)
plot(x, 'm');
xlabel('Time');
ylabel('Amplitude');
title('Original Signal');

figure(2)
plot(y, 'b');
xlabel('Time');
ylabel('Amplitude');
title('Flanged Signal');

figure(3) % Ploting both Flanged and Original Signal together
hold on 
plot(x, 'm');
plot(y, 'b');
xlabel('Time');
ylabel('Amplitude');
title('Flanged and Original Signal');
legend('Original Signal','Flanged Signal');

figure(4)
hold on
f1 = (0:length(x)-1)*50/length(x); %create the vector f1 that corresponds to the signal's sampling 
%in frequency space.
f2 = (0:length(y)-1)*50/length(y);
plot(f1, abs(fft(x)),'m');%Compute the Fourier transform of the signal
plot(f2, abs(fft(y)),'b');
xlabel('Frequency');
ylabel('Amplitude');
title('Magnitude');
legend('Original Signal','Flanged Signal');

%-------------------------------  GENERATED OUTPUT  ------------------------------------------------

audiowrite('out_flanger.wav', y, Fs); % outputfile is normalized in amplitude (generated flanged wave)   
dlmwrite('out_flanger.raw',y); %Writes the resulting wave file data to a new raw file
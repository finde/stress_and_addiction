# stress_and_addiction

## Preparation

- `git clone git@github.com:finde/stress_and_addiction.git` 
- Open Matlab, go to `stress_and_addiction`
- Add to current path


## Usage

### Plot ECG of single participant

Syntax:
```
sad_main(<Participant_ID>,<Range>)
sad_main(<Participant_ID>,<Start:Interval:End>)
```

To open and plot ecg for Participant `sub-010003` every __500ms__.
```
sad_main('sub-010003', '1:500:end')
```

To open and plot ecg for Participant `sub-010003` every __1ms__ until for the __first 1 minute__.
```
sad_main('sub-010003', '1:1:60000') 
```
or 
```
sad_main('sub-010003', 60000)
```

## ToDo

- [ ] Add HRV analysis toolbox
- [ ] Read and compare ECG of different participants
- [ ] Read and compare ECG of different state
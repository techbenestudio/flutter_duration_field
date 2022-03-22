A Flutter widget for easy Duration input

## Features
This widget renders multiple input fields for duration input.
* Automatically jumps to next field when filled
* Automatically jumps to previous field on backspace
* No error states, because:
  * limits all fields but the first to 59 seconds
  * fills empty fields with 0
* Hours-Minutes-Seconds and Minutes-Seconds mode

## Getting started

Install it
```
flutter pub add duration_field
```
Import it
```
import 'package:duration_field/duration_field.dart';
```

Enjoy

## Usage
```
const DurationField(
  label: 'Duration field',
  initialDuration: Duration(minutes: 5),
),
```

## Screenshot
![wireframe](https://github.com/techbenestudio/flutter_duration_field/blob/main/screenshot.png?raw=true)
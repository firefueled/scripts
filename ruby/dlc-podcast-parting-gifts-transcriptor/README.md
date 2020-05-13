# DLC podcast parting gifts transcriber

## Setup

This is built with Ruby so get that running before anything else.

You need `wget`, `curl` and `ffmpeg` to be available as command line tools.

The transcription is done by the [Speech-to-text IBM Cloud service](https://cloud.ibm.com/catalog/services/speech-to-text).
Create an  account and get an API key.

Create a `secrets.yml` file following the example `secrets_example.yml` and put your
API key there.

The service is free to use but there's a limit: 500 minutes of audio per month,
last time I checked.

Create additional accounts or cheese it in some other way if you must.

## Usage

`./transcribe.rb <episode_number>`

Every file created will be put in a `output` directory.
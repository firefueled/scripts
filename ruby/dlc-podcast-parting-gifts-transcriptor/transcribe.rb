require 'json'
require 'yaml'

SECRETS = YAML.load(File.read('secrets.yml'))
ENDPOINT = 'https://stream.watsonplatform.net/speech-to-text/api/v1/recognize'

def download_episode url
  uri = URI(url)
  file_name = File.basename(uri.path)

  # delete any file first to make sure we get the proper name
  `rm #{file_name}`

  # download the thing
  `wget #{url}`

  File.new(file_name)
end

def cut_section file
  file_sufix = File.basename(file).split('.')[0]
  new_filename = file_sufix << '-partinggifts' << File.extname(file)

  `ffmpeg -sseof -10:00 -i #{file.path} -codec copy #{new_filename}`
end

def transcribe_section file
  text_file_name = File.basename(file) << '.txt'
  api_key = SECRETS['watson_api_key']

  `curl -X POST -u "apikey:#{api_key}" --header "Content-Type: audio/mp3" --data-binary @#{file.path} "#{ENDPOINT}" -o #{text_file_name}`
end

def extract_text

end

def differentiate_guests

end

def output_text

end

url = 'http://director.5by5.tv/d/dlc/cdn.5by5.tv/audio/broadcasts/dlc/2019/dlc-286.mp3'

episode_file = download_episode url
pg_section_file = cut_section episode_file
transcription_result = transcribe_section pg_section_file
raw_text = extract_text transcription_result
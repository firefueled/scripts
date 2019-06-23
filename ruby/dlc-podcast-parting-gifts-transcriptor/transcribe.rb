require 'json'
require 'yaml'

SECRETS = YAML.load(File.read('secrets.yml'))
ENDPOINT = 'https://stream.watsonplatform.net/speech-to-text/api/v1/recognize'
current_file_name = ''

def download_episode url
  uri = URI(url)
  current_file_name = File.basename(uri.path)

  # delete any file first to make sure we get the proper name
  `rm #{current_file_name}`

  # download the thing
  `wget #{url}`

  File.new(current_file_name)
end

def cut_section file
  current_file_name.insert(-5, '-partinggifts')

  `ffmpeg -sseof -10:00 -i #{file.path} -codec copy #{new_filename}`
end

def transcribe_section file
  text_file_name = File.basename(file) << '.txt'
  api_key = SECRETS['watson_api_key']

  `curl -X POST -u "apikey:#{api_key}" --data-binary @#{file.path} "#{ENDPOINT}" -o #{text_file_name}`
end

def extract_text transcription_file
  result = JSON.parse(File.read(transcription))

  paragraphs = result['results'].map do |res|
    res['alternatives'][0]['transcript']
  end
end

def differentiate_guests

end

def output_text paragraphs
  current_file_name.insert(-5, '-transcription')
  current_file_name.sub('mp3', 'txt')

  IO.write(current_file_name, paragraphs.join("\n"))
end

url = 'http://director.5by5.tv/d/dlc/cdn.5by5.tv/audio/broadcasts/dlc/2019/dlc-286.mp3'

episode_file = download_episode url
pg_section_file = cut_section episode_file
transcription_result = transcribe_section pg_section_file
paragraphs = extract_text transcription_result
output_text paragraphs
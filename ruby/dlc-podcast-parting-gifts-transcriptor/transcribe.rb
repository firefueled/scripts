#!/usr/bin/env ruby
require 'json'
require 'yaml'

SECRETS = YAML.load(File.read('secrets.yml'))
base_podcast_url = 'http://director.5by5.tv/d/dlc/cdn.5by5.tv/audio/broadcasts/dlc/2019/'
ENDPOINT = 'https://stream.watsonplatform.net/speech-to-text/api/v1/recognize'
@current_file_name = ''

def download_episode uri
  @current_file_name = File.basename(uri.path)

  # # delete any file first to make sure we get the proper name
  # `rm -f #{@current_file_name}`

  # # download the thing
  # `wget -q #{uri.to_s}`
  File.new(@current_file_name)
end

def cut_section file
  @current_file_name.insert(-5, '-partinggifts')

  # `ffmpeg -loglevel quiet -sseof -10:00 -i #{file.path} -codec copy -y #{@current_file_name}`
  File.new(@current_file_name)
end

def transcribe_section file
  text_file_name = File.basename(file) << '.txt'
  api_key = SECRETS['watson_api_key']

  `curl -X POST -s -u "apikey:#{api_key}" --header "Content-Type: audio/mp3" --data-binary @#{file.path} "#{ENDPOINT}" -o #{text_file_name}`
  File.new(text_file_name)
end

def extract_text transcription_file
  result = JSON.parse(File.read(transcription_file))

  paragraphs = result['results'].map do |res|
    res['alternatives'][0]['transcript']
  end
end

def differentiate_guests

end

def output_text paragraphs
  @current_file_name.insert(-5, '-transcription')
  @current_file_name.sub!('mp3', 'txt')

  IO.write(@current_file_name, paragraphs.join("\n\n"))
end

ep_number = ARGV[0]
if ep_number.nil?
  puts 'No episode number. Exiting...'
  exit
end

puts "Should episode #{ep_number} be transcribed? [yN]"
confirmation = STDIN.gets.chomp

if confirmation != 'y' and confirmation != 'Y'
  puts 'No confirmation. Exiting...'
  exit
end

episode_file = download_episode URI.join(base_podcast_url, 'dlc-' << ep_number << '.mp3')
pg_section_file = cut_section episode_file
transcription_result = transcribe_section pg_section_file
paragraphs = extract_text transcription_result
output_text paragraphs
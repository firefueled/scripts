require 'json'

def download_episode url
  uri = URI(url)
  file_name = File.basename(uri.path)

  # delete any file first to make sure we get the proper name
  `rm #{file_name}`

  # download the thing
  `wget #{url}`

  File.new(file_name)
end

def cut_section
end

def transcribe_section

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
require 'json'

def download_episode

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

episode_file = download_episode
pg_section_file = cut_section episode_file
transcription_result = transcribe_section pg_section_file
raw_text = extract_text transcription_result
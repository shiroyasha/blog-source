puts "Building...\n\n"

system "bundle exec middleman build"

$ignored_words = File.read("spec/ignored_words.txt").split("\n")
$ignored_files = File.read("spec/ignored_files.txt").split("\n")
$files         = Dir.glob("build/**/*.html")

def find_errors(file)
  html_options = "--mode=html --add-html-skip=code --add-html-skip=pre"
  result       = `aspell #{html_options} list < #{file} | sort`

  result.split("\n").reject { |word| $ignored_words.include?(word) }
end

def show_errors(errors)
  puts errors.map { |word| "    #{word}" }.join("\n")
  puts
end

puts "\n\nTesting...\n\n"

exit_status = true

$files.each do |file|
  next if $ignored_files.include?(file)

  errors = find_errors(file)
  sign = errors.empty? ? "\e[32m\u2713\e[0m" : "\e[31m\u2718\e[0m"

  puts "#{sign} #{file}"
  show_errors(errors) unless errors.empty?

  exit_status = false if errors.length > 0
end

if exit_status == false
  puts "\n\nPlease fix these spelling errors."
  exit(exit_status)
else
  puts "\n\nYou have no spelling errors. Hooray!"
end

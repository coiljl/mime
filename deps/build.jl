if !isfile("mime-db.json")
  download("https://raw.githubusercontent.com/jshttp/mime-db/9ab92f0a912a602408a64db5741dfef6f82c597f/db.json", "mime-db.json")
end

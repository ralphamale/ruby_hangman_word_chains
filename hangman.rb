class Hangman
  MAX_TRIES = 10

  def initialize(guesser, referee)
    @guesser, @referee = guesser, referee
  end

  def play
    secret_length = @referee.pick_secret_word
    @guesser.register_secret_length(secret_length)
    @current_board = [nil] * secret_length

    MAX_TRIES.times do
      take_turn

      if won?
        p @current_board
        puts "Guesser wins!"
        return
      end
    end

    puts "Word was: #{@referee.require_secret}"
    puts "Guesser loses!"

    nil
  end

  private
  def take_turn
    guess = @guesser.guess(@current_board)
    response = @referee.check_guess(guess)
    update_board(guess, response)

    @guesser.handle_response(guess, response)
  end

  def update_board(guess, indices)
    indices.each { |index| @current_board[index] = guess }
  end

  def won?
    @current_board.all?
  end
end

class HumanPlayer
  def register_secret_length(length)
    puts "Secret is #{length} letters long"
  end

  def guess(board)
    p board
    puts "Input guess:"
    gets.chomp
  end

  def handle_response(guess, response)
    puts "Found #{guess} at positions #{response}"
  end

  def pick_secret_word
    puts "Think of a secret word; how long is it?"

    begin
      Integer(gets.chomp)
    rescue ArgumentError
      puts "Enter a valid length!"
      retry
    end
  end

  def check_guess(guess)
    puts "Player guessed #{guess}"
    puts "What positions does that occur at?"

    positions = gets.chomp.split(",").map { |i_str| Integer(i_str) }
  end

  def require_secret
    puts "What word were you thinking of?"
    gets.chomp
  end
end

class ComputerPlayer
  def self.player_with_dict_file(dict_file_name)
    ComputerPlayer.new(File.readlines(dict_file_name).map(&:chomp))
  end

  def initialize(dictionary)
    @dictionary = dictionary
  end

  def pick_secret_word
    @secret_word = @dictionary.sample

    @secret_word.length
  end

  def check_guess(guess)
    response = []

    @secret_word.split("").each_with_index do |letter, index|
      response << index if letter == guess
    end

    response
  end

  def register_secret_length(length)
    @candidate_words = @dictionary.dup

    @candidate_words.select! { |word| word.length == length }
  end

  def guess(board)
    p @candidate_words

    freq_table = freq_table(board)

    most_frequent_letters = freq_table.sort_by { |letter, count| count }
    letter, count = most_frequent_letters.last

    letter
  end

  def handle_response(guess, response_indices)
    @candidate_words.reject! do |word|
      should_delete = false

      word.split("").each_with_index do |letter, index|
        if (letter == guess) && (!response_indices.include?(index))
          should_delete = true
          break
        elsif (letter != guess) && (response_indices.include?(index))
          should_delete = true
          break
        end
      end

      should_delete
    end
  end

  def require_secret
    @secret_word
  end

  private
  def freq_table(board)
    freq_table = Hash.new(0)
    @candidate_words.each do |word|
      board.each_with_index do |letter, index|
        freq_table[word[index]] += 1 if letter.nil?
      end
    end

    freq_table
  end
end

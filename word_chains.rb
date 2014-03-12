require 'set'

module WordChainer
  extend self

  def run(source, target, dictionary_file_name)
    dictionary = File.readlines(dictionary_file_name).map(&:chomp)
    dictionary = Set.new(dictionary)
    parents = find_chain(source, target, dictionary)

    parents && build_path_from_breadcrumbs(parents, source, target, dictionary)
  end

  def build_path_from_breadcrumbs(parents, source, target, dictionary)
    chain_word = target
    path = []

    while chain_word
      path << chain_word
      chain_word = parents[chain_word]
    end

    path.reverse
  end

  def find_chain(source, target, dictionary)
    return nil unless source.length == target.length

    candidate_words = dictionary.select { |word| word.length == source.length }

    candidate_words = Set.new(candidate_words)
    candidate_words.delete(source)
    words_to_expand = [source]
    parents = {source => nil}

    until words_to_expand.empty?
      word_to_expand = words_to_expand.shift

      adjacent_words(word_to_expand, candidate_words).each do |adjacent_word|
        candidate_words.delete(adjacent_word)
        words_to_expand << adjacent_word
        parents[adjacent_word] = word_to_expand

        return parents if adjacent_word == target
      end
    end

    nil
  end

  def adjacent_words(word, dictionary)
    adjacent_words = []

    word.each_char.with_index do |old_letter, i|
      ('a'..'z').each do |new_letter|
        next if old_letter == new_letter

        new_word = word.dup
        new_word[i] = new_letter

        adjacent_words << new_word if dictionary.include?(new_word)
      end
    end

    adjacent_words
  end
end

if __FILE__ == $PROGRAM_NAME
  p WordChainer.run("duck", "ruby", "/dictionary.txt")
end
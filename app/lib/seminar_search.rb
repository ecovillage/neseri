class SeminarSearch
  attr_accessor :search_term
  def initialize search_term
    @search_term = search_term
  end

  def apply relation
    return relation if @search_term.blank?

    seminars = search_model.arel_table
    term_matcher = "%#{@search_term}%"
    relation.where(seminars[:title].matches(term_matcher).or(
      seminars[:subtitle].matches(term_matcher).or(
      seminars[:description].matches(term_matcher)
    )))
  end

  def search_model
    Seminar
  end
end

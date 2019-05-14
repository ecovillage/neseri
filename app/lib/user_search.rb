class UserSearch
  attr_accessor :search_term
  def initialize search_term
    @search_term = search_term
  end

  def apply relation
    return relation if @search_term.blank?

    users = User.arel_table
    term_matcher = "%#{@search_term}%"
    relation.where(users[:email].matches(term_matcher).or(
      users[:firstname].matches(term_matcher).or(
      users[:lastname].matches(term_matcher)
    )))
  end
end
